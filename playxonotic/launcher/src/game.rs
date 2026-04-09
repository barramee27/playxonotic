use directories::ProjectDirs;
use std::fs;
use std::path::PathBuf;

const XONOTIC_URL: &str = "https://dl.xonotic.org/xonotic-0.8.6.zip";

/// Bundled game location when installed via .deb
const BUNDLED_GAME_DIR: &str = "/usr/share/playxonotic";

fn bundled_game_dir() -> PathBuf {
    PathBuf::from(BUNDLED_GAME_DIR)
}

pub fn game_dir() -> Option<PathBuf> {
    // Prefer bundled game (installed via .deb)
    if bundled_game_dir().join("Xonotic").join("xonotic-linux-sdl.sh").exists()
        || bundled_game_dir().join("Xonotic").join("xonotic-linux-glx.sh").exists()
    {
        return Some(bundled_game_dir());
    }
    // Fall back to user data dir (download on first run)
    ProjectDirs::from("com", "playxonotic", "Launcher")
        .map(|d| d.data_local_dir().join("game"))
}

pub fn is_game_installed() -> bool {
    if let Some(dir) = game_dir() {
        let sdl = dir.join("Xonotic").join("xonotic-linux-sdl.sh");
        let glx = dir.join("Xonotic").join("xonotic-linux-glx.sh");
        let alt_sdl = dir.join("xonotic-linux-sdl.sh");
        sdl.exists() || glx.exists() || alt_sdl.exists()
    } else {
        false
    }
}

fn ensure_game_dir() -> Result<PathBuf, String> {
    let dir = game_dir().ok_or("Could not determine data directory")?;
    fs::create_dir_all(&dir).map_err(|e| e.to_string())?;
    Ok(dir)
}

pub fn download_and_extract(progress: impl Fn(&str)) -> Result<(), String> {
    let dir = ensure_game_dir()?;
    let zip_path = dir.join("xonotic.zip");

    progress("Downloading Xonotic (1.2 GB, one-time)...");
    // Use wget or curl - more reliable for large files
    let wget = std::process::Command::new("wget")
        .args(["-q", "--show-progress", "-O", zip_path.to_str().unwrap(), XONOTIC_URL])
        .current_dir(&dir)
        .spawn();

    if let Ok(mut child) = wget {
        let status = child.wait().map_err(|e| e.to_string())?;
        if !status.success() {
            return Err("Download failed. Check your internet connection.".to_string());
        }
    } else {
        // Fallback: curl
        let mut curl = std::process::Command::new("curl")
            .args(["-L", "-o", zip_path.to_str().unwrap(), XONOTIC_URL])
            .current_dir(&dir)
            .spawn()
            .map_err(|_| "Need wget or curl to download the game.".to_string())?;
        let status = curl.wait().map_err(|e| e.to_string())?;
        if !status.success() {
            return Err("Download failed. Check your internet connection.".to_string());
        }
    }

    progress("Extracting...");
    let file = fs::File::open(&zip_path).map_err(|e| e.to_string())?;
    let mut archive = zip::ZipArchive::new(file).map_err(|e| e.to_string())?;

    for i in 0..archive.len() {
        let mut entry = archive.by_index(i).map_err(|e| e.to_string())?;
        let name = entry.name();
        // Prevent zip slip (path traversal)
        if name.contains("..") || name.starts_with('/') {
            continue;
        }
        let outpath = dir.join(name);
        if name.ends_with('/') {
            fs::create_dir_all(&outpath).ok();
        } else {
            if let Some(p) = outpath.parent() {
                fs::create_dir_all(p).ok();
            }
            let mut outfile = fs::File::create(&outpath).map_err(|e| e.to_string())?;
            std::io::copy(&mut entry, &mut outfile).map_err(|e| e.to_string())?;
            #[cfg(unix)]
            {
                use std::os::unix::fs::PermissionsExt;
                if entry.unix_mode().unwrap_or(0) & 0o111 != 0 {
                    let mut perms = fs::metadata(&outpath).map_err(|e| e.to_string())?.permissions();
                    perms.set_mode(0o755);
                    fs::set_permissions(&outpath, perms).ok();
                }
            }
        }
    }

    fs::remove_file(&zip_path).ok();
    progress("Ready.");
    Ok(())
}

pub fn find_xonotic_binary() -> Option<(PathBuf, PathBuf)> {
    let dir = game_dir()?;
    let candidates = [
        dir.join("Xonotic").join("xonotic-linux-sdl.sh"),
        dir.join("Xonotic").join("xonotic-linux-glx.sh"),
        dir.join("xonotic-linux-sdl.sh"),
        dir.join("xonotic-linux-glx.sh"),
    ];
    for p in &candidates {
        if p.exists() {
            let work_dir = p.parent().unwrap_or(&dir).to_path_buf();
            return Some((p.clone(), work_dir));
        }
    }
    None
}

pub fn launch(username: &str) -> Result<(), String> {
    // Only download if not bundled and not in user dir
    if !is_game_installed() {
        download_and_extract(|_| {})?;
    }
    let (bin, work_dir) = find_xonotic_binary()
        .ok_or("Game not installed. Run the launcher to download.")?;

    // Run script directly (not via sh) so it properly passes args to the engine.
    // Removed +connect to start in main menu (offline friendly)
    // Set SDL_VIDEODRIVER to wayland,x11 to support both natively
    let status = std::process::Command::new(&bin)
        .args([
            "+name", username,
            "+g_weapondamagefactor", "0.7",
            "+g_balance_health_regen", "0.15",
            "+g_balance_pause_health_regen", "2",
            "+g_ctf_flagcarrier_damagefactor", "2",
            "+g_ctf_flagcarrier_forcefactor", "2",
            "+alias", "connect_myserver", "connect 72.61.151.199:26000"
        ])
        .env("SDL_VIDEODRIVER", "wayland,x11")
        .env("GDK_BACKEND", "wayland,x11")
        .current_dir(&work_dir)
        .spawn()
        .map_err(|e| format!("Failed to launch: {}", e))?;

    // Don't wait - let it run
    drop(status);
    Ok(())
}

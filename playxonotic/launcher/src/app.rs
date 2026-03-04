use crate::auth::{AuthResponse, User};
use crate::game;
use directories::ProjectDirs;
use std::fs;
use std::path::PathBuf;

#[derive(Clone)]
pub struct App {
    pub token: Option<String>,
    pub user: Option<User>,
}

impl App {
    pub fn new() -> Self {
        let (token, user) = Self::load_stored();
        Self { token, user }
    }

    fn config_dir() -> Option<PathBuf> {
        ProjectDirs::from("com", "playxonotic", "Launcher")
            .map(|d| d.config_dir().to_path_buf())
    }

    fn load_stored() -> (Option<String>, Option<User>) {
        let dir = match Self::config_dir() {
            Some(d) => d,
            None => return (None, None),
        };
        let token_path = dir.join("token");
        let user_path = dir.join("user.json");
        let token = fs::read_to_string(&token_path).ok().filter(|s| !s.is_empty());
        let user: Option<User> = fs::read_to_string(&user_path)
            .ok()
            .and_then(|s| serde_json::from_str(&s).ok());
        (token, user)
    }

    pub fn save_auth(&mut self, auth: AuthResponse) {
        self.token = Some(auth.token.clone());
        self.user = Some(auth.user.clone());
        if let Some(dir) = Self::config_dir() {
            let _ = fs::create_dir_all(&dir);
            let _ = fs::write(dir.join("token"), &auth.token);
            let _ = fs::write(
                dir.join("user.json"),
                serde_json::to_string(&auth.user).unwrap_or_default(),
            );
        }
    }

    pub fn clear_auth(&mut self) {
        self.token = None;
        self.user = None;
        if let Some(dir) = Self::config_dir() {
            let _ = fs::remove_file(dir.join("token"));
            let _ = fs::remove_file(dir.join("user.json"));
        }
    }

    pub fn launch_xonotic(&self) -> Result<(), String> {
        let username = self
            .user
            .as_ref()
            .map(|u| u.username.as_str())
            .unwrap_or("Player");
        game::launch(username)
    }
}

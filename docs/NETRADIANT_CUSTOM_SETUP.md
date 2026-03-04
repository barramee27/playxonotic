# NetRadiant Custom Setup for Xonotic

## 1. Engine Path (Path Settings)

The dialog asks for the directory where the game executable sits (e.g. `xonotic-linux-sdl.sh`).

**Use one of these paths depending on your Xonotic installation:**

| Installation | Engine Path |
|--------------|-------------|
| **PlayXonotic .deb** (your build) | `/usr/share/playxonotic/Xonotic/` |
| System Xonotic (apt/repo) | `/usr/share/games/xonotic/` |
| Manual / extracted zip | Path to the folder containing `xonotic-linux-sdl.sh` |

**For PlayXonotic** (your custom build with `zz_playxonotic_mod.pk3`), use:
```
/usr/share/playxonotic/Xonotic/
```

This path exists after you install the .deb from `playxonotic/launcher/build-deb.sh`. Use it so NetRadiant loads textures and assets from your game data, and you can test maps with your modded build.

---

## 2. Xonotic Gamepack (NetRadiant Custom)

NetRadiant Custom's **latest prebuilt releases** (from [Garux's GitHub](https://github.com/Garux/netradiant-custom/releases)) already include the updated Xonotic gamepack. You typically **don't need** to install it manually.

If you have an older build or Xonotic doesn't appear in the game list:

1. Download the Xonotic gamepack for **NetRadiant-custom** from:
   - [Xonotic forums thread](https://forums.xonotic.org/showthread.php?tid=9727)
   - Direct link: [Google Drive](https://drive.google.com/file/d/1OXwWOwp5at7HHSFPzY66QM2VBxjgRqD1/view?usp=sharing)
   - Use the **NetRadiant-custom** version (not the upstream NetRadiant one)

2. Unzip and place files:
   - `games/xonotic.game` → `[NetRadiant_install]/gamepacks/games/`
   - `xonotic.game/` folder (and contents) → `[NetRadiant_install]/gamepacks/`

   Example if NetRadiant is in `~/netradiant-custom/`:
   ```
   ~/netradiant-custom/gamepacks/games/xonotic.game
   ~/netradiant-custom/gamepacks/xonotic.game/  (entire folder)
   ```

---

## 3. Linux Dependencies

Install GTK2 and OpenGL support:

```bash
# Pop!_OS / Ubuntu / Debian
sudo apt install libgtkglext1

# Fedora
sudo dnf install gtkglext-libs

# Arch
sudo pacman -S gtkglext
```

---

## 4. Quick Checklist

- [ ] Engine path set to Xonotic directory (with `xonotic-linux-sdl.sh`)
- [ ] Xonotic gamepack present (or using latest NRC prebuild)
- [ ] `libgtkglext1` (or equivalent) installed
- [ ] Start NetRadiant Custom → choose **Xonotic** as game

---

## 5. Fix "SHADER NOT FOUND"

If you see checkerboard "SHADER NOT FOUND" textures, install the **mapping support package** (uncompressed textures NetRadiant can read):

```bash
cd /tmp
wget https://beta.xonotic.org/autobuild/Xonotic-latest-mappingsupport.zip
sudo unzip -j Xonotic-latest-mappingsupport.zip "Xonotic/data/*" -d /usr/share/playxonotic/Xonotic/data/
```

**If you already extracted** and got a nested `Xonotic/Xonotic/` folder, move the mapping pk3 to the correct place:

```bash
sudo mv /usr/share/playxonotic/Xonotic/Xonotic/data/xonotic-*-maps-mapping.pk3 /usr/share/playxonotic/Xonotic/data/
```

Then in NetRadiant: **Texture Browser → Tools → Flush & Reload Shaders**. Restart NetRadiant.

---

## 6. Testing

1. Create a simple brush (Block tool).
2. Add a `info_player_start` entity.
3. Build → Compile (or use the build menu).
4. Run map from the editor to test in-game.

---

## Path Reference

**PlayXonotic** (your .deb build) installs to:
```
/usr/share/playxonotic/Xonotic/
├── xonotic-linux-sdl.sh   ← executable
├── data/
│   └── zz_playxonotic_mod.pk3  ← your custom mod
├── bin64/
└── ...
```

Use **`/usr/share/playxonotic/Xonotic/`** as the engine path for your PlayXonotic setup.

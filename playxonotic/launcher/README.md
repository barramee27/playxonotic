# PlayXonotic Native Launcher

Native Linux launcher (Rust + GTK4) for PlayXonotic. Login with your account, then launches the **real Xonotic** game (Flatpak or system install).

## Requirements

- **Build**: Rust, GTK4 dev libraries
  ```bash
  sudo apt install cargo rustc libgtk-4-dev pkg-config
  ```
- **Run**: Flatpak + Xonotic
  ```bash
  flatpak install flathub org.xonotic.Xonotic
  ```

## Build .deb

```bash
cd playxonotic/launcher
./build-deb.sh
```

Produces `playxonotic-launcher_1.0.0_amd64.deb`.

## Install

```bash
sudo dpkg -i playxonotic-launcher_1.0.0_amd64.deb
```

## Flow

1. Open launcher → GTK login window (Sign In / Create Account)
2. Login → stores token in `~/.config/playxonotic/Launcher/`
3. Click Play → launches `flatpak run org.xonotic.Xonotic +name <username> +connect playxonotic.com:26000`
4. Next time: if token valid, launches game directly (no login window)

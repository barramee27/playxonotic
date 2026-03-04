# Antigravity

A tactical first-person/third-person shooter built on the DarkPlaces engine.  
Think: fast movement, team-based play, economy system, round-based modes.

[![License: GPL v2](https://img.shields.io/badge/License-GPL_v2-blue.svg)](LICENSE)

---

## Game Modes

| Mode | Description |
|------|-------------|
| **TDM** | Team Deathmatch — first team to frag limit wins |
| **Bomb** | Plant / defuse bomb at site A or B (CS-style) |
| **Domination** | *(coming soon)* Capture and hold control points |
| **Elimination** | *(coming soon)* Round-based, one life per round |

---

## Weapons

| Weapon | Price | Notes |
|--------|-------|-------|
| Knife | Free | One-shot from behind |
| Pistol | $200 | Starting weapon |
| SMG | $1,200 | Full auto, short range |
| Shotgun | $1,300 | 8 pellets, devastating up close |
| Rifle | $2,700 | Full auto, all-purpose |
| Sniper | $4,500 | One-shot headshot |
| Machine Gun | $5,200 | 100-round mag |
| Grenade | $300 | Cook before throwing |
| Flashbang | $200 | Blinds enemies |

---

## Project Structure

```
antigravity-game/
├── qcsrc/
│   ├── common/
│   │   ├── constants.qh        # all game constants
│   │   ├── physics.qh          # movement constants
│   │   └── weapons/
│   │       ├── weapons.qh      # weapon struct definitions
│   │       └── weapon_defs.qc  # all 9 weapons with full stats
│   ├── server/
│   │   ├── main.qc             # server entry point
│   │   ├── player.qc           # spawn, death, regen, sprint, crouch
│   │   ├── weapons_fire.qc     # shooting, recoil, reload, grenades
│   │   └── gamemodes/
│   │       ├── tdm.qc          # Team Deathmatch
│   │       └── bomb.qc         # Bomb Defuse (CS-style)
│   ├── client/
│   │   ├── main.qc             # client entry point
│   │   └── hud.qc              # HUD: health, ammo, timer, killfeed
│   ├── menu/
│   │   └── menu.qc             # in-game buy menu
│   └── Makefile
├── scripts/
│   ├── default.cfg             # all cvars + keybinds
│   └── mapinfo_template.mapinfo
├── maps/                       # .map source files
├── models/                     # .iqm models
├── sounds/                     # .ogg sounds
├── textures/                   # texture files
├── LICENSE
└── README.md
```

---

## Engine

Built on **DarkPlaces** (GPLv2) — the same engine that powers Xonotic.

The game logic (everything in `qcsrc/`) is written from scratch in **QuakeC**.  
No Xonotic game code was used or copied.

- DarkPlaces: https://github.com/DarkPlacesEngine/darkplaces
- QuakeC compiler (gmqcc): https://graphitemaster.github.io/gmqcc/

---

## Building

### Requirements
- `gmqcc` — QuakeC compiler
- DarkPlaces engine binary

```bash
# Install gmqcc (Ubuntu/Debian)
sudo apt install gmqcc

# Or build from source
git clone https://github.com/graphitemaster/gmqcc && cd gmqcc && make

# Compile game logic
cd antigravity-game/qcsrc
make all

# Run
darkplaces -game antigravity-game +map ag_dust
```

---

## Contributing

1. Fork the repo
2. Create a branch: `git checkout -b feature/my-feature`
3. Commit: `git commit -m "Add my feature"`
4. Push: `git push origin feature/my-feature`
5. Open a Pull Request

---

## License

[GNU General Public License v2](LICENSE) — same as DarkPlaces engine.

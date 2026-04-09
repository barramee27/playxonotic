# Xonotic in the browser (WebAssembly)

This repository is intentionally **narrow**: it holds the **Xonotic tree and DarkPlaces engine work needed to build and run a WebAssembly (Emscripten) client**—plus a small root license file. Everything else you may keep alongside this folder on your machine (other games, launchers, AssaultCube experiments, and so on) is **listed in [.gitignore](.gitignore)** so it stays local and is **not** pushed to GitHub.

Upstream Xonotic lives primarily on [GitLab](https://gitlab.com/xonotic/xonotic). This GitHub repo is a focused fork for the **WASM / web port** effort.

## Repository layout

| Path | Purpose |
|------|--------|
| [`xonotic-web-port/`](xonotic-web-port/) | Xonotic sources, data, scripts, and **`build-wasm.sh`** for the Emscripten build |
| [`xonotic-web-port/source/darkplaces`](xonotic-web-port/source/darkplaces) | **Git submodule** — DarkPlaces engine ([xonotic/darkplaces](https://github.com/xonotic/darkplaces)) |
| [`xonotic-web-port/source/d0_blind_id`](xonotic-web-port/source/d0_blind_id) | **Git submodule** — crypto helper lib used by the stack |
| [`LICENSE`](LICENSE) | GPLv2 notice for this packaging (engine and game data carry their own licenses under `xonotic-web-port/`) |

After cloning, initialize submodules:

```bash
git submodule update --init --recursive
```

## Requirements

- [Emscripten](https://emscripten.org/) (`emcc`, `em++`, `emmake`, …) installed and available in your shell  
- Standard Unix build tools (`make`, etc.) as expected by the DarkPlaces makefile  

## Build (WebAssembly)

From the **repository root**:

```bash
cd xonotic-web-port
./build-wasm.sh
```

The script sets `DP_MAKE_TARGET=wasm`, points the makefile at Emscripten, and runs `emmake make emscripten-standalone` with crypto/ODE features trimmed for the browser. Build products under `xonotic-web-port/source/darkplaces/` (`.wasm`, `.data`, generated `.html`/`.js`, `build-obj/`, and the local Emscripten cache) are **gitignored** so clones stay small; run the script locally to produce them.

See [`xonotic-web-port/README.md`](xonotic-web-port/README.md) for general Xonotic documentation and [`xonotic-web-port/COPYING`](xonotic-web-port/COPYING) for upstream licensing detail.

## Contributing

Engine changes usually belong in the **DarkPlaces** submodule (fork, branch, then bump the submodule commit here). Game data and Xonotic-specific packaging live under `xonotic-web-port/`. Keep this repo scoped to the **WASM / web client** story so unrelated side projects never enter the index.

## License

Root [`LICENSE`](LICENSE) is GPLv2, aligned with DarkPlaces. Xonotic assets and combined licensing notes are under `xonotic-web-port/` (see **GPL-2**, **GPL-3**, and **COPYING** there).

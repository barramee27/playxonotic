# Xonotic in the browser + PlayXonotic

This repository holds two related pieces:

1. **`xonotic-web-port/`** — the **Xonotic** tree and **DarkPlaces** work used to build a **WebAssembly (Emscripten)** client (`build-wasm.sh`).
2. **`playxonotic/`** — the **PlayXonotic** stack (web frontend, backend, desktop shell, optional launcher, deploy notes, WebSocket proxy).

Anything else you keep next to this clone (other games, AssaultCube experiments, tools, and so on) is listed in [.gitignore](.gitignore) so it stays on your machine and is not committed.

Upstream Xonotic lives primarily on [GitLab](https://gitlab.com/xonotic/xonotic). This GitHub repo combines the WASM port effort with the PlayXonotic application code.

## Repository layout

| Path | Purpose |
|------|--------|
| [`xonotic-web-port/`](xonotic-web-port/) | Xonotic sources, data, scripts, and **`build-wasm.sh`** for the Emscripten build |
| [`xonotic-web-port/source/darkplaces`](xonotic-web-port/source/darkplaces) | **Git submodule** — DarkPlaces ([xonotic/darkplaces](https://github.com/xonotic/darkplaces)) |
| [`xonotic-web-port/source/d0_blind_id`](xonotic-web-port/source/d0_blind_id) | **Git submodule** — crypto helper lib |
| [`playxonotic/frontend/`](playxonotic/frontend/) | Vite/React UI |
| [`playxonotic/backend/`](playxonotic/backend/) | Node API (copy `.env.example` → `.env` locally; never commit secrets) |
| [`playxonotic/proxy/`](playxonotic/proxy/) | WebSocket proxy for the browser client |
| [`playxonotic/desktop/`](playxonotic/desktop/) | Electron-style desktop wrapper |
| [`playxonotic/launcher/`](playxonotic/launcher/) | Rust/GTK launcher (optional) |
| [`playxonotic/deploy/`](playxonotic/deploy/) | Deployment helpers |
| [`LICENSE`](LICENSE) | Root license notice |

### Submodules (Xonotic engine)

```bash
git submodule update --init --recursive
```

## Build Xonotic (WebAssembly)

Requirements: [Emscripten](https://emscripten.org/), `make`, and usual Unix build tools.

```bash
cd xonotic-web-port
./build-wasm.sh
```

Generated `.wasm`, `.data`, `build-obj/`, Emscripten cache, and related artifacts under `xonotic-web-port/source/darkplaces/` are **gitignored**.

## Build / run PlayXonotic

Use each package’s `README` or `package.json` scripts. Typical flow:

- **Frontend**: `cd playxonotic/frontend && npm install && npm run dev` (or `npm run build` — output goes to `frontend/dist/`, which is gitignored).
- **Backend / proxy**: install dependencies with `npm install`, configure from `*.env.example`, do not commit `.env`.

## License

Root [`LICENSE`](LICENSE) is GPLv2, aligned with DarkPlaces. Xonotic licensing detail is under `xonotic-web-port/` (**GPL-2**, **GPL-3**, **COPYING**). PlayXonotic components may use their own `package.json` / crate licenses—check each subtree as needed.

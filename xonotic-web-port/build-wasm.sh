#!/bin/bash
set -e

# Configuration
export DP_MAKE_TARGET=wasm
export CC=emcc
export CXX=em++
export AR=emar
export RANLIB=emranlib
export EM_CACHE=$(pwd)/emscripten_cache
export EM_CONFIG=$(pwd)/emscripten_config
mkdir -p $EM_CACHE



# Flags for Emscripten
# -s USE_SDL=2 is handled by makefile, but we can enforce environment
# We disable crypto and other complex deps for the first build
export DP_LINK_CRYPTO=disabled # dlopen not supported in WASM
export DP_LINK_CRYPTO_RIJNDAEL=disabled
export DP_LINK_QC=dlopen # QuakeC VM

# Prevent Makefile from using system sdl2-config
export SDL_CONFIG=true 
export SDLCONFIG_UNIXCFLAGS=""
export SDLCONFIG_UNIXLIBS=""
export DP_VIDEO_CAPTURE=disabled



# Navigate to engine source
cd source/darkplaces

# Optional: copy pk3 into wasm/pk3-embed/ so emcc --preload-file bakes them into
# darkplaces-wasm.data (see wasm/pk3-embed/README.txt).
#
# XONOTIC_PK3_SOURCE may be any of:
#   - Xonotic root (contains data/*.pk3), e.g. Flatpak …/files/share/xonotic
#   - The data directory itself (…/share/xonotic/data)
# XONOTIC_ZZ_MOD=/abs/path/zz_playxonotic_mod.pk3 — if the mod lives elsewhere (e.g. xonotic-data-trimmed/)
if [[ -n "${XONOTIC_PK3_SOURCE:-}" ]]; then
	_SRC="${XONOTIC_PK3_SOURCE}"
	_EMBED="wasm/pk3-embed"
	mkdir -p "$_EMBED"
	_DATA=""
	if [[ -f "${_SRC}/data/font-unifont-20230620.pk3" ]]; then
		_DATA="${_SRC}/data"
		_KEY_ROOT="${_SRC}"
	elif [[ -f "${_SRC}/font-unifont-20230620.pk3" ]]; then
		_DATA="${_SRC}"
		_KEY_ROOT="$(cd "${_SRC}/.." && pwd)"
	elif [[ -f "${_SRC}/share/xonotic/data/font-unifont-20230620.pk3" ]]; then
		_DATA="${_SRC}/share/xonotic/data"
		_KEY_ROOT="${_SRC}/share/xonotic"
	fi
	if [[ -z "${_DATA}" ]]; then
		echo "WARNING: XONOTIC_PK3_SOURCE set but no font-unifont-20230620.pk3 found under:" >&2
		echo "  ${_SRC}/data/  ${_SRC}/  or  ${_SRC}/share/xonotic/data/" >&2
	else
		for _f in font-unifont-20230620.pk3 font-xolonium-20230620.pk3 xonotic-20230620-xoncompat.pk3 \
			xonotic-20230620-data.pk3 xonotic-20230620-maps.pk3 zz_playxonotic_mod.pk3; do
			if [[ -f "${_DATA}/${_f}" ]]; then
				cp -f "${_DATA}/${_f}" "$_EMBED/"
			fi
		done
		_key=""
		for _c in "${_KEY_ROOT}/key_0.d0pk" "${_DATA}/key_0.d0pk" "${_SRC}/key_0.d0pk"; do
			if [[ -f "${_c}" ]]; then _key="${_c}"; break; fi
		done
		if [[ -n "${_key}" ]]; then
			cp -f "${_key}" "$_EMBED/"
		else
			echo "WARNING: key_0.d0pk not found next to data or under XONOTIC_PK3_SOURCE" >&2
		fi
	fi
	if [[ -n "${XONOTIC_ZZ_MOD:-}" && -f "${XONOTIC_ZZ_MOD}" ]]; then
		cp -f "${XONOTIC_ZZ_MOD}" "$_EMBED/zz_playxonotic_mod.pk3"
	fi
	echo "Populated wasm/pk3-embed (see listing): XONOTIC_PK3_SOURCE=${XONOTIC_PK3_SOURCE}"
	ls -la "$_EMBED" || true
fi

# Clean previous builds
echo "Cleaning..."
make clean >/dev/null

# Build
echo "Building DarkPlaces for WebAssembly (Headless)..."
# We target 'cl-release' which builds 'darkplaces-sdl'
# We use debug build for now to avoid optimizations taking forever or breaking.
# We also use minimal flags to get link success.

emmake make emscripten-standalone \
    DP_MAKE_TARGET=wasm \
    DP_LINK_CRYPTO=disabled \
    DP_LINK_CRYPTO_RIJNDAEL=disabled \
    DP_LINK_ODE=disabled \
    DP_LINK_XMP=disabled \
    DP_LINK_ZLIB=shared \
    DP_LINK_JPEG=shared \
    debug=1

echo "Build complete. Artifacts should be in source/darkplaces/build-obj/release/"


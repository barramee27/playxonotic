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


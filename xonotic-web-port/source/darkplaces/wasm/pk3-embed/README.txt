Optional full game data for WASM builds
========================================

Copy these files from your Xonotic 0.8.6 install (or official download) into this
directory, using the exact filenames below. The next `emmake make emscripten-standalone`
(or build-wasm.sh) will pass each present file to emcc as --preload-file so they ship
in darkplaces-wasm.data (large) and load without HTTP.

  font-unifont-20230620.pk3
  font-xolonium-20230620.pk3
  xonotic-20230620-xoncompat.pk3
  key_0.d0pk
  xonotic-20230620-data.pk3
  xonotic-20230620-maps.pk3
  zz_playxonotic_mod.pk3

Typical source layout: <xonotic>/data/*.pk3 and <xonotic>/key_0.d0pk (sometimes key_0.d0pk sits inside data/).

Flatpak (org.xonotic.Xonotic): game root is usually
  …/stable/<hash>/files/share/xonotic
with pk3 under …/share/xonotic/data/. Point build-wasm.sh there:

  XONOTIC_PK3_SOURCE=/path/to/files/share/xonotic ./build-wasm.sh

If zz_playxonotic_mod.pk3 lives elsewhere (e.g. xonotic-data-trimmed/):

  XONOTIC_ZZ_MOD=/path/to/xonotic-data-trimmed/zz_playxonotic_mod.pk3 ./build-wasm.sh

If this folder is empty, the engine still links; the browser shell streams missing
files from /game/ (or ?gameBase=) at runtime.

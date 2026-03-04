#!/bin/bash
# Fix "SHADER NOT FOUND" in NetRadiant for PlayXonotic
# Run once. Moves the mapping pk3 to the correct data directory.

SRC="/usr/share/playxonotic/Xonotic/Xonotic/data"
DST="/usr/share/playxonotic/Xonotic/data"

PK3=$(ls "$SRC"/xonotic-*-maps-mapping.pk3 2>/dev/null | head -1)

if [ -z "$PK3" ]; then
    echo "Nothing to move — mapping pk3 not found in $SRC"
    echo "Maybe already fixed? Checking $DST:"
    ls "$DST"/xonotic-*-maps-mapping.pk3 2>/dev/null || echo "  Not found there either."
    exit 0
fi

echo "Moving: $PK3 → $DST/"
mv "$PK3" "$DST/"
echo "Done. Restart NetRadiant and use:"
echo "  Texture Browser → Tools → Flush & Reload Shaders"

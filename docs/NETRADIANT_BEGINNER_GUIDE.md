# NetRadiant Custom – Beginner Guide

## 1. Fix "SHADER NOT FOUND"

That error means NetRadiant can't load textures. Xonotic ships with compressed DDS textures that NetRadiant doesn't support. You need the **mapping support package** (uncompressed textures).

### Steps

1. **Download** the mapping support package (~106 MB):
   - https://beta.xonotic.org/autobuild/Xonotic-latest-mappingsupport.zip

2. **Extract** the mapping pk3 into your Xonotic `data/` folder:
   - **PlayXonotic:** `/usr/share/playxonotic/Xonotic/data/`

   ```bash
   cd /tmp
   wget https://beta.xonotic.org/autobuild/Xonotic-latest-mappingsupport.zip
   # Extract only the mapping pk3 (avoids nested Xonotic/Xonotic/ folder):
   sudo unzip -j Xonotic-latest-mappingsupport.zip "Xonotic/data/*" -d /usr/share/playxonotic/Xonotic/data/
   ```

   **If you already extracted** and got a nested folder, move the pk3:
   ```bash
   sudo mv /usr/share/playxonotic/Xonotic/Xonotic/data/xonotic-*-maps-mapping.pk3 /usr/share/playxonotic/Xonotic/data/
   ```

3. **Restart NetRadiant** and try **Texture Browser → Tools → Flush & Reload Shaders**.

Textures should load and the checkerboard "SHADER NOT FOUND" should disappear.

---

## 2. Basic NetRadiant Workflow

### Interface

| Panel | Purpose |
|-------|---------|
| **2D view (top)** | Top-down grid – main place to build |
| **3D view (right)** | 3D preview |
| **Texture browser (bottom)** | Pick textures for brushes |
| **Entity list** | Spawn points, lights, items |

### First Map in 5 Steps

1. **Create a room (brush)**
   - Deselect all (click empty space or press Escape).
   - **Block tool** (B or toolbar): click-drag in the 2D view to make a rectangle.
   - Drag the top face up in the side view to give it height.
   - You now have a box room.

2. **Apply a texture**
   - In the texture browser, pick something (e.g. `common/caulk` or `metaltechx/...`).
   - Select a brush face (Shift+Ctrl+click or face mode).
   - Right-click the texture → **Apply to selected faces** (or press S).

3. **Add a spawn point**
   - **Entity tool** (E): place `info_player_start` where the player should spawn.
   - Or: Entity → Create entity → `info_player_start`.

4. **Add light**
   - Create entity → `light` (or `light_fluoro`).
   - Place it in the room.

5. **Compile and test**
   - **Build → Build** (or F9).
   - **Build → Run map** to launch the game.

### Useful Shortcuts

| Key | Action |
|-----|--------|
| B | Block tool (create brush) |
| E | Entity tool |
| V | Vertex edit mode |
| E (in edit) | Edge mode |
| F | Face mode |
| S | Apply selected texture to face |
| N | Nudge (move selection) |
| Delete | Delete selection |
| Ctrl+S | Save map |

---

## 3. Meshy → Xonotic (3D Models)

### Export from Meshy

Use **OBJ** format. It’s the best option for bringing Meshy models into Xonotic.

### Workflow

1. **Meshy** → Export as **OBJ** (with textures if available).
2. **Blender** → Import OBJ → Export as **IQM** (Xonotic’s model format).
3. **NetRadiant** → Place with `misc_model` or similar, or bake IQM into the map.

### Blender IQM addon (no built-in IQM export)

1. Download: https://github.com/MikeMorals/blender2.93-iqm/releases  
2. Blender: **Edit → Preferences → Add-ons → Install** → select the `.zip`  
3. Enable **Import-Export: Inter-Quake Model (IQM)**  
4. **File → Export → Inter-Quake Model (.iqm)** will appear

### Notes

- Xonotic uses **IQM** for models, not OBJ.
- Blender has no built-in IQM. Install the addon: https://github.com/MikeMorals/blender2.93-iqm/releases → Edit → Preferences → Add-ons → Install.
- For simple props, you can also rebuild them as brushes in NetRadiant.

---

## 4. Common Issues

| Problem | Fix |
|--------|-----|
| SHADER NOT FOUND | Install mapping support package (see §1) |
| Map won't compile | Add `info_player_start`, seal the map (no holes to void) |
| Can't see in 3D view | Enable **View → Show textures** |
| Brushes turn red | Invalid geometry – check for tiny faces or bad vertex positions |

---

## 5. Next Steps

- [Xonotic mapping wiki](https://xonotic.org/wiki/Map_creation)
- [NetRadiant brushes (Wikibooks)](https://en.wikibooks.org/wiki/NetRadiant/Brushes)
- Start with a small box room, then add more geometry and test often.

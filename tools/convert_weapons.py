"""
Blender batch script: convert FBX/GLTF → OBJ for all weapons
Usage: /opt/blender/blender -b -P tools/convert_weapons.py
"""
import bpy
import os
import sys
import shutil

WEAPONS = [
    {
        "name":    "rifle",
        "input":   "/tmp/weapon_extract/low-poly-ar-ak/source/AK.fbx",
        "texture": "/tmp/weapon_extract/low-poly-ar-ak/textures/Modern_Weapon_Pack_Vol.01.png",
        "format":  "fbx",
    },
    {
        "name":    "shotgun",
        "input":   "/tmp/weapon_extract/low-poly-bar-shotgun/source/BAR 1918.fbx",
        "texture": None,
        "format":  "fbx",
    },
    {
        "name":    "smg",
        "input":   "/tmp/weapon_extract/mx4_smg/scene.gltf",
        "texture": "/tmp/weapon_extract/mx4_smg/textures/Material_001_baseColor.jpeg",
        "format":  "gltf",
    },
    {
        "name":    "pistol",
        "input":   "/tmp/weapon_extract/pistol/source/pistol.fbx",
        "texture": "/tmp/weapon_extract/pistol/textures/pistolcolor.png",
        "format":  "fbx",
    },
    {
        "name":    "sniper",
        "input":   "/tmp/weapon_extract/sv-98-sniper-rifle/source/sv 98.fbx",
        "texture": "/tmp/weapon_extract/sv-98-sniper-rifle/textures/sv_98_SV_98.002_BaseColor.png",
        "format":  "fbx",
    },
    {
        "name":    "machinegun",
        "input":   "/tmp/weapon_extract/uzi/source/uzi.fbx",
        "texture": "/tmp/weapon_extract/uzi/textures/UZI_AlbedoTransparency.png",
        "format":  "fbx",
    },
]

OUT_DIR = "/home/barramee27/antigravity/antigravity-game/models/weapons"
os.makedirs(OUT_DIR, exist_ok=True)

for w in WEAPONS:
    name   = w["name"]
    inp    = w["input"]
    tex    = w["texture"]
    fmt    = w["format"]
    outobj = os.path.join(OUT_DIR, f"{name}.obj")
    outmtl = os.path.join(OUT_DIR, f"{name}.mtl")

    if not os.path.exists(inp):
        print(f"SKIP {name}: {inp} not found")
        continue

    print(f"\n=== Converting {name} ===")

    # Clear scene
    bpy.ops.wm.read_factory_settings(use_empty=True)

    # Import
    try:
        if fmt == "fbx":
            bpy.ops.import_scene.fbx(filepath=inp)
        elif fmt == "gltf":
            bpy.ops.import_scene.gltf(filepath=inp)
    except Exception as e:
        print(f"  Import warning (non-fatal): {e}")

    # Remove lights/cameras that cause Blender 5 errors
    for obj in list(bpy.context.scene.objects):
        if obj.type in ('LIGHT', 'CAMERA', 'EMPTY'):
            bpy.data.objects.remove(obj, do_unlink=True)

    # Select all meshes
    bpy.ops.object.select_all(action='DESELECT')
    for obj in bpy.context.scene.objects:
        if obj.type == 'MESH':
            obj.select_set(True)
            bpy.context.view_layer.objects.active = obj

    if not any(o.type == 'MESH' for o in bpy.context.scene.objects):
        print(f"  WARNING: no mesh found in {name}")
        continue

    # Count faces
    total = sum(len(o.data.polygons) for o in bpy.context.scene.objects if o.type == 'MESH')
    print(f"  Faces: {total:,}")

    # Export OBJ
    bpy.ops.wm.obj_export(
        filepath=outobj,
        export_selected_objects=False,
        export_materials=True,
        export_uv=True,
        export_normals=True,
    )
    print(f"  Exported: {outobj}")

    # Copy texture alongside the OBJ
    if tex and os.path.exists(tex):
        tex_ext  = os.path.splitext(tex)[1]
        tex_dest = os.path.join(OUT_DIR, f"{name}_diffuse{tex_ext}")
        shutil.copy2(tex, tex_dest)
        print(f"  Texture:  {tex_dest}")

        # Fix MTL to point to local texture name
        mtl_name = f"{name}_diffuse{tex_ext}"
        if os.path.exists(outmtl):
            with open(outmtl) as f:
                mtl = f.read()
            import re
            mtl = re.sub(r'map_Kd .*', f'map_Kd {mtl_name}', mtl)
            with open(outmtl, 'w') as f:
                f.write(mtl)

print("\n=== All weapons converted ===")
print(f"Output: {OUT_DIR}")

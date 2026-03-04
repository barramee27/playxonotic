import bpy, os

bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.context.scene.render.engine = 'BLENDER_EEVEE'

try:
    bpy.ops.import_scene.fbx(
        filepath="/tmp/weapon_extract/low-poly-bar-shotgun/source/BAR 1918.fbx",
        ignore_leaf_bones=True,
    )
except Exception as e:
    print(f"Import warning: {e}")

for obj in list(bpy.context.scene.objects):
    if obj.type in ('LIGHT', 'CAMERA'):
        bpy.data.objects.remove(obj, do_unlink=True)

meshes = [o for o in bpy.context.scene.objects if o.type == 'MESH']
print(f"Meshes: {len(meshes)}, Faces: {sum(len(o.data.polygons) for o in meshes):,}")

if meshes:
    bpy.ops.wm.obj_export(
        filepath="/home/barramee27/antigravity/antigravity-game/models/weapons/shotgun.obj",
        export_materials=True, export_uv=True, export_normals=True,
    )
    print("Exported shotgun.obj")
else:
    print("No mesh - shotgun FBX may be empty or unsupported")

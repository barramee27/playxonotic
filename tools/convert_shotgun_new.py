import bpy, os, shutil, re

bpy.ops.wm.read_factory_settings(use_empty=True)

bpy.ops.import_scene.gltf(filepath="/tmp/weapon_extract/shotgun_new/scene.gltf")

for obj in list(bpy.context.scene.objects):
    if obj.type in ('LIGHT', 'CAMERA', 'EMPTY'):
        bpy.data.objects.remove(obj, do_unlink=True)

meshes = [o for o in bpy.context.scene.objects if o.type == 'MESH']
total  = sum(len(o.data.polygons) for o in meshes)
print(f"Meshes: {len(meshes)}, Faces: {total:,}")

OUT = "/home/barramee27/antigravity/antigravity-game/models/weapons"
bpy.ops.wm.obj_export(
    filepath=f"{OUT}/shotgun.obj",
    export_materials=True, export_uv=True, export_normals=True,
)
print(f"Exported: {OUT}/shotgun.obj")

tex_src  = "/tmp/weapon_extract/shotgun_new/textures/02___Default_1001_baseColor.jpeg"
tex_dest = f"{OUT}/shotgun_diffuse.jpeg"
shutil.copy2(tex_src, tex_dest)
print(f"Texture:  {tex_dest}")

mtl_path = f"{OUT}/shotgun.mtl"
if os.path.exists(mtl_path):
    with open(mtl_path) as f:
        mtl = f.read()
    mtl = re.sub(r'map_Kd .*', 'map_Kd shotgun_diffuse.jpeg', mtl)
    with open(mtl_path, 'w') as f:
        f.write(mtl)
    print("MTL fixed")

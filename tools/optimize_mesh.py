"""
Blender batch script: decimate + export OBJ
Usage:
  /opt/blender/blender -b -P tools/optimize_mesh.py -- input.obj output.obj 0.05

Arguments (after --):
  1. input  : path to source .obj file
  2. output : path to save decimated .obj
  3. ratio  : decimation ratio (0.0-1.0, default 0.05 = keep 5% of faces)

Example: 586,960 faces * 0.05 = ~29,000 faces (good for game props)
"""

import sys
import bpy

def main():
    argv = sys.argv
    if "--" in argv:
        argv = argv[argv.index("--") + 1:]
    else:
        print("Usage: blender -b -P optimize_mesh.py -- input.obj output.obj [ratio]")
        sys.exit(1)

    input_path  = argv[0]
    output_path = argv[1]
    ratio       = float(argv[2]) if len(argv) > 2 else 0.05

    # Clear scene
    bpy.ops.wm.read_factory_settings(use_empty=True)

    # Import OBJ
    print(f"Importing: {input_path}")
    bpy.ops.wm.obj_import(filepath=input_path)

    # Decimate all mesh objects
    for obj in bpy.context.scene.objects:
        if obj.type != 'MESH':
            continue
        bpy.context.view_layer.objects.active = obj
        obj.select_set(True)

        original_faces = len(obj.data.polygons)
        mod = obj.modifiers.new(name="Decimate", type='DECIMATE')
        mod.ratio = ratio
        mod.use_collapse_triangulate = True
        bpy.ops.object.modifier_apply(modifier=mod.name)
        new_faces = len(obj.data.polygons)
        print(f"  {obj.name}: {original_faces:,} → {new_faces:,} faces (ratio {ratio})")

    # Export
    print(f"Exporting to: {output_path}")
    bpy.ops.wm.obj_export(
        filepath=output_path,
        export_selected_objects=False,
        export_materials=True,
        export_uv=True,
        export_normals=True,
    )
    print("Done.")

main()

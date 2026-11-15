import bpy, math, os, sys

ROOT = "/Users/dankwawadie/projects/NASA_hack/pipeline"
os.chdir(ROOT)

OUT = "frames_long_blender"
os.makedirs(OUT, exist_ok=True)

# Factory reset
bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.image_settings.file_format = "JPEG"
scene.render.image_settings.quality = 92
scene.render.resolution_x = 1920
scene.render.resolution_y = 1080

# Starry world background
world = bpy.data.worlds.new("SpaceWorld")
scene.world = world
world.use_nodes = True
bg = world.node_tree.nodes.get("Background")
if bg:
    bg.inputs["Color"].default_value = (0.001, 0.002, 0.006, 1.0)
    bg.inputs["Strength"].default_value = 1.0

# Camera
cam_data = bpy.data.cameras.new("Camera")
cam_data.lens = 45
cam = bpy.data.objects.new("Camera", cam_data)
scene.collection.objects.link(cam)
scene.camera = cam

# Sunlight
sun_data = bpy.data.lights.new("Sun", type="SUN")
sun_data.energy = 5.2
sun_data.color = (1.0, 0.98, 0.95)
sun = bpy.data.objects.new("Sun", sun_data)
sun.rotation_euler = (math.radians(48), math.radians(-25), math.radians(42))
scene.collection.objects.link(sun)

# Secondary ambient fill light
fill_data = bpy.data.lights.new("Fill", type="SUN")
fill_data.energy = 0.4
fill_data.color = (0.22, 0.38, 0.65)
fill = bpy.data.objects.new("Fill", fill_data)
fill.rotation_euler = (math.radians(-35), math.radians(145), 0)
scene.collection.objects.link(fill)

# Earth Sphere (Radius 4.5)
bpy.ops.mesh.primitive_uv_sphere_add(radius=4.5, segments=64, ring_count=32, location=(0, 0, 0))
earth = bpy.context.active_object
earth.name = "Earth"

mat_earth = bpy.data.materials.new(name="EarthMat")
nodes = mat_earth.node_tree.nodes
bsdf = nodes.get("Principled BSDF")
bsdf.inputs["Base Color"].default_value = (0.05, 0.24, 0.45, 1.0)
bsdf.inputs["Roughness"].default_value = 0.42
earth.data.materials.append(mat_earth)

# Atmosphere
bpy.ops.mesh.primitive_uv_sphere_add(radius=4.62, segments=64, ring_count=32, location=(0, 0, 0))
atmo = bpy.context.active_object
atmo.name = "Atmosphere"
mat_atmo = bpy.data.materials.new(name="AtmoMat")
a_nodes = mat_atmo.node_tree.nodes
a_bsdf = a_nodes.get("Principled BSDF")
a_bsdf.inputs["Base Color"].default_value = (0.28, 0.58, 0.98, 1.0)
a_bsdf.inputs["Transmission Weight"].default_value = 0.88
a_bsdf.inputs["Roughness"].default_value = 0.08
atmo.data.materials.append(mat_atmo)

# -------------------------------------------------------------
# SHOT 1: Earth Restless Planet (232 frames, 0.0s to 9.68s)
# -------------------------------------------------------------
print("Rendering Shot 1: Earth Restless Planet (232 frames)...")

for f in range(232):
    u = f / 231.0
    cam_angle = math.radians(-15 + u * 24)
    dist = 14.5 + u * 4.5
    cam.location = (dist * math.sin(cam_angle), -dist * math.cos(cam_angle), 3.2 + u * 2.2)
    cam.rotation_euler = (math.radians(80 - u * 4), 0, cam_angle)
    earth.rotation_euler = (0, 0, math.radians(u * 28))
    
    scene.render.filepath = os.path.join(OUT, f"long_b01_{f:04d}.jpg")
    bpy.ops.render.render(write_still=True)
    if f % 40 == 0:
        print(f"  Earth shot progress: {f}/232", flush=True)

print("Blender Earth intro complete!")

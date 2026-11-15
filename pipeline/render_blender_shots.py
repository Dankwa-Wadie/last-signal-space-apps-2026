import bpy, math, os, sys

OUT_16x9 = "frames_30s_blender_16x9"
OUT_4x5  = "frames_30s_blender_4x5"
os.makedirs(OUT_16x9, exist_ok=True)
os.makedirs(OUT_4x5, exist_ok=True)

# Factory reset
bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.render.image_settings.file_format = "JPEG"
scene.render.image_settings.quality = 92

# Starry background (World)
world = bpy.data.worlds.new("SpaceWorld")
scene.world = world
world.use_nodes = True
bg = world.node_tree.nodes.get("Background")
if bg:
    bg.inputs["Color"].default_value = (0.002, 0.003, 0.008, 1.0)
    bg.inputs["Strength"].default_value = 1.0

# Camera
cam_data = bpy.data.cameras.new("Camera")
cam_data.lens = 42
cam = bpy.data.objects.new("Camera", cam_data)
scene.collection.objects.link(cam)
scene.camera = cam

# Sunlight
sun_data = bpy.data.lights.new("Sun", type="SUN")
sun_data.energy = 5.0
sun_data.color = (1.0, 0.98, 0.95)
sun = bpy.data.objects.new("Sun", sun_data)
sun.rotation_euler = (math.radians(50), math.radians(-20), math.radians(40))
scene.collection.objects.link(sun)

# Secondary faint fill light from deep space
fill_data = bpy.data.lights.new("Fill", type="SUN")
fill_data.energy = 0.35
fill_data.color = (0.2, 0.35, 0.6)
fill = bpy.data.objects.new("Fill", fill_data)
fill.rotation_euler = (math.radians(-40), math.radians(140), 0)
scene.collection.objects.link(fill)

# Earth Sphere (Radius 4.5)
bpy.ops.mesh.primitive_uv_sphere_add(radius=4.5, segments=64, ring_count=32, location=(0, 0, 0))
earth = bpy.context.active_object
earth.name = "Earth"

mat_earth = bpy.data.materials.new(name="EarthMat")
nodes = mat_earth.node_tree.nodes
bsdf = nodes.get("Principled BSDF")
bsdf.inputs["Base Color"].default_value = (0.05, 0.22, 0.42, 1.0)
bsdf.inputs["Roughness"].default_value = 0.45
earth.data.materials.append(mat_earth)

# Atmosphere
bpy.ops.mesh.primitive_uv_sphere_add(radius=4.62, segments=64, ring_count=32, location=(0, 0, 0))
atmo = bpy.context.active_object
atmo.name = "Atmosphere"
mat_atmo = bpy.data.materials.new(name="AtmoMat")
a_nodes = mat_atmo.node_tree.nodes
a_bsdf = a_nodes.get("Principled BSDF")
a_bsdf.inputs["Base Color"].default_value = (0.25, 0.55, 0.95, 1.0)
a_bsdf.inputs["Transmission Weight"].default_value = 0.88
a_bsdf.inputs["Roughness"].default_value = 0.08
atmo.data.materials.append(mat_atmo)

# Vanguard 1 Satellite Model (small shiny sphere with 4 antennae)
bpy.ops.mesh.primitive_uv_sphere_add(radius=0.18, segments=24, ring_count=16, location=(0, 0, 0))
vanguard = bpy.context.active_object
vanguard.name = "Vanguard"
mat_vg = bpy.data.materials.new(name="VanguardMat")
vg_nodes = mat_vg.node_tree.nodes
vg_bsdf = vg_nodes.get("Principled BSDF")
vg_bsdf.inputs["Base Color"].default_value = (0.9, 0.9, 0.92, 1.0)
vg_bsdf.inputs["Metallic"].default_value = 0.95
vg_bsdf.inputs["Roughness"].default_value = 0.15
vanguard.data.materials.append(mat_vg)

# Satellite Orbit parameters (scaled):
# Semi-major axis a ~ 6.8, eccentricity e ~ 0.18, inclination 34 deg
a_orbit = 6.4
e_orbit = 0.18
b_orbit = a_orbit * math.sqrt(1 - e_orbit*e_orbit)
c_focus = a_orbit * e_orbit

def get_vanguard_pos(angle):
    # Ellipse in orbital plane, shifted by c_focus so Earth is at one focus
    x0 = a_orbit * math.cos(angle) - c_focus
    y0 = b_orbit * math.sin(angle)
    z0 = 0.0
    # Rotate by inclination (34.25 degrees)
    inc = math.radians(34.25)
    x = x0
    y = y0 * math.cos(inc) - z0 * math.sin(inc)
    z = y0 * math.sin(inc) + z0 * math.cos(inc)
    return (x, y, z)

# Render Shot 1: Earth Cold Open (77 frames)
# Slow cinematic drift
print("Rendering Shot 1: Earth Cold Open (77 frames)...")
vanguard.hide_render = True

for f in range(77):
    u = f / 76.0
    # Camera slow orbit
    cam_angle = math.radians(-10 + u * 12)
    dist = 17.5 - u * 1.5
    cam.location = (dist * math.sin(cam_angle), -dist * math.cos(cam_angle), 4.2 + u * 0.8)
    cam.rotation_euler = (math.radians(78), 0, cam_angle)
    earth.rotation_euler = (0, 0, math.radians(u * 15))
    
    # 16:9
    scene.render.resolution_x = 1920
    scene.render.resolution_y = 1080
    scene.render.filepath = os.path.join(OUT_16x9, f"s1_{f:04d}.jpg")
    bpy.ops.render.render(write_still=True)

# Render Shot 2: Vanguard 1 Fast Orbit (91 frames)
print("Rendering Shot 2: Vanguard 1 Orbit (91 frames)...")
vanguard.hide_render = False

for f in range(91):
    u = f / 90.0
    # Vanguard completes ~1.5 orbits rapidly (fast motion, 600x real-time)
    vg_angle = u * math.pi * 3.2
    vpos = get_vanguard_pos(vg_angle)
    vanguard.location = vpos
    
    # Camera focuses on Vanguard tracking around Earth
    cam_dist = 16.0
    cam.location = (math.sin(math.radians(20 + u*25))*cam_dist, -math.cos(math.radians(20 + u*25))*cam_dist, 5.5 + math.sin(u*math.pi)*2.0)
    # Point camera at center-Vanguard mid
    look_tgt = (vpos[0]*0.4, vpos[1]*0.4, vpos[2]*0.4)
    dx = look_tgt[0] - cam.location[0]
    dy = look_tgt[1] - cam.location[1]
    dz = look_tgt[2] - cam.location[2]
    dist_xy = math.sqrt(dx*dx + dy*dy)
    cam.rotation_euler = (math.atan2(dist_xy, dz) - math.pi/2, 0, math.atan2(-dx, -dy))
    
    earth.rotation_euler = (0, 0, math.radians(15 + u * 20))
    
    # 16:9
    scene.render.resolution_x = 1920
    scene.render.resolution_y = 1080
    scene.render.filepath = os.path.join(OUT_16x9, f"s2_{f:04d}.jpg")
    bpy.ops.render.render(write_still=True)

print("Blender shots 1 & 2 complete!")


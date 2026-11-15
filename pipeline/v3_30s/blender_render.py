"""Background render of the two Blender shots for one output format.

  Blender -b blender/earth_v3.blend -S V3_30s_Earth --python blender_render.py -- 16x9
  Blender -b blender/earth_v3.blend -S V3_30s_Earth --python blender_render.py -- 4x5

Writes frames_blender_<fmt>/f0001.png ... and sat_track_<fmt>.json (the satellite's
screen position per frame, used by compose.py to draw its trail and label).
Shot 1 (earth)    : frames 1-77,   real time
Shot 2 (vanguard) : frames 78-168, time-lapse x COMP, labelled on screen
"""
import bpy, sys, os, json, math
from mathutils import Vector, Euler, Matrix
from bpy_extras.object_utils import world_to_camera_view

HERE = "/Users/dankwawadie/projects/NASA_hack/pipeline/v3_30s"
sys.path.insert(0, HERE)
import orbit as O

fmt = sys.argv[sys.argv.index("--") + 1] if "--" in sys.argv else "16x9"
TL = json.load(open(os.path.join(HERE, "timeline.json")))
COMP = TL["orbit"]["compression"]
T0 = TL["orbit"]["t0_fraction"] * O.PERIOD
W, H = TL["formats"][fmt]["w"], TL["formats"][fmt]["h"]

scn = bpy.data.scenes["V3_30s_Earth"]
bpy.context.window.scene = scn if bpy.context.window else scn
scn.render.resolution_x, scn.render.resolution_y = W, H
scn.render.image_settings.file_format = "PNG"
scn.render.image_settings.color_mode = "RGB"
out_dir = os.path.join(HERE, f"frames_blender_{fmt}")
os.makedirs(out_dir, exist_ok=True)
scn.render.filepath = os.path.join(out_dir, "f")
scn.frame_start, scn.frame_end = 1, 168
try:
    scn.eevee.taa_render_samples = 64
except Exception:
    pass

# Cinematic cameras were built and baked with the AutoCam add-on (one rig per shot);
# timeline markers switch V3_Cam_Shot1 -> V3_Cam_Shot2 at the cut (frame 78).
LENS = {"16x9": 50.0, "4x5": 60.0}[fmt]
for cname in ("V3_Cam_Shot1", "V3_Cam_Shot2"):
    bpy.data.objects[cname].data.lens = LENS
earth = bpy.data.objects["V3_Earth"]
orbit_obj = bpy.data.objects["V3_Orbit"]
sat = bpy.data.objects["V3_Vanguard"]
orbit_mat = bpy.data.materials["V3_OrbitLine"]
orbit_em = [n for n in orbit_mat.node_tree.nodes if n.type == "EMISSION"][0]

def smooth(u):
    u = max(0.0, min(1.0, u)); return u * u * u * (u * (u * 6 - 15) + 10)

def lerp(a, b, u):
    return tuple(a[k] + (b[k] - a[k]) * u for k in range(3))

SIDEREAL = 86164.1
Z0 = earth.rotation_euler.z
orbit_mw = orbit_obj.matrix_world.copy()

def sat_world(t_real):
    x, y, r, v = O.state(t_real)
    return orbit_mw @ Vector((x / O.RE, y / O.RE, 0.0)), r, v

track = []
for f in range(1, 169):
    if f <= 77:                       # shot 1: real time, slow push-in
        t_real = T0
        earth.rotation_euler.z = Z0
        sat.hide_render = True
        orbit_obj.hide_render = True          # zero emission still draws a dark ring
        orbit_em.inputs["Strength"].default_value = 0.0
    else:                             # shot 2: time-lapse, the satellite whips round
        k = f - 78
        t_real = T0 + (k / 24.0) * COMP
        earth.rotation_euler.z = Z0 + 2 * math.pi * (t_real - T0) / SIDEREAL
        sat.hide_render = False
        orbit_obj.hide_render = False
        orbit_em.inputs["Strength"].default_value = 2.2 * smooth(k / 10.0)
    p, r, v = sat_world(t_real)
    sat.location = p
    for obj, path in ((earth, "rotation_euler"), (sat, "location")):
        obj.keyframe_insert(path, frame=f)
    sat.keyframe_insert("hide_render", frame=f)
    orbit_obj.keyframe_insert("hide_render", frame=f)
    orbit_em.inputs["Strength"].keyframe_insert("default_value", frame=f)

    # screen position + whether Earth hides it (ray from camera hits the globe first)
    bpy.context.view_layer.update() if bpy.context.view_layer else None
    scn.frame_set(f)
    cam = scn.camera                       # marker-driven: the AutoCam camera for this shot
    co = world_to_camera_view(scn, cam, p)
    cpos = cam.matrix_world.translation
    d = (p - cpos); L = d.length; d.normalize()
    bq = cpos.dot(d); cq = cpos.dot(cpos) - 1.0
    disc = bq * bq - cq
    hidden = False
    if disc > 0:
        t_hit = -bq - math.sqrt(disc)
        hidden = 0 < t_hit < L
    track.append({"frame": f, "t_real": t_real, "alt_km": r - O.RE, "speed": v,
                  "x": co.x, "y": 1 - co.y, "depth": co.z, "hidden": hidden,
                  "shot": "earth" if f <= 77 else "vanguard"})

# every frame is keyed explicitly, so interpolation never matters
# (Blender 5 slotted actions no longer expose Action.fcurves).
json.dump(track, open(os.path.join(HERE, f"sat_track_{fmt}.json"), "w"), indent=0)
print(f"[{fmt}] keyed 168 frames, rendering {W}x{H} -> {out_dir}", flush=True)
if "test" in sys.argv:                       # quick check: three stills only
    for f in (40, 100, 135):
        scn.frame_set(f)
        scn.render.filepath = os.path.join(out_dir, f"test_{f:04d}")
        bpy.ops.render.render(write_still=True, scene=scn.name)
else:
    bpy.ops.render.render(animation=True, scene=scn.name)
print(f"[{fmt}] DONE", flush=True)

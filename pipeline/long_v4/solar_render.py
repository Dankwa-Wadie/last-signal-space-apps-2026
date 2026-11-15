"""S00: the solar system, then a sweep in to Earth that lands exactly on the first frame of the
Earth push-in (V3_Cam_Shot1 at frame 1). Background render on the v3 copy; nothing is saved.

  Blender -b ../v3_30s/blender/earth_v3.blend --python solar_render.py -- 16x9
  Blender -b ../v3_30s/blender/earth_v3.blend --python solar_render.py -- 4x5

Writes frames_solar_<fmt>/f0001.png .. f0072.png and solar_track_<fmt>.json (screen positions
of the Sun and planets per frame, for labels and the Sun's glow in compose_long.py).
Not to scale: the planets are spread and enlarged so the whole system fits in one view.
"""
import bpy, sys, os, json, math
from mathutils import Vector, Quaternion, Matrix
from bpy_extras.object_utils import world_to_camera_view

HERE = os.path.dirname(os.path.abspath(__file__))
fmt = sys.argv[sys.argv.index("--") + 1] if "--" in sys.argv else "16x9"
W, H = {"16x9": (1920, 1080), "4x5": (1080, 1350)}[fmt]
N = 72

scn = bpy.data.scenes["V3_30s_Earth"]
if bpy.context.window: bpy.context.window.scene = scn
scn.render.resolution_x, scn.render.resolution_y = W, H
scn.render.image_settings.file_format = "PNG"; scn.render.image_settings.color_mode = "RGB"
out_dir = os.path.join(HERE, f"frames_solar_{fmt}"); os.makedirs(out_dir, exist_ok=True)
try: scn.eevee.taa_render_samples = 48
except Exception: pass
for n in ("V3_Vanguard", "V3_SatBody", "V3_SatGlow", "V3_Orbit") + tuple(f"V3_Antenna{i}" for i in range(6)):
    o = bpy.data.objects.get(n)
    if o: o.hide_render = True

earth = bpy.data.objects["V3_Earth"]
sun_l = bpy.data.objects["V3_Sun"]
travel = (sun_l.matrix_world.to_3x3() @ Vector((0, 0, -1))).normalized()   # light travels Sun -> Earth
u = travel                                   # Sun -> Earth direction
v = u.cross(Vector((0, 0, 1))).normalized()
w = u.cross(v).normalized()                  # normal of our "ecliptic" plane
RE = 400.0                                   # Earth's (compressed) orbit radius in Blender units
SUN = -u * RE                                # Earth sits at the origin

def mat(name, col, emit=0.0, rough=0.8):
    m = bpy.data.materials.new(name); m.use_nodes = True
    b = next(n for n in m.node_tree.nodes if n.type == "BSDF_PRINCIPLED")
    b.inputs["Base Color"].default_value = (*col, 1)
    b.inputs["Roughness"].default_value = rough
    if emit:
        for key in ("Emission Color", "Emission"):
            if key in b.inputs: b.inputs[key].default_value = (*col, 1); break
        b.inputs["Emission Strength"].default_value = emit
    return m

def sphere(name, loc, r, m, seg=48):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=seg, ring_count=seg // 2, radius=r, location=loc)
    o = bpy.context.active_object; o.name = name; o.data.materials.append(m)
    o.visible_shadow = False        # the Sun sphere sits on the light's path to Earth: no shadows
    bpy.ops.object.shade_smooth(); return o

def ring(name, center, R, minor, m, normal):
    bpy.ops.mesh.primitive_torus_add(major_radius=R, minor_radius=minor, major_segments=256, minor_segments=8, location=center)
    o = bpy.context.active_object; o.name = name; o.data.materials.append(m)
    o.visible_shadow = False
    o.rotation_mode = "QUATERNION"; o.rotation_quaternion = Vector((0, 0, 1)).rotation_difference(normal)
    return o

sun_m = mat("S_Sun", (1.0, 0.82, 0.45), emit=40.0)
sphere("S_SunBody", SUN, 22.0, sun_m)
orbit_m = mat("S_Orbit", (0.45, 0.62, 0.9), emit=0.9)
PLANETS = [   # name, orbit radius, angle (rad) on the plane, radius, colour
    ("MERCURY", 150, 0.55, 4.0, (0.55, 0.53, 0.50)),
    ("VENUS",   270, -0.42, 6.5, (0.86, 0.78, 0.58)),
    ("EARTH",   RE,  0.0,  1.0,  None),
    ("MARS",    560, 0.30, 4.8,  (0.76, 0.36, 0.20)),
    ("JUPITER", 860, -0.22, 24.0, (0.80, 0.68, 0.52)),
    ("SATURN",  1240, 0.16, 20.0, (0.86, 0.78, 0.58)),
]
objs = {"SUN": SUN}
for name, R, th, r, col in PLANETS:
    pos = SUN + R * (math.cos(th) * u + math.sin(th) * v)
    if name == "EARTH":
        pos = Vector((0, 0, 0))
    else:
        m = mat("S_" + name, col, rough=0.9)
        if name == "JUPITER":     # cloud bands
            nt = m.node_tree; b = next(n for n in nt.nodes if n.type == "BSDF_PRINCIPLED")
            wv = nt.nodes.new("ShaderNodeTexWave"); wv.bands_direction = "Z"; wv.inputs["Scale"].default_value = 3.2
            wv.inputs["Distortion"].default_value = 6.0
            cr = nt.nodes.new("ShaderNodeValToRGB")
            cr.color_ramp.elements[0].color = (0.62, 0.46, 0.32, 1); cr.color_ramp.elements[1].color = (0.92, 0.86, 0.74, 1)
            nt.links.new(wv.outputs["Fac"], cr.inputs["Fac"]); nt.links.new(cr.outputs["Color"], b.inputs["Base Color"])
        sphere("S_" + name, pos, r, m)
        if name == "SATURN":
            rm = mat("S_Rings", (0.82, 0.74, 0.58), rough=0.9)
            rg = ring("S_SaturnRings", pos, r * 1.9, r * 0.45, rm, (w + 0.35 * u).normalized())
            rg.scale = (1, 1, 0.06)
    objs[name] = pos
    ring("S_Orbit_" + name, SUN, (pos - SUN).length, 1.4, orbit_m, w)

# camera: from high above the plane to exactly V3_Cam_Shot1 at frame 1
scn.frame_set(1)
end_cam = bpy.data.objects["V3_Cam_Shot1"]
end_M = end_cam.matrix_world.copy()
lens = {"16x9": 50.0, "4x5": 60.0}[fmt]
cam_data = bpy.data.cameras.new("S00_Cam"); cam_data.lens = lens; cam_data.clip_end = 20000
cam_data.sensor_width = end_cam.data.sensor_width; cam_data.sensor_fit = end_cam.data.sensor_fit
cam = bpy.data.objects.new("S00_Cam", cam_data); scn.collection.objects.link(cam)
cam.rotation_mode = "QUATERNION"
scn.camera = cam
for m in list(scn.timeline_markers): scn.timeline_markers.remove(m)   # markers would switch cameras

mid = SUN * 0.5
P1 = end_M.translation.copy()
Q1 = end_M.to_quaternion()
D0 = 2300.0
d0 = (-u * 0.55 + w * 0.83).normalized()         # high above the plane, on the Sun's side of Earth
d1 = P1.normalized(); D1 = P1.length

def look_quat(pos, tgt):
    d = (tgt - pos).normalized()
    return d.to_track_quat("-Z", "Y")

def ease(x): x = max(0.0, min(1.0, x)); return x * x * (3 - 2 * x)

def slerp_dir(a, b, t):
    om = math.acos(max(-1.0, min(1.0, a.dot(b))))
    if om < 1e-6: return a.copy()
    return (a * math.sin((1 - t) * om) + b * math.sin(t * om)) / math.sin(om)

orbits = [o for o in scn.objects if o.name.startswith("S_Orbit_")]
track = []
FR = [int(x) for x in os.environ.get('SOLAR_FRAMES','').split(',') if x] or list(range(1, N + 1))
for f in FR:
    s = (f - 1) / (N - 1)
    e = ease(s)
    dist = math.exp(math.log(D0) + (math.log(D1) - math.log(D0)) * (e ** 0.8))   # geometric zoom
    lp = slerp_dir(d0, d1, ease(min(1.0, s * 1.15))) * dist
    tgt = mid.lerp(Vector((0, 0, 0)), ease(min(1.0, s * 2.6)))      # turn toward Earth early so it never leaves frame
    q = look_quat(lp, tgt)
    if s > 0.80:
        q = q.slerp(Q1, ease((s - 0.80) / 0.20))
    if f == N: lp, q = P1, Q1
    cam.location = lp; cam.rotation_quaternion = q
    for o in orbits: o.hide_render = dist < 420
    scn.frame_set(f)
    scn.render.filepath = os.path.join(out_dir, f"f{f:04d}")
    bpy.ops.render.render(write_still=True)
    row = {}
    for name, pos in objs.items():
        p = world_to_camera_view(scn, cam, pos)
        row[name] = [p.x, 1 - p.y, p.z]
    track.append(row)
    print("solar frame", f, flush=True)
json.dump(track, open(os.path.join(HERE, f"solar_track_{fmt}.json"), "w"))
print("solar done", fmt)

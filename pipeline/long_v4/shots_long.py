"""Shot table for the long film, cut to the narration (voiceover_long.mp3, word-timed).
kind: roblox | blender | graphic | game | reuse
sky : space (starfield) | night (starfield + airglow) | mars | day (Roblox's own) | none
"""
import math

FPS = 24

def _e(t):
    t = max(0.0, min(1.0, t)); return t * t * t * (t * (t * 6 - 15) + 10)

def lerp(a, b, u): return [a[i] + (b[i] - a[i]) * u for i in range(3)]

def keys(*ks):
    """Camera from keyframes [(u, pos, tgt), ...], eased between each pair."""
    def f(i, n):
        u = i / max(1, n - 1)
        for (u0, p0, t0), (u1, p1, t1) in zip(ks, ks[1:]):
            if u <= u1:
                w = _e((u - u0) / max(1e-6, u1 - u0))
                return lerp(p0, p1, w), lerp(t0, t1, w)
        return ks[-1][1], ks[-1][2]
    return f

def orbit(r0, r1, a0, a1, h0, h1, tgt0, tgt1=None):
    tgt1 = tgt1 or tgt0
    def f(i, n):
        e = _e(i / max(1, n - 1))
        a = math.radians(a0 + (a1 - a0) * e); r = r0 + (r1 - r0) * e
        return [math.sin(a) * r + lerp(tgt0, tgt1, e)[0], h0 + (h1 - h0) * e,
                math.cos(a) * r + lerp(tgt0, tgt1, e)[2]], lerp(tgt0, tgt1, e)
    return f

def hill_y(x, z):   # surface of the terrain hill: ball centre (0,-60,-20), radius 70
    d2 = x * x + (z + 20) ** 2
    return -60 + math.sqrt(max(0.0, 70 * 70 - d2))

def mars_track(STOP=None, rate=0.06, off0=(-14.0, 2.6, 11.5), off1=(-15.5, 3.5, 4.0)):
    fwd = (math.sin(math.radians(25)), 0.0, -math.cos(math.radians(25)))
    def f(i, n):
        if STOP:
            u = min(1.0, i / STOP); d = 6.0 * (1 - (1 - u) ** 2.2)
        else:
            d = rate * i
        rover = [fwd[0] * d, 0.0, fwd[2] * d]
        e = _e(i / max(1, n - 1))
        off = lerp(list(off0), list(off1), e)
        return [rover[0] + off[0], off[1], rover[2] + off[2]], [rover[0], 2.9, rover[2]]
    return f

def drive_cam(i, n):
    # tracking alongside the rover as it drives -Z at 7 studs/s from z=40 (LRV at x=14)
    t = i / 24
    rz = 40 + 7.0 * t            # yaw 180: the rover's forward (local -Z) is world +Z
    u = _e(i / max(1, n - 1))
    pos = [14 + 15.0 - 2.5 * u, 5.2 + 0.6 * u, rz + 6.0 - 5.0 * u]
    tgt = [14, 3.2, rz + 1.0]
    return pos, tgt

def liftoff_cam(i, n):
    # hold on the lander; ignition at frame 14 ("blasted"); follow the slowly climbing cabin,
    # then tilt back down to the descent stage by frame ~61 ("The bottom half ... stayed behind")
    pos = lerp([-7, 4.4, 44], [-5.5, 4.2, 38], _e(i / (n - 1)))
    IG = 14
    t = max(0.0, (i - IG) / 24)
    hc = 1.5 * t * t
    if i < IG:   ty = 8.0
    elif i < 46: ty = 8.0 + min(hc, 9.0) * _e((i - IG) / 32)
    elif i < 64: ty = (8.0 + min(1.5 * ((46 - IG) / 24) ** 2, 9.0)) * (1 - _e((i - 46) / 18)) + 5.0 * _e((i - 46) / 18)
    else:        ty = 5.0
    return pos, [0.0, ty, 0.0]

HY = hill_y(0, -8) + 2.9

PRE = 3.0          # music-only intro before the narration starts (solar system pull-in)

SHOTS = [
 dict(id="S00", t0=-PRE, t1=0.00, kind="solar", note="the solar system, sweeping in to Earth (Blender)"),
 # ------------------------------------------------------------------ ACT 1: we explore
 dict(id="S01", t0=0.00, t1=2.60, kind="blender", note="Earth from space (v3 Blender frames)"),
 dict(id="S02", t0=2.60, t1=4.30, kind="roblox", scene="L02_ocean", frame="L02_frame", sky="day", fov=50,
      path=keys((0, [-62, 8, 72], [-6, 17, 0]), (1, [-70, 9, 60], [-14, 18, 0]))),
 dict(id="S03", t0=4.30, t1=6.20, kind="roblox", scene="L03_desert", frame="L03_frame", sky="day", fov=45,
      path=keys((0, [-1.0, 1.4, 24], [0, 3.4, -4]), (1, [2.0, 1.5, 22], [3, 3.6, -4]))),
 dict(id="S04", t0=6.20, t1=9.60, kind="roblox", scene="L04_hill", frame="L04_frame", sky="night", fov=55,
      tag=("GIZA, EGYPT", "the last of the Seven Wonders still standing"),
      path=keys((0, [0, 1.7, 6], [0, 2.5, -8]), (0.35, [0, 1.5, 6.5], [0, 3.3, -8]),
                (1, [0, 1.1, 8], [0, 24.9, -40]))),
 # ------------------------------------------------------------------ ACT 2: Apollo 11
 dict(id="S05", t0=9.60, t1=13.10, kind="roblox", scene="L05_landing", frame="L05_frame", sky="space", fov=50,
      tag=("APOLLO 11", "Tranquility Base · 20 July 1969"),
      path=keys((0, [-5, 7.0, 52], [0, 6.5, 4]), (1, [-2.5, 6.0, 40], [0, 6.2, 4]))),
 dict(id="S05b", t0=13.10, t1=14.60, kind="roblox", scene="L05b_interior", frame="L04_frame", sky="space", fov=70,
      tag=("INSIDE THE EAGLE", "on the surface for 21 h 36 min"),
      path=keys((0, [0, 18.4, 4.0], [0, 16.8, -4.2]), (1, [0, 18.1, 2.9], [0, 16.9, -4.2]))),
 dict(id="S06", t0=14.60, t1=17.00, kind="roblox", scene="L06_flag", frame="L06_frame", sky="space", fov=50,
      path=keys((0, [8.5, 3.0, 12.5], [-0.5, 2.6, 3.5]), (1, [7.2, 2.6, 11.6], [-0.4, 2.2, 3.6]))),
 dict(id="S07", t0=17.00, t1=19.60, kind="proc", fn="bootprint", scene="L07_bootprint", sky="none", fov=40,
      path=keys((0, [1.6, 3.2, 5.4], [0, 0, -0.3]), (1, [0.9, 2.3, 3.9], [0, 0, -0.4]))),
 dict(id="S08", t0=19.60, t1=22.70, kind="roblox", scene="L08_leaving", frame="L08_frame", sky="space", fov=50,
      path=keys((0, [8, 5.5, 32], [0, 6.0, 4]), (1, [13, 7.0, 44], [0, 6.5, 2]))),
 dict(id="S09", t0=22.70, t1=28.20, kind="roblox", scene="L09_descent", sky="space", fov=45,
      tag=("DESCENT STAGE", "the bottom half of the Eagle"),
      path=keys((0, [-21, 5.0, 24], [0, 5.2, 0]), (1, [20, 5.5, 24], [0, 5.4, 0]))),
 dict(id="S10a", t0=28.20, t1=29.70, kind="roblox", scene="L10a_ladder", frame="L10a_frame", sky="space", fov=50,
      path=keys((0, [5.5, 4.2, 21], [-3.4, 4.8, 7.0]), (1, [5.0, 5.0, 19.5], [-3.2, 6.8, 6.6]))),
 dict(id="S10", t0=29.70, t1=35.90, kind="roblox", scene="L10_liftoff", frame="L10_frame", sky="space", fov=55,
      path=liftoff_cam),
 dict(id="S11", t0=35.90, t1=39.60, kind="roblox", scene="L11_today", sky="space", fov=50,
      tag=("TODAY", "still standing at Tranquility Base"),
      path=keys((0, [-4, 5.6, 40], [0, 5.0, 0]), (1, [-2.5, 5.0, 29], [0, 4.6, 0]))),
 # ------------------------------------------------------------------ ACT 3: the seismometer
 dict(id="S12", t0=39.60, t1=46.80, kind="roblox", scene="L12_seis", frame="L12_frame", sky="space", fov=50,
      tag=("PASSIVE SEISMIC EXPERIMENT", "an electronic ear for moonquakes"),
      path=orbit(9.5, 7.2, 25, 70, 3.4, 2.6, [0.5, 1.8, 0.5])),
 dict(id="S13", t0=46.80, t1=54.90, kind="roblox", scene="L13_impact", frame="L13_frame", sky="space", fov=50,
      tag=("APOLLO 12 · 20 NOV 1969", "ascent stage crashed 73 km away, beyond the horizon"),
      path=keys((0, [-3.5, 2.3, 17], [6, 2.2, -60]), (1, [-2.5, 2.1, 13.5], [5, 2.0, -60]))),
 dict(id="S14", t0=54.90, t1=62.80, kind="graphic", fn="seismogram"),
 # ------------------------------------------------------------------ ACT 4: Hadley Rille
 dict(id="S15", t0=62.80, t1=69.40, kind="roblox", scene="L15_hadley", sky="space", fov=55,
      tag=("APOLLO 15 · HADLEY RILLE · 1971", "965 km from Tranquility Base · 1.5 km wide · up to 400 m deep"),
      path=keys((0, [70, 58, 110], [70, -12, -40]), (1, [4, 11, 24], [18, 3.0, 0]))),
 dict(id="S16a", t0=69.40, t1=72.30, kind="roblox", scene="L16a_drive", frame="L16a_frame", sky="space", fov=50,
      tag=("1971 · LUNAR ROVING VEHICLE", "battery-powered, wire-mesh wheels, top speed about 13 km/h"),
      path=drive_cam),
 dict(id="S16", t0=72.30, t1=74.60, kind="roblox", scene="L15_hadley", sky="space", fov=45, counter="lrv_years",
      path=orbit(12.5, 11.0, -15, 55, 4.6, 4.2, [18, 3.6, 0])),
 dict(id="S17", t0=74.60, t1=78.30, kind="roblox", scene="L17_lrvempty", sky="space", fov=50,
      path=keys((0, [28, 6.4, 12], [12, 3.4, -8]), (1, [25, 5.8, 9], [11, 3.2, -10]))),
 # ------------------------------------------------------------------ ACT 5: Mars
 dict(id="S18a", t0=78.30, t1=79.90, kind="photozoom", img="refs/PIA00407.jpg",
      target=(1156, 770), label=("MERIDIANI PLANUM", "Opportunity landed here · 25 January 2004"),
      credit="NASA PHOTO · Viking Orbiter global mosaic (PIA00407)"),
 dict(id="S18", t0=79.90, t1=81.30, kind="roblox", scene="L18_mars", frame="L18_frame", sky="mars", fov=55,
      path=keys((0, [-6, 4.5, 34], [-12, 7, -120]), (1, [-3, 4.5, 33], [6, 7, -120]))),
 dict(id="S19", t0=81.30, t1=92.20, kind="roblox", scene="L19_mars", frame="L19_frame", sky="mars", fov=50,
      counter="sols", path=mars_track()),
 dict(id="S20", t0=92.20, t1=99.20, kind="roblox", scene="L20_mars", frame="L20_frame", sky="mars", fov=50,
      storm=True, path=mars_track(STOP=34)),
 dict(id="S21", t0=99.20, t1=103.10, kind="roblox", scene="L21_mars", frame="L21_frame", sky="mars", fov=45,
      storm_hold=True, pulse=True,
      path=keys((0, [-12, 3.0, 10], [0, 3.0, 0]), (1, [-7.5, 3.4, 6], [0, 3.8, 0]))),
 dict(id="S22", t0=103.10, t1=106.40, kind="graphic", fn="dsn"),
 # ------------------------------------------------------------------ ACT 6: Voyager
 dict(id="S23", t0=106.40, t1=113.40, kind="roblox", scene="L23_voyager", frame="L23_frame", sky="space", fov=50,
      tag=("VOYAGER 1", "launched 5 September 1977"),
      path=keys((0, [-24, 5.5, 19], [0, 2.8, -3]), (1, [8, 3.6, 29], [-1, 2.8, -3]))),
 dict(id="S24", t0=113.40, t1=123.20, kind="graphic", fn="lightday"),
 dict(id="S25", t0=123.20, t1=131.20, kind="roblox", scene="L25_voyager", frame="L25_frame", sky="space", fov=45,
      instruments=True, path=orbit(31, 26, 25, 70, 5.0, 3.6, [0, 1.6, -3])),
 # ------------------------------------------------------------------ ACT 7: the mirrors
 dict(id="S26", t0=131.20, t1=139.80, kind="roblox", scene="L26_retro", sky="space", fov=50,
      tag=("LASER RANGING RETROREFLECTOR", "Apollo 11 · still working"),
      path=keys((0, [-15, 8.0, 11], [0, 2.4, 0]), (1, [-9.5, 5.6, 5], [0, 2.6, 0]))),
 dict(id="S27", t0=139.80, t1=147.40, kind="graphic", fn="reflector"),
 dict(id="S28", t0=147.40, t1=156.62, kind="graphic", fn="laser"),
 dict(id="S29", t0=156.62, t1=164.00, kind="reuse", src="../v3_30s/roblox/retro", sky="space", timer_fire=29),
 dict(id="S30", t0=164.00, t1=171.40, kind="graphic", fn="drift"),
 # ------------------------------------------------------------------ ACT 8: we keep looking up
 dict(id="S31", t0=171.40, t1=175.30, kind="roblox", scene="L31_hill", frame="L31_frame", sky="night", fov=55,
      tag=("THE GREAT PYRAMID", "about 4,500 years old, and not forgotten"),
      fastforward=True,
      path=keys((0, [1, 1.5, 8], [1, 2.7, -8]), (0.3, [1, 1.4, 8.5], [1, 3.9, -8]),
                (1, [1, 1.0, 9.5], [2, 26.9, -40]))),
 dict(id="S32", t0=175.30, t1=181.00, kind="game"),
 dict(id="S33", t0=181.00, t1=185.00, kind="graphic", fn="cta"),
]

for s in SHOTS:            # narration times above; the film runs PRE seconds later
    s["t0"] += PRE; s["t1"] += PRE
    s["f0"] = int(round(s["t0"] * FPS)); s["f1"] = int(round(s["t1"] * FPS)); s["n"] = s["f1"] - s["f0"]

if __name__ == "__main__":
    tot = 0
    for s in SHOTS:
        tot += s["n"]
        print(f"{s['id']} {s['t0']:6.2f}-{s['t1']:6.2f} {s['n']:4d}f  {s['kind']:8s} {s.get('scene', s.get('fn', ''))}")
    gaps = [(a["id"], b["id"]) for a, b in zip(SHOTS, SHOTS[1:]) if a["f1"] != b["f0"]]
    print("total frames", tot, "=", tot / FPS, "s | gaps/overlaps:", gaps)
    print("roblox frames:", sum(s["n"] for s in SHOTS if s["kind"] == "roblox"),
          "of which need a matte:", sum(s["n"] for s in SHOTS if s["kind"] == "roblox" and s.get("sky") in ("space", "night", "mars")))

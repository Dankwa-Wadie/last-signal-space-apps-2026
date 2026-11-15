"""The 30-second cut (v4 reworked with live gameplay scenes):
Everything in the long film, cut to narration (1114(2).MP3), ending with actual
recorded gameplay video scenes from Roblox (Moon exploration, interplanetary transit,
Mars Opportunity rover discovery & scan) instead of static still pictures.

  python3 compose_30.py 16x9               -> last_signal_30s_v4_16x9.mp4
  python3 compose_30.py 4x5                -> last_signal_30s_v4_4x5.mp4
  python3 compose_30.py 16x9 --only-ending -> re-renders only gameplay ending (f0470-f0599)
  python3 compose_30.py 16x9 --at 23.5     -> preview still(s)
"""
import os, sys, json, math, subprocess
HERE = os.path.dirname(os.path.abspath(__file__))
LONG = os.path.join(HERE, "..", "long_v4")
REPO_ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))

fmt = sys.argv[1] if len(sys.argv) > 1 and sys.argv[1] in ("16x9", "4x5") else "16x9"
sys.argv = [sys.argv[0], fmt] + sys.argv[2:]
sys.path.insert(0, LONG)
import compose_long as C                      # sets W, H, S for this format
from shots_long import SHOTS
from PIL import Image, ImageDraw
G = C.G; GL = C.GL
W, H, S = C.W, C.H, C.S
FPS = 24; DUR = 30.0; NF = int(DUR * FPS)
SH = {s["id"]: s for s in SHOTS}
C.PIP.clear()                                 # no NASA photo cards in the 30 s cut: too fast to read

VO = "/Users/dankwawadie/Downloads/1114(2).MP3"
MUSIC = "/Users/dankwawadie/Downloads/1114(1).MP3"
# narration pieces: (source start, source end, film start).
VO_PIECES = [(0.00, 17.05, 2.00), (24.20, 26.90, 19.52), (31.95, 33.90, 22.51)]

# Gameplay video sources from the recorded game sessions
MOON_VIDEO = os.path.join(REPO_ROOT, "game", "videos", "moon-live-gameplay.mp4")
MARS_VIDEO = os.path.join(REPO_ROOT, "game", "videos", "mars-live-gameplay.mp4")
GAMEPLAY_DIR = os.path.join(HERE, "gameplay_cuts")
SHOW_BADGES = "--no-badges" not in sys.argv

# 4 distinct live gameplay scenes across 19.60s to 25.00s (5.40s = 130 frames at 24 fps)
GAME_CUTS = [
    {
        "id": "GAME_MOON",
        "name": "moon",
        "src": MOON_VIDEO,
        "ss": 1.80,
        "count": 34,
        "t0": 19.60,
        "t1": 21.00,
        "tag": ("THE MOON · APOLLO 11", "live gameplay in LAST SIGNAL")
    },
    {
        "id": "GAME_TRANSIT",
        "name": "transit",
        "src": MARS_VIDEO,
        "ss": 0.50,
        "count": 30,
        "t0": 21.00,
        "t1": 22.25,
        "tag": ("TRANSIT TO MARS", "live gameplay in LAST SIGNAL")
    },
    {
        "id": "GAME_MARS_WALK",
        "name": "mars_walk",
        "src": MARS_VIDEO,
        "ss": 5.80,
        "count": 32,
        "t0": 22.25,
        "t1": 23.60,
        "tag": ("MARS · MERIDIANI", "live gameplay in LAST SIGNAL")
    },
    {
        "id": "GAME_MARS_SCAN",
        "name": "mars_scan",
        "src": MARS_VIDEO,
        "ss": 12.20,
        "count": 34,
        "t0": 23.60,
        "t1": 25.00,
        "tag": ("OPPORTUNITY ROVER", "live gameplay in LAST SIGNAL")
    },
]
CUT_MAP = {c["id"]: c for c in GAME_CUTS}

def ensure_gameplay_frames():
    os.makedirs(GAMEPLAY_DIR, exist_ok=True)
    for cut in GAME_CUTS:
        prefix = cut["name"]
        existing = [f for f in os.listdir(GAMEPLAY_DIR) if f.startswith(prefix) and f.endswith(".jpg")]
        if len(existing) < cut["count"]:
            subprocess.run([
                "ffmpeg", "-y", "-v", "error",
                "-ss", str(cut["ss"]),
                "-i", cut["src"],
                "-frames:v", str(cut["count"]),
                os.path.join(GAMEPLAY_DIR, f"{prefix}_%03d.jpg")
            ], check=True)

# The edit: (film start, film end, shot id, first source frame, speed)
EDIT = [
    (0.00, 2.00, "S00", 0, 1.5),     # the solar system, sweeping in to Earth (music only)
    (2.00, 3.30, "S01", 20, 1.0),    # "We've always been explorers,"
    (3.30, 4.15, "S02", 8, 1.0),     # "every ocean,"
    (4.15, 5.00, "S03", 10, 1.0),    # "every desert."
    (5.00, 6.15, "S04", 40, 1.4),    # "Then we looked up."  (Giza, tilt up to the stars)
    (6.15, 7.60, "S10", 6, 1.6),     # "On the Moon, we left a landing stage,"  (cabin lifts off, stage stays)
    (7.60, 8.35, "S12", 60, 1.0),    # "a seismometer,"
    (8.35, 9.00, "S16a", 10, 1.0),   # "and a car."
    (9.00, 10.10, "S18a", 0, 1.4),   # "On Mars,"  (NASA photo, zoom to Meridiani)
    (10.10, 11.45, "S19", 60, 1.0),  # "Opportunity was built for ninety days."
    (11.45, 12.95, "S20", 20, 1.6),  # "It drove for fourteen years."  (the storm closes in)
    (12.95, 15.20, "S29", 24, 1.0),  # "And a mirror on the Moon still sends our lasers back."
    (15.20, 17.30, "S23", 40, 1.0),  # "Voyager 1 is still talking,"
    (17.30, 19.60, "S24", 173, 1.0),  # "from almost 26 billion kilometers away."  (light-day graphic)
    (19.60, 21.00, "GAME_MOON", 0, 1.0),      # "Dozens of machines,"  (Moon Apollo 11 gameplay)
    (21.00, 22.25, "GAME_TRANSIT", 0, 1.0),   # "*abandoned*, but *not forgotten*."  (Transit console & warp)
    (22.25, 23.60, "GAME_MARS_WALK", 0, 1.0), # (Mars surface run)
    (23.60, 25.00, "GAME_MARS_SCAN", 0, 1.0), # "Find them all in LAST SIGNAL, on Roblox."  (Opportunity scan)
    (25.00, 30.00, "S33", 0, 1.0),   # end card with QR
]
STRIP = ("tag", "counter", "pulse", "instruments", "fastforward")

def edit_at(t):
    for e in EDIT:
        if e[0] <= t < e[1]: return e
    return EDIT[-1]

def gameplay_frame(sid, t, t0, t1):
    cut = CUT_MAP[sid]
    k = int(round((t - t0) * FPS))
    k = max(0, min(cut["count"] - 1, k))
    path = os.path.join(GAMEPLAY_DIR, f"{cut['name']}_{k+1:03d}.jpg")
    src = Image.open(path).convert("RGB")
    im = C.game_fit(src).convert("RGBA")
    if SHOW_BADGES and cut.get("tag"):
        d = ImageDraw.Draw(im)
        title, sub = cut["tag"]
        f1 = G.font(int(26 * S), "heavy", cond=True)
        f2 = G.font(int(17 * S), "demi", cond=True)
        bx, by = int(48 * S), int(48 * S)
        d.text((bx, by), title, font=f1, fill=(245, 231, 60, 255), stroke_width=int(2 * S), stroke_fill=(0, 0, 0, 220))
        d.text((bx, by + int(32 * S)), sub, font=f2, fill=(220, 222, 226, 255), stroke_width=int(1.5 * S), stroke_fill=(0, 0, 0, 220))
    return im

def base(t):
    t0, t1, sid, k0, spd = edit_at(t)
    if sid.startswith("GAME_"):
        return gameplay_frame(sid, t, t0, t1)
    sh = dict(SH[sid])
    for k in STRIP: sh.pop(k, None)
    k = int(k0 + (t - t0) * FPS * spd)
    k = max(0, min(sh["n"] - 1, k))
    if sh["kind"] == "graphic":          # graphics animate on their own clock
        img = GL.GRAPHICS[sh["fn"]](W, H, k / FPS, sh["n"] / FPS) if sh["fn"] != "cta" else None
        if sh["fn"] == "cta":
            return G.end_screen(W, H, t - t0, C.URL, shot_still=C.keyart_bg(t - t0, t1 - t0)).convert("RGBA")
        return img.convert("RGBA")
    return C.base_frame(sh, k)

# ---- captions from the word timings of 1114(2).MP3, moved onto the film timeline
def captions():
    words = json.load(open(os.path.join(HERE, "words_1114_2.json")))
    def place(t):
        for a, b, f0 in VO_PIECES:
            if a - 0.15 <= t <= b + 0.15: return t - a + f0
        return None
    LINES = [   # (number of words, caption text)
        (4, "We've always been explorers,"),
        (4, "every ocean, every desert."),
        (4, "Then we looked up."),
        (8, "On the *Moon*, we left a landing stage,"),
        (5, "a seismometer, and a car."),
        (8, "On *Mars*, *Opportunity* was built for *ninety* days."),
        (5, "It drove for *fourteen* years."),
        (11, "And a *mirror* on the *Moon* still sends our lasers back."),
        (5, "*Voyager 1* is still talking,"),
        (6, "from almost 26 billion kilometers away."),
        (3, "Dozens of machines,"),
        (4, "*abandoned*, but *not forgotten*."),
        (8, "Find them all in *LAST SIGNAL* on Roblox."),
    ]
    assert sum(n for n, _ in LINES) == len(words), (sum(n for n, _ in LINES), len(words))
    out, i = [], 0
    for n, txt in LINES:
        out.append([place(words[i][1]), place(words[i + n - 1][2]), txt]); i += n
    for j in range(len(out) - 1):                 # hold each caption until the next starts
        if out[j + 1][0] - out[j][1] < 0.6: out[j][1] = out[j + 1][0]
    return out

CAPS = captions()
CAP_BOTTOM = int((70 if W > H else 120) * S)

def frame(i):
    t = i / FPS
    img = base(t)
    for c0, c1, txt in CAPS:
        if c0 <= t < c1: G.caption(img, txt, c0, t, CAP_BOTTOM)
    fade = min(1.0, t / 0.3, (DUR - t) / 0.8)
    if fade < 1: img = Image.blend(Image.new("RGBA", img.size, (0, 0, 0, 255)), img, max(0.0, fade))
    return img.convert("RGB")

def audio(out):
    fc = []
    for n, (a, b, f0) in enumerate(VO_PIECES):
        ms = int(f0 * 1000)
        fc.append(f"[0:a]atrim={a}:{b},asetpts=PTS-STARTPTS,afade=t=in:d=0.03,afade=t=out:st={b - a - 0.06:.2f}:d=0.06,adelay={ms}|{ms}[v{n}]")
    fc.append("[v0][v1][v2]amix=inputs=3:normalize=0,apad=whole_dur=30[vo]")
    fc.append("[vo]asplit=2[vo1][vokey]")
    fc.append(f"[1:a]atrim=0:{DUR},asetpts=PTS-STARTPTS,volume=0.55,afade=t=out:st={DUR - 2.0}:d=2.0[mus]")
    fc.append("[mus][vokey]sidechaincompress=threshold=0.03:ratio=8:attack=20:release=400[duck]")
    fc.append("[vo1][duck]amix=inputs=2:normalize=0,loudnorm=I=-16:TP=-1.5:LRA=11[a]")
    subprocess.run(["ffmpeg", "-y", "-v", "error", "-i", VO, "-i", MUSIC, "-filter_complex", ";".join(fc),
                    "-map", "[a]", "-t", f"{DUR}", "-ar", "48000", out], check=True)

def write(i):
    frame(i).save(os.path.join(HERE, f"frames30_{fmt}", f"f{i:04d}.jpg"), quality=92)

if __name__ == "__main__":
    ensure_gameplay_frames()
    if "--at" in sys.argv:
        os.makedirs(os.path.join(HERE, "preview"), exist_ok=True)
        for x in sys.argv[sys.argv.index("--at") + 1:]:
            t = float(x); frame(int(t * FPS)).save(os.path.join(HERE, "preview", f"{fmt}_{t:05.2f}.jpg"), quality=88)
        print("captions:", *[f"{a:.2f}-{b:.2f} {c}" for a, b, c in CAPS], sep="\n  "); sys.exit(0)
    out = os.path.join(HERE, f"frames30_{fmt}"); os.makedirs(out, exist_ok=True)
    from multiprocessing import Pool
    if "--only-ending" in sys.argv:
        # Only re-render gameplay frames 470 to 599
        print(f"Re-rendering gameplay ending frames 470..599 for {fmt}...")
        with Pool(6) as p: p.map(write, range(470, 600), chunksize=8)
    else:
        print(f"Rendering all {NF} frames for {fmt}...")
        with Pool(6) as p: p.map(write, range(NF), chunksize=8)
    wav = os.path.join(HERE, "audio30.wav")
    if not os.path.exists(wav) or "--audio" in sys.argv: audio(wav)
    mp4 = os.path.join(HERE, f"last_signal_30s_v4_{fmt}.mp4")
    subprocess.run(["ffmpeg", "-y", "-v", "error", "-framerate", str(FPS), "-i", os.path.join(out, "f%04d.jpg"), "-i", wav,
                    "-t", f"{DUR}", "-c:v", "libx264", "-crf", "18", "-preset", "slow", "-pix_fmt", "yuv420p",
                    "-c:a", "aac", "-b:a", "192k", "-movflags", "+faststart", mp4], check=True)
    print("wrote", mp4)

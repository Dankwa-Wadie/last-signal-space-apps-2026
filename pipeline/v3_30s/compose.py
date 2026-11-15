"""Assemble the v3 30-second cut, every frame in Python, then encode with the voiceover.

  python3 compose.py 16x9      -> last_signal_v3_16x9.mp4
  python3 compose.py 4x5       -> last_signal_v3_4x5.mp4
  python3 compose.py 16x9 260  -> just frame 260, saved as preview (for checking)

Captions are drawn here (not chained ffmpeg overlays, which silently dropped them in v2).
"""
import json, math, os, sys, subprocess
import numpy as np
from PIL import Image, ImageDraw, ImageFilter
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import graphics as G

HERE = os.path.dirname(os.path.abspath(__file__))
fmt = sys.argv[1] if len(sys.argv) > 1 else "16x9"
ONLY = int(sys.argv[2]) if len(sys.argv) > 2 else None
TL = json.load(open(os.path.join(HERE, "timeline.json")))
FPS = TL["fps"]; NF = int(round(TL["duration"] * FPS))
W, H = TL["formats"][fmt]["w"], TL["formats"][fmt]["h"]
S = G.scale_for(W, H)
URL = "https://www.roblox.com/games/104157966303180"
CAP_BOTTOM = int((70 if W > H else 120) * S)

shots = []
for sh in TL["shots"]:
    shots.append(dict(sh, f0=int(round(sh["start"] * FPS)), f1=int(round(sh["end"] * FPS))))
def shot_at(i):
    for sh in shots:
        if sh["f0"] <= i < sh["f1"]: return sh
    return shots[-1]

track = json.load(open(os.path.join(HERE, f"sat_track_{fmt}.json")))
COMP = TL["orbit"]["compression"]

# ------------------------------------------------------------------ sky
SKY = None
def sky_img():
    global SKY
    if SKY is None:
        SKY = np.asarray(Image.open(os.path.join(HERE, "sky_equirect.png")).convert("RGB")).astype(np.float32) / 255.0
    return SKY

_grid = {}
def ray_dirs(w, h, cam, yaw=0.0, pitch=0.0):
    """World directions through each pixel of a Roblox camera (vertical FOV)."""
    fov = math.radians(cam["fov"])
    if (w, h) not in _grid:
        xs = (np.arange(w) + 0.5) / w * 2 - 1
        ys = 1 - (np.arange(h) + 0.5) / h * 2
        _grid[(w, h)] = np.meshgrid(xs, ys)
    nx, ny = _grid[(w, h)]
    pos = np.array(cam["pos"], float); tgt = np.array(cam["tgt"], float)
    fwd = tgt - pos; fwd /= np.linalg.norm(fwd)
    right = np.cross(fwd, [0, 1, 0]); right /= np.linalg.norm(right)
    up = np.cross(right, fwd)
    t = math.tan(fov / 2); asp = w / h
    d = (fwd[None, None, :] + (nx * t * asp)[..., None] * right[None, None, :]
         + (ny * t)[..., None] * up[None, None, :])
    d /= np.linalg.norm(d, axis=2, keepdims=True)
    if yaw or pitch:   # rotate the sky so the Milky Way sits nicely in frame
        cy, sy, cp, sp = math.cos(yaw), math.sin(yaw), math.cos(pitch), math.sin(pitch)
        x, y, z = d[..., 0], d[..., 1], d[..., 2]
        x, z = cy * x + sy * z, -sy * x + cy * z
        y, z = cp * y - sp * z, sp * y + cp * z
        d = np.stack([x, y, z], -1)
    return d

def sample_equirect(d):
    sky = sky_img(); Hs, Ws = sky.shape[:2]
    u = (np.arctan2(d[..., 0], -d[..., 2]) / (2 * np.pi) + 0.5) * Ws - 0.5
    v = (0.5 - np.arcsin(np.clip(d[..., 1], -1, 1)) / np.pi) * Hs - 0.5
    x0 = np.floor(u).astype(int); y0 = np.floor(v).astype(int)
    fx = (u - x0)[..., None]; fy = (v - y0)[..., None]
    x0 %= Ws; x1 = (x0 + 1) % Ws
    y0 = np.clip(y0, 0, Hs - 1); y1 = np.clip(y0 + 1, 0, Hs - 1)
    return ((sky[y0, x0] * (1 - fx) + sky[y0, x1] * fx) * (1 - fy)
            + (sky[y1, x0] * (1 - fx) + sky[y1, x1] * fx) * fy)

def mars_sky(d, storm):
    """Martian daytime sky: butterscotch, paler at the horizon. Dims and flattens in the storm."""
    e = np.clip(np.arcsin(np.clip(d[..., 1], -1, 1)) / (math.pi / 2), 0, 1)[..., None]
    horizon = np.array([0.86, 0.72, 0.58]); zenith = np.array([0.60, 0.43, 0.31])
    clear = horizon * (1 - e ** 0.6) + zenith * (e ** 0.6)
    dusty = np.array([0.55, 0.38, 0.25]) * (1 - 0.15 * e)
    return (clear * (1 - storm) + dusty * storm) * (1 - 0.45 * storm)

SKY_ROT = {"retro": (math.radians(70), math.radians(-8)), "lander": (math.radians(160), math.radians(-12))}

def roblox_frame(sh, k):
    base = os.path.join(HERE, "roblox", sh["id"])
    cams = json.load(open(os.path.join(base, "camera.json")))
    cam = dict(cams["frames"][min(k, len(cams["frames"]) - 1)], fov=cams["fov"])
    bea = np.asarray(Image.open(os.path.join(base, "beauty", f"f{k:04d}.jpg")).convert("RGB")).astype(np.float32) / 255
    mat = np.asarray(Image.open(os.path.join(base, "matte", f"f{k:04d}.jpg")).convert("L")).astype(np.float32) / 255
    a = np.clip((mat - 0.28) / (0.75 - 0.28), 0, 1)[..., None]
    h, w = mat.shape
    if sh["id"] == "mars":
        storm = min(1.0, max(0.0, (k - 16) / 36.0))
        sky = mars_sky(ray_dirs(w, h, cam), storm)
    else:
        yaw, pitch = SKY_ROT.get(sh["id"], (0, 0))
        sky = sample_equirect(ray_dirs(w, h, cam, yaw, pitch)) * 1.05
    out = bea * a + sky * (1 - a)
    img = Image.fromarray(np.clip(out * 255, 0, 255).astype(np.uint8))
    return fit(img)

def fit(img):
    """Cover-crop to the output frame (centre), then scale."""
    iw, ih = img.size; tw, th = W, H
    if iw / ih > tw / th:
        nw = int(ih * tw / th); img = img.crop(((iw - nw) // 2, 0, (iw - nw) // 2 + nw, ih))
    else:
        nh = int(iw * th / tw); img = img.crop((0, (ih - nh) // 2, iw, (ih - nh) // 2 + nh))
    return img.resize((tw, th), Image.LANCZOS)

# ------------------------------------------------------------------ satellite trail
def draw_trail(img, f):
    """Comet trail behind Vanguard 1, from its exported screen positions."""
    pts = [track[j] for j in range(max(77, f - 16), f + 1) if j < len(track)]
    layer = Image.new("RGBA", img.size, (0, 0, 0, 0)); d = ImageDraw.Draw(layer)
    n = len(pts)
    for j in range(1, n):
        p0, p1 = pts[j - 1], pts[j]
        if p0["hidden"] or p1["hidden"]: continue
        u = j / n
        d.line([(p0["x"] * W, p0["y"] * H), (p1["x"] * W, p1["y"] * H)],
               fill=(255, 236, 150, int(230 * u ** 1.6)), width=max(2, int(6 * S * u)))
    glow = layer.filter(ImageFilter.GaussianBlur(4 * S))
    img.alpha_composite(glow); img.alpha_composite(layer)
    cur = track[f]
    if not cur["hidden"]:
        x, y = cur["x"] * W, cur["y"] * H
        r = 7 * S
        dot = Image.new("RGBA", img.size, (0, 0, 0, 0)); dd = ImageDraw.Draw(dot)
        dd.ellipse([x - r * 2.4, y - r * 2.4, x + r * 2.4, y + r * 2.4], fill=(255, 240, 170, 90))
        dd.ellipse([x - r, y - r, x + r, y + r], fill=(255, 252, 230, 255))
        img.alpha_composite(dot.filter(ImageFilter.GaussianBlur(1.2 * S)))
        lab = "VANGUARD 1"
        fnt = G.font(int(24 * S), "heavy", cond=True)
        ld = ImageDraw.Draw(img)
        ld.text((x + 16 * S, y - 34 * S), lab, font=fnt, fill=(245, 231, 60, 255),
                stroke_width=max(2, int(3 * S)), stroke_fill=(0, 0, 0, 220))

# ------------------------------------------------------------------ frame
def frame(i):
    t = i / FPS
    sh = shot_at(i); k = i - sh["f0"]; ts = k / FPS
    if sh["source"] == "blender":
        img = Image.open(os.path.join(HERE, f"frames_blender_{fmt}", f"f{i + 1:04d}.png")).convert("RGB")
        if img.size != (W, H): img = fit(img)
        img = img.convert("RGBA")
        if sh["id"] == "vanguard":
            draw_trail(img, i)
            tr = track[i]
            G.vanguard_panel(img, ts, tr["alt_km"], tr["speed"], COMP)
    elif sh["source"] == "roblox":
        img = roblox_frame(sh, k).convert("RGBA")
        if sh["id"] == "mars": G.opportunity_stamp(img, ts)
        if sh["id"] == "retro": G.laser_timer(img, ts, fire_at=29 / FPS)
    else:
        img = G.end_screen(W, H, ts, URL)
    for (c0, c1, txt) in TL["captions"]:
        if c0 <= t < c1:
            G.caption(img, txt, c0, t, CAP_BOTTOM)
    # fade from and to black
    fade = min(1.0, t / 0.4, (TL["duration"] - t) / 0.8)
    if fade < 1:
        img = Image.blend(Image.new("RGBA", img.size, (0, 0, 0, 255)), img, max(0.0, fade))
    return img.convert("RGB")

if ONLY is not None:
    frame(ONLY).save(os.path.join(HERE, f"preview_{fmt}_{ONLY:04d}.jpg"), quality=90)
    print("preview", ONLY); sys.exit(0)

out_dir = os.path.join(HERE, f"out_{fmt}"); os.makedirs(out_dir, exist_ok=True)
for i in range(NF):
    frame(i).save(os.path.join(out_dir, f"f{i:04d}.jpg"), quality=93)
    if i % 48 == 0: print(f"  {fmt} frame {i}/{NF}", flush=True)

mp4 = os.path.join(HERE, f"last_signal_v3_{fmt}.mp4")
vo = os.path.join(HERE, TL["voiceover"])
cmd = ["ffmpeg", "-y", "-v", "error", "-framerate", str(FPS), "-i", os.path.join(out_dir, "f%04d.jpg"),
       "-i", vo, "-t", str(TL["duration"]),
       "-c:v", "libx264", "-crf", "18", "-preset", "slow", "-pix_fmt", "yuv420p",
       "-c:a", "aac", "-b:a", "192k", "-af", f"afade=t=out:st={TL['duration'] - 0.8}:d=0.8",
       "-movflags", "+faststart", mp4]
subprocess.run(cmd, check=True)
print("wrote", mp4)

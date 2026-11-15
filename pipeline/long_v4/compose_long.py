"""Assemble the long film (185 s) frame by frame, then encode with voiceover_long.mp3.

  python3 compose_long.py 16x9                 -> last_signal_long_v4_16x9.mp4
  python3 compose_long.py 4x5                  -> last_signal_long_v4_4x5.mp4
  python3 compose_long.py 16x9 --at 12.5 60.0  -> preview stills at these times (seconds)
  python3 compose_long.py 16x9 --shots S05 S10 -> only these shots' frames (no encode)

Every Roblox shot with a space/night/mars sky is composited from a beauty and a matte
pass; the sky behind the matte is ray-traced per pixel from the logged camera.
"""
import json, math, os, sys, subprocess
from multiprocessing import Pool
import numpy as np
from PIL import Image, ImageDraw, ImageFilter

HERE = os.path.dirname(os.path.abspath(__file__))
V3 = os.path.join(HERE, "..", "v3_30s")
sys.path.insert(0, HERE); sys.path.insert(0, V3)
import graphics as G                     # v3: font, caption, laser_timer, end_screen
import graphics_long as GL
from shots_long import SHOTS, FPS

FORMATS = {"16x9": (1920, 1080), "4x5": (1080, 1350)}
fmt = sys.argv[1] if len(sys.argv) > 1 and sys.argv[1] in FORMATS else "16x9"
W, H = FORMATS[fmt]
S = G.scale_for(W, H)
CAP_BOTTOM = int((70 if W > H else 120) * S)
NF = SHOTS[-1]["f1"]; DUR = NF / FPS
from shots_long import PRE
CAPS = [[c0 + PRE, c1 + PRE, tx] for c0, c1, tx in json.load(open(os.path.join(HERE, "captions.json")))]
URL = "https://www.roblox.com/games/104157966303180"

# soft transitions (frames of cross-dissolve from the previous shot), everything else is a cut
XFADE = {"S18": 8, "S05": 12, "S14": 6, "S18": 10, "S22": 6, "S23": 10, "S24": 6, "S26": 10,
         "S27": 6, "S30": 6, "S31": 12, "S32": 8, "S05b": 6}
SKY_ROT = {"S05": (110, -6), "S06": (40, -10), "S08": (150, -4), "S09": (75, -8), "S10": (200, -10),
           "S11": (110, -6), "S12": (300, -6), "S13": (20, -4), "S15": (250, -12), "S16": (180, -8),
           "S17": (90, -6), "S23": (30, 20), "S25": (130, 10), "S26": (70, -8), "S29": (70, -8),
           "S04": (0, 0), "S31": (0, 0)}

def shot_at(i):
    for sh in SHOTS:
        if sh["f0"] <= i < sh["f1"]: return sh
    return SHOTS[-1]

# ------------------------------------------------------------------ sky
_SKY = None
def sky_img():
    global _SKY
    if _SKY is None:
        _SKY = np.asarray(Image.open(os.path.join(V3, "sky_equirect.png")).convert("RGB"))  # uint8, ~100 MB
    return _SKY

_grid = {}
def ray_dirs(w, h, cam):
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
    return d / np.linalg.norm(d, axis=2, keepdims=True)

def rot_yp(d, yaw, pitch):
    cy, sy = math.cos(math.radians(yaw)), math.sin(math.radians(yaw))
    cp, sp = math.cos(math.radians(pitch)), math.sin(math.radians(pitch))
    x, y, z = d[..., 0], d[..., 1], d[..., 2]
    x, z = cy * x + sy * z, -sy * x + cy * z
    y, z = cp * y - sp * z, sp * y + cp * z
    return np.stack([x, y, z], -1)

def rot_axis(d, axis, ang):
    """Rodrigues rotation of every direction in d about a unit axis."""
    k = np.asarray(axis, float); k = k / np.linalg.norm(k)
    c, s = math.cos(ang), math.sin(ang)
    kd = (d @ k)[..., None]
    return d * c + np.cross(k, d) * s + k * kd * (1 - c)

def sample_equirect(d):
    sky = sky_img(); Hs, Ws = sky.shape[:2]
    u = (np.arctan2(d[..., 0], -d[..., 2]) / (2 * np.pi) + 0.5) * Ws - 0.5
    v = (0.5 - np.arcsin(np.clip(d[..., 1], -1, 1)) / np.pi) * Hs - 0.5
    x0 = np.floor(u).astype(int); y0 = np.floor(v).astype(int)
    fx = (u - x0)[..., None]; fy = (v - y0)[..., None]
    x0 %= Ws; x1 = (x0 + 1) % Ws
    y0 = np.clip(y0, 0, Hs - 1); y1 = np.clip(y0 + 1, 0, Hs - 1)
    f = lambda a, b: sky[a, b].astype(np.float32) / 255.0
    return ((f(y0, x0) * (1 - fx) + f(y0, x1) * fx) * (1 - fy)
            + (f(y1, x0) * (1 - fx) + f(y1, x1) * fx) * fy)

def elev(d): return np.arcsin(np.clip(d[..., 1], -1, 1))

def mars_sky(d, storm):
    e = np.clip(elev(d) / (math.pi / 2), 0, 1)[..., None]
    horizon = np.array([0.86, 0.72, 0.58]); zenith = np.array([0.60, 0.43, 0.31])
    clear = horizon * (1 - e ** 0.6) + zenith * (e ** 0.6)
    dusty = np.array([0.55, 0.38, 0.25]) * (1 - 0.15 * e)
    return (clear * (1 - storm) + dusty * storm) * (1 - 0.45 * storm)

POLE = (0.10, 0.55, -0.83)          # S31: the sky turns about a pole sitting in frame
MOON = (-0.18, 0.62, -0.76)

_PSKY = None
def _pole_basis():
    z = np.array(POLE, float); z /= np.linalg.norm(z)
    x = np.cross([0.0, 1.0, 0.0], z); x /= np.linalg.norm(x); y = np.cross(z, x)
    return x, y, z

def pole_sky():
    """The sky resampled so POLE is its north pole: rotating about POLE = shifting longitude."""
    global _PSKY
    if _PSKY is None:
        cache = os.path.join(HERE, "sky_pole.npy")
        if os.path.exists(cache):
            _PSKY = np.load(cache)
        else:
            x, y, z = _pole_basis(); W2, H2 = 4096, 2048
            lon = (np.arange(W2) + 0.5) / W2 * 2 * np.pi - np.pi
            lat = np.pi / 2 - (np.arange(H2) + 0.5) / H2 * np.pi
            LON, LAT = np.meshgrid(lon, lat)
            dd = (np.cos(LAT) * np.cos(LON))[..., None] * x + (np.cos(LAT) * np.sin(LON))[..., None] * y + np.sin(LAT)[..., None] * z
            _PSKY = (sample_equirect(dd) * 255).astype(np.uint8)
            np.save(cache, _PSKY)
    return _PSKY

def pole_trails(d, theta, trail):
    from scipy.ndimage import maximum_filter1d
    P = pole_sky().astype(np.float32) / 255.0; H2, W2 = P.shape[:2]
    wpx = max(1, int(trail / (2 * np.pi) * W2))
    if wpx > 1:
        full = maximum_filter1d(P, size=wpx, axis=1, origin=-(wpx // 2) + (0 if wpx % 2 else 1) - 0, mode="wrap")
        half = maximum_filter1d(P, size=max(1, wpx // 3), axis=1, origin=-(max(1, wpx // 3) // 2), mode="wrap")
        P = np.maximum(np.maximum(full * 0.55, half * 0.8), P)
    x, y, z = _pole_basis()
    lat = np.arcsin(np.clip(d @ z, -1, 1)); lon = np.arctan2(d @ y, d @ x) - theta
    uu = ((lon + np.pi) / (2 * np.pi) % 1.0) * W2 - 0.5; vv = (np.pi / 2 - lat) / np.pi * H2 - 0.5
    x0 = np.floor(uu).astype(int); y0 = np.floor(vv).astype(int); fx = (uu - x0)[..., None]; fy = (vv - y0)[..., None]
    x0 %= W2; x1 = (x0 + 1) % W2; y0 = np.clip(y0, 0, H2 - 1); y1 = np.clip(y0 + 1, 0, H2 - 1)
    return (P[y0, x0] * (1 - fx) + P[y0, x1] * fx) * (1 - fy) + (P[y1, x0] * (1 - fx) + P[y1, x1] * fx) * fy

def night_sky(d, sh, ts):
    e = elev(d)[..., None]
    glow = np.array([0.035, 0.065, 0.13]) * np.exp(-np.clip(e, 0, None) / 0.11) + \
           np.array([0.012, 0.016, 0.03])
    if sh.get("fastforward"):
        dur = sh["n"] / FPS
        u = max(0.0, min(1.0, (ts - 0.4) / (dur - 0.4)))
        theta = 2 * math.pi * 1.6 * u * u            # accelerating: years pass faster and faster
        trail = min(theta, 1.1)
        stars = np.clip(pole_trails(d, theta, trail) * 1.35, 0, 1)
        mdir = rot_axis(np.array(MOON, float)[None, None, :] / np.linalg.norm(MOON), POLE, theta)[0, 0]
    else:
        stars = sample_equirect(d) * 0.95
        mdir = None
    sky = stars * np.clip(e * 6 + 0.25, 0.2, 1.0) + glow
    if mdir is not None:
        ang = np.arccos(np.clip(d @ mdir, -1, 1))[..., None]
        r = math.radians(1.1)                       # drawn ~4x real size so it reads on a phone
        disc = np.clip((r - ang) / (r * 0.08), 0, 1)
        halo = np.exp(-np.clip(ang - r, 0, None) / math.radians(2.5)) * 0.25
        sky = sky * (1 - disc) + np.array([0.93, 0.92, 0.86]) * disc + np.array([0.5, 0.55, 0.65]) * halo
    return sky

def devils(img_arr, d, cam, k):
    """S18: three dust devils drifting across the plain, as soft funnels ray-marched from the
    real camera (same world positions the old Roblox ball-stacks used)."""
    p = np.array(cam["pos"], float)
    dxz = d[..., [0, 2]]; n2 = np.maximum((dxz ** 2).sum(-1), 1e-9)
    tg = np.where(d[..., 1] < -1e-4, -p[1] / np.minimum(d[..., 1], -1e-4), 1e9)   # ground hit
    out = img_arr
    for j in (1, 2, 3):
        bx, bz = -90 + j * 55 + k * 0.18, -120 - j * 40
        t = ((bx - p[0]) * dxz[..., 0] + (bz - p[2]) * dxz[..., 1]) / n2
        y = p[1] + t * d[..., 1]
        sway = 7.0 * np.sin(y * 0.035 + k * 0.05 + j)
        cx = p[0] + t * dxz[..., 0] - (bx + sway); cz = p[2] + t * dxz[..., 1] - bz
        r = np.sqrt(cx * cx + cz * cz)
        rad = 3.0 + np.clip(y, 0, None) * 0.20
        prof = np.clip(y / 6, 0, 1) * np.clip(1 - y / 120, 0, 1) ** 0.8
        swirl = 0.82 + 0.18 * np.sin(y * 0.11 - k * 0.22 + j * 2.1)
        dens = 0.72 * np.exp(-(r / rad) ** 2) * prof * swirl * (t > 0) * (t < tg)
        col = np.array([0.60, 0.39, 0.26]) * (0.85 + 0.25 * np.clip(y / 150, 0, 1))[..., None]
        out = out * (1 - dens[..., None]) + col * dens[..., None]
    return out

_DUST = None
def dust_layer(w, h, k, storm):
    """Wind-blown dust: two noise layers scrolling sideways at different speeds."""
    global _DUST
    if _DUST is None:
        from scipy.ndimage import gaussian_filter
        rng = np.random.default_rng(2018)
        a = gaussian_filter(rng.standard_normal((512, 2048)), (10, 40), mode="wrap")
        b = gaussian_filter(rng.standard_normal((512, 2048)), (4, 18), mode="wrap")
        _DUST = [(x - x.min()) / (x.max() - x.min()) for x in (a, b)]
    out = np.zeros((h, w), np.float32)
    ys = (np.arange(h) * 512 // h)[:, None]
    for tex, spd, wt in ((_DUST[0], 9, 0.6), (_DUST[1], 22, 0.4)):
        xs = ((np.arange(w) * 2048 // w + k * spd) % 2048)[None, :]
        out += tex[ys, xs] * wt
    return np.clip((out - 0.35) * 1.8, 0, 1) * storm

def storm_level(sh, k):
    if sh.get("storm_hold"): return 1.0
    if sh.get("storm"): return min(1.0, max(0.0, (k - 16) / 70.0))
    return 0.0

CROP_X = {"S05": 0.40, "S33K": 0.50}                 # 4:5 crop centre (0..1) where the subject is off-centre
CROP_Y = {"S12": 0.40, "S33K": 0.45, "S05b": 0.40, "S06": 0.56}                 # 16:9 crop centre where heads would be cut
def fit(img, cx=0.5, cy=0.5):
    iw, ih = img.size
    if iw / ih > W / H:
        nw = int(ih * W / H); x0 = int(max(0, min(iw - nw, cx * iw - nw / 2)))
        img = img.crop((x0, 0, x0 + nw, ih))
    else:
        nh = int(iw * H / W); y0 = int(max(0, min(ih - nh, cy * ih - nh / 2)))
        img = img.crop((0, y0, iw, y0 + nh))
    return img.resize((W, H), Image.LANCZOS)

_cams = {}
def roblox_frame(sh, k, base=None, sky=None):
    base = base or os.path.join(HERE, "roblox", sh["id"])
    sky = sky or sh.get("sky")
    bp = os.path.join(base, "beauty", f"f{k:04d}.jpg")
    bea = np.asarray(Image.open(bp).convert("RGB")).astype(np.float32) / 255
    if sky not in ("space", "night", "mars"):
        return fit(Image.fromarray((bea * 255).astype(np.uint8)), CROP_X.get(sh["id"], 0.5), CROP_Y.get(sh["id"], 0.5))
    if base not in _cams: _cams[base] = json.load(open(os.path.join(base, "camera.json")))
    cams = _cams[base]
    cam = dict(cams["frames"][min(k, len(cams["frames"]) - 1)], fov=cams["fov"])
    mat = np.asarray(Image.open(os.path.join(base, "matte", f"f{k:04d}.jpg")).convert("L")).astype(np.float32) / 255
    a = np.clip((mat - 0.28) / (0.75 - 0.28), 0, 1)[..., None]
    h, w = mat.shape
    d = ray_dirs(w, h, cam)
    if sky == "mars":
        bg = mars_sky(d, storm_level(sh, k))
    else:
        yaw, pitch = SKY_ROT.get(sh["id"], (0, 0))
        dd = rot_yp(d, yaw, pitch) if (yaw or pitch) else d
        bg = night_sky(dd, sh, k / FPS) if sky == "night" else sample_equirect(dd) * 1.05
    if sh.get("id") in ("S15", "S16", "S17"):
        # the carved rille has no floor: below the horizon, gaps are deep shadowed regolith, not sky
        # (the real rille is ~1.5 km wide and up to ~400 m deep; its floor is mostly in shadow)
        e = elev(d)[..., None]
        below = np.clip((0.03 - e) / 0.05, 0, 1)
        floor = np.array([0.055, 0.053, 0.05]) * (0.8 + 0.4 * np.clip(-e * 3, 0, 1))
        bg = bg * (1 - below) + floor * below
    out = bea * a + bg * (1 - a)
    if sh.get("id") == "S18": out = devils(out, d, cam, k)
    if sky == "mars" and storm_level(sh, k) > 0:
        st = storm_level(sh, k)
        dl = dust_layer(w, h, k, st)[..., None] * 0.55
        out = out * (1 - dl) + np.array([0.42, 0.28, 0.19]) * dl
        hz = (np.exp(-np.abs(elev(d)) / 0.05) * st * 0.7)[..., None]     # no hard horizon in a storm
        out = out * (1 - hz) + mars_sky(d, st) * hz
    return fit(Image.fromarray(np.clip(out * 255, 0, 255).astype(np.uint8)), CROP_X.get(sh["id"], 0.5), CROP_Y.get(sh["id"], 0.5))


# ------------------------------------------------------------------ end card key art (S33)
_EARTH = None
def earth_sprite():
    """Earth disc cut from the Blender opening (frame 24), feathered at its limb."""
    global _EARTH
    if _EARTH is None:
        src = Image.open(os.path.join(V3, "frames_blender_16x9", "f0024.png")).convert("RGB")
        cx, cy, r = 960, 537, 394
        im = src.crop((cx - r, cy - r, cx + r, cy + r))
        yy, xx = np.mgrid[0:2 * r, 0:2 * r]
        dist = np.sqrt((xx - r + 0.5) ** 2 + (yy - r + 0.5) ** 2)
        a = np.clip((r - dist) / 6.0, 0, 1)
        im = im.convert("RGBA"); im.putalpha(Image.fromarray((a * 255).astype(np.uint8)))
        _EARTH = im
    return _EARTH

_KEYBG = None
def keyart_bg(ts, dur):
    """Tranquility Base today with Earth overhead: a slow push-in behind the title and QR."""
    global _KEYBG
    if _KEYBG is None:
        base = os.path.join(HERE, "roblox", "K33" if W > H else "K33v")
        sh = {"id": "S33K", "sky": "space"}
        _KEYBG = roblox_frame(sh, 0, base=base, sky="space")
        _KEYBG = _KEYBG.convert("RGBA")
        e = earth_sprite()
        er = int((0.07 if W > H else 0.045) * H)
        ex, ey = (int(0.80 * W), int(0.15 * H)) if W > H else (int(0.85 * W), int(0.47 * H))
        _KEYBG.alpha_composite(e.resize((2 * er, 2 * er), Image.LANCZOS), (ex - er, ey - er))
        # darken behind the words so the title and QR stay legible
        g = np.zeros((H, W), np.float32)
        if W > H:
            xs = np.linspace(0, 1, W)[None, :]
            g = np.clip(1 - xs / 0.62, 0, 1) ** 1.4 * 0.78 + 0 * g
        else:
            ys = np.linspace(0, 1, H)[:, None]
            g = np.clip(1 - ys / 0.42, 0, 1) ** 1.2 * 0.7 + 0 * g
        shade = Image.new("RGBA", (W, H), (3, 5, 10, 0))
        shade.putalpha(Image.fromarray((np.broadcast_to(g, (H, W)) * 255).astype(np.uint8)))
        _KEYBG.alpha_composite(shade)
    z = 1.0 + 0.06 * (ts / max(dur, 0.01))
    cw, ch = W / z, H / z
    return _KEYBG.crop((int((W - cw) / 2), int((H - ch) / 2), int((W + cw) / 2), int((H + ch) / 2))).resize((W, H), Image.LANCZOS)

# ------------------------------------------------------------------ gameplay (S32)
GAME_DIR = os.path.join(HERE, "game_caps")
def game_fit(src):
    """Gameplay stills keep their HUD: 16:9 crops from the top, 4:5 fits the full width on a blurred fill."""
    sc = min(W / src.width, H / src.height)
    sw, sh_ = int(src.width * sc), int(src.height * sc)
    fg = src.resize((sw, sh_), Image.LANCZOS)
    bgi = fit(src).filter(ImageFilter.GaussianBlur(28 * S))
    bgi = Image.blend(bgi, Image.new("RGB", bgi.size, (0, 0, 0)), 0.45)
    bgi.paste(fg, ((W - sw) // 2, int((H - sh_) * 0.42)))
    return bgi

def game_frame(sh, k):
    stills = sorted(f for f in os.listdir(GAME_DIR) if f.lower().endswith((".jpg", ".png"))) if os.path.isdir(GAME_DIR) else []
    if not stills:
        img = Image.new("RGBA", (W, H), (8, 10, 14, 255)); d = ImageDraw.Draw(img)
        f = G.font(int(60 * S), "heavy"); d.text((W / 2 - f.getlength("GAMEPLAY") / 2, H / 2), "GAMEPLAY", font=f, fill=(255, 255, 255, 255))
        return img
    # each still starts on its phrase: space suit / jump / scan the relics / logbook
    starts = [int(round(x * FPS)) for x in (0.0, 1.30, 2.48, 3.62)][:len(stills)] + [sh["n"]]
    j = max(i for i in range(len(stills)) if starts[i] <= k)
    def still(jj, kk):
        u = (kk - starts[jj]) / max(1, starts[jj + 1] - starts[jj])
        im = game_fit(Image.open(os.path.join(GAME_DIR, stills[jj])).convert("RGB"))
        z = 1.0 + 0.05 * u                          # slow push-in on each still
        cw, ch = W / z, H / z
        return im.crop((int((W - cw) / 2), int((H - ch) / 2), int((W + cw) / 2), int((H + ch) / 2))).resize((W, H), Image.LANCZOS).convert("RGBA")
    return still(j, k)                              # straight cuts: the cards' text can't crossfade


# ------------------------------------------------------------------ S00 solar system + NASA photo inserts
_SOLAR = {}
def solar_frame(k):
    tr = _SOLAR.get("tr")
    if tr is None:
        tr = _SOLAR["tr"] = json.load(open(os.path.join(HERE, f"solar_track_{fmt}.json")))
    img = Image.open(os.path.join(HERE, f"frames_solar_{fmt}", f"f{k + 1:04d}.png")).convert("RGBA")
    row = tr[min(k, len(tr) - 1)]
    layer = Image.new("RGBA", img.size, (0, 0, 0, 0)); d = ImageDraw.Draw(layer)
    u = k / 71.0
    # the Sun's glow (EEVEE has no bloom here)
    sx, sy, sz = row["SUN"]
    if sz > 0 and -0.2 < sx < 1.2 and -0.2 < sy < 1.2:
        g = Image.new("L", img.size, 0); gd = ImageDraw.Draw(g)
        cx, cy = sx * W, sy * H
        for r, a in ((260, 40), (150, 80), (70, 150)):
            rr = r * S * (1 - 0.6 * u); gd.ellipse([cx - rr, cy - rr, cx + rr, cy + rr], fill=a)
        g = g.filter(ImageFilter.GaussianBlur(60 * S))
        glow = Image.new("RGBA", img.size, (255, 214, 140, 0)); glow.putalpha(g)
        img.alpha_composite(glow)
    # planet names while the whole system is in view, then "EARTH" stays as we fall toward it
    f = G.font(int(28 * S), "heavy", cond=True)
    for name, (x, y, z) in row.items():
        if z <= 0 or not (0.02 < x < 0.98 and 0.04 < y < 0.96): continue
        if name == "EARTH":
            a = max(0.0, min(1.0, (0.78 - u) / 0.15))
        else:
            a = max(0.0, min(1.0, (0.42 - u) / 0.12))
        if a <= 0: continue
        px, py = x * W, y * H
        col = (143, 211, 255, int(230 * a)) if name != "EARTH" else (245, 231, 60, int(255 * a))
        if name != "SUN":
            r = 10 * S; d.ellipse([px - r, py - r, px + r, py + r], outline=col, width=max(2, int(3 * S)))
        d.text((px + 16 * S, py - 15 * S), name, font=f, fill=col, stroke_width=int(2 * S), stroke_fill=(0, 0, 0, int(200 * a)))
    img.alpha_composite(layer)
    a = max(0.0, min(1.0, (0.55 - u) / 0.2)) * min(1.0, k / 10)
    if a > 0:
        t1 = "OUR SOLAR SYSTEM"; ft = G.font(int(30 * S), "heavy", cond=True)
        ImageDraw.Draw(img).text(((W - ft.getlength(t1)) / 2, H * 0.86), t1, font=ft, fill=(246, 246, 240, int(230 * a)))
        t2 = "not to scale"; fs = G.font(int(18 * S), "medium")
        ImageDraw.Draw(img).text(((W - fs.getlength(t2)) / 2, H * 0.86 + 38 * S), t2, font=fs, fill=(154, 160, 166, int(220 * a)))
    return img

_PHOTO = {}
def photo(path):
    if path not in _PHOTO: _PHOTO[path] = Image.open(os.path.join(HERE, path)).convert("RGB")
    return _PHOTO[path]

def photozoom_frame(sh, k):
    """Push into a real NASA photo toward a target pixel, with a pin and a credit."""
    src = photo(sh["img"]); iw, ih = src.size
    u = k / max(1, sh["n"] - 1); e = u * u * (3 - 2 * u)
    tx, ty = sh["target"]
    z = 0.9 + 3.3 * e                        # zoom factor (starts with margin round the whole disc)
    # crop window: starts fitting the whole disc, ends centred on the target
    side = ih / z
    cx = iw / 2 + (tx - iw / 2) * e; cy = ih / 2 + (ty - ih / 2) * e
    asp = W / H
    cw, ch = (side * asp, side) if asp >= 1 else (side, side / asp)
    if asp < 1: cw, ch = side, side / asp
    box = (cx - cw / 2, cy - ch / 2, cx + cw / 2, cy + ch / 2)
    canvas = Image.new("RGB", (int(cw) + 2, int(ch) + 2), (0, 0, 0))
    ox, oy = -box[0], -box[1]
    canvas.paste(src, (int(round(ox)), int(round(oy))))
    img = canvas.resize((W, H), Image.LANCZOS).convert("RGBA")
    d = ImageDraw.Draw(img)
    px = (tx - box[0]) / cw * W; py = (ty - box[1]) / ch * H
    a = max(0.0, min(1.0, (u - 0.25) / 0.2))
    if a > 0:
        rr = (26 + 10 * math.sin(k * 0.5)) * S
        d.ellipse([px - rr, py - rr, px + rr, py + rr], outline=(245, 231, 60, int(255 * a)), width=max(2, int(3 * S)))
        d.ellipse([px - 5 * S, py - 5 * S, px + 5 * S, py + 5 * S], fill=(245, 231, 60, int(255 * a)))
        fb = G.font(int(30 * S), "heavy", cond=True); fs = G.font(int(20 * S), "medium")
        lw = max(fb.getlength(sh["label"][0]), fs.getlength(sh["label"][1]))
        lx = px - lw - 44 * S if px > W * 0.55 else px + 44 * S
        d.text((lx, py - 32 * S), sh["label"][0], font=fb, fill=(245, 231, 60, int(255 * a)), stroke_width=int(2 * S), stroke_fill=(0, 0, 0, 200))
        d.text((lx, py + 4 * S), sh["label"][1], font=fs, fill=(246, 246, 240, int(255 * a)), stroke_width=int(2 * S), stroke_fill=(0, 0, 0, 200))
    nasa_badge(img, sh["credit"], 1.0)
    return img

def nasa_badge(img, text, a):
    fs = G.font(int(17 * S), "demi", cond=True)
    d = ImageDraw.Draw(img)
    x, y = W - 40 * S - fs.getlength(text), H - (150 if W > H else 220) * S
    d.rounded_rectangle([x - 12 * S, y - 6 * S, x + fs.getlength(text) + 12 * S, y + 26 * S], radius=int(8 * S), fill=(6, 10, 16, int(170 * a)))
    d.text((x, y), text, font=fs, fill=(246, 246, 240, int(235 * a)))

# real NASA photographs shown beside the recreation they were modelled on
PIP = {
  "S06":  ("refs/as16-106-17340.jpg", "NASA PHOTO · AS16-106-17340", "collecting samples with tongs (Apollo 16)"),
  "S10a": ("refs/as11-40-5868.jpg",   "NASA PHOTO · AS11-40-5868",   "Buzz Aldrin on the Eagle's ladder"),
  "S10":  ("refs/S72-55421.jpg",      "NASA PHOTO · S72-55421",      "Apollo 17 liftoff, seen by the rover's TV camera"),
  "S15":  ("refs/as15-85-11425.jpg",  "NASA PHOTO · AS15-85-11425",  "the real Hadley Rille"),
  "S16a": ("refs/as15-88-11901.jpg",  "NASA PHOTO · AS15-88-11901",  "Apollo 15's rover at Hadley"),
  "S18":  ("refs/PIA06754.jpg",       "NASA/JPL PHOTO · PIA06754",   "dunes in Endurance Crater, seen by Opportunity"),
}
def pip_card(img, sh, ts, dur):
    spec = PIP.get(sh["id"])
    if not spec: return
    a = max(0.0, min(1.0, (ts - 0.35) / 0.35)) * max(0.0, min(1.0, (dur - ts) / 0.3))
    if a <= 0: return
    ph = photo(spec[0])
    cw = int((0.24 if W > H else 0.30) * W)
    chh = int(cw * ph.height / ph.width)
    chh = min(chh, int((0.34 if W > H else 0.22) * H)); cw2 = int(chh * ph.width / ph.height)
    thumb = ph.resize((cw2, chh), Image.LANCZOS).convert("RGBA")
    pad = int(8 * S); lab_h = int(52 * S)
    card = Image.new("RGBA", (cw2 + 2 * pad, chh + 2 * pad + lab_h), (8, 10, 14, 235))
    card.paste(thumb, (pad, pad))
    cd = ImageDraw.Draw(card)
    cd.text((pad, chh + pad + 6 * S), spec[1], font=G.font(int(17 * S), "heavy", cond=True), fill=(245, 231, 60, 255))
    cd.text((pad, chh + pad + 27 * S), spec[2], font=G.font(int(16 * S), "medium"), fill=(220, 222, 226, 255))
    card.putalpha(card.split()[3].point(lambda v: int(v * a)))
    x = W - card.width - int(40 * S)
    if W > H:
        y = int(0.24 * H)
        if sh["id"] in ("S10a",): x = int(40 * S)        # subject on the right in this shot
    else:               # 4:5: sit on the ground just above the subtitles, clear of the subject
        y = H - int(300 * S) - card.height
    img.alpha_composite(card, (x, y))

# ------------------------------------------------------------------ one frame
def base_frame(sh, k):
    ts = k / FPS; dur = sh["n"] / FPS
    kind = sh["kind"]
    if kind == "solar":
        return solar_frame(k)
    if kind == "photozoom":
        return photozoom_frame(sh, k)
    if kind == "blender":
        p = os.path.join(V3, f"frames_blender_{fmt}", f"f{k + 1:04d}.png")
        img = Image.open(p).convert("RGB")
        if img.size != (W, H): img = fit(img)
        return img.convert("RGBA")
    if kind == "roblox":
        img = roblox_frame(sh, k).convert("RGBA")
        if sh["id"] == "S13" and ts > 2.9:          # the ground shakes after the impact arrives
            q = ts - 2.9; amp = 7 * S * min(1, q / 0.5) * math.exp(-q / 2.5)
            dx = int(amp * math.sin(q * 47)); dy = int(amp * 0.6 * math.sin(q * 39 + 1))
            img = img.transform(img.size, Image.AFFINE, (1 / 1.03, 0, W * (1 - 1 / 1.03) / 2 + dx, 0, 1 / 1.03, H * (1 - 1 / 1.03) / 2 + dy), Image.BILINEAR)
        if sh.get("tag"): GL.tag(img, ts, sh["tag"][0], sh["tag"][1], dur)
        if sh.get("counter") == "lrv_years": GL.counter_years(img, ts, dur)
        if sh.get("counter") == "sols": GL.counter_sols(img, ts, dur)
        if sh.get("pulse"): GL.pulse(img, ts, dur)
        if sh.get("instruments"): GL.instruments(img, ts, dur)
        if sh.get("fastforward"): GL.year_ff(img, ts, dur)
        if sh["id"] == "S13":
            GL.seis_live(img, ts, dur)
        pip_card(img, sh, ts, dur)
        return img
    if kind == "reuse":
        src = os.path.normpath(os.path.join(HERE, sh["src"]))
        navail = len(os.listdir(os.path.join(src, "beauty")))
        img = roblox_frame(sh, min(k, navail - 1), base=src, sky=sh.get("sky")).convert("RGBA")
        G.laser_timer(img, ts, fire_at=sh["timer_fire"] / FPS)
        return img
    if kind == "proc":
        import bootprint
        return bootprint.frame(W, H, ts, dur)
    if kind == "game":
        return game_frame(sh, k)
    if sh["fn"] == "cta" and os.path.isdir(os.path.join(HERE, "roblox", "K33")):
        return G.end_screen(W, H, ts, URL, shot_still=keyart_bg(ts, dur)).convert("RGBA")
    img = GL.GRAPHICS[sh["fn"]](W, H, ts, dur)
    return img.convert("RGBA")

def frame(i):
    t = i / FPS
    sh = shot_at(i); k = i - sh["f0"]
    img = base_frame(sh, k)
    xf = XFADE.get(sh["id"], 0)
    if xf and k < xf:
        idx = SHOTS.index(sh)
        if idx > 0:
            pv = SHOTS[idx - 1]
            prev = base_frame(pv, pv["n"] - 1)
            u = (k + 1) / (xf + 1); u = u * u * (3 - 2 * u)
            img = Image.blend(prev, img, u)
    for (c0, c1, txt) in CAPS:
        if c0 <= t < c1:
            G.caption(img, txt, c0, t, CAP_BOTTOM)
    fade = min(1.0, t / 0.5, (DUR - t) / 1.0)
    if fade < 1:
        img = Image.blend(Image.new("RGBA", img.size, (0, 0, 0, 255)), img, max(0.0, fade))
    return img.convert("RGB")

OUT = os.path.join(HERE, f"out_{fmt}")
def write(i):
    p = os.path.join(OUT, f"f{i:05d}.jpg")
    if os.path.exists(p) and "--force" not in sys.argv: return
    frame(i).save(p, quality=92)

if __name__ == "__main__":
    if "--at" in sys.argv:
        ts = [float(x) for x in sys.argv[sys.argv.index("--at") + 1:] if not x.startswith("--")]
        os.makedirs(os.path.join(HERE, "preview"), exist_ok=True)
        for t in ts:
            i = min(NF - 1, int(round(t * FPS)))
            frame(i).save(os.path.join(HERE, "preview", f"{fmt}_{t:07.2f}.jpg"), quality=88)
            print("preview", fmt, t, shot_at(i)["id"])
        sys.exit(0)
    os.makedirs(OUT, exist_ok=True)
    idx = list(range(NF))
    if "--shots" in sys.argv:
        want = set(a for a in sys.argv if a.startswith("S"))
        idx = [i for i in idx if shot_at(i)["id"] in want]
    with Pool(int(os.environ.get("POOL", "6"))) as pool:
        for n, _ in enumerate(pool.imap(write, idx, chunksize=8)):
            if n % 240 == 0: print(f"  {fmt} {n}/{len(idx)}", flush=True)
    if "--shots" in sys.argv: sys.exit(0)
    mp4 = os.path.join(HERE, f"last_signal_long_v4_{fmt}.mp4")
    vo = os.path.join(HERE, "..", "voiceover_long.mp3")
    pad = os.path.join(HERE, "intro_pad.wav")
    ms = int(PRE * 1000)
    fc = (f"[1:a]adelay={ms}|{ms},aresample=48000[v];[2:a]volume=0.55,aresample=48000[p];"
          f"[v][p]amix=inputs=2:duration=longest:normalize=0,afade=t=out:st={DUR - 1.0:.3f}:d=1.0[a]")
    subprocess.run(["ffmpeg", "-y", "-v", "error", "-framerate", str(FPS), "-i", os.path.join(OUT, "f%05d.jpg"),
                    "-i", vo, "-i", pad, "-filter_complex", fc, "-map", "0:v", "-map", "[a]", "-t", f"{DUR:.3f}",
                    "-c:v", "libx264", "-crf", "18", "-preset", "slow", "-pix_fmt", "yuv420p",
                    "-c:a", "aac", "-b:a", "192k", "-movflags", "+faststart", mp4], check=True)
    print("wrote", mp4)

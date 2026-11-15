"""Generate one equirectangular all-sky starfield used by every shot.

Equirect convention used by compose.py (Roblox axes, Y up):
  lon = atan2(dir.x, -dir.z)   -> u = lon/(2*pi) + 0.5
  lat = asin(dir.y)            -> v = 0.5 - lat/pi
Run: python3 starfield.py   -> sky_equirect.png (8192x4096)
"""
import numpy as np
from PIL import Image

W, H = 8192, 4096
rng = np.random.default_rng(1969)

# Galactic plane: the Milky Way band is the great circle perpendicular to this.
GAL_N = np.array([0.42, 0.62, 0.66]); GAL_N /= np.linalg.norm(GAL_N)

def dirs_from_uv(u, v):
    lon = (u - 0.5) * 2 * np.pi
    lat = (0.5 - v) * np.pi
    x = np.cos(lat) * np.sin(lon)
    y = np.sin(lat)
    z = -np.cos(lat) * np.cos(lon)
    return x, y, z

# ---------------------------------------------------------------- Milky Way
# Built at quarter resolution (it's soft), then upscaled.
w4, h4 = W // 4, H // 4
uu, vv = np.meshgrid((np.arange(w4) + 0.5) / w4, (np.arange(h4) + 0.5) / h4)
x, y, z = dirs_from_uv(uu, vv)
b = np.arcsin(np.clip(x * GAL_N[0] + y * GAL_N[1] + z * GAL_N[2], -1, 1))  # galactic latitude

_PERM = np.random.default_rng(42).permutation(512).astype(np.int64)
_VAL = np.random.default_rng(43).random(512).astype(np.float32)

def lattice3(px, py, pz):
    """Classic 3-D value noise: random values on an integer lattice, smoothly interpolated."""
    xi, yi, zi = np.floor(px).astype(np.int64), np.floor(py).astype(np.int64), np.floor(pz).astype(np.int64)
    fx, fy, fz = px - xi, py - yi, pz - zi
    sx, sy, sz = fx * fx * (3 - 2 * fx), fy * fy * (3 - 2 * fy), fz * fz * (3 - 2 * fz)
    def h(a, b, c):
        return _VAL[_PERM[(_PERM[(_PERM[a & 511] + b) & 511] + c) & 511]]
    n000, n100 = h(xi, yi, zi), h(xi + 1, yi, zi)
    n010, n110 = h(xi, yi + 1, zi), h(xi + 1, yi + 1, zi)
    n001, n101 = h(xi, yi, zi + 1), h(xi + 1, yi, zi + 1)
    n011, n111 = h(xi, yi + 1, zi + 1), h(xi + 1, yi + 1, zi + 1)
    x00 = n000 + sx * (n100 - n000); x10 = n010 + sx * (n110 - n010)
    x01 = n001 + sx * (n101 - n001); x11 = n011 + sx * (n111 - n011)
    y0 = x00 + sy * (x10 - x00); y1 = x01 + sy * (x11 - x01)
    return (y0 + sz * (y1 - y0)) * 2 - 1          # -1..1

def fbm(px, py, pz, base, seed, octaves=6):
    off = np.random.default_rng(seed).uniform(0, 100, 3)
    out = np.zeros_like(px); amp = 1.0; tot = 0.0; f = base
    for _ in range(octaves):
        out += amp * lattice3(px * f + off[0], py * f + off[1], pz * f + off[2])
        tot += amp; amp *= 0.52; f *= 2.03
    return out / tot

band = np.exp(-(b / 0.16) ** 2) + 0.35 * np.exp(-(b / 0.42) ** 2)   # bright core + wide faint wing
# star clouds: high-contrast multi-scale noise so the band has texture
clumps = np.clip(0.5 + 1.1 * fbm(x, y, z, 3.2, 11), 0, 1) ** 1.8
# dust lanes: ridged noise makes thin dark filaments down the middle
ridge = 1 - np.abs(fbm(x, y, z, 4.5, 37))
lanes = 1 - 0.88 * np.clip((ridge - 0.62) / 0.30, 0, 1) * np.exp(-(b / 0.09) ** 2)
mw = band * (0.10 + 0.90 * clumps) * lanes
# brighter galactic core in one direction along the band
core_dir = np.cross(GAL_N, [0, 1, 0]); core_dir /= np.linalg.norm(core_dir)
core = np.exp(-((x - core_dir[0]) ** 2 + (y - core_dir[1]) ** 2 + (z - core_dir[2]) ** 2) / 0.35)
mw *= 0.55 + 0.9 * core
mw_rgb = np.stack([mw * (0.78 + 0.22 * core), mw * 0.82, mw * (0.95 - 0.15 * core)], -1) * 0.62
mw_img = Image.fromarray(np.clip(mw_rgb * 255, 0, 255).astype(np.uint8)).resize((W, H), Image.BICUBIC)
sky = np.asarray(mw_img).astype(np.float32) / 255.0

# ---------------------------------------------------------------- stars
N = 52000
# uniform on the sphere, then extra stars thrown at the galactic plane
d = rng.normal(size=(N, 3)); d /= np.linalg.norm(d, axis=1, keepdims=True)
extra = rng.normal(size=(N // 2, 3)); extra /= np.linalg.norm(extra, axis=1, keepdims=True)
eb = extra @ GAL_N
keep = rng.random(len(extra)) < 2.2 * np.exp(-(eb / 0.20) ** 2)
d = np.vstack([d, extra[keep]])
n = len(d)
lon = np.arctan2(d[:, 0], -d[:, 2]); lat = np.arcsin(d[:, 1])
px = (lon / (2 * np.pi) + 0.5) * W
py = (0.5 - lat / np.pi) * H
# brightness: steep power law, so the sky is mostly faint pinpoints
mag = rng.pareto(2.1, n) + 1.0
lum = np.clip(0.16 * mag ** 1.45, 0, 4.0)
# colour temperature from blue-white to warm orange
t = rng.beta(2.2, 2.0, n)
col = np.stack([0.80 + 0.30 * t, 0.86 + 0.08 * (1 - abs(t - 0.5)), 1.05 - 0.40 * t], 1)

img = sky.copy()
x0 = np.floor(px).astype(int); y0 = np.floor(py).astype(int)
fx = px - x0; fy = py - y0
for dx, dy, wgt in ((0, 0, (1 - fx) * (1 - fy)), (1, 0, fx * (1 - fy)),
                    (0, 1, (1 - fx) * fy), (1, 1, fx * fy)):
    xi = (x0 + dx) % W; yi = np.clip(y0 + dy, 0, H - 1)
    for c in range(3):
        np.add.at(img[:, :, c], (yi, xi), lum * wgt * col[:, c])

# a soft halo only around the brightest few hundred stars
bright = np.argsort(lum)[-420:]
halo = np.zeros((H, W, 3), np.float32)
for i in bright:
    cx, cy = int(px[i]), int(py[i]); r = 3
    ys = slice(max(0, cy - r), min(H, cy + r + 1)); xs = slice(max(0, cx - r), min(W, cx + r + 1))
    gy, gx = np.mgrid[ys, xs]
    g = np.exp(-((gx - px[i]) ** 2 + (gy - py[i]) ** 2) / 2.2)[..., None]
    halo[ys, xs] += g * lum[i] * 0.10 * col[i]
img += halo

out = np.clip(img, 0, 1) ** (1 / 1.15)
Image.fromarray((out * 255).astype(np.uint8)).save("sky_equirect.png", optimize=True)
print(f"sky_equirect.png {W}x{H}, {n} stars")

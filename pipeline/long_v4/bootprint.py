"""S07: a bootprint in lunar dust, as a shaded height field (after the famous Apollo 11
print, photo AS11-40-5878). The Apollo boot sole had straight ribs across it.
Built once (cached), then each frame is a slow push-in and drift with a low sun."""
import math, os
import numpy as np
from scipy.ndimage import gaussian_filter, map_coordinates
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
N = 2048
_H = None

def heightmap():
    global _H
    if _H is not None: return _H
    cache = os.path.join(HERE, "bootprint_h.npy")
    if os.path.exists(cache):
        _H = np.load(cache); return _H
    rng = np.random.default_rng(1969)
    h = np.zeros((N, N), np.float32)
    for sig, amp in ((110, 16.0), (35, 5.0), (10, 1.5), (3.5, 0.55), (1.3, 0.28)):
        g = gaussian_filter(rng.standard_normal((N, N)).astype(np.float32), sig)
        h += g / g.std() * amp
    # small pebbles and pits
    yy, xx = np.mgrid[0:N, 0:N].astype(np.float32)
    for _ in range(420):
        cx, cy = rng.uniform(0, N, 2); r = rng.uniform(2, 10) * (1 + 2.5 * rng.random() ** 6)
        d2 = ((xx - cx) ** 2 + (yy - cy) ** 2) / (r * r)
        m = d2 < 4
        h[m] += (np.exp(-d2[m] * 1.6) * r * (0.9 if rng.random() < 0.6 else -0.6)).astype(np.float32)
    # the sole: rounded rectangle, slightly narrower at the heel, toe up-frame
    cx, cy = N * 0.5, N * 0.5
    L, Wd = N * 0.30, N * 0.115
    u = (yy - cy) / L                        # -1 toe .. +1 heel
    # boot outline: broad toe, waist at the arch, rounded heel
    halfw = Wd * (1.0 - 0.17 * np.exp(-((u - 0.25) / 0.28) ** 2) - 0.06 * np.clip(u, 0, 1))
    v = (xx - cx) / halfw
    p = 6.0
    sdf = (np.abs(u) ** p + np.abs(v) ** p) ** (1 / p) - 1.0     # <0 inside
    inside = 1.0 / (1.0 + np.exp(np.clip(sdf * 40, -60, 60)))                       # soft wall
    depth = 22.0
    rim = np.exp(-np.clip(sdf, 0, None) * 9) * (sdf > 0) * 7.0     # dust squeezed out
    # straight ribs across the sole (the Apollo tread pattern)
    rib_period = L * 2 / 17
    rib = 0.5 + 0.5 * np.cos((yy - cy) / rib_period * 2 * math.pi)
    rib = np.clip((rib - 0.3) / 0.4, 0, 1) * 4.5
    h = h * (1 - 0.6 * inside) - inside * depth + inside * rib + rim   # compacted floor is smoother
    # crisp compacted walls, smoothed just a little
    h = gaussian_filter(h, 1.1)
    _H = h.astype(np.float32); np.save(cache, _H)
    return _H

def shade(h, sun_az, sun_el):
    gy, gx = np.gradient(h)
    n = np.stack([-gx, -gy, np.ones_like(h) * 2.2], -1)
    n /= np.linalg.norm(n, axis=-1, keepdims=True)
    L = np.array([math.cos(sun_el) * math.cos(sun_az), math.cos(sun_el) * math.sin(sun_az), math.sin(sun_el)])
    lam = np.clip(n @ L, 0, None)
    # cast shadow: march toward the sun a few steps
    sh = np.ones_like(h)
    dx, dy = math.cos(sun_az), math.sin(sun_az); slope = math.tan(sun_el)
    yy, xx = np.mgrid[0:h.shape[0], 0:h.shape[1]].astype(np.float32)
    for st in (3, 7, 13, 21, 32, 46):
        hs = map_coordinates(h, [yy + dy * st, xx + dx * st], order=1, mode="nearest")
        sh = np.minimum(sh, np.clip(1 - (hs - h - st * slope) * 0.25, 0, 1))
    return lam * sh

def frame(W, H, t, dur):
    h = heightmap()
    u = t / dur; e = u * u * (3 - 2 * u)
    zoom = 1.0 + 0.28 * e                       # slow push-in
    ang = math.radians(-8 + 6 * e)              # gentle rotation
    side = N * (0.76 if W > H else 0.72) / zoom
    sc = side / H
    cxs, cys = N * 0.5 + 30 * e, N * 0.52 - 20 * e
    ys, xs = np.mgrid[0:H, 0:W].astype(np.float32)
    px = (xs - W / 2) * sc; py = (ys - H / 2) * sc
    # mild perspective: the top of frame is farther away
    persp = 1.0 + 0.18 * (py / (side / 2)) * 0 + 0.12 * (py * sc / side)
    px *= persp
    rx = math.cos(ang) * px - math.sin(ang) * py + cxs
    ry = math.sin(ang) * px + math.cos(ang) * py + cys
    hh = map_coordinates(h, [ry, rx], order=1, mode="reflect")
    # shade at output res from the warped field (gradients in output pixels, rescaled)
    li = shade(hh / sc, math.radians(200), math.radians(14))
    base = np.array([0.60, 0.59, 0.56])
    img = base * np.clip(0.05 + 0.80 * li[..., None] / math.sin(math.radians(14)), 0, 1.6)
    img = img ** (1 / 1.1)
    # vignette
    vg = 1 - 0.35 * (((xs - W / 2) / W) ** 2 + ((ys - H / 2) / H) ** 2) * 2
    img *= vg[..., None]
    return Image.fromarray(np.clip(img * 255, 0, 255).astype(np.uint8)).convert("RGBA")

if __name__ == "__main__":
    frame(1920, 1080, 1.3, 2.6).convert("RGB").save(os.path.join(HERE, "preview", "boot.jpg"), quality=88)
    frame(1080, 1350, 1.3, 2.6).convert("RGB").save(os.path.join(HERE, "preview", "boot45.jpg"), quality=88)

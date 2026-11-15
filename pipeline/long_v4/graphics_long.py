"""Motion graphics for the long film. Every number on screen is either quoted from a
checked source (see README) or computed from one. Each full-screen graphic is a function
g_<name>(W, H, t, dur) -> RGBA image; overlays draw onto an existing frame."""
import math, os, sys, random
from PIL import Image, ImageDraw, ImageFilter
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "v3_30s"))
import graphics as G
from graphics import font, scale_for, WHITE, YELLOW, CYAN, DIM, RED

GREEN = (90, 255, 130, 255)
EARTHB = (70, 140, 230, 255)
MARSR = (214, 110, 70, 255)
MOONG = (196, 196, 190, 255)

def ease(u): u = max(0.0, min(1.0, u)); return u * u * u * (u * (u * 6 - 15) + 10)
def fin(t, t0, d=0.4): return max(0.0, min(1.0, (t - t0) / d))
def a255(c, a): return (c[0], c[1], c[2], int(c[3] * max(0.0, min(1.0, a))))

def bg(W, H, t):
    """Deep-space backdrop with the same star look as the rendered sky."""
    return _stars_bg(W, H, t)

_bgcache = {}
def _stars_bg(W, H, t):
    if (W, H) not in _bgcache:
        img = Image.new("RGBA", (W, H), (5, 7, 13, 255)); d = ImageDraw.Draw(img)
        rng = random.Random(11)
        for _ in range(int(W * H / 1400)):
            x, y, b = rng.random() * W, rng.random() * H, rng.random() ** 3
            v = int(60 + 190 * b); r = 0.6 + b * 1.6 * scale_for(W, H)
            d.ellipse([x - r, y - r, x + r, y + r], fill=(v, v, min(255, v + 12), 255))
        g = Image.new("L", (W, H), 0); gd = ImageDraw.Draw(g)
        for r in range(int(max(W, H) * 0.8), 0, -16):
            gd.ellipse([W * 0.5 - r, H * 0.45 - r, W * 0.5 + r, H * 0.45 + r], fill=int(36 * (1 - r / (max(W, H) * 0.8))))
        glow = Image.new("RGBA", (W, H), (40, 64, 120, 0)); glow.putalpha(g.filter(ImageFilter.GaussianBlur(50)))
        img.alpha_composite(glow)
        _bgcache[(W, H)] = img
    return _bgcache[(W, H)].copy()

def title(img, t, big, small=None, y=None, t0=0.15):
    W, H = img.size; s = scale_for(W, H); d = ImageDraw.Draw(img)
    a = ease(fin(t, t0, 0.5))
    fb = font(int(46 * s), "heavy"); fs = font(int(24 * s), "demi", cond=True)
    y = int(H * 0.08) if y is None else y
    if small:
        d.text(((W - fs.getlength(small)) / 2, y), small, font=fs, fill=a255(CYAN, a))
        y += int(36 * s)
    d.text(((W - fb.getlength(big)) / 2, y + (1 - a) * 14 * s), big, font=fb, fill=a255(WHITE, a))

def body(W, H):
    """Layout box for diagrams: wide = full width band, tall = middle band."""
    if W > H: return int(W * 0.08), int(H * 0.24), int(W * 0.92), int(H * 0.80)
    return int(W * 0.07), int(H * 0.22), int(W * 0.93), int(H * 0.74)

def planet(d, cx, cy, r, col, label=None, s=1.0, lab_below=True):
    for k in range(6, 0, -1):
        rr = r * (1 + k * 0.12)
        d.ellipse([cx - rr, cy - rr, cx + rr, cy + rr], fill=(col[0], col[1], col[2], int(14 * k)))
    d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=col)
    d.ellipse([cx - r * 0.55, cy - r * 0.7, cx + r * 0.15, cy - r * 0.15], fill=(255, 255, 255, 40))
    if label:
        f = font(int(22 * s), "demi", cond=True)
        ly = cy + r + 10 * s if lab_below else cy - r - 34 * s
        d.text((cx - f.getlength(label) / 2, ly), label, font=f, fill=DIM)

# ---------------------------------------------------------------- S14 seismogram
def g_seismogram(W, H, t, dur):
    """Same impact energy, two worlds: Earth's wet rock damps a quake in minutes; the Moon's dry,
    fractured crust rang for ~55 minutes after Apollo 12's ascent stage hit (20 Nov 1969)."""
    img = bg(W, H, t); s = scale_for(W, H); d = ImageDraw.Draw(img)
    title(img, t, "The Moon rang for nearly an hour", "APOLLO 12 SEISMOMETER  ·  20 NOV 1969")
    x0, y0, x1, y1 = body(W, H)
    rowh = (y1 - y0) / 2
    clock = 55 * ease(fin(t, 0.6, dur - 1.8))          # minutes shown on the time axis
    for row, (lab, col, tau) in enumerate((("EARTH", EARTHB, 3.0), ("MOON", MOONG, 26.0))):
        cy = y0 + rowh * (row + 0.5)
        d.text((x0, cy - rowh * 0.42), lab, font=font(int(26 * s), "heavy", cond=True), fill=col)
        d.line([(x0, cy), (x1, cy)], fill=(60, 70, 84, 255), width=max(1, int(2 * s)))
        pts = []
        N = 900
        for i in range(N):
            m = 60 * i / (N - 1)                        # minutes along the axis
            if m > clock: break
            env = (m / 0.5) if m < 0.5 else math.exp(-(m - 0.5) / tau)
            wig = math.sin(i * 1.31) * math.sin(i * 0.37 + row) + 0.35 * math.sin(i * 2.9)
            pts.append((x0 + (x1 - x0) * m / 60, cy - wig * env * rowh * 0.36))
        if len(pts) > 1: d.line(pts, fill=col, width=max(1, int(2 * s)))
    # time axis
    fa = font(int(20 * s), "demi", cond=True)
    for m in (0, 10, 20, 30, 40, 50, 60):
        x = x0 + (x1 - x0) * m / 60
        d.text((x - fa.getlength(f"{m}") / 2, y1 + 6 * s), f"{m}", font=fa, fill=DIM)
    d.text((x1 - fa.getlength("minutes after impact"), y1 + 32 * s), "minutes after impact", font=fa, fill=DIM)
    # running clock, honest about the time-lapse
    ck = f"{int(clock):02d} min"
    d.text((x0, y1 + 30 * s), ck, font=font(int(34 * s), "heavy"), fill=YELLOW)
    return img      # (the narration says why it rang; a text note here collided with captions)

# ---------------------------------------------------------------- S22 commands to Mars
def g_dsn(W, H, t, dur):
    """Over 1,000 commands were sent to Opportunity before the mission was declared over."""
    img = bg(W, H, t); s = scale_for(W, H); d = ImageDraw.Draw(img)
    title(img, t, "Wake up, Opportunity", "JUNE 2018 – FEBRUARY 2019")
    x0, y0, x1, y1 = body(W, H); cy = (y0 + y1) / 2
    ex, mx = x0 + (x1 - x0) * 0.12, x0 + (x1 - x0) * 0.88
    planet(d, ex, cy, 54 * s, EARTHB, "EARTH", s); planet(d, mx, cy, 32 * s, MARSR, "MARS", s)
    n = int(1000 * ease(fin(t, 0.2, dur - 1.0))) + (1 if t > 0.2 else 0)
    for j in range(14):                                   # pulses in flight
        ph = (t * 0.9 + j / 14) % 1.0
        px = ex + (mx - ex) * ph
        r = (6 + 20 * ph) * s
        d.arc([px - r, cy - r, px + r, cy + r], -40, 40, fill=a255(GREEN, 0.9 * (1 - ph)), width=max(1, int(3 * s)))
    fc = font(int(52 * s), "heavy")
    txt = f"{min(n, 1000):,}{'+' if n >= 1000 else ''} commands sent"
    d.text(((W - fc.getlength(txt)) / 2, y1 - 20 * s), txt, font=fc, fill=YELLOW)
    if t > dur * 0.55:
        a = fin(t, dur * 0.55, 0.4)
        nr = "NO REPLY"
        fr = font(int(34 * s), "heavy", cond=True)
        d.text((mx - fr.getlength(nr) / 2, cy - 110 * s), nr, font=fr, fill=a255(RED, a))
    return img

# ---------------------------------------------------------------- S24 one light-day
def g_lightday(W, H, t, dur):
    """Voyager 1 reaches one light-day from Earth on 18 Nov 2026 (NASA): 25.902 billion km."""
    img = bg(W, H, t); s = scale_for(W, H); d = ImageDraw.Draw(img)
    title(img, t, "One light-day from home", "VOYAGER 1  ·  18 NOVEMBER 2026")
    x0, y0, x1, y1 = body(W, H); cy = (y0 + y1) / 2
    ex, vx = x0 + 40 * s, x1 - 40 * s
    planet(d, ex, cy, 26 * s, EARTHB, "EARTH", s)
    d.line([(ex + 30 * s, cy), (vx - 20 * s, cy)], fill=(70, 80, 96, 255), width=max(1, int(2 * s)))
    # Voyager glyph
    d.ellipse([vx - 14 * s, cy - 14 * s, vx + 14 * s, cy + 14 * s], outline=WHITE, width=max(2, int(3 * s)))
    d.line([(vx, cy), (vx + 30 * s, cy - 20 * s)], fill=WHITE, width=max(1, int(2 * s)))
    fv = font(int(22 * s), "demi", cond=True)
    d.text((vx - fv.getlength("VOYAGER 1") / 2, cy + 22 * s), "VOYAGER 1", font=fv, fill=DIM)
    u = ease(fin(t, 0.8, dur - 2.4))
    hours = 24 * u
    px = ex + 30 * s + (vx - ex - 50 * s) * u
    for k in range(10):
        a = (1 - k / 10) * 0.9
        d.ellipse([px - (9 - k * 0.5) * s - k * 6 * s, cy - (9 - k * 0.6) * s, px + (9 - k * 0.5) * s - k * 6 * s, cy + (9 - k * 0.6) * s],
                  fill=a255((255, 246, 200, 255), a))
    hh = int(hours); mm = int((hours - hh) * 60)
    fc = font(int(58 * s), "heavy")
    clock = f"{hh:02d} h {mm:02d} min"
    d.text(((W - fc.getlength(clock)) / 2, cy - 140 * s), clock, font=fc, fill=YELLOW)
    km = 25.902 * u
    fk = font(int(30 * s), "bold")
    kt = f"{km:5.2f} billion km"
    d.text(((W - fk.getlength(kt)) / 2, cy + 70 * s), kt, font=fk, fill=CYAN)
    fl = font(int(20 * s), "demi", cond=True)
    lab = "TIME-LAPSE  ·  LIGHT ITSELF TAKES THE FULL 24 HOURS"
    d.text(((W - fl.getlength(lab)) / 2, y1 + 8 * s), lab, font=fl, fill=DIM)
    return img

# ---------------------------------------------------------------- S27 corner cube
def g_reflector(W, H, t, dur):
    """A corner cube: three mirrors at right angles. Light leaves the way it came,
    whatever angle it arrives at. Apollo 11's array holds 100 of them."""
    img = bg(W, H, t); s = scale_for(W, H); d = ImageDraw.Draw(img)
    title(img, t, "Light goes back the way it came", "CORNER CUBE REFLECTOR")
    x0, y0, x1, y1 = body(W, H)
    wide = W > H
    # the corner, drawn as two mirrors meeting at 90 degrees
    cx = x0 + (x1 - x0) * (0.42 if wide else 0.5); cy = y1 - (y1 - y0) * 0.12
    L = (y1 - y0) * 0.62
    m1 = (cx - L * 0.7, cy - L * 0.7); m2 = (cx + L * 0.7, cy - L * 0.7)
    d.line([m1, (cx, cy), m2], fill=(176, 214, 255, 255), width=max(3, int(6 * s)))
    # incoming ray, two real reflections (mirror normals at 90 deg), exits exactly reversed
    def nrm(v): l = math.hypot(*v); return (v[0] / l, v[1] / l)
    def refl(v, n): k = 2 * (v[0] * n[0] + v[1] * n[1]); return (v[0] - k * n[0], v[1] - k * n[1])
    m1d = nrm((-1, -1)); m2d = nrm((1, -1))
    n1 = nrm((1, -1)); n2 = nrm((1, 1))
    v = nrm((0.42, 1.0))                                   # travelling down and to the right
    hit1 = (cx + m1d[0] * L * 0.42, cy + m1d[1] * L * 0.42)
    start = (hit1[0] - v[0] * L * 1.05, hit1[1] - v[1] * L * 1.05)
    v1 = refl(v, n1)
    # intersect hit1 + t*v1 with the second mirror line cx + s*m2d
    den = v1[0] * m2d[1] - v1[1] * m2d[0]
    tt = ((cx - hit1[0]) * m2d[1] - (cy - hit1[1]) * m2d[0]) / den
    hit2 = (hit1[0] + v1[0] * tt, hit1[1] + v1[1] * tt)
    v2 = refl(v1, n2)                                       # equals -v: straight back
    out = (hit2[0] + v2[0] * L * 1.05, hit2[1] + v2[1] * L * 1.05)
    path = [start, hit1, hit2, out]
    u = max(0.0, min(1.0, (t - 0.6) / (dur * 0.45)))
    u = u * u * (3 - 2 * u)
    segl = [math.dist(path[i], path[i + 1]) for i in range(3)]
    tot = sum(segl); run = tot * u
    drawn = [path[0]]
    for i in range(3):
        if run <= 0: break
        f = min(1.0, run / segl[i])
        p = (path[i][0] + (path[i + 1][0] - path[i][0]) * f, path[i][1] + (path[i + 1][1] - path[i][1]) * f)
        drawn.append(p); run -= segl[i]
    d.line(drawn, fill=GREEN, width=max(2, int(4 * s)))
    fa = font(int(24 * s), "demi", cond=True)
    if u >= 1:
        a = fin(t, 0.6 + dur * 0.55, 0.5)
        d.text((out[0] + 14 * s, out[1] - 6 * s), "back to the source", font=fa, fill=a255(GREEN, a))
    # bicycle reflector comparison
    a2 = fin(t, dur * 0.45, 0.6)
    if wide:
        bx, by = x1 - (x1 - x0) * 0.2, y0 + (y1 - y0) * 0.45
    else:
        bx, by = x0 + (x1 - x0) * 0.8, y0 + (y1 - y0) * 0.1
    r = 46 * s
    d.ellipse([bx - r, by - r, bx + r, by + r], outline=a255(RED, a2), width=max(3, int(8 * s)))
    for k in range(6):
        aa = k * math.pi / 3
        d.line([(bx, by), (bx + math.cos(aa) * r * 0.86, by + math.sin(aa) * r * 0.86)], fill=a255(RED, a2 * 0.7), width=max(1, int(3 * s)))
    fb = font(int(22 * s), "demi", cond=True)
    lab = "same idea as your bike reflector"
    d.text((bx - fb.getlength(lab) / 2, by + r + 10 * s), lab, font=fb, fill=a255(DIM, a2))
    a3 = fin(t, dur * 0.7, 0.5)
    note = "Apollo 11's tray: 100 corner cubes. No power needed."
    fn = font(int(26 * s), "medium")
    d.text(((W - fn.getlength(note)) / 2, int(H * 0.88) - int(60 * s)), note, font=fn, fill=a255(CYAN, a3))
    return img

# ---------------------------------------------------------------- S28 laser to the Moon
def g_laser(W, H, t, dur):
    """APOLLO observatory (Apache Point, New Mexico) fires a 532 nm green laser at the arrays
    several times a month. Mean Earth-Moon distance 384,400 km = 9.6 x Earth's 40,075 km girth."""
    img = bg(W, H, t); s = scale_for(W, H); d = ImageDraw.Draw(img)
    title(img, t, "Aim a laser at the Moon", "SEVERAL TIMES A MONTH  ·  NEW MEXICO, USA")
    x0, y0, x1, y1 = body(W, H); cy = (y0 + y1) / 2
    ex, mx = x0 + 60 * s, x1 - 40 * s
    planet(d, ex, cy, 60 * s, EARTHB, "EARTH", s)
    planet(d, mx, cy, 17 * s, MOONG, "MOON", s)
    u = ease(fin(t, 0.8, dur * 0.6))
    bx = ex + 62 * s + (mx - ex - 80 * s) * u
    d.line([(ex + 62 * s, cy), (bx, cy)], fill=GREEN, width=max(2, int(4 * s)))
    d.ellipse([bx - 6 * s, cy - 6 * s, bx + 6 * s, cy + 6 * s], fill=(200, 255, 210, 255))
    km = 384400 * u
    fk = font(int(54 * s), "heavy")
    kt = f"{km:,.0f} km"
    d.text(((W - fk.getlength(kt)) / 2, cy - 130 * s), kt, font=fk, fill=YELLOW)
    a = fin(t, 0.8 + dur * 0.6, 0.5)
    laps = "about 10 laps around Earth  (9.6)"
    fl = font(int(30 * s), "bold")
    d.text(((W - fl.getlength(laps)) / 2, cy + 70 * s), laps, font=fl, fill=a255(CYAN, a))
    # ten little Earth circumferences, filling as the beam travels
    n = int(9.6 * u * 10) / 10
    fw = (x1 - x0) * 0.6; ox = (W - fw) / 2; oy = cy + 150 * s
    for i in range(10):
        cxx = ox + fw * (i + 0.5) / 10; r = min(18 * s, fw / 26)
        fill = min(1.0, max(0.0, n - i))
        d.ellipse([cxx - r, oy - r, cxx + r, oy + r], outline=(70, 110, 170, 255), width=max(1, int(2 * s)))
        if fill > 0:
            d.pieslice([cxx - r, oy - r, cxx + r, oy + r], -90, -90 + 360 * fill, fill=(70, 140, 230, 200))
    return img

# ---------------------------------------------------------------- S30 the Moon drifts away
def g_drift(W, H, t, dur):
    """Lunar laser ranging: the Moon recedes 3.83 cm/yr (arXiv 2110.09037). Fingernails grow
    roughly 3.5 mm a month, about 4 cm a year. Since 1969: 57 years x 3.83 cm = 2.18 m."""
    img = bg(W, H, t); s = scale_for(W, H); d = ImageDraw.Draw(img)
    title(img, t, "The Moon is drifting away", "MEASURED WITH THE APOLLO MIRRORS")
    x0, y0, x1, y1 = body(W, H); cy = (y0 + y1) * 0.46
    ex = x0 + (x1 - x0) * 0.18
    planet(d, ex, cy, 50 * s, EARTHB, "EARTH", s)
    u = ease(fin(t, 0.6, dur * 0.55))
    mx0 = x1 - (x1 - x0) * 0.24; mx = mx0 + (x1 - x0) * 0.10 * u
    d.line([(mx0, cy - 34 * s), (mx0, cy + 34 * s)], fill=(90, 100, 116, 255), width=max(1, int(2 * s)))
    planet(d, mx, cy, 16 * s, MOONG, None, s)
    d.line([(mx0, cy + 44 * s), (mx, cy + 44 * s)], fill=YELLOW, width=max(2, int(3 * s)))
    fs = font(int(20 * s), "demi", cond=True)
    d.text((mx0 - 10 * s, cy + 52 * s), "1969", font=fs, fill=DIM)
    d.text((mx - 20 * s, cy - 64 * s), "2026", font=fs, fill=DIM)
    fb = font(int(64 * s), "heavy")
    big = "3.8 cm a year"
    d.text(((W - fb.getlength(big)) / 2, y1 - 120 * s), big, font=fb, fill=YELLOW)
    a = fin(t, dur * 0.45, 0.5)
    fn = font(int(28 * s), "medium")
    for j, line in enumerate(("about as fast as your fingernails grow", "2.2 m farther away than in 1969")):
        aa = fin(t, dur * (0.45 + 0.18 * j), 0.5)
        d.text(((W - fn.getlength(line)) / 2, y1 - 40 * s + j * 40 * s), line, font=fn, fill=a255(CYAN if j == 0 else WHITE, aa))
    fl = font(int(18 * s), "demi", cond=True)
    lab = "distance change exaggerated for visibility"
    d.text((x1 - fl.getlength(lab), y0 + 4 * s), lab, font=fl, fill=DIM)
    return img

def g_cta(W, H, t, dur):
    return G.end_screen(W, H, t, "https://www.roblox.com/games/104157966303180")

GRAPHICS = {"seismogram": g_seismogram, "dsn": g_dsn, "lightday": g_lightday,
            "reflector": g_reflector, "laser": g_laser, "drift": g_drift, "cta": g_cta}

# ---------------------------------------------------------------- overlays on live shots
def tag(img, t, big, small, dur):
    """Lower-third label that slides in and out."""
    W, H = img.size; s = scale_for(W, H)
    a = ease(fin(t, 0.35, 0.45)) * (1 - ease(fin(t, dur - 0.6, 0.45)))
    if a <= 0: return
    fb = font(int(36 * s), "heavy", cond=True); fs = font(int(22 * s), "medium")
    w = int(max(fb.getlength(big), fs.getlength(small)) + 56 * s); h = int(92 * s)
    x = int(48 * s - (1 - a) * 40 * s); y = int(48 * s)
    layer = Image.new("RGBA", img.size, (0, 0, 0, 0)); ld = ImageDraw.Draw(layer)
    ld.rounded_rectangle([x, y, x + w, y + h], radius=int(12 * s), fill=(6, 10, 16, int(176 * a)))
    ld.rectangle([x, y, x + int(6 * s), y + h], fill=a255(YELLOW, a))
    ld.text((x + 26 * s, y + 12 * s), big, font=fb, fill=a255(WHITE, a))
    ld.text((x + 26 * s, y + 54 * s), small, font=fs, fill=a255(CYAN, a))
    img.alpha_composite(layer)

def counter_years(img, t, dur, y0=1971, y1=2026):
    W, H = img.size; s = scale_for(W, H); d = ImageDraw.Draw(img)
    u = ease(fin(t, 0.4, dur - 1.4)); yr = int(y0 + (y1 - y0) * u)
    f = font(int(64 * s), "heavy"); fs = font(int(22 * s), "demi", cond=True)
    txt = f"{yr}"
    x = W - 48 * s - f.getlength(txt); y = 48 * s
    d.text((x, y), txt, font=f, fill=YELLOW, stroke_width=int(3 * s), stroke_fill=(0, 0, 0, 200))
    lab = f"PARKED {y0}  ·  {yr - y0} YEARS"
    d.text((W - 48 * s - fs.getlength(lab), y + 74 * s), lab, font=fs, fill=WHITE, stroke_width=int(2 * s), stroke_fill=(0, 0, 0, 200))

def counter_sols(img, t, dur, t90=6.0, tend=10.5):
    """Opportunity: planned 90 sols; it lasted 5,111 sols (landed Jan 2004, silent June 2018)."""
    W, H = img.size; s = scale_for(W, H)
    if t < 0.3: return
    sol = 90 * ease(fin(t, 0.3, t90 - 0.3)) if t < t90 else 90 + (5111 - 90) * ease(fin(t, t90 + 0.4, tend - t90 - 0.4))
    layer = Image.new("RGBA", img.size, (0, 0, 0, 0)); d = ImageDraw.Draw(layer)
    m = int(48 * s); pw = int(480 * s); ph = int(178 * s)
    d.rounded_rectangle([m, m, m + pw, m + ph], radius=int(12 * s), fill=(6, 10, 16, 176))
    d.text((m + 24 * s, m + 14 * s), "OPPORTUNITY  ·  MARS DAYS (SOLS)", font=font(int(20 * s), "demi", cond=True), fill=DIM)
    d.text((m + 24 * s, m + 38 * s), f"SOL {int(sol):,}", font=font(int(52 * s), "heavy"), fill=YELLOW)
    bx, by, bw, bh = m + 24 * s, m + ph - 34 * s, pw - 48 * s, int(10 * s)
    d.rounded_rectangle([bx, by, bx + bw, by + bh], radius=bh, fill=(50, 58, 70, 255))
    d.rounded_rectangle([bx, by, bx + bw * min(1, sol / 5111), by + bh], radius=bh, fill=YELLOW)
    px = bx + bw * 90 / 5111
    d.line([(px, by - 8 * s), (px, by + bh + 8 * s)], fill=WHITE, width=max(1, int(2 * s)))
    d.text((px + 4 * s, by - 28 * s), "planned: 90", font=font(int(18 * s), "demi", cond=True), fill=WHITE)
    img.alpha_composite(layer)

def pulse(img, t, dur, cx=0.52, cy=0.30):
    """Opportunity's final transmission, 10 June 2018."""
    W, H = img.size; s = scale_for(W, H)
    layer = Image.new("RGBA", img.size, (0, 0, 0, 0)); d = ImageDraw.Draw(layer)
    x, y = cx * W, cy * H
    for j in range(3):
        ph = (t * 0.55 - j * 0.33)
        if 0 <= ph <= 1:
            r = (20 + 360 * ph) * s
            d.ellipse([x - r, y - r, x + r, y + r], outline=(120, 255, 160, int(200 * (1 - ph))), width=max(2, int(4 * s)))
    a = ease(fin(t, 0.8, 0.6))
    fb = font(int(60 * s), "heavy"); fs = font(int(26 * s), "demi", cond=True)
    big = "LAST SIGNAL"; small = "OPPORTUNITY  ·  10 JUNE 2018"
    d.text((48 * s, H * 0.07), big, font=fb, fill=a255(YELLOW, a), stroke_width=int(3 * s), stroke_fill=(0, 0, 0, int(200 * a)))
    d.text((52 * s, H * 0.07 + 72 * s), small, font=fs, fill=a255(WHITE, a), stroke_width=int(2 * s), stroke_fill=(0, 0, 0, int(200 * a)))
    img.alpha_composite(layer)

def instruments(img, t, dur):
    """NASA status (updated 17 Apr 2026): on = MAG, PWS. Off: CRS, LECP, PLS, ISS, IRIS, PPS, PRA, UVS."""
    W, H = img.size; s = scale_for(W, H)
    a = ease(fin(t, 3.0, 0.6))
    if a <= 0: return
    names = ["MAG", "PWS", "CRS", "LECP", "PLS", "ISS", "IRIS", "PPS", "PRA", "UVS"]
    layer = Image.new("RGBA", img.size, (0, 0, 0, 0)); d = ImageDraw.Draw(layer)
    cols = 5; cw = int(86 * s); chh = int(44 * s)
    pw = cols * cw + int(40 * s); ph = 2 * chh + int(84 * s)
    x0 = W - pw - int(48 * s); y0 = int(48 * s)
    d.rounded_rectangle([x0, y0, x0 + pw, y0 + ph], radius=int(12 * s), fill=(6, 10, 16, int(180 * a)))
    d.text((x0 + 20 * s, y0 + 12 * s), "VOYAGER 1 INSTRUMENTS  ·  2 OF 10 STILL ON", font=font(int(20 * s), "demi", cond=True), fill=a255(WHITE, a))
    for i, nm in enumerate(names):
        cx = x0 + 20 * s + (i % cols) * cw; cy = y0 + 46 * s + (i // cols) * chh
        on = i < 2
        col = (120, 230, 150, 255) if on else (70, 76, 86, 255)
        d.rounded_rectangle([cx, cy, cx + cw - 10 * s, cy + chh - 10 * s], radius=int(6 * s), fill=a255(col if on else (24, 28, 34, 255), a), outline=a255(col, a), width=max(1, int(2 * s)))
        f = font(int(18 * s), "heavy", cond=True)
        d.text((cx + (cw - 10 * s - f.getlength(nm)) / 2, cy + 8 * s), nm, font=f, fill=a255((10, 12, 16, 255) if on else DIM, a))
    img.alpha_composite(layer)

def year_ff(img, t, dur, y0=1969, y1=2026):
    W, H = img.size; s = scale_for(W, H); d = ImageDraw.Draw(img)
    u = ease(fin(t, 0.2, dur - 0.9)); yr = int(y0 + (y1 - y0) * u)
    f = font(int(76 * s), "heavy")
    txt = f"{yr}"
    d.text(((W - f.getlength(txt)) / 2, H * 0.16), txt, font=f, fill=a255(YELLOW, ease(fin(t, 0.1, 0.4))),
           stroke_width=int(3 * s), stroke_fill=(0, 0, 0, 200))
    fs = font(int(22 * s), "demi", cond=True)
    lab = "STILL UP THERE"
    a = fin(t, dur - 1.4, 0.5)
    d.text(((W - fs.getlength(lab)) / 2, H * 0.16 + 88 * s), lab, font=fs, fill=a255(WHITE, a))

def seis_live(img, t, dur, t_imp=2.9):
    """S13: live seismometer readout. Quiet trace, then the impact arrives and keeps ringing."""
    W, H = img.size; s = scale_for(W, H)
    a = ease(fin(t, 0.5, 0.5))
    if a <= 0: return
    layer = Image.new("RGBA", img.size, (0, 0, 0, 0)); d = ImageDraw.Draw(layer)
    pw, ph = int(min(W * 0.42, 560 * s)), int(150 * s)
    x0 = W - pw - int(40 * s); y0 = int(40 * s)
    d.rounded_rectangle([x0, y0, x0 + pw, y0 + ph], radius=int(12 * s), fill=(6, 10, 16, int(190 * a)))
    d.text((x0 + 18 * s, y0 + 12 * s), "SEISMOMETER  ·  LIVE", font=font(int(20 * s), "demi", cond=True), fill=a255(DIM, a))
    hit = t >= t_imp
    if hit:
        d.text((x0 + pw - 18 * s - font(int(20 * s), "heavy", cond=True).getlength("IMPACT DETECTED"), y0 + 12 * s),
               "IMPACT DETECTED", font=font(int(20 * s), "heavy", cond=True), fill=a255(YELLOW, a))
    cy = y0 + ph * 0.6; amp = ph * 0.32
    span = 4.0                                     # seconds of trace shown
    rng = random.Random(7)
    noise = [rng.uniform(-1, 1) for _ in range(4000)]
    pts = []
    n = 220
    for j in range(n):
        tt = t - span + span * j / (n - 1)
        if tt < 0: continue
        k = int(tt * 90) % 4000
        v = noise[k] * 0.06
        if tt >= t_imp:
            q = tt - t_imp
            env = min(1.0, q / 0.6) * math.exp(-q / 9.0)     # slow build, very slow decay: the Moon rings
            v += env * (0.75 * math.sin(q * 31) + 0.45 * noise[(k * 7) % 4000])
        x = x0 + 18 * s + (pw - 36 * s) * j / (n - 1)
        pts.append((x, cy - max(-1.2, min(1.2, v)) * amp))
    if len(pts) > 1:
        d.line(pts, fill=a255((230, 230, 225, 255), a), width=max(1, int(2 * s)))
    img.alpha_composite(layer)

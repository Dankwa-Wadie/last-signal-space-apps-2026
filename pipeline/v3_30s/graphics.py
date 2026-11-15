"""Overlay graphics for the v3 30-second cut: captions, data panels, end screen.
Every function draws onto an RGBA image of the output size, so the same code
serves 16:9 (1920x1080) and 4:5 (1080x1350) without cropping anything."""
import math, random
from PIL import Image, ImageDraw, ImageFilter, ImageFont
import qrcode

AV = "/System/Library/Fonts/Avenir Next.ttc"
AVC = "/System/Library/Fonts/Supplemental/Avenir Next Condensed.ttc"
FACE = {"bold": 0, "demi": 2, "medium": 5, "regular": 7, "heavy": 8}

WHITE = (246, 246, 240, 255)
YELLOW = (245, 231, 60, 255)
CYAN = (143, 211, 255, 255)
DIM = (154, 160, 166, 255)
RED = (235, 95, 72, 255)

_cache = {}
def font(size, face="bold", cond=False):
    key = (size, face, cond)
    if key not in _cache:
        _cache[key] = ImageFont.truetype(AVC if cond else AV, size, index=FACE[face])
    return _cache[key]

def scale_for(w, h):
    """1.0 on 1080-tall 16:9; type sizes follow the shorter side."""
    return min(w, h) / 1080.0

# ---------------------------------------------------------------- captions
def caption(img, text, t_in, t, safe_bottom):
    """Subtitle with *highlighted* words, bottom-centre. Fades in over 0.12 s."""
    W, H = img.size
    s = scale_for(W, H)
    size = int(62 * s) if W > H else int(60 * s)
    f = font(size, "bold")
    # tokens carry whether a space precedes them, so "*1964*." stays "1964." not "1964 ."
    toks, hi, prev_space = [], False, True
    for chunk in text.split("*"):
        if chunk:
            pieces = chunk.split(" ")
            for j, word in enumerate(pieces):
                if word == "":
                    continue
                # glue only when there was no space on either side of the * boundary
                glued = (j == 0 and toks != [] and not chunk.startswith(" ") and not prev_space)
                toks.append([word, hi, not glued])
            prev_space = chunk.endswith(" ")
        hi = not hi
    maxw = W * 0.86
    lines, cur, curw = [], [], 0
    for word, h, spaced in toks:
        ww = f.getlength((" " if spaced and cur else "") + word)
        if cur and spaced and curw + ww > maxw:
            lines.append(cur); cur, curw = [], 0
            ww = f.getlength(word)
        cur.append((word, h, spaced and bool(cur))); curw += ww
    if cur:
        lines.append(cur)
    alpha = max(0.0, min(1.0, (t - t_in) / 0.12))
    layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    lh = int(size * 1.22)
    y = int(H - safe_bottom - lh * len(lines))
    sp = f.getlength(" ")
    for line in lines:
        total = sum(f.getlength(w) + (sp if gap else 0) for w, _, gap in line)
        x = (W - total) / 2
        for w, h, gap in line:
            if gap: x += sp
            col = YELLOW if h else WHITE
            d.text((x, y), w, font=f, fill=col,
                   stroke_width=max(3, int(5 * s)), stroke_fill=(0, 0, 0, 235))
            x += f.getlength(w)
        y += lh
    # soft shadow under the text for legibility on bright regolith
    sh = layer.split()[3].filter(ImageFilter.GaussianBlur(int(10 * s)))
    shadow = Image.new("RGBA", img.size, (0, 0, 0, 0))
    shadow.putalpha(sh.point(lambda v: int(v * 0.55)))
    if alpha < 1:
        layer.putalpha(layer.split()[3].point(lambda v: int(v * alpha)))
        shadow.putalpha(shadow.split()[3].point(lambda v: int(v * alpha)))
    img.alpha_composite(shadow)
    img.alpha_composite(layer)

# ---------------------------------------------------------------- panels
def _panel(img, x, y, w, h, alpha=1.0):
    s = scale_for(*img.size)
    layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    d.rounded_rectangle([x, y, x + w, y + h], radius=int(14 * s),
                        fill=(6, 10, 16, int(178 * alpha)),
                        outline=(143, 211, 255, int(120 * alpha)), width=max(1, int(2 * s)))
    img.alpha_composite(layer)
    return ImageDraw.Draw(img)

def _fadein(t, t0, d=0.35):
    return max(0.0, min(1.0, (t - t0) / d))

def vanguard_panel(img, t_shot, alt_km, speed, compression):
    """Live readout matching the animated orbit."""
    W, H = img.size
    s = scale_for(W, H)
    a = _fadein(t_shot, 0.15)
    if a <= 0:
        return
    m = int(48 * s)
    pw, ph = int(470 * s), int(250 * s)
    d = _panel(img, m, m, pw, ph, a)
    ga = int(255 * a)
    def col(c): return (c[0], c[1], c[2], ga)
    x, y = m + int(26 * s), m + int(20 * s)
    d.text((x, y), "VANGUARD 1", font=font(int(40 * s), "heavy"), fill=col(YELLOW)); y += int(52 * s)
    d.text((x, y), "Silent since 1964  ·  still in orbit", font=font(int(22 * s), "medium"), fill=col(WHITE)); y += int(44 * s)
    rows = [("ALTITUDE", f"{alt_km:,.0f} km"),
            ("SPEED", f"{speed:.2f} km/s"),
            ("ONE ORBIT", "134 min")]
    for k, v in rows:
        d.text((x, y), k, font=font(int(20 * s), "demi", cond=True), fill=col(DIM))
        d.text((x + int(190 * s), y - int(4 * s)), v, font=font(int(28 * s), "bold"), fill=col(CYAN))
        y += int(40 * s)
    # time-lapse badge, top right: the orbit is sped up and we say so
    bt = f"TIME  ×{compression:,.0f}"
    bf = font(int(26 * s), "heavy", cond=True)
    bw = int(bf.getlength(bt) + 40 * s); bh = int(52 * s)
    bx = W - m - bw
    d2 = _panel(img, bx, m, bw, bh, a)
    d2.text((bx + int(20 * s), m + int(11 * s)), bt, font=bf, fill=col(YELLOW))

def opportunity_stamp(img, t_shot):
    W, H = img.size
    s = scale_for(W, H)
    a = _fadein(t_shot, 0.2)
    if a <= 0:
        return
    m = int(48 * s)
    pw, ph = int(430 * s), int(132 * s)
    d = _panel(img, m, m, pw, ph, a)
    ga = int(255 * a)
    x, y = m + int(26 * s), m + int(18 * s)
    d.text((x, y), "OPPORTUNITY  ·  MARS", font=font(int(22 * s), "demi", cond=True), fill=(154, 160, 166, ga))
    y += int(34 * s)
    d.text((x, y), "Last signal", font=font(int(26 * s), "medium"), fill=(246, 246, 240, ga))
    d.text((x + int(150 * s), y - int(6 * s)), "10 June 2018", font=font(int(34 * s), "heavy"), fill=(235, 95, 72, ga))

def laser_timer(img, t_shot, fire_at, rtt=2.5):
    """Round-trip counter. Runs in REAL time: 2.5 s on screen is 2.5 s of light travel."""
    W, H = img.size
    s = scale_for(W, H)
    a = _fadein(t_shot, fire_at - 0.4)
    if a <= 0:
        return
    el = max(0.0, min(rtt, t_shot - fire_at))
    returned = t_shot >= fire_at + rtt
    m = int(48 * s)
    pw, ph = int(520 * s), int(150 * s)
    x0 = (W - pw) // 2
    d = _panel(img, x0, m, pw, ph, a)
    ga = int(255 * a)
    # Avenir has no arrow glyph (renders as a box), so use en dashes
    d.text((x0 + int(26 * s), m + int(16 * s)), "LASER ROUND TRIP  ·  EARTH – MOON – EARTH",
           font=font(int(22 * s), "demi", cond=True), fill=(154, 160, 166, ga))
    val = f"{el:0.2f} s"
    colr = (120, 230, 150, ga) if returned else (143, 211, 255, ga)
    d.text((x0 + int(26 * s), m + int(46 * s)), val, font=font(int(54 * s), "heavy"), fill=colr)
    if returned:
        d.text((x0 + int(250 * s), m + int(64 * s)), "RETURN PULSE", font=font(int(26 * s), "heavy", cond=True), fill=colr)
    # progress bar
    bx, by, bw, bh = x0 + int(26 * s), m + ph - int(26 * s), pw - int(52 * s), max(4, int(6 * s))
    d.rounded_rectangle([bx, by, bx + bw, by + bh], radius=bh, fill=(60, 70, 84, ga))
    d.rounded_rectangle([bx, by, bx + int(bw * el / rtt), by + bh], radius=bh, fill=colr)

# ---------------------------------------------------------------- end screen
_stars = {}
def _starfield(W, H):
    if (W, H) not in _stars:
        rng = random.Random(7)
        _stars[(W, H)] = [(rng.random() * W, rng.random() * H, rng.random() ** 3, rng.random())
                          for _ in range(int(W * H / 2600))]
    return _stars[(W, H)]

def _qr(url, px):
    q = qrcode.QRCode(border=2, box_size=10, error_correction=qrcode.constants.ERROR_CORRECT_M)
    q.add_data(url); q.make(fit=True)
    return q.make_image(fill_color="black", back_color="white").convert("RGBA").resize((px, px), Image.NEAREST)

def end_screen(W, H, t, url, shot_still=None):
    """Astrolog presents LAST SIGNAL. Laid out separately for wide and tall frames."""
    s = scale_for(W, H)
    if shot_still is not None:      # key-art background supplied by the caller (long cut)
        img = shot_still.convert("RGBA").copy()
    else:
        img = Image.new("RGBA", (W, H), (4, 6, 12, 255))
    # gradient glow
    g = Image.new("L", (W, H), 0)
    gd = ImageDraw.Draw(g)
    cx, cy = (W * 0.30, H * 0.55) if W > H else (W * 0.5, H * 0.30)
    for r in range(int(max(W, H) * 0.7), 0, -12):
        gd.ellipse([cx - r, cy - r, cx + r, cy + r], fill=int(48 * (1 - r / (max(W, H) * 0.7))))
    glow = Image.new("RGBA", (W, H), (40, 70, 120, 0)); glow.putalpha(g.filter(ImageFilter.GaussianBlur(40)))
    if shot_still is None: img.alpha_composite(glow)
    d = ImageDraw.Draw(img)
    for (x, y, b, ph) in ([] if shot_still is not None else _starfield(W, H)):
        tw = 0.6 + 0.4 * math.sin(t * 2.2 + ph * 6.28)
        v = int(90 + 165 * b * tw)
        rr = 1 + int(b * 2 * s)
        d.ellipse([x - rr, y - rr, x + rr, y + rr], fill=(v, v, min(255, v + 10), 255))

    def ease(u): u = max(0.0, min(1.0, u)); return 1 - (1 - u) ** 3
    a_pre = ease((t - 0.1) / 0.5)
    a_title = ease((t - 0.35) / 0.6)
    a_tag = ease((t - 0.9) / 0.5)
    a_qr = ease((t - 1.3) / 0.5)

    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ld = ImageDraw.Draw(layer)
    pre = font(int(30 * s), "demi", cond=True)
    title = font(int(150 * s) if W > H else int(128 * s), "heavy")
    tag = font(int(38 * s), "medium")
    small = font(int(26 * s), "demi")
    qr_px = int(330 * s) if W > H else (int(262 * s) if shot_still is not None else int(420 * s))
    qr = _qr(url, qr_px)

    if W > H:   # ---- 16:9: words left, code right
        lx = int(150 * s)
        ty = int(H * 0.30) + int((1 - a_title) * 30 * s)
        ld.text((lx, int(H * 0.25)), "ASTROLOG  PRESENTS", font=pre, fill=(143, 211, 255, int(255 * a_pre)))
        ld.text((lx, ty), "LAST SIGNAL", font=title, fill=(245, 231, 60, int(255 * a_title)))
        ld.text((lx, ty + int(180 * s)), "Find what we left on the Moon.", font=tag, fill=(246, 246, 240, int(255 * a_tag)))
        ld.text((lx, ty + int(236 * s)), "Scan it. Remember it. Bring it back online.", font=tag, fill=(200, 205, 210, int(255 * a_tag)))
        ld.text((lx, ty + int(320 * s)), "Free to play on Roblox", font=small, fill=(154, 160, 166, int(255 * a_tag)))
        qx, qy = W - int(150 * s) - qr_px, (H - qr_px) // 2 - int(30 * s)
    else:       # ---- 4:5: stacked
        cxp = W // 2
        def centred(y, txt, f, col):
            ld.text((cxp - f.getlength(txt) / 2, y), txt, font=f, fill=col)
        centred(int(H * 0.08), "ASTROLOG  PRESENTS", pre, (143, 211, 255, int(255 * a_pre)))
        centred(int(H * 0.115) + int((1 - a_title) * 30 * s), "LAST SIGNAL", title, (245, 231, 60, int(255 * a_title)))
        centred(int(H * 0.255), "Find what we left on the Moon.", tag, (246, 246, 240, int(255 * a_tag)))
        centred(int(H * 0.295), "Scan it. Remember it. Bring it back online.", font(int(30 * s), "medium"), (200, 205, 210, int(255 * a_tag)))
        qx, qy = (W - qr_px) // 2, int(H * (0.375 if shot_still is not None else 0.37))
    img.alpha_composite(layer)

    if a_qr > 0:
        pad = int(18 * s)
        card = Image.new("RGBA", (qr_px + 2 * pad, qr_px + 2 * pad + int(64 * s)), (0, 0, 0, 0))
        cd = ImageDraw.Draw(card)
        cd.rounded_rectangle([0, 0, card.width - 1, card.height - 1], radius=int(18 * s), fill=(255, 255, 255, 255))
        card.alpha_composite(qr, (pad, pad))
        lab = font(int(28 * s), "heavy", cond=True)
        txt = "SCAN TO PLAY"
        cd.text(((card.width - lab.getlength(txt)) / 2, qr_px + pad + int(12 * s)), txt, font=lab, fill=(10, 12, 18, 255))
        sc = 0.92 + 0.08 * a_qr
        cw, ch = int(card.width * sc), int(card.height * sc)
        card = card.resize((cw, ch), Image.LANCZOS)
        card.putalpha(card.split()[3].point(lambda v: int(v * a_qr)))
        img.alpha_composite(card, (qx + (qr_px + 2 * pad - cw) // 2 - pad, qy + (qr_px + 2 * pad - ch) // 2 - pad))
    return img

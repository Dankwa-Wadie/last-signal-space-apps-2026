"""Game-page art from the end-card key art: 1920x1080 thumbnail + 512x512 icon -> game_art/."""
import os, sys
sys.argv = ["x", "16x9"]
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
import compose_long as C
from PIL import Image, ImageDraw
G = C.G; W, H = C.W, C.H; s = G.scale_for(W, H)
os.makedirs(os.path.join(HERE, "game_art"), exist_ok=True)
bg = C.keyart_bg(0.0, 1.0).convert("RGBA")
d = ImageDraw.Draw(bg)
lx = int(150 * s)
d.text((lx, int(H * 0.25)), "ASTROLOG  PRESENTS", font=G.font(int(30 * s), "demi", cond=True), fill=(143, 211, 255, 255))
d.text((lx, int(H * 0.30)), "LAST SIGNAL", font=G.font(int(150 * s), "heavy"), fill=(245, 231, 60, 255))
d.text((lx, int(H * 0.30) + int(180 * s)), "Find what we left on the Moon.", font=G.font(int(38 * s), "medium"), fill=(246, 246, 240, 255))
d.text((lx, int(H * 0.30) + int(236 * s)), "Scan it. Remember it. Bring it back online.", font=G.font(int(38 * s), "medium"), fill=(200, 205, 210, 255))
bg.convert("RGB").save(os.path.join(HERE, "game_art", "thumbnail_1920x1080.jpg"), quality=94)
# icon: square crop on the descent stage + Earth, with a short title
src = C.keyart_bg(0.0, 1.0).convert("RGBA")
side = H
x0 = 230                     # base + flag + astronaut, Earth left out rather than cut in half
ic = src.crop((max(0, x0), 0, max(0, x0) + side, side)).resize((512, 512), Image.LANCZOS)
di = ImageDraw.Draw(ic)
f = G.font(78, "heavy")
for i, line in enumerate(["LAST", "SIGNAL"]):
    w = f.getlength(line)
    di.text(((512 - w) / 2, 40 + i * 78), line, font=f, fill=(245, 231, 60, 255), stroke_width=4, stroke_fill=(0, 0, 0, 220))
ic.convert("RGB").save(os.path.join(HERE, "game_art", "icon_512.png"))
print("game_art written")

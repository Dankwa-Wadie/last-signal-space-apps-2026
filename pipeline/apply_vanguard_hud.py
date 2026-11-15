from PIL import Image, ImageDraw, ImageFont
import os, glob

FONT_BOLD = "/System/Library/Fonts/Supplemental/Arial Bold.ttf"
FONT_MONO = "/System/Library/Fonts/SFNSMono.ttf"
if not os.path.exists(FONT_MONO):
    FONT_MONO = "/System/Library/Fonts/Supplemental/Courier New Bold.ttf"

def apply_hud(dir_path):
    f_sm = ImageFont.truetype(FONT_MONO, 24)
    f_lg = ImageFont.truetype(FONT_BOLD, 30)
    f_badge = ImageFont.truetype(FONT_BOLD, 26)

    files = sorted(glob.glob(os.path.join(dir_path, "s2_*.jpg")))
    N = len(files)
    print(f"Applying HUD to {N} frames in {dir_path}...")

    for i, path in enumerate(files):
        u = i / max(1, N - 1)
        im = Image.open(path).convert("RGBA")
        W, H = im.size
        d = ImageDraw.Draw(im)

        # Top-left telemetry box
        box_w, box_h = 540, 165
        d.rounded_rectangle((40, 40, 40 + box_w, 40 + box_h), radius=10, fill=(10, 16, 28, 180), outline=(80, 180, 240, 220), width=2)
        d.text((55, 52), "TARGET: VANGUARD 1", font=f_lg, fill=(100, 220, 255, 255))
        d.text((55, 92), "ORBIT: 654 x 3,969 km | PERIOD: 134 min", font=f_sm, fill=(220, 235, 255, 240))
        d.text((55, 122), "VELOCITY: ~7.7 km/s (27,600 km/h)", font=f_sm, fill=(245, 230, 100, 240))
        d.text((55, 152), "STATUS: SILENT (RADIO LOST MAY 1964)", font=f_sm, fill=(255, 120, 120, 240))

        # Top-right simulation speed badge
        year = int(1964 + u * (2026 - 1964))
        badge_w, badge_h = 360, 105
        bx = W - badge_w - 40
        d.rounded_rectangle((bx, 40, bx + badge_w, 40 + badge_h), radius=10, fill=(20, 24, 38, 200), outline=(255, 215, 60, 230), width=2)
        d.text((bx + 20, 52), "SPEED: 600x REAL-TIME", font=f_badge, fill=(255, 225, 70, 255))
        d.text((bx + 20, 92), f"TIMELINE: {year} AD", font=f_badge, fill=(160, 240, 255, 240))

        im.convert("RGB").save(path, quality=94)

if __name__ == "__main__":
    if os.path.exists("frames_30s_blender_16x9"):
        apply_hud("frames_30s_blender_16x9")


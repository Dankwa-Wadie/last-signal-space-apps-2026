from PIL import Image, ImageDraw, ImageFont
import os, math, qrcode

OUT_16x9 = "frames_30s_cta_16x9"
OUT_4x5  = "frames_30s_cta_4x5"
os.makedirs(OUT_16x9, exist_ok=True)
os.makedirs(OUT_4x5, exist_ok=True)

FONT_BOLD = "/System/Library/Fonts/Supplemental/Arial Bold.ttf"
FONT_REG = "/System/Library/Fonts/Supplemental/Arial.ttf"

# Ensure QR code is ready
qr_img = Image.open("game_qr.png").convert("RGBA")

def render_cta_frames(W, H, out_dir, is_tall=False):
    f_header = ImageFont.truetype(FONT_BOLD, 36 if not is_tall else 34)
    f_title  = ImageFont.truetype(FONT_BOLD, 92 if not is_tall else 86)
    f_sub    = ImageFont.truetype(FONT_REG, 34 if not is_tall else 32)
    f_link   = ImageFont.truetype(FONT_BOLD, 32 if not is_tall else 28)
    f_cta    = ImageFont.truetype(FONT_BOLD, 28 if not is_tall else 26)

    # Base background (deep space navy gradient with subtle stars)
    base = Image.new("RGBA", (W, H), (8, 11, 20, 255))
    d_base = ImageDraw.Draw(base)
    # Draw simple stars
    import random
    rng = random.Random(42)
    for _ in range(120):
        sx = rng.randint(0, W)
        sy = rng.randint(0, H)
        br = rng.randint(120, 255)
        rad = rng.choice([1, 1, 1, 2])
        d_base.ellipse((sx-rad, sy-rad, sx+rad, sy+rad), fill=(br, br, br, 255))

    # Resize QR code
    qr_size = 280 if not is_tall else 320
    qr_scaled = qr_img.resize((qr_size, qr_size), Image.Resampling.LANCZOS)

    # Render 144 frames (6 seconds at 24 fps)
    for f in range(144):
        im = base.copy()
        d = ImageDraw.Draw(im)
        u = min(1.0, f / 18.0) # Smooth entry fade
        alpha = int(255 * u)

        # Pulse on border
        pulse = 0.5 + 0.5 * math.sin(f * 0.1)
        border_col = (int(100 + pulse*80), int(180 + pulse*75), 255, alpha)

        if not is_tall:
            # 16:9 Landscape Layout
            # Left side: Text info
            d.text((140, 260), "ASTROLOG PRESENTS", font=f_header, fill=(130, 215, 255, alpha))
            d.text((135, 320), "LAST SIGNAL", font=f_title, fill=(255, 225, 70, alpha))
            d.text((140, 440), "Abandoned, but not forgotten.", font=f_sub, fill=(210, 220, 235, alpha))
            d.text((140, 520), "Explore Apollo relics & Martian rovers on the Moon & Mars.", font=f_sub, fill=(170, 185, 205, alpha))
            d.text((140, 620), "Record findings in the ASTROLOG logbook.", font=f_cta, fill=(140, 230, 200, alpha))

            # Right side: QR Code in high-tech card
            qx = W - 140 - qr_size - 40
            qy = 260
            card_rect = (qx - 25, qy - 25, qx + qr_size + 25, qy + qr_size + 130)
            d.rounded_rectangle(card_rect, radius=16, fill=(18, 24, 42, alpha), outline=border_col, width=3)
            im.paste(qr_scaled, (qx, qy))

            d.text((qx + 10, qy + qr_size + 15), "SCAN TO PLAY ON ROBLOX", font=f_cta, fill=(255, 255, 255, alpha))
            d.text((qx - 5, qy + qr_size + 55), "roblox.com/games/104157966303180", font=ImageFont.truetype(FONT_BOLD, 20), fill=(140, 190, 255, alpha))
        else:
            # 4:5 Portrait Layout
            d.text(((W - d.textbbox((0,0), "ASTROLOG PRESENTS", font=f_header)[2])//2, 160), "ASTROLOG PRESENTS", font=f_header, fill=(130, 215, 255, alpha))
            d.text(((W - d.textbbox((0,0), "LAST SIGNAL", font=f_title)[2])//2, 220), "LAST SIGNAL", font=f_title, fill=(255, 225, 70, alpha))
            d.text(((W - d.textbbox((0,0), "Abandoned, but not forgotten.", font=f_sub)[2])//2, 335), "Abandoned, but not forgotten.", font=f_sub, fill=(210, 220, 235, alpha))

            # Centered QR Box
            qx = (W - qr_size) // 2
            qy = 460
            card_rect = (qx - 25, qy - 25, qx + qr_size + 25, qy + qr_size + 130)
            d.rounded_rectangle(card_rect, radius=16, fill=(18, 24, 42, alpha), outline=border_col, width=3)
            im.paste(qr_scaled, (qx, qy))

            d.text(((W - d.textbbox((0,0), "SCAN TO PLAY ON ROBLOX", font=f_cta)[2])//2, qy + qr_size + 18), "SCAN TO PLAY ON ROBLOX", font=f_cta, fill=(255, 255, 255, alpha))
            d.text(((W - d.textbbox((0,0), "roblox.com/games/104157966303180", font=ImageFont.truetype(FONT_BOLD, 22))[2])//2, qy + qr_size + 65), "roblox.com/games/104157966303180", font=ImageFont.truetype(FONT_BOLD, 22), fill=(140, 190, 255, alpha))

        im.convert("RGB").save(os.path.join(out_dir, f"cta_{f:04d}.jpg"), quality=94)

print("Rendering CTA 16:9 frames...")
render_cta_frames(1920, 1080, OUT_16x9, is_tall=False)
print("Rendering CTA 4:5 frames...")
render_cta_frames(1080, 1350, OUT_4x5, is_tall=True)
print("CTA cards rendering complete!")


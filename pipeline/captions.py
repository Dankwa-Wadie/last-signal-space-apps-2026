from PIL import Image, ImageDraw, ImageFont
import json, os
W,H=1080,1920
FONT="/System/Library/Fonts/Supplemental/Arial Bold.ttf"
lines=json.load(open("script.json"))
os.makedirs("caps",exist_ok=True)
for i,(s,e,txt) in enumerate(lines):
    size=104
    f=ImageFont.truetype(FONT,size)
    im=Image.new("RGBA",(W,H),(0,0,0,0)); d=ImageDraw.Draw(im)
    while d.textbbox((0,0),txt,font=f)[2] > W-120 and size>52:
        size-=4; f=ImageFont.truetype(FONT,size)
    bb=d.textbbox((0,0),txt,font=f)
    x=(W-(bb[2]-bb[0]))//2-bb[0]
    y=int(H*0.73)
    d.text((x,y),txt,font=f,fill=(245,231,60,255),stroke_width=10,stroke_fill=(0,0,0,240))
    im.save(f"caps/c{i:02d}.png")
print(f"{len(lines)} caption plates, last ends {lines[-1][1]}s")

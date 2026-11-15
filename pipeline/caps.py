from PIL import Image, ImageDraw, ImageFont
import os
W,H=1080,1920
FONT="/System/Library/Fonts/Supplemental/Arial Bold.ttf"
caps=[("Nobody",0.0,2.2),("has touched",2.2,4.4),("this",4.4,6.6),
      ("since",6.6,8.4),("1972",8.4,10.0)]
os.makedirs("caps",exist_ok=True)
f=ImageFont.truetype(FONT,96)
for i,(txt,s,e) in enumerate(caps):
    im=Image.new("RGBA",(W,H),(0,0,0,0)); d=ImageDraw.Draw(im)
    bb=d.textbbox((0,0),txt,font=f)
    x=(W-(bb[2]-bb[0]))//2 - bb[0]; y=int(H*0.60)
    d.text((x,y),txt,font=f,fill=(245,231,60,255),
           stroke_width=9,stroke_fill=(0,0,0,235))
    im.save(f"caps/c{i}.png")
print("\n".join(f"{i} {s} {e}" for i,(t,s,e) in enumerate(caps)))

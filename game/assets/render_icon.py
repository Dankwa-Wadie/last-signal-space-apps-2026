from math import hypot
from PIL import Image, ImageDraw, ImageFilter

S = 1024
im = Image.new("RGB", (S, S), "#091321")
p = im.load()
for y in range(S):
    for x in range(S):
        t = y / S
        glow = max(0, 1 - hypot((x - 520) / 690, (y - 590) / 670))
        p[x, y] = (int(7 + 17*t + 9*glow), int(15 + 20*t + 35*glow), int(29 + 23*t + 48*glow))
d = ImageDraw.Draw(im, "RGBA")

# Stars and Earth
for x, y, r in [(113,166,3),(261,107,2),(408,202,2),(877,143,3),(786,251,2),(935,351,2),(159,355,2),(340,309,2),(685,119,2)]:
    d.ellipse((x-r,y-r,x+r,y+r), fill=(220,239,250,210))
earth_glow = Image.new("RGBA", im.size)
eg = ImageDraw.Draw(earth_glow)
eg.ellipse((635,292,905,562), fill=(56,190,255,90))
im = Image.alpha_composite(im.convert("RGBA"), earth_glow.filter(ImageFilter.GaussianBlur(30)))
d = ImageDraw.Draw(im, "RGBA")
d.ellipse((679,336,861,518), fill=(34,117,178,255), outline=(165,232,255,220), width=4)
d.polygon([(696,389),(714,365),(742,366),(760,383),(753,403),(725,411),(711,440),(690,435),(682,410)], fill=(91,207,178,255))
d.polygon([(782,377),(802,370),(823,383),(827,403),(808,413),(793,397)], fill=(89,204,171,255))
d.polygon([(781,438),(811,425),(842,441),(837,465),(813,480),(789,460)], fill=(82,196,163,255))
d.arc((676,333,864,521), 190, 305, fill=(218,247,255,190), width=8)

# Signal rings
for box, start, end, width, alpha in [((346,393,469,516),220,140,10,235),((301,363,510,574),220,140,7,145),((572,393,695,516),40,-40,10,235),((531,363,740,574),40,-40,7,145)]:
    d.arc(box, start, end, fill=(77,218,255,alpha), width=width)

# Lunar terrain with a jagged ridge
d.polygon([(0,680),(119,637),(239,675),(341,611),(446,661),(558,622),(670,675),(782,623),(899,677),(1024,639),(1024,1024),(0,1024)], fill=(82,83,82,255))
for y, col in [(710,(131,126,111,255)),(770,(84,83,81,255)),(850,(54,58,65,255)),(950,(39,45,54,255))]:
    d.rectangle((0,y,1024,y+100), fill=col)
d.arc((-190,606,1210,875), 5, 175, fill=(204,194,169,100), width=12)
for poly in [[(84,807),(198,776),(258,794),(148,823)],[(679,754),(784,775),(834,804),(696,778)],[(263,922),(356,898),(414,917),(303,942)]]:
    d.polygon(poly, fill=(206,187,145,55))

# Soft ground shadows
shadow=Image.new("RGBA",im.size); sd=ImageDraw.Draw(shadow)
sd.ellipse((326,766,704,852), fill=(0,0,0,155))
im=Image.alpha_composite(im,shadow.filter(ImageFilter.GaussianBlur(18)))
d=ImageDraw.Draw(im,"RGBA")

# Abandoned reflector, mast, tripod
d.line((477,674,454,835), fill=(65,77,87,255), width=45)
d.line((558,674,582,835), fill=(50,66,79,255), width=46)
d.polygon([(483,663),(559,663),(590,838),(556,840),(523,736),(491,840),(455,838)], fill=(154,173,181,255), outline=(35,49,61,255))
d.polygon([(444,623),(475,575),(518,552),(560,575),(594,623),(559,650),(477,650)], fill=(211,222,218,255), outline=(66,83,94,255))
d.polygon([(457,619),(489,590),(520,578),(554,591),(580,620),(520,638)], fill=(110,140,153,255))
d.line((518,602,518,494), fill=(220,232,225,255), width=13)
d.line((486,563,518,494,555,565), fill=(194,212,212,255), width=11)
d.rounded_rectangle((503,481,533,586), radius=13, fill=(221,232,224,255), outline=(75,94,105,255), width=5)
d.line((478,650,405,783), fill=(177,190,190,255), width=12)
d.line((563,650,632,783), fill=(177,190,190,255), width=12)
d.line((518,720,423,783), fill=(142,158,164,255), width=10)
d.line((518,720,617,783), fill=(142,158,164,255), width=10)
d.line((380,783,426,783), fill=(232,197,103,255), width=11)
d.line((612,783,653,783), fill=(232,197,103,255), width=11)

# Beacon glow
glow=Image.new("RGBA",im.size); gd=ImageDraw.Draw(glow)
gd.ellipse((475,426,561,512), fill=(255,194,49,225))
im=Image.alpha_composite(im,glow.filter(ImageFilter.GaussianBlur(25)))
d=ImageDraw.Draw(im,"RGBA")
d.ellipse((497,450,539,492), fill=(255,205,67,255), outline=(255,242,183,255), width=4)
d.ellipse((506,459,530,483), fill=(255,251,215,255))

# Astronaut silhouette facing the artifact
d.ellipse((166,755,340,825), fill=(10,15,23,130))
d.polygon([(211,687),(231,651),(267,651),(291,687),(303,844),(284,855),(263,765),(251,854),(214,854),(226,766),(198,836),(176,825)], fill=(27,37,51,255), outline=(99,120,136,255))
d.rounded_rectangle((204,625,290,727), radius=35, fill=(208,221,219,255), outline=(246,232,197,255), width=8)
d.ellipse((220,637,278,700), fill=(13,26,43,255))
d.arc((220,637,278,700), 200, 315, fill=(92,215,255,230), width=5)
d.rectangle((212,712,283,747), fill=(70,91,109,255))
d.line((205,748,167,806), fill=(27,37,51,255), width=25)
d.line((282,748,313,806), fill=(27,37,51,255), width=25)

# Sparks and subtle outer vignette
d.polygon([(711,582),(721,607),(746,617),(721,627),(711,652),(701,627),(676,617),(701,607)], fill=(255,225,113,245))
d.polygon([(320,526),(327,543),(344,550),(327,557),(320,574),(313,557),(296,550),(313,543)], fill=(255,223,119,190))
for x,y,r in [(664,687,6),(354,713,5),(713,739,4)]: d.ellipse((x-r,y-r,x+r,y+r),fill=(255,224,128,220))
v=Image.new("RGBA",im.size); vp=v.load()
for y in range(S):
    for x in range(S):
        edge=max(abs(x-S/2),abs(y-S/2))/(S/2)
        a=int(max(0,edge-.68)*90)
        vp[x,y]=(3,7,13,a)
im=Image.alpha_composite(im,v)

# Roblox square icon: rounded corners are intentionally avoided so Roblox crops safely.
im.convert("RGB").save("game/assets/last-signal-icon.png", quality=95)

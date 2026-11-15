-- WORLD LAYOUT (v138). Every body we can land on is a ring of ground that wraps around:
-- walk far enough one way and you come back from the other, the way walking round a ball
-- brings you home. Each ring sits in its own band of the map, far beyond any draw distance.
-- Sites stand at their REAL latitude and longitude (NSSDCA), scaled onto their ring:
--   x = origin + (lon - lon0)/360 * W        z = -(lat - lat0)/180 * D   (north is -z)
-- The seam (where you wrap) is put in the widest gap between sites, so nothing pops.
-- Scale notes (also on the signs): the Moon ring is 8,192 studs round; Mars, which is really
-- twice the Moon's size, is 4,096 so every site stays a few minutes' walk apart; Eros is 1,024.
local L={}
L.WORLDS={
  moon={origin=Vector3.new(0,0,0),     W=8192,D=4096,lat0=0.674, lon0=23.473,seam=103,
        colour=Color3.fromRGB(128,126,122),material=Enum.Material.Sand,rock=Color3.fromRGB(96,95,92)},
  mars={origin=Vector3.new(20000,0,0), W=4096,D=2048,lat0=-1.95, lon0=-5.53, seam=41,
        colour=Color3.fromRGB(176,110,70),material=Enum.Material.Sand,rock=Color3.fromRGB(120,66,42)},
  eros={origin=Vector3.new(40000,0,0), W=1024,D=512, lat0=-41.626, lon0=80.421, seam=180,
        colour=Color3.fromRGB(150,135,110),material=Enum.Material.Slate,rock=Color3.fromRGB(110,98,80)},
}
for _,w in pairs(L.WORLDS) do
  w.R=w.W/(2*math.pi)                          -- radius of the ring, for the horizon curve
  w.xmin=w.origin.X+(w.seam-360)/360*w.W       -- the ring spans [xmin, xmin+W)
  w.zmin=-(90-w.lat0)/180*w.D                  -- north pole edge; spans [zmin, zmin+D)
end
-- old centres (before v138) -> where each site folder is relocated from
L.SITES={
  Tranquility={"moon",0.674,23.473,Vector3.new(0,0,0)},
  Procellarum={"moon",-3.016,-23.418,Vector3.new(-470,0,150)},
  Hadley={"moon",26.132,3.633,Vector3.new(430,0,-210)},
  Farside={"moon",-15.5,-130.7,Vector3.new(-900,0,-620)},
  Meridiani={"mars",-1.95,-5.53,Vector3.new(60,0,1500)},
  AresVallis={"mars",19.33,-33.55,Vector3.new(-210,0,1540)},
  Chryse={"mars",22.27,-47.95,Vector3.new(-470,0,1420)},
  Utopia={"mars",47.67,134.28,Vector3.new(-430,0,1760)},
  Gusev={"mars",-14.57,175.48,Vector3.new(330,0,1420)},
  VastitasBorealis={"mars",68.15,-125.9,Vector3.new(-150,0,1210)},
  Elysium={"mars",4.5,135.62,Vector3.new(360,0,1740)},
  Jezero={"mars",18.45,77.45,Vector3.new(60,0,1830)},
  Eros={"eros",-41.626,80.421,Vector3.new(1500,0,-500)},
}
function L.worldAt(p)
  if p.X>30000 then return "eros" elseif p.X>10000 then return "mars" end
  return "moon"
end
function L.pos(world,lat,lon)
  local w=L.WORLDS[world]
  local d=((lon-w.lon0+180)%360)-180
  if d>=w.seam then d-=360 end
  return Vector3.new(w.origin.X+d/360*w.W,0,-(lat-w.lat0)/180*w.D)
end
function L.siteCentre(name) local s=L.SITES[name] return L.pos(s[1],s[2],s[3]) end
function L.latlon(world,p)
  local w=L.WORLDS[world]
  local lon=w.lon0+(p.X-w.origin.X)/w.W*360
  lon=((lon+180)%360)-180
  local lat=w.lat0-(p.Z)/w.D*180
  return lat,lon
end
-- bring a position back inside its ring (used when a player walks off the seam)
function L.wrap(world,p)
  local w=L.WORLDS[world]
  local x,z=p.X,p.Z
  if x<w.xmin then x+=w.W elseif x>=w.xmin+w.W then x-=w.W end
  if z<w.zmin then z+=w.D elseif z>=w.zmin+w.D then z-=w.D end
  return Vector3.new(x,p.Y,z)
end
return L

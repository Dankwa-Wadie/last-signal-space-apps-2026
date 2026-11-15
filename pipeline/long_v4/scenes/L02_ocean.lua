-- "We sailed across every ocean": a two-masted brig under sail, crewed. Built to human scale
-- (1 stud ~ 0.31 m: hull ~30 m, mainmast ~22 m), so the sailors read on deck.
local s=wipe(); daySky(17.35, Color3.fromRGB(214,200,188)); ocean(Color3.fromRGB(20,70,92))
local ship=Instance.new("Model"); ship.Name="SHIP"; ship.Parent=s
local WOOD=Color3.fromRGB(92,58,34); local DARKW=Color3.fromRGB(52,34,22); local DECK=Color3.fromRGB(168,128,84)
local SAIL=Color3.fromRGB(236,228,206); local ROPE=Color3.fromRGB(60,48,36)
local function P(n,sz,cf,col,mat,cls)
  local p=Instance.new(cls or "Part"); p.Name=n; p.Size=sz; p.CFrame=cf; p.Anchored=true; p.CanCollide=false
  p.Color=col; p.Material=mat or Enum.Material.Wood; p.TopSurface=Enum.SurfaceType.Smooth; p.BottomSurface=Enum.SurfaceType.Smooth
  p.Parent=ship; return p
end
local L,B,D=84,20,10           -- hull length (along -Z = bow), beam, depth
-- hull: main body, tapered bow (wedges) and a squared stern
P("Hull",Vector3.new(B,D,L*0.7),CFrame.new(0,0,4),WOOD)
P("HullLow",Vector3.new(B*0.8,3,L*0.72),CFrame.new(0,-5.5,4),DARKW)
-- pointed bow: the two hull sides angle in to the stem; the deck narrows in slices to match
local zf=4-L*0.35                      -- front of the straight hull
local Lb=22                            -- bow length
for _,sx in ipairs({-1,1}) do
  local a=Vector3.new(sx*B/2,0,zf); local b=Vector3.new(0,0,zf-Lb)
  local len=(b-a).Magnitude
  P("BowSide",Vector3.new(1.0,D,len),CFrame.lookAt((a+b)/2,b),WOOD)
  P("BowStripe",Vector3.new(1.2,1.0,len),CFrame.lookAt((a+b)/2+Vector3.new(0,2.2,0),b+Vector3.new(0,2.2,0)),Color3.fromRGB(230,222,200),Enum.Material.SmoothPlastic)
  P("BowRail",Vector3.new(0.6,1.6,len),CFrame.lookAt((a+b)/2+Vector3.new(0,D/2+1,0),b+Vector3.new(0,D/2+1,0)),DARKW)
end
for i=0,5 do
  local u=(i+0.5)/6
  P("BowDeck",Vector3.new(B*(1-u)-0.6,0.4,Lb/6+0.1),CFrame.new(0,D/2+0.2,zf-Lb*u),DECK)
  P("BowFill",Vector3.new(B*(1-u)-1.0,D-0.4,Lb/6+0.1),CFrame.new(0,0,zf-Lb*u),WOOD)
end
P("Stem",Vector3.new(1.0,D+3,1.0),CFrame.new(0,1.5,zf-Lb),DARKW)
P("Stripe",Vector3.new(B+0.2,1.0,L*0.7),CFrame.new(0,2.2,4),Color3.fromRGB(230,222,200),Enum.Material.SmoothPlastic)
P("Deck",Vector3.new(B-1,0.4,L*0.7),CFrame.new(0,D/2+0.2,4),DECK)
-- gunwales (rails) along both sides
for _,sx in ipairs({-1,1}) do P("Rail",Vector3.new(0.6,1.6,L*0.7),CFrame.new(sx*(B/2-0.3),D/2+1.0,4),DARKW) end
P("Quarterdeck",Vector3.new(B-1,2.4,L*0.18),CFrame.new(0,D/2+1.4,4+L*0.26),DECK)
P("Bowsprit",Vector3.new(1.2,1.2,26),CFrame.new(0,D/2+4.5,zf-Lb-10)*CFrame.Angles(math.rad(-12),0,0),DARKW)
-- masts, yards and square sails, slightly bellied by the wind (three angled panels each)
local masts={{-14,62},{14,56}}
for mi,m in ipairs(masts) do
  local mz,mh=m[1],m[2]
  P("Mast",Vector3.new(1.6,mh,1.6),CFrame.new(0,D/2+mh/2,mz),DARKW)
  for yi=0,2 do
    local yy=D/2+16+yi*15; local w=36-yi*8
    P("Yard",Vector3.new(w,0.8,0.8),CFrame.new(0,yy+6.5,mz-0.6),DARKW)
    for pi=-1,1 do
      local pw=w/3
      local sail=P("Sail",Vector3.new(pw,12.5,0.25),CFrame.new(pi*pw,yy,mz-1.6+math.abs(pi)*0.9)*CFrame.Angles(0,math.rad(-pi*11),0),SAIL,Enum.Material.Fabric)
    end
  end
  P("Nest",Vector3.new(6,1,6),CFrame.new(0,D/2+mh-10,mz),DARKW)
end
-- rigging: shrouds from the rails up the masts, and stays fore and aft
local function line(a,b)
  local mid=(a+b)/2; local len=(b-a).Magnitude
  P("Rope",Vector3.new(0.18,0.18,len),CFrame.lookAt(mid,b),ROPE,Enum.Material.Fabric)
end
for _,m in ipairs(masts) do
  for _,sx in ipairs({-1,1}) do for j=-1,1 do
    line(Vector3.new(sx*(B/2),D/2+1.6,m[1]+j*3),Vector3.new(0,D/2+m[2]-10,m[1]))
  end end
end
line(Vector3.new(0,D/2+62,-14),Vector3.new(0,D/2+6,-L*0.5-20))
line(Vector3.new(0,D/2+56,14),Vector3.new(0,D/2+62,-14))
P("Wheel",Vector3.new(0.4,3.2,3.2),CFrame.new(0,D/2+4.6,4+L*0.3)*CFrame.Angles(0,math.rad(90),0),DARKW,Enum.Material.Wood,"Part").Shape=Enum.PartType.Cylinder
P("Lantern",Vector3.new(1,1.4,1),CFrame.new(0,D/2+5,4+L*0.35),Color3.fromRGB(255,210,120),Enum.Material.Neon)
-- the crew
local crew={
  {"Helmsman",CFrame.new(0,D/2+2.6+2.9,4+L*0.28)*CFrame.Angles(0,math.rad(0),0),Color3.fromRGB(150,40,40)},
  {"Lookout", CFrame.new(1.2,D/2+62-10+0.5+2.9,-14)*CFrame.Angles(0,math.rad(180),0),Color3.fromRGB(40,70,140)},
  {"Bosun",   CFrame.new(-5,D/2+0.4+2.9,-4)*CFrame.Angles(0,math.rad(200),0),Color3.fromRGB(230,226,210)},
  {"Sailor1", CFrame.new(5,D/2+0.4+2.9,2)*CFrame.Angles(0,math.rad(160),0),Color3.fromRGB(60,90,60)},
  {"Sailor2", CFrame.new(-6,D/2+0.4+2.9,10)*CFrame.Angles(0,math.rad(90),0),Color3.fromRGB(200,180,120)},
  {"Sailor3", CFrame.new(3,D/2+0.4+2.9,-22)*CFrame.Angles(0,math.rad(180),0),Color3.fromRGB(120,40,30)},
  {"Bowman",  CFrame.new(-2,D/2+0.4+2.9,-32)*CFrame.Angles(0,math.rad(180),0),Color3.fromRGB(40,40,60)},
}
for i,c in ipairs(crew) do
  local m,an=explorer(c[1],c[2],c[3],Color3.fromRGB(60,48,40),Color3.fromRGB(150+i*8,105+i*5,72))
  m.Parent=ship
  play(an,(i==4 or i==6) and "walk" or "idle",0.7,i*0.37)
end
-- the ship sits in the water: sink it so the waterline is ~2/3 up the hull
ship.WorldPivot=CFrame.new()          -- default pivot is the bounding-box centre (up in the masts)
ship:PivotTo(CFrame.new(0,-1.5,0)*CFrame.Angles(0,math.rad(90),0))
ship:SetAttribute("P0",ship:GetPivot())
return "L02"

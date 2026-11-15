-- Hadley-Apennine: Apollo 15, 30 July - 2 Aug 1971. 26.13239 N, 3.63330 E.
-- The rover, the Falcon descent stage and the largest of the laser retroreflectors.
local game_=workspace:WaitForChild("Game")
local old=game_:FindFirstChild("Hadley"); if old then old:Destroy() end
local F=Instance.new("Folder"); F.Name="Hadley"; F.Parent=game_
local OX,OZ = 430, -210
local M = 2.4

local pan=Instance.new("Part")
pan.Name="Ground"; pan.Anchored=true; pan.Size=Vector3.new(260,4,260)
pan.Position=Vector3.new(OX,-2,OZ); pan.Color=Color3.fromRGB(112,110,106)
pan.Material=Enum.Material.Sand; pan.TopSurface=Enum.SurfaceType.Smooth; pan.Parent=F

-- the Apennine front: highland crust thrown up by the Imbrium impact, on one side only
for i=1,11 do
  local m=Instance.new("Part")
  m.Name="Apennine"; m.Anchored=true
  local w=90+((i*37)%60)
  m.Size=Vector3.new(w,60+((i*23)%48),w)
  m.Shape=Enum.PartType.Ball
  m.Position=Vector3.new(OX-150+i*31, -26-((i*11)%14), OZ-140-((i*17)%30))
  m.Color=Color3.fromRGB(126,124,120); m.Material=Enum.Material.Slate; m.Parent=F
end
-- Hadley Rille: a collapsed lava channel, on the other side
for i=1,16 do
  local r=Instance.new("Part")
  r.Name="Rille"; r.Anchored=true
  r.Size=Vector3.new(26,9,30)
  r.Position=Vector3.new(OX-120+i*16, -4.2, OZ+96+math.sin(i*0.6)*16)
  r.Color=Color3.fromRGB(74,72,70); r.Material=Enum.Material.Slate; r.Parent=F
end

local function attrs(m,t) for k,v in pairs(t) do m:SetAttribute(k,v) end end
local function anchorFor(m,pos,action,object)
  local a=Instance.new("Part"); a.Name="Anchor"; a.Size=Vector3.new(1,1,1)
  a.Transparency=1; a.CanCollide=false; a.Anchored=true; a.CFrame=CFrame.new(pos); a.Parent=m
  local pp=Instance.new("ProximityPrompt")
  pp.ActionText=action; pp.ObjectText=object; pp.KeyboardKeyCode=Enum.KeyCode.E
  pp.HoldDuration=0.25; pp.MaxActivationDistance=12; pp.RequiresLineOfSight=false; pp.Parent=a
end
local function P(parent,base,n,sz,cf,col,mat)
  local p=Instance.new("Part"); p.Name=n; p.Anchored=true; p.CanCollide=false
  p.Size=sz*M; p.CFrame=base*CFrame.new(cf.Position*M)*(cf-cf.Position)
  p.Color=col; p.Material=mat or Enum.Material.SmoothPlastic
  p.TopSurface=Enum.SurfaceType.Smooth; p.BottomSurface=Enum.SurfaceType.Smooth
  p.Parent=parent; return p
end
local FOIL=Color3.fromRGB(226,226,220)
local GOLD=Color3.fromRGB(214,176,70)
local DARKC=Color3.fromRGB(46,46,50)

-- ---------- Falcon descent stage ----------
local fal=Instance.new("Model"); fal.Name="Falcon_DescentStage"; fal.Parent=F
local fb=CFrame.new(Vector3.new(OX-30,0,OZ-18))*CFrame.Angles(0,math.rad(24),0)
P(fal,fb,"Body",Vector3.new(4.3,1.7,4.3),CFrame.new(0,1.95,0),GOLD,Enum.Material.Foil)
P(fal,fb,"Skirt",Vector3.new(3.6,0.7,3.6),CFrame.new(0,0.95,0),DARKC,Enum.Material.Metal)
P(fal,fb,"Bell",Vector3.new(1.5,1.0,1.5),CFrame.new(0,0.45,0),Color3.fromRGB(40,38,36),Enum.Material.Metal)
for i=0,3 do
  local a=math.rad(45+i*90)
  local lx,lz=math.sin(a)*2.5,math.cos(a)*2.5
  P(fal,fb,"Leg"..i,Vector3.new(0.16,2.6,0.16),
    CFrame.new(lx,1.2,lz)*CFrame.Angles(math.rad(lz*7),0,math.rad(-lx*7)),FOIL,Enum.Material.Metal)
  P(fal,fb,"Pad"..i,Vector3.new(0.95,0.18,0.95),CFrame.new(lx*1.3,0.09,lz*1.3),FOIL,Enum.Material.Metal)
end
attrs(fal,{ArtifactId="falcon",Title="Apollo 15 Lunar Module — Descent Stage \"Falcon\"",
  Year="Landed 30 July 1971",
  What="The lower half of the lander: engine, tanks, landing gear, and the bays that carried the rover and the science packages down.",
  Why="Like Eagle at Tranquility, it was the launch platform the ascent stage pushed off from. It was never coming back.",
  Science="Apollo 15 was the first of the long stays — three days on the surface and nearly 19 hours outside, against Apollo 11's two and a half. It still stands here, and orbiting cameras still use it as a fixed point."})
anchorFor(fal,Vector3.new(OX-30,4.2,OZ-18),"Scan","Falcon descent stage")

-- ---------- Lunar Roving Vehicle ----------
local rov=Instance.new("Model"); rov.Name="LunarRover"; rov.Parent=F
local rb=CFrame.new(Vector3.new(OX+22,0,OZ+10))*CFrame.Angles(0,math.rad(-62),0)
P(rov,rb,"Chassis",Vector3.new(3.1,0.22,1.8),CFrame.new(0,0.75,0),FOIL,Enum.Material.Foil)
P(rov,rb,"Floor",Vector3.new(2.6,0.08,1.5),CFrame.new(0,0.86,0),Color3.fromRGB(190,190,186))
for i=-1,1,2 do
  P(rov,rb,"SeatBack",Vector3.new(0.12,0.75,0.62),CFrame.new(-0.42,1.22,i*0.42),Color3.fromRGB(232,232,228))
  P(rov,rb,"SeatBase",Vector3.new(0.62,0.1,0.62),CFrame.new(-0.1,0.9,i*0.42),Color3.fromRGB(232,232,228))
end
for _,wz in ipairs({0.95,-0.95}) do
  for _,wx in ipairs({1.15,-1.15}) do
    local w=P(rov,rb,"Wheel",Vector3.new(0.22,0.82,0.82),
      CFrame.new(wx,0.41,wz)*CFrame.Angles(0,0,math.rad(90)),DARKC,Enum.Material.Fabric)
    w.Shape=Enum.PartType.Cylinder
    w.CFrame=rb*CFrame.new(Vector3.new(wx,0.41,wz)*M)*CFrame.Angles(math.rad(90),0,math.rad(90))
  end
end
-- the umbrella-shaped high-gain antenna: live TV only worked with this aimed at Earth,
-- and only while the rover was stopped
P(rov,rb,"HGAMast",Vector3.new(0.07,1.25,0.07),CFrame.new(1.25,1.45,0),FOIL,Enum.Material.Metal)
local dish=P(rov,rb,"HighGainDish",Vector3.new(0.06,1.5,1.5),
  CFrame.new(1.25,2.15,0),FOIL,Enum.Material.Foil)
dish.Shape=Enum.PartType.Cylinder
dish.CFrame=rb*CFrame.new(Vector3.new(1.25,2.15,0)*M)*CFrame.Angles(0,math.rad(90),math.rad(62))
P(rov,rb,"LowGain",Vector3.new(0.05,0.9,0.05),CFrame.new(1.0,1.3,0.5),Color3.fromRGB(200,200,196),Enum.Material.Metal)
P(rov,rb,"TVCamera",Vector3.new(0.3,0.3,0.42),CFrame.new(1.05,1.52,-0.42),Color3.fromRGB(226,226,222),Enum.Material.Metal)
P(rov,rb,"Console",Vector3.new(0.4,0.3,0.5),CFrame.new(0.55,1.05,0),Color3.fromRGB(205,205,200))
attrs(rov,{ArtifactId="lrv",Title="Lunar Roving Vehicle (LRV-1)",
  Year="Driven 31 July – 2 Aug 1971",
  What="A folding, battery-electric car that rode down strapped to the side of the lander. Four wheels of woven piano wire, a top speed of about 13 km/h, and two antennas: a low-gain antenna oriented during traverses and a high-gain dish for television when stopped.",
  Why="To get the crew out to the mountain front and the edge of Hadley Rille and back, carrying tools and rock boxes, within walking distance of safety if it ever failed.",
  Science="It turned a landing site into a field area: Apollo 15 covered about 28 km of ground in three drives. The dish is the reason anyone on Earth saw it happen — but it had to be stopped and re-aimed at Earth before the pictures could come."})
anchorFor(rov,Vector3.new(OX+22,2.6,OZ+10),"Scan","Lunar Roving Vehicle")

-- ---------- Apollo 15 laser retroreflector ----------
local lr=Instance.new("Model"); lr.Name="Retroreflector15"; lr.Parent=F
local lb=CFrame.new(Vector3.new(OX-4,0,OZ+44))*CFrame.Angles(0,math.rad(14),0)
P(lr,lb,"Base",Vector3.new(1.5,0.1,1.2),CFrame.new(0,0.32,0),Color3.fromRGB(196,196,192),Enum.Material.Metal)
local panelp=P(lr,lb,"Array",Vector3.new(1.42,0.12,1.1),
  CFrame.new(0,0.52,0)*CFrame.Angles(math.rad(-26),0,0),Color3.fromRGB(28,30,38),Enum.Material.Glass)
panelp.Reflectance=0.42
for i=-1,1,2 do
  P(lr,lb,"Foot",Vector3.new(0.09,0.34,0.09),CFrame.new(i*0.6,0.17,0.42),Color3.fromRGB(196,196,192),Enum.Material.Metal)
end
P(lr,lb,"Handle",Vector3.new(0.06,0.5,0.06),CFrame.new(0,0.75,-0.5),Color3.fromRGB(220,200,90),Enum.Material.Metal)
attrs(lr,{ArtifactId="lrrr15",Title="Laser Ranging Retroreflector (Apollo 15)",
  Year="Deployed 31 July 1971",
  What="Three hundred corner-cube prisms in two panels — three times the array Apollo 11 left, and still the largest on the Moon.",
  Why="More cubes means more photons come home, so observatories can range on it in worse conditions and get a cleaner measurement.",
  Science="You have seen one of these before, at Tranquility. With 300 corner cubes, this is the largest Apollo reflector array; Apollo 11 and 14 each left 100. The arrays remain part of lunar laser-ranging research, the Apollo surface experiment still returning data more than fifty years on."})
anchorFor(lr,Vector3.new(OX-4,1.8,OZ+44),"Scan","Laser Ranging Retroreflector")

-- ---------- site sign ----------
local sign=Instance.new("Model"); sign.Name="SiteSign"; sign.Parent=F
local sb=CFrame.lookAt(Vector3.new(OX+6,0,OZ+78),Vector3.new(OX+6,0,OZ))
local function SP(n,sz,cf,col)
  local p=Instance.new("Part"); p.Name=n; p.Anchored=true; p.Size=sz; p.CFrame=sb*cf
  p.Color=col; p.Material=Enum.Material.Metal; p.Parent=sign; return p
end
SP("Post",Vector3.new(0.2,4.2,0.2),CFrame.new(-2.3,2.1,0),Color3.fromRGB(190,190,186))
SP("Post2",Vector3.new(0.2,4.2,0.2),CFrame.new(2.3,2.1,0),Color3.fromRGB(190,190,186))
local board=SP("Board",Vector3.new(5.2,2.3,0.12),CFrame.new(0,3.3,0),Color3.fromRGB(14,14,16))
board.Material=Enum.Material.SmoothPlastic
local sg=Instance.new("SurfaceGui"); sg.Face=Enum.NormalId.Back; sg.CanvasSize=Vector2.new(620,274)
sg.LightInfluence=0; sg.Parent=board
local function T(txt,y,h,font,col)
  local l=Instance.new("TextLabel"); l.Size=UDim2.new(1,-28,0,h); l.Position=UDim2.fromOffset(14,y)
  l.BackgroundTransparency=1; l.Font=font; l.TextColor3=col; l.Text=txt
  l.TextScaled=true; l.TextXAlignment=Enum.TextXAlignment.Left; l.Parent=sg
end
T("HADLEY–APENNINE",12,44,Enum.Font.GothamBold,Color3.fromRGB(245,231,60))
T("26.13239 N, 3.63330 E  ·  Apollo 15, July 1971",62,30,Enum.Font.GothamMedium,Color3.fromRGB(215,215,220))
T("The mountains are the rim of the Imbrium basin.",102,28,Enum.Font.Gotham,Color3.fromRGB(165,170,176))
T("The channel to the north is Hadley Rille, a collapsed lava tube.",134,28,Enum.Font.Gotham,Color3.fromRGB(165,170,176))
T("HERITAGE SITE  ·  DO NOT DISTURB",176,34,Enum.Font.GothamBold,Color3.fromRGB(150,205,255))

return "Hadley built at ("..OX..",0,"..OZ..")"

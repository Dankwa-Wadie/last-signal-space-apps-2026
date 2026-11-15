-- Oceanus Procellarum: the Surveyor 3 / Apollo 12 site.
-- Surveyor 3 is the only discarded spacecraft anyone ever went back to visit: Apollo 12 landed
-- about 180 m away in Nov 1969 and the crew cut pieces off it. Real site 3.0162 S, 23.418 W.
-- The walk from Tranquility is a deliberate compression; the real sites are ~1,400 km apart,
-- and the sign at the site says so.
local B=(function()
EQUIPMENT_MODELS
end)()

local game_=workspace:WaitForChild("Game")
local old=game_:FindFirstChild("Procellarum"); if old then old:Destroy() end
local F=Instance.new("Folder"); F.Name="Procellarum"; F.Parent=game_

local OX,OZ = -470, 150     -- a walk west of Tranquility
local M = 2.4               -- the same metres->studs scale as the Eagle

-- ground: a shallow regolith pan, a little greyer than Tranquility's
local pan=Instance.new("Part")
pan.Name="Ground"; pan.Anchored=true; pan.Size=Vector3.new(220,4,220)
pan.Position=Vector3.new(OX,-2,OZ); pan.Color=Color3.fromRGB(104,102,99)
pan.Material=Enum.Material.Sand; pan.TopSurface=Enum.SurfaceType.Smooth; pan.Parent=F
-- a low crater rim so the site reads as its own place, not a corner of the first one
for i=0,23 do
  local a=math.rad(i*15)
  local r=Instance.new("Part")
  r.Name="Rim"; r.Anchored=true; r.Size=Vector3.new(30,7,30)
  r.Shape=Enum.PartType.Ball
  r.Position=Vector3.new(OX+math.sin(a)*112,-2.5,OZ+math.cos(a)*112)
  r.Color=Color3.fromRGB(96,94,92); r.Material=Enum.Material.Sand; r.Parent=F
end

local function attrs(m,t)
  for k,v in pairs(t) do m:SetAttribute(k,v) end
end

local function anchorFor(m,pos,action,object)
  local a=Instance.new("Part"); a.Name="Anchor"; a.Size=Vector3.new(1,1,1)
  a.Transparency=1; a.CanCollide=false; a.Anchored=true; a.CFrame=CFrame.new(pos); a.Parent=m
  local pp=Instance.new("ProximityPrompt")
  pp.ActionText=action; pp.ObjectText=object; pp.KeyboardKeyCode=Enum.KeyCode.E
  pp.HoldDuration=0.25; pp.MaxActivationDistance=12; pp.RequiresLineOfSight=false; pp.Parent=a
  return a
end

-- ---------- Surveyor 3 ----------
local s3base=CFrame.new(Vector3.new(OX-14,0,OZ+6))*CFrame.Angles(0,math.rad(28),0)
local s3=B.surveyor3(s3base,F)
s3.Name="Surveyor3"
attrs(s3,{
  ArtifactId="surv3",
  Title="Surveyor 3",
  Year="Landed 20 April 1967",
  What="A three-legged robotic lander with a scoop on an arm, sent before anyone knew whether a spacecraft would sink into the lunar surface.",
  Why="To prove a soft landing was possible, and to find out whether the ground could hold a crewed lander. Its engine cut out late, so it bounced twice before settling.",
  Science="It showed the regolith was firm enough to land on and walk on. Two and a half years later Apollo 12 touched down about 180 m away — the only time anyone has gone back to visit something we had left behind. Conrad and Bean cut pieces off it and carried them home; its TV camera is in the Smithsonian.",
})
anchorFor(s3,Vector3.new(OX-14,2.2,OZ+6),"Scan","Surveyor 3")

-- ---------- Apollo 12 ALSEP (central station + PSE) ----------
local al=Instance.new("Model"); al.Name="Apollo12_ALSEP"; al.Parent=F
local abase=CFrame.new(Vector3.new(OX+16,0,OZ-10))*CFrame.Angles(0,math.rad(-35),0)
local function P(n,sz,cf,col,mat,parent)
  local p=Instance.new("Part"); p.Name=n; p.Anchored=true; p.CanCollide=false
  p.Size=sz*M; p.CFrame=abase*CFrame.new(cf.Position*M)*(cf-cf.Position)
  p.Color=col; p.Material=mat or Enum.Material.SmoothPlastic
  p.TopSurface=Enum.SurfaceType.Smooth; p.BottomSurface=Enum.SurfaceType.Smooth
  p.Parent=parent or al; return p
end
local FOIL=Color3.fromRGB(226,226,220)
local DARKC=Color3.fromRGB(52,52,56)
-- central station: a flat box under a sunshade, with the dish-on-a-mast aimed at Earth
local central=P("Central",Vector3.new(0.78,0.26,0.60),CFrame.new(0,0.33,0),FOIL,Enum.Material.Foil)
P("Shade",Vector3.new(0.92,0.03,0.74),CFrame.new(0,0.50,0),Color3.fromRGB(240,240,236),Enum.Material.Foil)
for i=-1,1,2 do
  P("Leg",Vector3.new(0.04,0.42,0.04),CFrame.new(i*0.32,0.21,0.22),Color3.fromRGB(188,188,184),Enum.Material.Metal)
  P("Leg",Vector3.new(0.04,0.42,0.04),CFrame.new(i*0.32,0.21,-0.22),Color3.fromRGB(188,188,184),Enum.Material.Metal)
end
P("Mast",Vector3.new(0.035,0.86,0.035),CFrame.new(0.18,0.95,0),Color3.fromRGB(188,188,184),Enum.Material.Metal)
local dish=P("Dish",Vector3.new(0.05,0.46,0.46),CFrame.new(0.18,1.40,0)*CFrame.Angles(0,math.rad(90),math.rad(58)),FOIL,Enum.Material.Foil)
dish.Shape=Enum.PartType.Cylinder
-- the SNAP-27 radioisotope generator, standing off on its own: this is why Apollo 12's
-- station outlived Apollo 11's solar-powered one
local rtg=P("RTG",Vector3.new(0.25,0.46,0.25),CFrame.new(-0.95,0.40,0.30),Color3.fromRGB(96,96,100),Enum.Material.Metal)
rtg.Shape=Enum.PartType.Cylinder
rtg.CFrame=abase*CFrame.new(Vector3.new(-0.95,0.40,0.30)*M)*CFrame.Angles(0,0,math.rad(90))
P("RTGFins",Vector3.new(0.40,0.05,0.40),CFrame.new(-0.95,0.65,0.30),Color3.fromRGB(80,80,84),Enum.Material.Metal)
P("Cable",Vector3.new(0.70,0.02,0.02),CFrame.new(-0.52,0.10,0.30),DARKC)
-- the passive seismic experiment, a short cable away
P("PSE",Vector3.new(0.30,0.22,0.30),CFrame.new(0.62,0.28,0.70),FOIL,Enum.Material.Foil)
P("PSESkirt",Vector3.new(0.52,0.02,0.52),CFrame.new(0.62,0.17,0.70),Color3.fromRGB(236,236,232),Enum.Material.Foil)
P("Cable2",Vector3.new(0.52,0.02,0.02),CFrame.new(0.36,0.10,0.48),DARKC)
attrs(al,{
  ArtifactId="a12alsep",
  Title="Apollo 12 ALSEP",
  Year="Deployed 19 November 1969",
  What="The first full Apollo science station: a central transmitter, a seismometer, and a SNAP-27 nuclear generator standing off to one side on its own cable.",
  Why="Apollo 11's seismometer ran on sunlight and died within weeks. This one had a radioisotope generator, so it could keep working through the two-week lunar night.",
  Science="Days after the crew left, their ascent stage was deliberately crashed into the Moon 73 km away. This seismometer heard the Moon ring for about 55 minutes — dry, deeply fractured rock with no water in it to damp the shaking. It kept listening until every ALSEP station was switched off on 30 September 1977.",
})
anchorFor(al,Vector3.new(OX+16,2.0,OZ-10),"Scan","Apollo 12 ALSEP")

-- ---------- the site sign: says where this really is, and how far ----------
local sign=Instance.new("Model"); sign.Name="SiteSign"; sign.Parent=F
local sbase=CFrame.lookAt(Vector3.new(OX,0,OZ+40),Vector3.new(OX,0,OZ))
local function SP(n,sz,cf,col,mat)
  local p=Instance.new("Part"); p.Name=n; p.Anchored=true; p.Size=sz; p.CFrame=sbase*cf
  p.Color=col; p.Material=mat or Enum.Material.Metal
  p.TopSurface=Enum.SurfaceType.Smooth; p.BottomSurface=Enum.SurfaceType.Smooth; p.Parent=sign
  return p
end
SP("Post",Vector3.new(0.2,4.2,0.2),CFrame.new(-2.3,2.1,0),Color3.fromRGB(190,190,186))
SP("Post2",Vector3.new(0.2,4.2,0.2),CFrame.new(2.3,2.1,0),Color3.fromRGB(190,190,186))
local board=SP("Board",Vector3.new(5.2,2.3,0.12),CFrame.new(0,3.3,0),Color3.fromRGB(14,14,16),Enum.Material.SmoothPlastic)
local sg=Instance.new("SurfaceGui"); sg.Face=Enum.NormalId.Back; sg.CanvasSize=Vector2.new(620,274)
sg.LightInfluence=0; sg.Parent=board
local function T(txt,y,h,font,col)
  local l=Instance.new("TextLabel"); l.Size=UDim2.new(1,-28,0,h); l.Position=UDim2.fromOffset(14,y)
  l.BackgroundTransparency=1; l.Font=font; l.TextColor3=col; l.Text=txt
  l.TextScaled=true; l.TextXAlignment=Enum.TextXAlignment.Left; l.Parent=sg
end
T("OCEANUS PROCELLARUM",12,44,Enum.Font.GothamBold,Color3.fromRGB(245,231,60))
T("3.0162 S, 23.418 W  ·  Surveyor 3 and the Apollo 12 station",62,30,Enum.Font.GothamMedium,Color3.fromRGB(215,215,220))
T("The real site is about 1,400 km from Tranquility Base.",102,28,Enum.Font.Gotham,Color3.fromRGB(165,170,176))
T("The short walk is ours, not NASA's.",134,28,Enum.Font.Gotham,Color3.fromRGB(165,170,176))
T("HERITAGE SITE  ·  DO NOT DISTURB",176,34,Enum.Font.GothamBold,Color3.fromRGB(150,205,255))

return "Procellarum built at ("..OX..",0,"..OZ..") with "..#F:GetChildren().." objects"

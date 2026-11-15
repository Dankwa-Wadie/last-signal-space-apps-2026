-- Meridiani Planum, Mars: Opportunity (MER-B) and the heat shield it threw away on the
-- way down and later drove back to photograph. Landed 25 Jan 2004; last signal 10 Jun 2018.
local game_=workspace:WaitForChild("Game")
local old=game_:FindFirstChild("Meridiani"); if old then old:Destroy() end
local F=Instance.new("Folder"); F.Name="Meridiani"; F.Parent=game_
local OX,OZ = 60, 1500        -- a long way from the Moon sites; the transit console goes there
local M = 2.4
F:SetAttribute("World","Mars")
F:SetAttribute("Origin",Vector3.new(OX,0,OZ))

local pan=Instance.new("Part")
pan.Name="Ground"; pan.Anchored=true; pan.Size=Vector3.new(300,4,300)
pan.Position=Vector3.new(OX,-2,OZ); pan.Color=Color3.fromRGB(154,96,62)
pan.Material=Enum.Material.Sand; pan.TopSurface=Enum.SurfaceType.Smooth; pan.Parent=F
-- flat, dark, and almost featureless: Meridiani is a plain, which is why it was chosen
for i=1,30 do
  local d=Instance.new("Part")
  d.Name="Dune"; d.Anchored=true
  d.Size=Vector3.new(26+((i*13)%34),2.4,16+((i*7)%20))
  d.Position=Vector3.new(OX-130+((i*53)%260),-1.4,OZ-130+((i*83)%260))
  d.Orientation=Vector3.new(0,(i*37)%180,0)
  d.Color=Color3.fromRGB(140,84,54); d.Material=Enum.Material.Sand; d.Parent=F
end
-- the haematite "blueberries" that proved there had been water here
for i=1,46 do
  local b=Instance.new("Part")
  b.Name="Spherule"; b.Anchored=true; b.Shape=Enum.PartType.Ball
  b.Size=Vector3.new(0.5,0.5,0.5)
  b.Position=Vector3.new(OX-40+((i*29)%80),0.2,OZ-40+((i*47)%80))
  b.Color=Color3.fromRGB(78,62,58); b.Material=Enum.Material.Pebble; b.Parent=F
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
local CELL=Color3.fromRGB(34,46,92)
local BODY=Color3.fromRGB(216,214,206)
local DARKC=Color3.fromRGB(52,52,56)

-- ---------- Opportunity ----------
local op=Instance.new("Model"); op.Name="Opportunity"; op.Parent=F
local ob=CFrame.new(Vector3.new(OX-10,0,OZ-6))*CFrame.Angles(0,math.rad(36),0)
P(op,ob,"Deck",Vector3.new(1.6,0.14,1.3),CFrame.new(0,0.72,0),BODY,Enum.Material.Metal)
-- the three solar wings: the whole mission, and the whole tragedy, is here
P(op,ob,"PanelC",Vector3.new(1.5,0.05,1.2),CFrame.new(0,0.82,0),CELL,Enum.Material.Glass)
P(op,ob,"PanelL",Vector3.new(1.5,0.05,0.85),CFrame.new(0,0.80,-1.0)*CFrame.Angles(math.rad(6),0,0),CELL,Enum.Material.Glass)
P(op,ob,"PanelR",Vector3.new(1.5,0.05,0.85),CFrame.new(0,0.80,1.0)*CFrame.Angles(math.rad(-6),0,0),CELL,Enum.Material.Glass)
-- camera mast
P(op,ob,"Mast",Vector3.new(0.09,1.0,0.09),CFrame.new(0.5,1.25,0),BODY,Enum.Material.Metal)
P(op,ob,"PanCam",Vector3.new(0.5,0.16,0.14),CFrame.new(0.5,1.80,0),DARKC,Enum.Material.Metal)
P(op,ob,"HGA",Vector3.new(0.42,0.08,0.42),CFrame.new(-0.45,0.92,0.3),Color3.fromRGB(200,198,192),Enum.Material.Foil)
-- robotic arm, stowed
P(op,ob,"Arm",Vector3.new(0.7,0.08,0.08),CFrame.new(0.55,0.60,-0.3),Color3.fromRGB(180,178,172),Enum.Material.Metal)
for _,wz in ipairs({0.72,-0.72}) do
  for _,wx in ipairs({0.62,0,-0.62}) do
    local w=P(op,ob,"Wheel",Vector3.new(0.18,0.52,0.52),CFrame.new(wx,0.3,wz),DARKC,Enum.Material.Metal)
    w.Shape=Enum.PartType.Cylinder
    w.CFrame=ob*CFrame.new(Vector3.new(wx,0.3,wz)*M)*CFrame.Angles(math.rad(90),0,math.rad(90))
    P(op,ob,"Strut",Vector3.new(0.06,0.42,0.06),CFrame.new(wx*0.8,0.52,wz*0.8),Color3.fromRGB(170,168,162),Enum.Material.Metal)
  end
end
attrs(op,{ArtifactId="oppy",Title="Opportunity (MER-B)",
  Year="Landed 25 January 2004 · last signal 10 June 2018",
  What="A solar-powered field geologist the size of a golf cart: six wheels, a camera mast at about eye height, and an arm carrying a microscope and a rock grinder.",
  Why="To find out whether Mars ever had liquid water on its surface, by reading the rocks directly instead of guessing from orbit.",
  Science="In its first weeks, it found layered rocks and hematite spherules that supported a watery past. Built for 90 sols, Opportunity worked for more than 5,000 and drove 45.16 km. It held the off-Earth driving-distance record until Perseverance passed it on 11 October 2026, reaching 45.22 km."})
anchorFor(op,Vector3.new(OX-10,2.4,OZ-6),"Scan","Opportunity")

-- ---------- the heat shield it discarded on the way in ----------
local hs=Instance.new("Model"); hs.Name="HeatShield"; hs.Parent=F
local hb=CFrame.new(Vector3.new(OX+34,0,OZ+26))*CFrame.Angles(0,math.rad(-50),0)
local bowl=P(hs,hb,"Shell",Vector3.new(2.6,0.9,2.6),
  CFrame.new(0,0.5,0)*CFrame.Angles(math.rad(34),0,math.rad(12)),Color3.fromRGB(86,64,54),Enum.Material.Slate)
P(hs,hb,"Rim",Vector3.new(2.7,0.1,2.7),
  CFrame.new(0.1,0.92,0)*CFrame.Angles(math.rad(34),0,math.rad(12)),Color3.fromRGB(64,48,42),Enum.Material.Slate)
P(hs,hb,"Fragment",Vector3.new(0.9,0.3,1.1),CFrame.new(-2.0,0.18,1.1)*CFrame.Angles(0,math.rad(28),math.rad(9)),Color3.fromRGB(80,60,50),Enum.Material.Slate)
-- Heat Shield Rock: the iron meteorite found lying beside it
local met=P(hs,hb,"HeatShieldRock",Vector3.new(0.75,0.5,0.6),CFrame.new(2.3,0.26,-0.7),Color3.fromRGB(62,56,54),Enum.Material.Metal)
met.Reflectance=0.18
attrs(hs,{ArtifactId="heatshield",Title="Opportunity's Heat Shield",
  Year="Jettisoned during descent, 25 January 2004",
  What="The shield that took the heat of entry, thrown away a few kilometres up and left where it hit. It struck hard enough to turn itself inside out.",
  Why="It was never meant to be visited. It is here because something had to be discarded for the rover to arrive at all.",
  Science="Opportunity drove back to photograph its own discarded shield — and found an iron meteorite lying beside it, the first meteorite ever identified on another planet. It was named Heat Shield Rock."})
anchorFor(hs,Vector3.new(OX+34,2.0,OZ+26),"Scan","Heat shield")

-- ---------- site sign ----------
local sign=Instance.new("Model"); sign.Name="SiteSign"; sign.Parent=F
local sb=CFrame.lookAt(Vector3.new(OX+8,0,OZ+70),Vector3.new(OX+8,0,OZ))
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
T("MERIDIANI PLANUM",12,44,Enum.Font.GothamBold,Color3.fromRGB(245,231,60))
T("1.95 S, 5.53 W  ·  Mars  ·  Opportunity, 2004–2018",62,30,Enum.Font.GothamMedium,Color3.fromRGB(215,215,220))
T("Gravity here is 3.72 m/s² — about 2.3 times the Moon's.",102,28,Enum.Font.Gotham,Color3.fromRGB(165,170,176))
T("The small dark spheres are haematite. They form in water.",134,28,Enum.Font.Gotham,Color3.fromRGB(165,170,176))
T("HERITAGE SITE  ·  DO NOT DISTURB",176,34,Enum.Font.GothamBold,Color3.fromRGB(150,205,255))

return "Meridiani built at ("..OX..",0,"..OZ..")"

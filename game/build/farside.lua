-- The far side: Ranger 4's impact site. 26 April 1962 — the first US spacecraft to reach
-- another celestial body, and the first of any nation to reach the far-side surface.
-- Its onboard computer failed on the way out, so it arrived silent and returned nothing.
-- Nothing on this side of the Moon can see Earth. That is the mission.
local game_=workspace:WaitForChild("Game")
local old=game_:FindFirstChild("Farside"); if old then old:Destroy() end
local F=Instance.new("Folder"); F.Name="Farside"; F.Parent=game_
local OX,OZ = -900, -620
local M=2.4
F:SetAttribute("World","Moon")

local pan=Instance.new("Part")
pan.Name="Ground"; pan.Anchored=true; pan.Size=Vector3.new(240,4,240)
pan.Position=Vector3.new(OX,-2,OZ); pan.Color=Color3.fromRGB(122,120,116)
pan.Material=Enum.Material.Sand; pan.TopSurface=Enum.SurfaceType.Smooth; pan.Parent=F
-- the far side is older, rougher and far more cratered than the near side
for i=1,34 do
  local c=Instance.new("Part")
  c.Name="Crater"; c.Anchored=true; c.Shape=Enum.PartType.Ball
  local d=14+((i*19)%46)
  c.Size=Vector3.new(d,d*0.42,d)
  c.Position=Vector3.new(OX-110+((i*67)%220),-1.6-((i*5)%4),OZ-110+((i*91)%220))
  c.Color=Color3.fromRGB(106,104,100); c.Material=Enum.Material.Slate; c.Parent=F
end
-- high ground for the relay beacons
for i=1,3 do
  local a=math.rad(90+i*120)
  local p=Instance.new("Part")
  p.Name="Peak"..i; p.Anchored=true; p.Shape=Enum.PartType.Ball
  p.Size=Vector3.new(46,40,46)
  p.Position=Vector3.new(OX+math.sin(a)*92,-10,OZ+math.cos(a)*92)
  p.Color=Color3.fromRGB(134,132,128); p.Material=Enum.Material.Slate; p.Parent=F
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

-- ---------- Ranger 4: an impact scar, not a lander ----------
local rg=Instance.new("Model"); rg.Name="Ranger4"; rg.Parent=F
local rb=CFrame.new(Vector3.new(OX,0,OZ))*CFrame.Angles(0,math.rad(18),0)
-- the crater it made at about 9,600 km/h
local scar=Instance.new("Part")
scar.Name="ImpactScar"; scar.Anchored=true; scar.CanCollide=false; scar.Shape=Enum.PartType.Ball
scar.Size=Vector3.new(26,7,26); scar.Position=Vector3.new(OX,-3.4,OZ)
scar.Color=Color3.fromRGB(84,82,80); scar.Material=Enum.Material.Slate; scar.Parent=rg
for i=1,14 do
  local a=math.rad(i*26)
  local r=5+((i*7)%9)
  local frag=P(rg,rb,"Fragment"..i,Vector3.new(0.3+((i%4)*0.14),0.14,0.26+((i%3)*0.12)),
    CFrame.new(math.sin(a)*r,0.1,math.cos(a)*r)*CFrame.Angles(0,math.rad(i*41),math.rad((i%5)*9)),
    Color3.fromRGB(168,166,160),Enum.Material.Metal)
end
-- the biggest surviving piece: the crumpled frame and a bent solar panel that never opened
P(rg,rb,"Frame",Vector3.new(1.2,0.5,1.2),CFrame.new(0,0.4,0)*CFrame.Angles(math.rad(22),0,math.rad(14)),
  Color3.fromRGB(176,174,168),Enum.Material.Metal)
P(rg,rb,"StowedPanel",Vector3.new(1.9,0.07,0.75),
  CFrame.new(1.1,0.3,0.5)*CFrame.Angles(math.rad(8),math.rad(28),math.rad(62)),
  Color3.fromRGB(34,46,92),Enum.Material.Glass)
P(rg,rb,"Capsule",Vector3.new(0.62,0.62,0.62),CFrame.new(-1.3,0.3,0.7),
  Color3.fromRGB(150,148,142),Enum.Material.Metal).Shape=Enum.PartType.Ball
attrs(rg,{ArtifactId="ranger4",Title="Ranger 4",
  Year="Impacted 26 April 1962",
  What="A early lunar probe carrying cameras and a balsa-wood capsule with a seismometer inside, meant to survive a rough landing. Its onboard computer failed hours after launch, so the solar panels never opened and nothing ever switched on.",
  Why="To get the first close-up pictures of the Moon, and to put the first seismometer on another world — seven years before Apollo 11 managed it.",
  Science="It returned no data at all. It drifted, dead, until the Moon got in the way, and hit the far side at about 9,600 km/h. It was still the first US spacecraft to reach another celestial body, and the first object of any nation to reach the far-side surface. Everything else you have found out here worked first. This one never did — and we came anyway."})
anchorFor(rg,Vector3.new(OX,2.2,OZ),"Scan","Ranger 4 impact site")

-- ---------- the relay console ----------
local con=Instance.new("Model"); con.Name="RelayConsole"; con.Parent=F
local cb=CFrame.new(Vector3.new(OX+26,0,OZ+22))*CFrame.Angles(0,math.rad(210),0)
local function C(n,sz,cf,col,mat)
  local p=Instance.new("Part"); p.Name=n; p.Size=sz; p.CFrame=cb*cf; p.Anchored=true
  p.Color=col; p.Material=mat or Enum.Material.Metal
  p.TopSurface=Enum.SurfaceType.Smooth; p.BottomSurface=Enum.SurfaceType.Smooth
  p.Parent=con; return p
end
C("Pedestal",Vector3.new(3.2,3.4,1.6),CFrame.new(0,1.7,0),Color3.fromRGB(70,72,76))
C("Desk",Vector3.new(3.6,0.25,2.2),CFrame.new(0,3.45,-0.3)*CFrame.Angles(math.rad(-12),0,0),Color3.fromRGB(40,42,46))
local scr=C("Screen",Vector3.new(3.0,1.9,0.12),CFrame.new(0,4.6,0.35)*CFrame.Angles(math.rad(-18),0,0),
  Color3.fromRGB(120,40,40),Enum.Material.Neon)
local sg=Instance.new("SurfaceGui"); sg.Face=Enum.NormalId.Front; sg.CanvasSize=Vector2.new(600,380)
sg.LightInfluence=0; sg.Parent=scr
local l1=Instance.new("TextLabel"); l1.Size=UDim2.new(1,-20,0.55,0); l1.Position=UDim2.fromOffset(10,10)
l1.BackgroundTransparency=1; l1.Font=Enum.Font.GothamBold; l1.TextColor3=Color3.fromRGB(255,120,110)
l1.TextScaled=true; l1.Text="NO LINK\nTO EARTH"; l1.Parent=sg
local l2=Instance.new("TextLabel"); l2.Size=UDim2.new(1,-20,0.3,0); l2.Position=UDim2.new(0,10,0.62,0)
l2.BackgroundTransparency=1; l2.Font=Enum.Font.GothamMedium; l2.TextColor3=Color3.fromRGB(215,215,220)
l2.TextScaled=true; l2.TextWrapped=true; l2.Text="The Moon is in the way. Place a relay."; l2.Parent=sg
local anc=Instance.new("Part"); anc.Name="Anchor"; anc.Size=Vector3.new(1,1,1)
anc.Transparency=1; anc.CanCollide=false; anc.Anchored=true
anc.CFrame=cb*CFrame.new(0,3.5,-1.4); anc.Parent=con
anc:SetAttribute("ConsoleId","relay")
local pp=Instance.new("ProximityPrompt")
pp.ActionText="Open relay plot"; pp.ObjectText="Comms relay"; pp.KeyboardKeyCode=Enum.KeyCode.E
pp.HoldDuration=0.25; pp.MaxActivationDistance=10; pp.RequiresLineOfSight=false; pp.Parent=anc

-- ---------- site sign ----------
local sign=Instance.new("Model"); sign.Name="SiteSign"; sign.Parent=F
local sb=CFrame.lookAt(Vector3.new(OX+4,0,OZ+56),Vector3.new(OX+4,0,OZ))
local function SP(n,sz,cf,col)
  local p=Instance.new("Part"); p.Name=n; p.Anchored=true; p.Size=sz; p.CFrame=sb*cf
  p.Color=col; p.Material=Enum.Material.Metal; p.Parent=sign; return p
end
SP("Post",Vector3.new(0.2,4.2,0.2),CFrame.new(-2.3,2.1,0),Color3.fromRGB(190,190,186))
SP("Post2",Vector3.new(0.2,4.2,0.2),CFrame.new(2.3,2.1,0),Color3.fromRGB(190,190,186))
local board=SP("Board",Vector3.new(5.2,2.3,0.12),CFrame.new(0,3.3,0),Color3.fromRGB(14,14,16))
board.Material=Enum.Material.SmoothPlastic
local bg=Instance.new("SurfaceGui"); bg.Face=Enum.NormalId.Back; bg.CanvasSize=Vector2.new(620,274)
bg.LightInfluence=0; bg.Parent=board
local function T(txt,y,h,font,col)
  local l=Instance.new("TextLabel"); l.Size=UDim2.new(1,-28,0,h); l.Position=UDim2.fromOffset(14,y)
  l.BackgroundTransparency=1; l.Font=font; l.TextColor3=col; l.Text=txt
  l.TextScaled=true; l.TextXAlignment=Enum.TextXAlignment.Left; l.Parent=bg
end
T("THE FAR SIDE",12,44,Enum.Font.GothamBold,Color3.fromRGB(245,231,60))
T("Ranger 4 impact site  ·  26 April 1962",62,30,Enum.Font.GothamMedium,Color3.fromRGB(215,215,220))
T("Earth is never in this sky. Not at night, not ever.",102,28,Enum.Font.Gotham,Color3.fromRGB(165,170,176))
T("The Moon keeps one face turned to us, and this is the other one.",134,28,Enum.Font.Gotham,Color3.fromRGB(165,170,176))
T("HERITAGE SITE  ·  DO NOT DISTURB",176,34,Enum.Font.GothamBold,Color3.fromRGB(150,205,255))

return "Farside built at ("..OX..",0,"..OZ..")"

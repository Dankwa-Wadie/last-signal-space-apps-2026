-- 433 Eros: NEAR Shoemaker's landing site, 41.626 S, 80.421 E, near the saddle Himeros.
-- The first spacecraft to orbit an asteroid, and then the first to land on one, though it was
-- never built to land. Touched down 12 Feb 2001; final contact 28 Feb 2001.
-- Gravity here is about 0.0059 m/s^2, under a thousandth of Earth's. A visitor stays clipped
-- to a tether stake, because at the ends of this rock a jump comes close to escape speed.
local B=(function()
EQUIPMENT_MODELS
end)()

local game_=workspace:WaitForChild("Game")
local old=game_:FindFirstChild("Eros"); if old then old:Destroy() end
local F=Instance.new("Folder"); F.Name="Eros"; F.Parent=game_
F:SetAttribute("World","Eros")
local OX,OZ=1500,-500

local function P(parent,n,sz,cf,col,mat,shape)
  local p=Instance.new("Part"); p.Name=n; p.Anchored=true; p.Size=sz; p.CFrame=cf
  p.Color=col; p.Material=mat or Enum.Material.Slate
  if shape then p.Shape=shape end
  p.TopSurface=Enum.SurfaceType.Smooth; p.BottomSurface=Enum.SurfaceType.Smooth
  p.Parent=parent; return p
end

-- ground: dark, dusty regolith, littered with boulders -- Eros is covered in them
P(F,"Ground",Vector3.new(240,4,240),CFrame.new(OX,-2,OZ),Color3.fromRGB(106,96,84),Enum.Material.Sand)
for i=1,26 do
  local s=2+((i*37)%14)
  local b=P(F,"Boulder",Vector3.new(s,s*0.8,s*0.9),
    CFrame.new(OX-108+((i*53)%216),s*0.25,OZ-108+((i*79)%216))*CFrame.Angles(0,math.rad(i*41),math.rad(i%9)),
    Color3.fromRGB(96+((i*7)%20),86,74),Enum.Material.Slate)
  b.CanCollide=true
end
-- the ground falls away towards a very near horizon: this is a rock only 34 km long
for i=0,15 do
  local a=math.rad(i*22.5)
  P(F,"Rim",Vector3.new(60,10,30),
    CFrame.new(OX+math.sin(a)*128,-6,OZ+math.cos(a)*128)*CFrame.Angles(math.rad(-14),a,0),
    Color3.fromRGB(92,84,74),Enum.Material.Slate)
end

-- ---------- NEAR Shoemaker ----------
-- No landing legs: it came down slowly and settled on whatever touched first, so it sits tilted.
local near=B.near(CFrame.new(OX,1.2,OZ)*CFrame.Angles(math.rad(14),math.rad(30),math.rad(-18)),F)
near.Name="NEARShoemaker"
-- The replica kit gives NEAR a slab of "Eros" to sit on, for display in the trophy room.
-- Here the ground already IS Eros, so the slab goes. And in gravity this weak, glancing
-- off a tilted solar panel can fling a player a long way -- so NEAR is not solid here.
local slab=near:FindFirstChild("Eros"); if slab then slab:Destroy() end
for _,d in ipairs(near:GetDescendants()) do
  if d:IsA("BasePart") then d.CanCollide=false end
end
for k,v in pairs({
  ArtifactId="near",
  Title="NEAR Shoemaker",
  Year="Landed 12 February 2001 · final contact 28 February 2001",
  What="A spacecraft built to orbit an asteroid, not to land on one. It has no landing legs: four solar panels, a dish antenna, and a camera on the end of a body the size of a small car.",
  Why="To spend a year circling Eros, mapping it up close — the first spacecraft ever to orbit an asteroid.",
  Science="When the year was up, the team brought it down anyway, though it was never designed to land. It came down at about walking pace, survived, and kept transmitting from the surface for more than two weeks — the first spacecraft ever to land on an asteroid. It is still lying here, just south of the saddle-shaped valley called Himeros.",
}) do near:SetAttribute(k,v) end
local a=P(near,"Anchor",Vector3.new(1,1,1),CFrame.new(OX,3,OZ),Color3.new(1,1,1))
a.Transparency=1; a.CanCollide=false
local pp=Instance.new("ProximityPrompt")
pp.ActionText="Scan"; pp.ObjectText="NEAR Shoemaker"; pp.KeyboardKeyCode=Enum.KeyCode.E
pp.HoldDuration=0.25; pp.MaxActivationDistance=12; pp.RequiresLineOfSight=false; pp.Parent=a

-- ---------- the tether stake every visitor clips to ----------
local stake=Instance.new("Model"); stake.Name="TetherStake"; stake.Parent=F
P(stake,"Base",Vector3.new(3,0.4,3),CFrame.new(OX,0.2,OZ),Color3.fromRGB(70,72,76),Enum.Material.Metal)
P(stake,"Post",Vector3.new(0.5,4,0.5),CFrame.new(OX,2.2,OZ),Color3.fromRGB(190,190,186),Enum.Material.Metal)
local clip=P(stake,"Clip",Vector3.new(0.8,0.8,0.8),CFrame.new(OX,4.4,OZ),Color3.fromRGB(245,214,60),
  Enum.Material.Neon,Enum.PartType.Ball)
clip.CanCollide=false

-- ---------- the transit console home ----------
local con=Instance.new("Model"); con.Name="TransitConsole"; con.Parent=F
local cb=CFrame.new(OX-16,0,OZ+18)*CFrame.Angles(0,math.rad(200),0)
P(con,"Pedestal",Vector3.new(3.2,3.4,1.6),cb*CFrame.new(0,1.7,0),Color3.fromRGB(70,72,76),Enum.Material.Metal)
P(con,"Desk",Vector3.new(3.6,0.25,2.2),cb*CFrame.new(0,3.45,-0.3)*CFrame.Angles(math.rad(-12),0,0),Color3.fromRGB(40,42,46),Enum.Material.Metal)
local scr=P(con,"Screen",Vector3.new(3.0,1.9,0.12),cb*CFrame.new(0,4.6,0.35)*CFrame.Angles(math.rad(-18),0,0),
  Color3.fromRGB(80,64,24),Enum.Material.Neon)
local sg=Instance.new("SurfaceGui"); sg.Face=Enum.NormalId.Front; sg.CanvasSize=Vector2.new(600,380)
sg.LightInfluence=0; sg.Parent=scr
local function TL(parent,txt,y,h,font,col)
  local l=Instance.new("TextLabel"); l.Size=UDim2.new(1,-28,0,h); l.Position=UDim2.fromOffset(14,y)
  l.BackgroundTransparency=1; l.Font=font; l.TextColor3=col; l.Text=txt; l.TextScaled=true
  l.TextXAlignment=Enum.TextXAlignment.Left; l.Parent=parent
end
TL(sg,"TRANSIT",10,190,Enum.Font.GothamBold,Color3.fromRGB(245,231,60))
TL(sg,"Departures · Moon · Mars",214,100,Enum.Font.GothamMedium,Color3.fromRGB(215,215,220))
local ca=P(con,"Anchor",Vector3.new(1,1,1),cb*CFrame.new(0,3.5,-1.4),Color3.new(1,1,1))
ca.Transparency=1; ca.CanCollide=false
ca:SetAttribute("ConsoleId","transit")
local cp=Instance.new("ProximityPrompt")
cp.ActionText="Board"; cp.ObjectText="Transit module"; cp.KeyboardKeyCode=Enum.KeyCode.E
cp.HoldDuration=0.25; cp.MaxActivationDistance=10; cp.RequiresLineOfSight=false; cp.Parent=ca

-- ---------- the sign ----------
local sign=Instance.new("Model"); sign.Name="SiteSign"; sign.Parent=F
local sb=CFrame.lookAt(Vector3.new(OX+18,0,OZ+30),Vector3.new(OX,0,OZ))
P(sign,"Post",Vector3.new(0.2,4.4,0.2),sb*CFrame.new(-2.3,2.2,0),Color3.fromRGB(190,190,186),Enum.Material.Metal)
P(sign,"Post2",Vector3.new(0.2,4.4,0.2),sb*CFrame.new(2.3,2.2,0),Color3.fromRGB(190,190,186),Enum.Material.Metal)
local board=P(sign,"Board",Vector3.new(5.2,2.8,0.12),sb*CFrame.new(0,3.5,0),Color3.fromRGB(14,14,16),Enum.Material.SmoothPlastic)
local bg=Instance.new("SurfaceGui"); bg.Face=Enum.NormalId.Back; bg.CanvasSize=Vector2.new(620,334)
bg.LightInfluence=0; bg.Parent=board
TL(bg,"433 EROS",10,42,Enum.Font.GothamBold,Color3.fromRGB(245,231,60))
TL(bg,"41.626 S, 80.421 E  ·  NEAR Shoemaker, 2001",56,28,Enum.Font.GothamMedium,Color3.fromRGB(215,215,220))
TL(bg,"A peanut-shaped asteroid about 34 km long.",92,26,Enum.Font.Gotham,Color3.fromRGB(175,180,186))
TL(bg,"Gravity here is under a thousandth of Earth's. At the far",124,26,Enum.Font.Gotham,Color3.fromRGB(175,180,186))
TL(bg,"ends, a jump comes close to escape speed — so you stay clipped on.",152,26,Enum.Font.Gotham,Color3.fromRGB(175,180,186))
TL(bg,"We let you fall a little faster than the real Eros,",196,24,Enum.Font.GothamMedium,Color3.fromRGB(150,205,255))
TL(bg,"or a single hop would carry you off the map.",222,24,Enum.Font.GothamMedium,Color3.fromRGB(150,205,255))
TL(bg,"HERITAGE SITE  ·  DO NOT DISTURB",270,34,Enum.Font.GothamBold,Color3.fromRGB(150,205,255))

return ("Eros built at (%d,0,%d)"):format(OX,OZ)

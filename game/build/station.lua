-- TRANQUILITY HERITAGE STATION. The player used to spawn 26 studs from Eagle, with the
-- archive, radio and transit consoles parked on the heritage site itself. Now they arrive at
-- a small working station outside a marked boundary, and walk in to the landing site.
local game_=workspace:WaitForChild("Game")
local T=game_:WaitForChild("Tranquility")
local SPAWN=Vector3.new(0,0,150)
local EAGLE=Vector3.new(0,0,8)

local function P(parent,n,sz,cf,col,mat,shape)
  local p=Instance.new("Part"); p.Name=n; p.Anchored=true; p.Size=sz; p.CFrame=cf
  p.Color=col; p.Material=mat or Enum.Material.Metal
  if shape then p.Shape=shape end
  p.TopSurface=Enum.SurfaceType.Smooth; p.BottomSurface=Enum.SurfaceType.Smooth
  p.Parent=parent; return p
end
local function TL(parent,txt,y,h,font,col,align)
  local l=Instance.new("TextLabel"); l.Size=UDim2.new(1,-28,0,h); l.Position=UDim2.fromOffset(14,y)
  l.BackgroundTransparency=1; l.Font=font; l.TextColor3=col; l.Text=txt; l.TextScaled=true
  l.TextXAlignment=align or Enum.TextXAlignment.Left; l.Parent=parent
end
-- a CFrame at pos whose readable face (+Z, SurfaceGui Face=Back) turns towards `toward`
local function facing(pos,toward) return CFrame.lookAt(pos,pos+(pos-toward)) end

local old=T:FindFirstChild("Station"); if old then old:Destroy() end
local S=Instance.new("Model"); S.Name="Station"; S.Parent=T

-- ---------- the pad and the habitat ----------
P(S,"Pad",Vector3.new(40,0.4,34),CFrame.new(0,0.2,154),Color3.fromRGB(58,60,66),Enum.Material.DiamondPlate)
for _,x in ipairs({-19,19}) do
  for _,z in ipairs({138,170}) do
    local l=P(S,"PadLight",Vector3.new(0.8,0.5,0.8),CFrame.new(x,0.6,z),Color3.fromRGB(245,214,60),Enum.Material.Neon)
    local pl=Instance.new("PointLight"); pl.Range=14; pl.Brightness=1.2; pl.Color=Color3.fromRGB(255,220,140); pl.Parent=l
  end
end
-- A larger pressure shell with a clear walkable interior and a framed front airlock.
P(S,"HabFloor",Vector3.new(32,0.5,18),CFrame.new(0,0.45,184),Color3.fromRGB(120,122,124),Enum.Material.Metal)
P(S,"HabRoof",Vector3.new(32,0.5,18),CFrame.new(0,16.2,184),Color3.fromRGB(198,200,198),Enum.Material.Metal)
P(S,"HabSideL",Vector3.new(0.6,15.5,18),CFrame.new(-15.7,8.4,184),Color3.fromRGB(226,226,220),Enum.Material.SmoothPlastic)
P(S,"HabSideR",Vector3.new(0.6,15.5,18),CFrame.new(15.7,8.4,184),Color3.fromRGB(226,226,220),Enum.Material.SmoothPlastic)
P(S,"HabBack",Vector3.new(32,15.5,0.6),CFrame.new(0,8.4,192.7),Color3.fromRGB(226,226,220),Enum.Material.SmoothPlastic)
-- front wall segments frame a 7-stud airlock opening
P(S,"HabFrontL",Vector3.new(12.5,15.5,0.6),CFrame.new(-9.75,8.4,175.3),Color3.fromRGB(226,226,220),Enum.Material.SmoothPlastic)
P(S,"HabFrontR",Vector3.new(12.5,15.5,0.6),CFrame.new(9.75,8.4,175.3),Color3.fromRGB(226,226,220),Enum.Material.SmoothPlastic)
P(S,"HabLintel",Vector3.new(7,5,0.6),CFrame.new(0,13.65,175.3),Color3.fromRGB(226,226,220),Enum.Material.SmoothPlastic)
P(S,"HabSkirt",Vector3.new(36,1,22),CFrame.new(0,0.5,184),Color3.fromRGB(140,140,138))
local Airlock=P(S,"Airlock",Vector3.new(7,9,2),CFrame.new(0,4.6,174.2),Color3.fromRGB(52,54,60))
Airlock.CanCollide=false; Airlock.Transparency=0.35
local win=P(S,"Window",Vector3.new(11,2.8,0.3),CFrame.new(-9.5,11.7,175.2),Color3.fromRGB(255,214,140),Enum.Material.Neon)
win.CanCollide=false
local win2=P(S,"Window2",Vector3.new(7,2.8,0.3),CFrame.new(10.5,11.7,175.2),Color3.fromRGB(255,214,140),Enum.Material.Neon)
win2.CanCollide=false
local console=P(S,"StationConsole",Vector3.new(4.8,4.2,1.1),CFrame.new(0,3.2,188.7),Color3.fromRGB(38,54,65),Enum.Material.Metal)
console.CanCollide=false -- central wall-mounted life-support kiosk; don't snag or trap the astronaut
local csg=Instance.new("SurfaceGui"); csg.Face=Enum.NormalId.Front; csg.CanvasSize=Vector2.new(400,300); csg.Parent=console
TL(csg,"LIFE SUPPORT",8,70,Enum.Font.GothamBold,Color3.fromRGB(150,225,255))
TL(csg,"O₂ + POWER REFILL INSIDE  ·  HOLD E FOR INSTANT REFILL",88,90,Enum.Font.GothamBold,Color3.fromRGB(245,231,60))
local service=Instance.new("ProximityPrompt")
service.Name="LifeSupportService"; service.ActionText="Refill oxygen + power"; service.ObjectText="LIFE SUPPORT"
service.HoldDuration=0.5; service.MaxActivationDistance=12; service.RequiresLineOfSight=false
service.Parent=console
local serviceMarker=P(S,"LifeSupportMarker",Vector3.new(2.4,0.18,0.4),CFrame.new(0,5.45,188.7),
  Color3.fromRGB(100,210,255),Enum.Material.Neon)
serviceMarker.CanCollide=false
local serviceLight=Instance.new("PointLight"); serviceLight.Color=serviceMarker.Color
serviceLight.Brightness=1.4; serviceLight.Range=12; serviceLight.Parent=serviceMarker
-- Keep the habitat walkable: an unprompted Seat automatically captures players
-- and prevents them from leaving the room without deliberately jumping out.
local function ceilingLight(name,x,z,color,brightness,range)
  local fixture=P(S,name,Vector3.new(6,0.18,0.7),CFrame.new(x,15.75,z),Color3.fromRGB(244,235,198),Enum.Material.Neon)
  fixture.CanCollide=false
  local light=Instance.new("PointLight"); light.Color=color; light.Brightness=brightness; light.Range=range; light.Shadows=true; light.Parent=fixture
end
ceilingLight("CeilingLightFront",-7,179,Color3.fromRGB(255,235,194),2.2,28)
ceilingLight("CeilingLightCenter",5,184,Color3.fromRGB(222,238,255),2.4,30)
ceilingLight("CeilingLightRear",-7,189,Color3.fromRGB(255,235,194),2.2,28)
P(S,"Mast",Vector3.new(0.4,10,0.4),CFrame.new(13,21,191),Color3.fromRGB(190,190,186))
local dish=P(S,"Dish",Vector3.new(0.3,5,5),CFrame.new(13,26,191)*CFrame.Angles(0,math.rad(90),math.rad(60)),
  Color3.fromRGB(226,226,222),Enum.Material.SmoothPlastic,Enum.PartType.Cylinder)
local board=P(S,"NameBoard",Vector3.new(26,3,0.3),CFrame.new(0,17.4,174.5),Color3.fromRGB(14,14,16),Enum.Material.SmoothPlastic)
local g=Instance.new("SurfaceGui"); g.Face=Enum.NormalId.Front; g.CanvasSize=Vector2.new(1000,130)
g.LightInfluence=0; g.Parent=board
TL(g,"TRANQUILITY HERITAGE STATION",8,70,Enum.Font.GothamBold,Color3.fromRGB(245,231,60),Enum.TextXAlignment.Center)
TL(g,"Mare Tranquillitatis  ·  outside the Apollo 11 boundary",84,38,Enum.Font.GothamMedium,Color3.fromRGB(205,208,214),Enum.TextXAlignment.Center)

-- ---------- spawn moves here ----------
local start=T:FindFirstChild("Start")
if start then start.CFrame=CFrame.new(SPAWN.X,0.5,SPAWN.Z) end

-- ---------- the archive terminal moves off the site, into the station ----------
local term=T:FindFirstChild("ArchiveTerminal")
if term then
  -- Move by the prompt anchor, not the model pivot. The model's automatically
  -- calculated pivot is not at its original build origin and used to send it
  -- hundreds of studs away from the station.
  local anchor=term:FindFirstChild("Anchor",true)
  if anchor and anchor:IsA("BasePart") then
    local target=CFrame.lookAt(Vector3.new(-10,3.5,188),Vector3.new(SPAWN.X,3.5,SPAWN.Z))
    term:PivotTo(target*anchor.CFrame:Inverse()*term:GetPivot())
  end
end

-- ---------- the heritage boundary ----------
-- An arc of posts 72 studs out from Eagle, on the station side. NASA's 2011 recommendation
-- is 75 m, which at this scale is 180 studs: the walk here is shortened, and the sign says so.
local old2=T:FindFirstChild("Boundary"); if old2 then old2:Destroy() end
local Bd=Instance.new("Model"); Bd.Name="Boundary"; Bd.Parent=T
local R=72
local prev=nil
for i=-6,6 do
  local a=math.rad(i*9)
  local pos=EAGLE+Vector3.new(math.sin(a)*R,0,math.cos(a)*R)
  P(Bd,"Post",Vector3.new(0.35,2.6,0.35),CFrame.new(pos+Vector3.new(0,1.3,0)),Color3.fromRGB(230,230,226))
  P(Bd,"Band",Vector3.new(0.42,0.5,0.42),CFrame.new(pos+Vector3.new(0,2.2,0)),Color3.fromRGB(245,190,40),Enum.Material.Neon)
  if prev then
    local mid=(prev+pos)/2
    local len=(pos-prev).Magnitude
    local rope=P(Bd,"Line",Vector3.new(0.08,0.08,len),CFrame.lookAt(mid+Vector3.new(0,1.9,0),pos+Vector3.new(0,1.9,0)),
      Color3.fromRGB(245,190,40),Enum.Material.Neon)
    rope.CanCollide=false
  end
  prev=pos
end
-- a gap in the line where the path crosses it
for _,d in ipairs(Bd:GetChildren()) do
  if d.Name=="Line" and math.abs(d.Position.X)<5 then d:Destroy() end
end
local bpos=EAGLE+Vector3.new(7,0,R+2)
local bs=Instance.new("Model"); bs.Name="BoundarySign"; bs.Parent=Bd
local bb=facing(bpos,Vector3.new(SPAWN.X,0,SPAWN.Z))
P(bs,"Post",Vector3.new(0.2,4.2,0.2),bb*CFrame.new(-2.4,2.1,0),Color3.fromRGB(190,190,186))
P(bs,"Post2",Vector3.new(0.2,4.2,0.2),bb*CFrame.new(2.4,2.1,0),Color3.fromRGB(190,190,186))
local bboard=P(bs,"Board",Vector3.new(5.4,2.6,0.12),bb*CFrame.new(0,3.4,0),Color3.fromRGB(14,14,16),Enum.Material.SmoothPlastic)
local bg=Instance.new("SurfaceGui"); bg.Face=Enum.NormalId.Back; bg.CanvasSize=Vector2.new(640,310)
bg.LightInfluence=0; bg.Parent=bboard
TL(bg,"HERITAGE BOUNDARY",10,44,Enum.Font.GothamBold,Color3.fromRGB(245,190,40))
TL(bg,"In 2011 NASA recommended a 75 m boundary around the",64,26,Enum.Font.Gotham,Color3.fromRGB(215,215,220))
TL(bg,"Apollo 11 site, to protect the hardware and the footprints.",92,26,Enum.Font.Gotham,Color3.fromRGB(215,215,220))
TL(bg,"Surveyors cross on foot, and touch nothing.",132,28,Enum.Font.GothamMedium,Color3.fromRGB(245,231,60))
TL(bg,"The walk here is shortened: the real boundary is more",180,24,Enum.Font.GothamMedium,Color3.fromRGB(150,205,255))
TL(bg,"than twice as far out.",206,24,Enum.Font.GothamMedium,Color3.fromRGB(150,205,255))
TL(bg,"EAGLE  ·  STRAIGHT AHEAD",250,40,Enum.Font.GothamBold,Color3.fromRGB(215,215,220))

return "station built; spawn at "..tostring(SPAWN)

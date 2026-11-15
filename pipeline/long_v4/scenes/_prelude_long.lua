-- Appended after ../scenes/_prelude.lua for the long film (long_v4).
-- Characters, skies, terrain and props shared by every long-film scene.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local T = ws.Terrain

local ANIM = {walk = "rbxassetid://507777826", idle = "rbxassetid://507766388"}

-- ---------------------------------------------------------------- skies
local function skyStore()
  local st = RS:FindFirstChild("SkyLibrary") or Instance.new("Folder")
  st.Name = "SkyLibrary"; st.Parent = RS
  return st
end
-- Earth daylight: the default Roblox sky (no Sky object) plus a blue atmosphere and clouds
local function daySky(clock, hazeColor)
  local st = skyStore()
  for _, c in ipairs(L:GetChildren()) do
    if c:IsA("Sky") then
      if not st:FindFirstChild(c.Name) then c.Parent = st else c:Destroy() end
    end
  end
  clearAtmos()
  local a = Instance.new("Atmosphere")
  a.Density = 0.32; a.Offset = 0.12; a.Haze = 1.4; a.Glare = 0.6
  a.Color = hazeColor or Color3.fromRGB(199, 214, 230)
  a.Decay = Color3.fromRGB(106, 112, 125)
  a.Parent = L
  L.ClockTime = clock or 17.2; L.GeographicLatitude = 30
  L.Brightness = 3; L.ExposureCompensation = 0.1
  L.Ambient = Color3.fromRGB(70, 70, 78); L.OutdoorAmbient = Color3.fromRGB(128, 128, 136)
  L.EnvironmentDiffuseScale = 1; L.EnvironmentSpecularScale = 1
  local cl = T:FindFirstChildOfClass("Clouds") or Instance.new("Clouds", T)
  cl.Cover = 0.55; cl.Density = 0.6; cl.Color = Color3.fromRGB(255, 244, 232); cl.Enabled = true
end
-- space: put the dark Milky Way sky back (the composite replaces it anyway)
local function spaceSky()
  local st = skyStore()
  for _, c in ipairs(L:GetChildren()) do if c:IsA("Sky") then c:Destroy() end end
  local mw = st:FindFirstChild("MilkyWay")
  if mw then mw:Clone().Parent = L end
  local cl = T:FindFirstChildOfClass("Clouds"); if cl then cl.Enabled = false end
end

-- ---------------------------------------------------------------- people
local function rig(name, cf, desc)
  local d = Instance.new("HumanoidDescription")
  for k, v in pairs(desc or {}) do pcall(function() d[k] = v end) end
  local m = Players:CreateHumanoidModelFromDescription(d, Enum.HumanoidRigType.R15)
  m.Name = name; m:PivotTo(cf); m.Parent = ws.Scene
  for _, p in ipairs(m:GetDescendants()) do if p:IsA("BasePart") then p.Anchored = false end end
  m.HumanoidRootPart.Anchored = true            -- we place the root ourselves each frame
  local hum = m:FindFirstChildOfClass("Humanoid")
  hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
  local an = hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum)
  return m, an
end

local function play(an, which, speed, offset)
  local a = Instance.new("Animation"); a.AnimationId = ANIM[which] or which
  local tr = an:LoadAnimation(a)
  local t0 = os.clock()
  while tr.Length == 0 and os.clock() - t0 < 6 do task.wait(0.05) end
  tr.Looped = true; tr:Play(0); tr:AdjustSpeed(speed or 1)
  if offset then tr.TimePosition = offset % math.max(tr.Length, 0.01) end
  return tr
end

local WHITE = Color3.fromRGB(236, 236, 232)
local function weldTo(part, base, c0)
  local w = Instance.new("Weld"); w.Part0 = base; w.Part1 = part; w.C0 = c0; w.Parent = part
end
local function prop(name, size, color, mat, parent)
  local p = Instance.new("Part"); p.Name = name; p.Size = size; p.Color = color
  p.Material = mat; p.CanCollide = false; p.Massless = true; p.Anchored = false
  p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth
  p.Parent = parent; return p
end

-- Apollo EVA suit (same design as the game): white suit, life-support pack, helmet, gold visor
local function astronaut(name, cf, stripe)
  local m, an = rig(name, cf, {HeadColor = WHITE, TorsoColor = WHITE, LeftArmColor = WHITE,
    RightArmColor = WHITE, LeftLegColor = WHITE, RightLegColor = WHITE})
  for _, a in ipairs(m:GetChildren()) do
    if a:IsA("Accessory") or a:IsA("Shirt") or a:IsA("Pants") or a:IsA("ShirtGraphic") then a:Destroy() end
  end
  for _, d in ipairs(m:GetDescendants()) do
    if d:IsA("BasePart") and d.Name ~= "HumanoidRootPart" then d.Color = WHITE; d.Material = Enum.Material.SmoothPlastic end
    if d:IsA("Decal") and d.Name == "face" then d:Destroy() end
  end
  local torso, head = m.UpperTorso, m.Head
  local pack = prop("PLSS", Vector3.new(1.9, 2.0, 0.85), Color3.fromRGB(222, 222, 218), Enum.Material.SmoothPlastic, m)
  pack.CFrame = torso.CFrame * CFrame.new(0, 0.1, 0.78); weldTo(pack, torso, CFrame.new(0, 0.1, 0.78))
  local helm = prop("Helmet", Vector3.new(2.0, 2.0, 2.0), Color3.fromRGB(240, 240, 240), Enum.Material.Glass, m)
  helm.Shape = Enum.PartType.Ball; helm.Transparency = 0.55; helm.Reflectance = 0.1
  helm.CFrame = head.CFrame; weldTo(helm, head, CFrame.new())
  local visor = prop("Visor", Vector3.new(1.45, 1.0, 0.55), Color3.fromRGB(214, 168, 54), Enum.Material.Glass, m)
  visor.Reflectance = 0.5; visor.Transparency = 0.1
  visor.CFrame = head.CFrame * CFrame.new(0, 0.02, -0.72); weldTo(visor, head, CFrame.new(0, 0.02, -0.72))
  if stripe then   -- Apollo commanders wore red bands
    local arm = m.RightUpperArm
    local band = prop("Band", Vector3.new(arm.Size.X * 1.07, 0.2, arm.Size.Z * 1.07), Color3.fromRGB(190, 62, 48), Enum.Material.SmoothPlastic, m)
    band.CFrame = arm.CFrame * CFrame.new(0, 0.25, 0); weldTo(band, arm, CFrame.new(0, 0.25, 0))
  end
  return m, an
end

local function explorer(name, cf, shirt, pants, skin)
  local m, an = rig(name, cf, {HeadColor = skin, TorsoColor = shirt, LeftArmColor = skin,
    RightArmColor = skin, LeftLegColor = pants, RightLegColor = pants})
  for _, d in ipairs(m:GetDescendants()) do
    if d:IsA("BasePart") and d.Name ~= "HumanoidRootPart" then d.Material = Enum.Material.SmoothPlastic end
  end
  return m, an
end


-- Giza at night: three stepped pyramids on the real diagonal (1 stud = 2.5 m, sizes to scale)
local function giza(s)
  local stone=Color3.fromRGB(158,146,122)
  local cap=Color3.fromRGB(205,198,184)        -- Khafre keeps its limestone casing at the tip
  local function pyramid(cx,cz,base,h,capFrac)
    local ch=2
    local n=math.floor(h/ch)
    for i=0,n-1 do
      local y=(i+0.5)*ch
      local w=base*(1-y/h)
      if w<2 then break end
      local p=Instance.new("Part"); p.Anchored=true; p.CanCollide=false
      p.Size=Vector3.new(w,ch,w); p.CFrame=CFrame.new(cx,y,cz)
      p.Material=Enum.Material.Concrete
      p.Color=(capFrac and y>h*(1-capFrac)) and cap or stone
      p.Parent=s
    end
  end
  -- a dim high "moon" so the faces catch light instead of going black
  local moon=Instance.new("Part"); moon.Anchored=true; moon.CanCollide=false; moon.Transparency=1
  moon.Size=Vector3.new(0.2,0.2,0.2); moon.CFrame=CFrame.new(-140,320,-60); moon.Parent=s
  local ml=Instance.new("PointLight"); ml.Brightness=0.9; ml.Range=900; ml.Color=Color3.fromRGB(190,205,255); ml.Parent=moon
  pyramid(-55,-210,92,56)              -- Khufu, the Great Pyramid (230 m base, 139 m high)
  pyramid(15,-262,86,54,0.18)          -- Khafre, with the casing cap
  pyramid(72,-300,41,26)               -- Menkaure
  for i=0,2 do pyramid(86+i*11,-284,7,4.4) end   -- the three queens' pyramids
end


-- Opportunity's wheels: the hosted mesh has its 4 wheels baked in (lumpy, unrotatable), so we
-- enclose each in a clean cylinder wheel that the frame scripts can spin (probe-measured offsets)
local OPPW={{-2.12,2.55},{2.12,2.55},{-2.12,-2.55},{2.12,-2.55}}
local function oppWheels(r)
  local pv=r:GetPivot()
  local W=Instance.new("Model"); W.Name="Wheels"; W.Parent=r
  local d=1.95; local wd=1.2
  W:SetAttribute("d",d)
  for i,p in ipairs(OPPW) do
    local wc=pv*CFrame.new(p[1],(d/2-0.12)-pv.Position.Y,p[2])   -- axle = local X
    local w=Instance.new("Part"); w.Name="Wheel"..i; w.Anchored=true; w.CanCollide=false
    w.Shape=Enum.PartType.Cylinder; w.Size=Vector3.new(wd,d,d)
    w.Material=Enum.Material.SmoothPlastic; w.Color=Color3.fromRGB(205,199,188)
    w.CFrame=wc; w.Parent=W
    local hub=Instance.new("Part"); hub.Name="Hub"..i; hub.Anchored=true; hub.CanCollide=false
    hub.Shape=Enum.PartType.Cylinder; hub.Size=Vector3.new(wd+0.05,d*0.44,d*0.44)
    hub.Material=Enum.Material.Metal; hub.Color=Color3.fromRGB(122,116,108)
    hub.CFrame=wc; hub.Parent=W
    local spoke=Instance.new("Part"); spoke.Name="Spoke"..i; spoke.Anchored=true; spoke.CanCollide=false
    spoke.Size=Vector3.new(wd+0.1,d*0.42,0.16)
    spoke.Material=Enum.Material.Metal; spoke.Color=Color3.fromRGB(150,144,134)
    spoke.CFrame=wc; spoke.Parent=W
    for t=0,11 do
      local tread=Instance.new("Part"); tread.Name="Tread_"..i.."_"..t; tread.Anchored=true; tread.CanCollide=false
      tread.Size=Vector3.new(wd+0.04,0.09,0.26)
      tread.Material=Enum.Material.SmoothPlastic; tread.Color=Color3.fromRGB(100,94,86)
      tread.CFrame=wc*CFrame.Angles(t*math.pi/6,0,0)*CFrame.new(0,d/2-0.055,0)
      tread.Parent=W
    end
  end
  return W
end


-- Apollo Lunar Roving Vehicle, built from parts so the wire wheels actually show
-- (1 stud = 0.4 m; real LRV: 3.1 m long, 0.81 m wire wheels, orange fenders)
local function procLRV(x,z,yaw)
  local m=Instance.new("Model"); m.Name="LRV"; m.Parent=workspace.Scene
  local rp=RaycastParams.new(); rp.FilterType=Enum.RaycastFilterType.Include; rp.FilterDescendantsInstances={workspace.Terrain}
  -- freshly filled terrain isn't raycastable for a moment: wait for it (rille() surface is y=2.0)
  local hit
  for _=1,40 do
    hit=workspace:Raycast(Vector3.new(x,200,z),Vector3.new(0,-400,0),rp)
    if hit then break end
    task.wait(0.05)
  end
  local gy=hit and hit.Position.Y or 2.0
  local base=CFrame.new(x,gy-0.15,z)*CFrame.Angles(0,math.rad(yaw or 0),0)
  m.WorldPivot=base
  local AL=Color3.fromRGB(198,196,190)
  local DK=Color3.fromRGB(70,68,64)
  local OR=Color3.fromRGB(196,198,200)      -- fenders: grey fiberglass (see AS15-88-11901)
  local TAN=Color3.fromRGB(205,186,150)
  local function P(nm,sz,cf,col,mat,shape)
    local p=Instance.new("Part"); p.Name=nm; p.Size=sz; p.CFrame=base*cf; p.Anchored=true; p.CanCollide=false
    p.Color=col; p.Material=mat or Enum.Material.Metal; if shape then p.Shape=shape end; p.Parent=m; return p
  end
  -- chassis floor (two hinged pallets) + side rails
  P("Floor",Vector3.new(4.6,0.18,7.2),CFrame.new(0,1.5,0),AL)
  P("RailL",Vector3.new(0.14,0.5,7.2),CFrame.new(-2.3,1.8,0),AL)
  P("RailR",Vector3.new(0.14,0.5,7.2),CFrame.new(2.3,1.8,0),AL)
  -- wire wheels + orange fenders at the four corners
  local d=2.0; local wd=0.9
  for i,w in ipairs({{-2.6,2.65},{2.6,2.65},{-2.6,-2.65},{2.6,-2.65}}) do
    local wc=CFrame.new(w[1],d/2,w[2])          -- Cylinder axis is local X = the axle
    local tire=P("Tire"..i,Vector3.new(wd,d,d),wc,Color3.fromRGB(176,174,170),Enum.Material.DiamondPlate,Enum.PartType.Cylinder)
    P("TireIn"..i,Vector3.new(wd+0.06,d*0.55,d*0.55),wc,DK,Enum.Material.Metal,Enum.PartType.Cylinder)
    P("HubCap"..i,Vector3.new(wd+0.12,d*0.22,d*0.22),wc,Color3.fromRGB(226,224,218),Enum.Material.Metal,Enum.PartType.Cylinder)
    for t=0,7 do   -- chevron tread strips on the wire mesh
      P("Tread_"..i.."_"..t,Vector3.new(wd+0.02,0.07,0.3),wc*CFrame.Angles(t*math.pi/4+0.3,0,0)*CFrame.new(0,d/2-0.035,0),Color3.fromRGB(120,118,114),Enum.Material.Metal)
    end
    -- fender: three angled strips over the top of the wheel
    local fy=d+0.16
    P("Fender",Vector3.new(wd+0.3,0.08,1.1),CFrame.new(w[1],fy,w[2]),OR,Enum.Material.SmoothPlastic)
    P("Fender",Vector3.new(wd+0.3,0.08,0.8),CFrame.new(w[1],fy-0.26,w[2]+0.82)*CFrame.Angles(math.rad(38),0,0),OR,Enum.Material.SmoothPlastic)
    P("Fender",Vector3.new(wd+0.3,0.08,0.8),CFrame.new(w[1],fy-0.26,w[2]-0.82)*CFrame.Angles(math.rad(-38),0,0),OR,Enum.Material.SmoothPlastic)
    -- suspension arm to chassis
    P("Susp",Vector3.new(0.75,0.14,0.14),CFrame.new(w[1]*0.84,d/2+0.12,w[2]),AL)
  end
  -- two folding seats
  for _,sx in ipairs({-1.05,1.05}) do
    P("SeatPan",Vector3.new(1.7,0.12,1.6),CFrame.new(sx,2.05,0.3),TAN,Enum.Material.Fabric)
    P("SeatBack",Vector3.new(1.7,1.7,0.12),CFrame.new(sx,2.95,1.15)*CFrame.Angles(math.rad(-8),0,0),TAN,Enum.Material.Fabric)
    P("SeatLeg",Vector3.new(1.5,0.5,1.4),CFrame.new(sx,1.78,0.3),AL)
  end
  -- centre console with the T-handle controller
  P("Console",Vector3.new(0.7,0.9,0.9),CFrame.new(0,2.1,-0.1),DK)
  P("Stick",Vector3.new(0.1,0.5,0.1),CFrame.new(0,2.8,-0.1),DK)
  P("THandle",Vector3.new(0.5,0.1,0.12),CFrame.new(0,3.05,-0.1),DK)
  -- front: battery + LCRU boxes under gold foil, high-gain dish, TV camera
  P("Batt",Vector3.new(3.6,1.0,1.4),CFrame.new(0,2.1,-2.6),Color3.fromRGB(214,176,70),Enum.Material.Foil)
  P("Mast",Vector3.new(0.12,2.6,0.12),CFrame.new(-1.2,3.6,-3.1),AL)
  -- umbrella-like high-gain antenna: disc facing up and toward Earth (cylinder axis is X)
  local dishc=CFrame.new(-1.2,5.1,-3.1)*CFrame.Angles(math.rad(-25),0,0)*CFrame.Angles(0,0,math.rad(90))
  P("Dish",Vector3.new(0.25,2.4,2.4),dishc,Color3.fromRGB(235,233,228),Enum.Material.SmoothPlastic,Enum.PartType.Cylinder)
  P("DishFeed",Vector3.new(0.9,0.08,0.08),dishc*CFrame.new(0.5,0,0),AL)
  P("TV",Vector3.new(0.5,0.45,0.6),CFrame.new(1.3,3.3,-3.0),Color3.fromRGB(90,88,84),Enum.Material.Metal)
  P("TVMast",Vector3.new(0.1,1.4,0.1),CFrame.new(1.3,2.4,-3.0),AL)
  -- rear: tool pallet
  P("Tools",Vector3.new(3.4,0.9,1.0),CFrame.new(0,2.0,3.2),Color3.fromRGB(160,158,152),Enum.Material.Metal)
  P("Antenna",Vector3.new(0.06,2.2,0.06),CFrame.new(1.6,3.4,-2.4),AL)
  m.WorldPivot=base          -- pivot at the chassis base (default would be the first part)
  m:SetAttribute("D",d)
  return m
end


-- Meridiani Planum (reference PIA05847, PIA06754): nearly rock-free plains of dark basaltic sand
-- covered in low parallel wind ripples ~1 m apart (~3.2 studs here), crests a little dustier/lighter
local function marsRipples(scene, cx, cz, half)
  local F = Instance.new("Folder"); F.Name = "Ripples"; F.Parent = scene
  local r = Random.new(2004)
  local crest = Color3.fromRGB(152, 88, 58); local flank = Color3.fromRGB(138, 78, 51)
  -- (fine wind ripples come from the Sand material's own texture; wedge ripples read as planks)
  -- shallow dimples (small eroded craters), as across the plains in the Pancam mosaics
  for i = 1, 18 do
    local d = Instance.new("Part"); d.Anchored = true; d.CanCollide = false; d.Shape = Enum.PartType.Cylinder
    local rr = r:NextNumber(2.5, 7)
    d.Size = Vector3.new(0.04, rr * 2, rr * 2 * r:NextNumber(0.75, 1))
    d.CFrame = CFrame.new(cx + r:NextNumber(-half, half), 0.02, cz + r:NextNumber(-half, half)) * CFrame.Angles(0, 0, math.rad(90))
    d.Material = Enum.Material.Sand; d.Color = Color3.fromRGB(122, 70, 46); d.CastShadow = false; d.Parent = F
  end
  return F
end


-- a field of sharp-crested barchan-like dunes in the distance (Endurance crater dunes, PIA06754)
local function marsDunes(scene, cz, cx)
  T:SetMaterialColor(Enum.Material.Sand, Color3.fromRGB(168, 104, 66))
  local r = Random.new(198)
  for i = 1, 22 do
    local x = (cx or 0) + r:NextNumber(-280, 280); local z = cz + r:NextNumber(-140, 40)
    local len = r:NextNumber(40, 90); local h = r:NextNumber(5, 12); local w = h * r:NextNumber(6, 9)
    local yaw = math.rad(r:NextNumber(-25, 25))
    local base = CFrame.new(x, h / 2 - 0.5, z) * CFrame.Angles(0, yaw, 0)
    -- gentle windward face (long) and steep slip face (short): an asymmetric ridge
    T:FillWedge(base * CFrame.new(0, 0, w * 0.36), Vector3.new(len, h, w * 0.72), Enum.Material.Sand)
    T:FillWedge(base * CFrame.new(0, 0, -w * 0.14) * CFrame.Angles(0, math.pi, 0), Vector3.new(len, h, w * 0.28), Enum.Material.Sand)
  end
  task.wait(3)
end

-- ---------------------------------------------------------------- terrain
local function ocean(seaColor)
  T.WaterColor = seaColor or Color3.fromRGB(18, 74, 96)
  T.WaterWaveSize = 0.55; T.WaterWaveSpeed = 12; T.WaterReflectance = 0.45; T.WaterTransparency = 0.25
  T:FillBlock(CFrame.new(0, -12, 0), Vector3.new(2048, 24, 2048), Enum.Material.Water)
end

local function dunes(seed)
  local r = Random.new(seed or 4)
  T:SetMaterialColor(Enum.Material.Sand, Color3.fromRGB(214, 176, 120))
  local floor = Instance.new("Part"); floor.Name = "DesertFloor"; floor.Anchored = true
  floor.Size = Vector3.new(2048, 2, 2048); floor.CFrame = CFrame.new(0, -1, 0)
  floor.Material = Enum.Material.Sand; floor.Color = Color3.fromRGB(214, 176, 120); floor.Parent = ws.Scene
  for i = 1, 70 do
    local x, z = r:NextNumber(-500, 500), r:NextNumber(-500, 500)
    local rad = r:NextNumber(40, 110)
    if math.sqrt(x * x + z * z) > rad + 60 then  -- the whole dune stays clear of the walking lane
      T:FillBall(Vector3.new(x, -rad * 0.82, z), rad, Enum.Material.Sand)
    end
  end
end

-- a winding lunar valley (Hadley Rille) cut into grey regolith, mountains beyond
local function rille()
  -- Hadley Rille, modelled on AS15-85-11425 / AS15-89-12100: a broad V-shaped trough with rounded
  -- rims, ~33 deg walls littered with talus boulders, and the smooth domes of Mount Hadley and
  -- Hadley Delta behind (the real rille is ~1.5 km wide and up to ~400 m deep; compressed here).
  T:SetMaterialColor(Enum.Material.Ground, Color3.fromRGB(150, 149, 145))   -- lunar grey, as in the Hasselblad frames
  T:FillBlock(CFrame.new(0, -30, 0), Vector3.new(2048, 60, 2048), Enum.Material.Ground)
  local W, LAY = 38, 10                    -- rim half-width, layers of 4 studs (depth 40)
  for z = -520, 520, 8 do
    local x = 70 + 38 * math.sin(z / 72)
    local ang = math.atan(38 / 72 * math.cos(z / 72))
    for j = 0, LAY - 1 do
      local w = W * (1 - j / LAY) + 3
      T:FillBlock(CFrame.new(x, -2 - 4 * j, z) * CFrame.Angles(0, ang, 0), Vector3.new(2 * w, 4.4, 11), Enum.Material.Air)
    end
  end
  -- the mountains: smooth massifs, not peaks (Mount Hadley rises ~4.5 km above the plain)
  T:FillBall(Vector3.new(-260, -330, -760), 470, Enum.Material.Ground)
  T:FillBall(Vector3.new(380, -300, -640), 400, Enum.Material.Ground)
  T:FillBall(Vector3.new(40, -420, -980), 520, Enum.Material.Ground)
  task.wait(4)          -- big terrain edits need a few seconds to mesh before captures see them
end

-- talus: boulders on the rille walls and floor and scattered on the plain (call after rille())
local function rilleRocks(scene, seed)
  local rp = RaycastParams.new(); rp.FilterType = Enum.RaycastFilterType.Include; rp.FilterDescendantsInstances = {workspace.Terrain}
  for _ = 1, 60 do if workspace:Raycast(Vector3.new(0, 200, 0), Vector3.new(0, -400, 0), rp) then break end task.wait(0.05) end
  local r = Random.new(seed or 15)
  for i = 1, 260 do
    local z = r:NextNumber(-260, 220)
    local cx = 70 + 38 * math.sin(z / 72)
    local inR = r:NextNumber() < 0.7
    local x = inR and (cx + r:NextNumber(-40, 40)) or r:NextNumber(-120, 220)
    local hit = workspace:Raycast(Vector3.new(x, 200, z), Vector3.new(0, -400, 0), rp)
    if hit then
      local big = r:NextNumber() < (inR and 0.25 or 0.08)
      local sz = big and r:NextNumber(1.6, 4.2) or r:NextNumber(0.35, 1.3)
      local p = Instance.new("Part"); p.Name = "Talus"; p.Anchored = true; p.CanCollide = false
      p.Size = Vector3.new(sz, sz * r:NextNumber(0.55, 0.9), sz * r:NextNumber(0.7, 1.1))
      p.CFrame = CFrame.new(hit.Position + Vector3.new(0, p.Size.Y * 0.3, 0)) * CFrame.Angles(r:NextNumber(-0.5, 0.5), r:NextNumber(0, 6.3), r:NextNumber(-0.5, 0.5))
      p.Material = Enum.Material.Basalt; p.Color = Color3.fromRGB(104, 101, 96); p.Parent = scene
    end
  end
end

-- ---------------------------------------------------------------- props
-- Apollo flag: pole + horizontal crossbar, 13 stripes, blue canton with stars
local function flag(cf, parent)
  local f = Instance.new("Model"); f.Name = "Flag"; f.Parent = parent or ws.Scene
  local function P(n, s, c, col, mat)
    local p = Instance.new("Part"); p.Name = n; p.Size = s; p.CFrame = cf * c; p.Anchored = true
    p.CanCollide = false; p.Color = col; p.Material = mat or Enum.Material.SmoothPlastic; p.Parent = f; return p
  end
  P("Pole", Vector3.new(0.12, 7.0, 0.12), CFrame.new(0, 3.5, 0), Color3.fromRGB(210, 210, 214), Enum.Material.Metal)
  P("Bar", Vector3.new(3.9, 0.08, 0.08), CFrame.new(1.95, 6.9, 0), Color3.fromRGB(210, 210, 214), Enum.Material.Metal)
  local W, H = 3.8, 2.4
  for i = 0, 12 do
    local col = (i % 2 == 0) and Color3.fromRGB(178, 34, 52) or Color3.fromRGB(245, 245, 245)
    local y = 6.85 - (i + 0.5) * H / 13
    -- slight ripple: the Apollo flag kept the creases from being folded
    local wave = math.sin(i * 0.9) * 0.05
    P("Stripe" .. i, Vector3.new(W, H / 13, 0.03), CFrame.new(2.0, y, wave), col)
  end
  local cw, ch = W * 0.4, H * 7 / 13
  P("Canton", Vector3.new(cw, ch, 0.035), CFrame.new(0.05 + cw / 2 + 0.05, 6.85 - ch / 2, 0.005), Color3.fromRGB(60, 59, 110))
  for r = 0, 4 do for c = 0, 5 do
    P("Star", Vector3.new(0.07, 0.07, 0.04), CFrame.new(0.2 + c * (cw - 0.2) / 5.5, 6.75 - r * (ch - 0.2) / 4.5, 0.03), Color3.fromRGB(245, 245, 245), Enum.Material.Neon)
  end end
  return f
end

-- Apollo Lunar Module "Eagle", built from parts to the real layout (references AS11-40-5868, AS11-40-5873,
-- AS11-40-5927 and the NASA LM drawings). Metres are converted at M studs/m: the real LM stood ~7.0 m on
-- its legs; M=2.4 makes it ~17 studs, about 3.3x the astronauts here (the real ratio is ~3.9).
-- Local frame: -Z is the FRONT (forward hatch, porch and ladder leg). Returns the model and the ascent stage.
local function procLM(x, z, yaw)
  local M = 2.4
  local m = Instance.new("Model"); m.Name = "LM"; m.Parent = ws.Scene
  local asc = Instance.new("Model"); asc.Name = "AscentStage"; asc.Parent = m
  local base = CFrame.new(x or 0, 0, z or 0) * CFrame.Angles(0, math.rad(yaw or -25), 0)
  local GOLD = Color3.fromRGB(212, 132, 44); local AMBER = Color3.fromRGB(176, 88, 30)   -- amber Kapton, as photographed
  local BLACK = Color3.fromRGB(30, 30, 32); local SILVER = Color3.fromRGB(196, 196, 192)
  local GREY = Color3.fromRGB(150, 150, 146); local DGREY = Color3.fromRGB(82, 82, 84)
  local function P(parent, n, sz, cf, col, mat, cls)
    local p = Instance.new(cls or "Part"); p.Name = n; p.Anchored = true; p.CanCollide = false
    p.Size = sz * M; p.CFrame = base * (cf - cf.Position + cf.Position * M)
    p.Color = col; p.Material = mat or Enum.Material.SmoothPlastic
    p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent; return p
  end
  local function C(parent, n, len, dia, cf, col, mat)        -- cylinder along local X of cf
    local p = P(parent, n, Vector3.new(len, dia, dia), cf, col, mat); p.Shape = Enum.PartType.Cylinder; return p
  end
  local function rod(parent, n, a, b, dia, col, mat)          -- strut between two points (metres)
    local mid = (a + b) / 2; local len = (b - a).Magnitude
    return P(parent, n, Vector3.new(dia, dia, len), CFrame.lookAt(mid, b), col, mat or Enum.Material.Metal)
  end
  -- ---------------- DESCENT STAGE: octagon 4.2 m across, 1.65 m tall, wrapped in gold foil ----------
  local A, Y0, Y1 = 2.1, 1.45, 3.1                  -- apothem, bottom, top
  local side = 2 * A * math.tan(math.pi / 8)        -- octagon side length (1.74 m)
  for i = 0, 7 do
    local ang = i * math.pi / 4
    local diag = (i % 2 == 1)
    local cf = CFrame.Angles(0, ang, 0) * CFrame.new(0, (Y0 + Y1) / 2, -A)
    P(m, diag and "BayPanel" or "FacePanel", Vector3.new(side + 0.02, Y1 - Y0, 0.12), cf,
      diag and AMBER or GOLD, Enum.Material.Foil)
    if diag then   -- the quadrant bays carry black thermal blankets on their lower half
      P(m, "BayBlack", Vector3.new(side * 0.8, (Y1 - Y0) * 0.45, 0.13), cf * CFrame.new(0, -(Y1 - Y0) * 0.22, -0.01), BLACK, Enum.Material.Fabric)
    end
  end
  P(m, "Deck", Vector3.new(2 * A, 0.1, side), CFrame.new(0, Y1, 0), GOLD, Enum.Material.Foil)
  P(m, "Deck", Vector3.new(side, 0.1, 2 * A), CFrame.new(0, Y1, 0), GOLD, Enum.Material.Foil)
  P(m, "Deck", Vector3.new(2 * A * 0.93, 0.1, 2 * A * 0.93), CFrame.new(0, Y1, 0) * CFrame.Angles(0, math.rad(45), 0), GOLD, Enum.Material.Foil)
  P(m, "HeatShield", Vector3.new(2 * A * 0.98, 0.12, 2 * A * 0.98), CFrame.new(0, Y0, 0), BLACK, Enum.Material.Fabric)
  P(m, "HeatShield", Vector3.new(2 * A * 0.9, 0.12, 2 * A * 0.9), CFrame.new(0, Y0, 0) * CFrame.Angles(0, math.rad(45), 0), BLACK, Enum.Material.Fabric)
  -- descent engine bell under the centre
  for j, s2 in ipairs({{1.55, 0.18}, {1.35, 0.25}, {1.12, 0.25}, {0.92, 0.25}}) do
    C(m, "Bell", s2[2], s2[1], CFrame.new(0, Y0 - 0.1 - (j - 1) * 0.24, 0) * CFrame.Angles(0, 0, math.rad(90)), DGREY, Enum.Material.Metal)
  end
  -- a hidden reference part the frame scripts use for the stage's centre and top
  local ref = C(m, "DescentStage", Y1 - Y0, 2 * A, CFrame.new(0, (Y0 + Y1) / 2, 0) * CFrame.Angles(0, 0, math.rad(90)), GOLD)
  ref.Transparency = 1; ref.CastShadow = false
  -- ---------------- LEGS: on the four main axes; primary strut + two secondaries + footpad ----------
  local ladder = Instance.new("Model"); ladder.Name = "Ladder"; ladder.Parent = m
  for i = 0, 3 do
    local R = CFrame.Angles(0, i * math.pi / 2, 0)
    local function L(v) return (R * CFrame.new(v)).Position end
    local top = L(Vector3.new(0, Y1 - 0.25, -A - 0.05))
    local knee = L(Vector3.new(0, 1.25, -3.55))
    local pad = L(Vector3.new(0, 0.14, -4.45))
    rod(m, "Leg" .. i, top, knee, 0.2, GOLD, Enum.Material.Foil)
    rod(m, "LegLow" .. i, knee, pad + Vector3.new(0, 0.12, 0), 0.16, SILVER)
    for _, sx in ipairs({-1, 1}) do
      local root = L(Vector3.new(sx * 0.95, Y0 + 0.05, -A + 0.1))
      rod(m, "Strut" .. i, root, knee, 0.09, GOLD, Enum.Material.Foil)
      rod(m, "Strut" .. i, L(Vector3.new(sx * 1.2, Y0 + 0.4, -A + 0.4)), L(Vector3.new(0, 2.0, -3.0)), 0.06, SILVER)
    end
    local pcf = CFrame.new(pad)
    C(m, "Pad" .. i, 0.16, 0.94, pcf * CFrame.Angles(0, 0, math.rad(90)), GOLD, Enum.Material.Foil)
    C(m, "PadRim" .. i, 0.06, 0.98, (pcf + Vector3.new(0, 0.08, 0)) * CFrame.Angles(0, 0, math.rad(90)), AMBER, Enum.Material.Foil)
    if i ~= 0 then   -- contact probes, bent back under the pads after touchdown
      rod(m, "Probe" .. i, pad + Vector3.new(0, 0.05, 0), L(Vector3.new(0.5, 0.05, -5.3)), 0.04, SILVER)
    end
    if i == 0 then   -- the ladder on the forward leg, and the porch under the hatch
      local up = (top - knee).Unit
      local rgt = (R * CFrame.new(0, 0, 0)).RightVector
      local function RL(v) return v end
      for _, sx in ipairs({-0.32, 0.32}) do
        rod(ladder, "Rail", knee + rgt * sx, top + rgt * sx - up * 0.15, 0.06, GOLD, Enum.Material.Foil)
      end
      for r = 0, 8 do
        local q = knee:Lerp(top - up * 0.25, (r + 0.5) / 9)
        local rung = rod(ladder, "Rung", q - rgt * 0.32 - Vector3.new(0, 0, 0.06), q + rgt * 0.32 - Vector3.new(0, 0, 0.06), 0.05, SILVER)
      end
      P(m, "Porch", Vector3.new(0.95, 0.06, 0.75), CFrame.new(0, Y1 + 0.02, -A - 0.38), SILVER, Enum.Material.DiamondPlate)
      for _, sx in ipairs({-0.48, 0.48}) do
        rod(m, "PorchRail", Vector3.new(sx, Y1 + 0.05, -A - 0.75), Vector3.new(sx, Y1 + 0.75, -A - 0.15), 0.04, SILVER)
      end
    end
  end
  -- ---------------- ASCENT STAGE ------------------------------------------------------------------
  local Y2 = Y1 + 0.05
  C(asc, "Interstage", 0.3, 1.7, CFrame.new(0, Y2 + 0.15, 0.1) * CFrame.Angles(0, 0, math.rad(90)), BLACK, Enum.Material.Fabric)
  -- crew compartment: black front, faceted upper face carrying the two triangular windows
  local cz = -0.55
  P(asc, "Cabin", Vector3.new(2.35, 1.75, 1.55), CFrame.new(0, Y2 + 0.3 + 0.875, cz), DGREY, Enum.Material.Metal)
  P(asc, "CabinFront", Vector3.new(2.35, 1.75, 0.08), CFrame.new(0, Y2 + 0.3 + 0.875, cz - 0.8), Color3.fromRGB(168, 168, 164), Enum.Material.Metal)
  P(asc, "WindowFrame", Vector3.new(2.0, 0.85, 0.06), CFrame.new(0, Y2 + 1.72, cz - 0.86), BLACK, Enum.Material.Fabric)
  local fac = P(asc, "Facet", Vector3.new(2.35, 0.7, 1.2), CFrame.new(0, Y2 + 2.05 + 0.35, cz + 0.17), DGREY, Enum.Material.Metal, "WedgePart")
  fac.CFrame = base * (CFrame.new(Vector3.new(0, Y2 + 2.4, cz + 0.17) * M) * CFrame.Angles(0, math.pi, 0))
  for _, sx in ipairs({-1, 1}) do     -- two triangular windows, apex toward the centre line
    local w = P(asc, "Window", Vector3.new(0.05, 0.62, 0.78), CFrame.new(0, 0, 0), Color3.fromRGB(70, 84, 104), Enum.Material.Glass, "WedgePart")
    w.Reflectance = 0.45
    w.CFrame = base * (CFrame.new(Vector3.new(sx * 0.5, Y2 + 1.72, cz - 0.9) * M) * CFrame.Angles(0, math.rad(sx > 0 and 90 or -90), 0))
  end
  P(asc, "Hatch", Vector3.new(0.82, 0.82, 0.06), CFrame.new(0, Y2 + 0.75, cz - 0.84), GREY, Enum.Material.Metal)
  P(asc, "HatchHandle", Vector3.new(0.35, 0.05, 0.05), CFrame.new(0.2, Y2 + 0.8, cz - 0.88), SILVER, Enum.Material.Metal)
  -- midsection with the propellant-tank fairings bulging out on each side
  P(asc, "Midsection", Vector3.new(3.0, 1.9, 1.3), CFrame.new(0, Y2 + 0.3 + 0.95, 0.75), SILVER, Enum.Material.Foil)
  for _, sx in ipairs({-1, 1}) do
    local t = P(asc, "TankFairing", Vector3.new(1.3, 1.3, 1.3), CFrame.new(sx * 1.45, Y2 + 1.05, 0.55), SILVER, Enum.Material.Foil)
    t.Shape = Enum.PartType.Ball
  end
  -- aft equipment bay (black)
  P(asc, "AftBay", Vector3.new(1.9, 1.05, 0.7), CFrame.new(0, Y2 + 1.35, 1.72), BLACK, Enum.Material.Fabric)
  -- docking tunnel on top, rendezvous radar (front right), S-band steerable dish (left), VHF antennas
  C(asc, "DockTunnel", 0.5, 0.85, CFrame.new(0, Y2 + 2.75 + 0.25, 0.15) * CFrame.Angles(0, 0, math.rad(90)), GREY, Enum.Material.Metal)
  P(asc, "DockTarget", Vector3.new(0.05, 0.5, 0.05), CFrame.new(-0.5, Y2 + 3.05, -0.2), BLACK)
  rod(asc, "RadarMast", Vector3.new(0.8, Y2 + 2.45, -0.75), Vector3.new(0.8, Y2 + 2.95, -0.95), 0.08, SILVER)
  C(asc, "RadarDish", 0.12, 0.62, CFrame.new(0.8, Y2 + 3.05, -1.02) * CFrame.Angles(math.rad(-35), math.rad(90), 0), SILVER, Enum.Material.Metal)
  rod(asc, "SBandBoom", Vector3.new(-1.05, Y2 + 2.4, 0.7), Vector3.new(-1.45, Y2 + 3.0, 0.9), 0.07, SILVER)
  C(asc, "SBandDish", 0.1, 0.66, CFrame.new(-1.5, Y2 + 3.1, 0.92) * CFrame.Angles(math.rad(-20), math.rad(60), math.rad(10)), SILVER, Enum.Material.Metal)
  for _, sx in ipairs({-1, 1}) do
    rod(asc, "VHF", Vector3.new(sx * 0.7, Y2 + 2.25, 2.0), Vector3.new(sx * 1.15, Y2 + 3.15, 2.2), 0.035, SILVER)
  end
  -- four RCS thruster quads at the corners, each with four nozzles
  for _, c in ipairs({{-1, -1}, {1, -1}, {-1, 1}, {1, 1}}) do
    local q = Vector3.new(c[1] * 1.6, Y2 + 2.0, c[2] * 1.05 + 0.3)
    P(asc, "RCSQuad", Vector3.new(0.32, 0.32, 0.32), CFrame.new(q), DGREY, Enum.Material.Metal)
    rod(asc, "RCSBoom", q, Vector3.new(c[1] * 1.15, Y2 + 2.0, c[2] * 0.75 + 0.3), 0.08, SILVER)
    for _, d in ipairs({Vector3.new(0, 1, 0), Vector3.new(0, -1, 0), Vector3.new(0, 0, c[2]), Vector3.new(c[1], 0, 0)}) do
      rod(asc, "RCSNozzle", q + d * 0.16, q + d * 0.36, 0.11, Color3.fromRGB(60, 60, 62), Enum.Material.Metal)
    end
  end
  -- ascent engine cover glimpsed under the stage
  C(asc, "AscentEngine", 0.25, 0.9, CFrame.new(0, Y2 + 0.05, 0.1) * CFrame.Angles(0, 0, math.rad(90)), DGREY, Enum.Material.Metal)
  m.WorldPivot = base; asc.WorldPivot = base
  return m, asc
end

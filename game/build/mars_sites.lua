-- The six remaining machines that are really sitting on Mars right now, each at its own
-- landing site. Coordinates from game/archive_catalog.json (NSSDCA).
local B=(function()
EQUIPMENT_MODELS
end)()

local game_=workspace:WaitForChild("Game")
local M=2.4
local made={}

local function attrs(m,t) for k,v in pairs(t) do m:SetAttribute(k,v) end end
local function anchorFor(m,pos,object)
  local a=Instance.new("Part"); a.Name="Anchor"; a.Size=Vector3.new(1,1,1)
  a.Transparency=1; a.CanCollide=false; a.Anchored=true; a.CFrame=CFrame.new(pos); a.Parent=m
  local pp=Instance.new("ProximityPrompt")
  pp.ActionText="Scan"; pp.ObjectText=object; pp.KeyboardKeyCode=Enum.KeyCode.E
  pp.HoldDuration=0.25; pp.MaxActivationDistance=12; pp.RequiresLineOfSight=false; pp.Parent=a
end

local function sign(F,OX,OZ,title,coords,l1,l2)
  local sg=Instance.new("Model"); sg.Name="SiteSign"; sg.Parent=F
  local sb=CFrame.lookAt(Vector3.new(OX,0,OZ+48),Vector3.new(OX,0,OZ))
  local function SP(n,sz,cf,col)
    local p=Instance.new("Part"); p.Name=n; p.Anchored=true; p.Size=sz; p.CFrame=sb*cf
    p.Color=col; p.Material=Enum.Material.Metal; p.Parent=sg; return p
  end
  SP("Post",Vector3.new(0.2,4.2,0.2),CFrame.new(-2.3,2.1,0),Color3.fromRGB(190,190,186))
  SP("Post2",Vector3.new(0.2,4.2,0.2),CFrame.new(2.3,2.1,0),Color3.fromRGB(190,190,186))
  local board=SP("Board",Vector3.new(5.2,2.3,0.12),CFrame.new(0,3.3,0),Color3.fromRGB(14,14,16))
  board.Material=Enum.Material.SmoothPlastic
  local g=Instance.new("SurfaceGui"); g.Face=Enum.NormalId.Back; g.CanvasSize=Vector2.new(620,274)
  g.LightInfluence=0; g.Parent=board
  local function T(txt,y,h,font,col)
    local l=Instance.new("TextLabel"); l.Size=UDim2.new(1,-28,0,h); l.Position=UDim2.fromOffset(14,y)
    l.BackgroundTransparency=1; l.Font=font; l.TextColor3=col; l.Text=txt
    l.TextScaled=true; l.TextXAlignment=Enum.TextXAlignment.Left; l.Parent=g
  end
  T(title,12,44,Enum.Font.GothamBold,Color3.fromRGB(245,231,60))
  T(coords,62,30,Enum.Font.GothamMedium,Color3.fromRGB(215,215,220))
  T(l1,102,28,Enum.Font.Gotham,Color3.fromRGB(165,170,176))
  T(l2,134,28,Enum.Font.Gotham,Color3.fromRGB(165,170,176))
  T("HERITAGE SITE  ·  DO NOT DISTURB",176,34,Enum.Font.GothamBold,Color3.fromRGB(150,205,255))
end

-- ground, scattered to suit each place
local function terrain(F,OX,OZ,soil,rockCol,rocks,polar)
  local pan=Instance.new("Part")
  pan.Name="Ground"; pan.Anchored=true; pan.Size=Vector3.new(250,4,250)
  pan.Position=Vector3.new(OX,-2,OZ); pan.Color=soil
  pan.Material=polar and Enum.Material.Glacier or Enum.Material.Sand
  pan.TopSurface=Enum.SurfaceType.Smooth; pan.Parent=F
  for i=1,rocks do
    local r=Instance.new("Part")
    r.Name="Rock"; r.Anchored=true
    local s=0.7+((i*11)%28)/10
    r.Size=Vector3.new(s,s*0.6,s*0.8)
    r.Position=Vector3.new(OX-110+((i*43)%220),s*0.3,OZ-110+((i*67)%220))
    r.Orientation=Vector3.new(0,(i*31)%180,0)
    r.Color=rockCol; r.Material=Enum.Material.Slate; r.Parent=F
  end
  if polar then
    -- polygonal ice-wedge ground, which is what Phoenix landed on and photographed
    for i=1,24 do
      local p=Instance.new("Part")
      p.Name="Polygon"; p.Anchored=true
      p.Size=Vector3.new(34,0.5,34)
      p.Position=Vector3.new(OX-100+((i%5)*48),0.2,OZ-100+(math.floor(i/5)*48))
      p.Color=Color3.fromRGB(186,172,152); p.Material=Enum.Material.Glacier; p.Parent=F
    end
  end
end

local function site(name,OX,OZ,soil,rockCol,rocks,polar)
  local old=game_:FindFirstChild(name); if old then old:Destroy() end
  local F=Instance.new("Folder"); F.Name=name; F.Parent=game_
  F:SetAttribute("World","Mars")
  terrain(F,OX,OZ,soil,rockCol,rocks,polar)
  table.insert(made,name)
  return F
end

local RED=Color3.fromRGB(150,92,58)
local DRK=Color3.fromRGB(112,68,46)

-- ========== Viking 1 · Chryse Planitia ==========
do
  local OX,OZ=-470,1420
  local F=site("Chryse",OX,OZ,Color3.fromRGB(158,100,66),DRK,60)
  local m=B.viking(CFrame.new(OX,0,OZ)*CFrame.Angles(0,math.rad(26),0),F)
  m.Name="Viking1"
  attrs(m,{ArtifactId="viking1",Title="Viking 1 Lander",
    Year="Landed 20 July 1976 · last contact 13 November 1982",
    What="A three-legged lander the size of a small car, powered by two plutonium generators rather than sunlight, with a scoop on an arm and a weather mast.",
    Why="To take the first pictures from the surface of Mars, and to run the first experiments looking for life in the soil.",
    Science="It returned the first clear photographs ever taken from the Martian surface, and worked for more than six years — far beyond its 90-day design. Its biology experiments gave results nobody could agree on, which is part of why we are still sending landers."})
  anchorFor(m,Vector3.new(OX,3.0,OZ),"Viking 1")
  sign(F,OX,OZ,"CHRYSE PLANITIA","22.27 N, 312.05 E  ·  Viking 1, 1976",
    "The first US spacecraft to work on the surface of Mars.","Nuclear powered, so the dust could not starve it.")
end

-- ========== Viking 2 · Utopia Planitia ==========
do
  local OX,OZ=-430,1760
  local F=site("Utopia",OX,OZ,Color3.fromRGB(146,96,64),DRK,72)
  local m=B.viking(CFrame.new(OX,0,OZ)*CFrame.Angles(0,math.rad(-40),0),F)
  m.Name="Viking2"
  attrs(m,{ArtifactId="viking2",Title="Viking 2 Lander",
    Year="Landed 3 September 1976 · switched off 11 April 1980",
    What="Viking 1's identical twin, set down on the other side of the planet.",
    Why="Two landers in two very different places, so the results could be compared rather than guessed at. That is how you tell a local oddity from something true of the whole planet.",
    Science="It photographed thin water frost forming on the ground in winter — the first time anyone saw weather happen on another planet's surface. Its batteries failed after three and a half years."})
  anchorFor(m,Vector3.new(OX,3.0,OZ),"Viking 2")
  sign(F,OX,OZ,"UTOPIA PLANITIA","47.67 N, 134.28 E  ·  Viking 2, 1976",
    "Far enough north that frost settles here in winter.","Viking 1's twin, deliberately landed somewhere unlike it.")
end

-- ========== Spirit · Gusev Crater ==========
do
  local OX,OZ=330,1420
  local F=site("Gusev",OX,OZ,Color3.fromRGB(142,86,54),DRK,66)
  -- Spirit is Opportunity's identical twin, so it is built from the same parts
  local m=Instance.new("Model"); m.Name="Spirit"; m.Parent=F
  local base=CFrame.new(OX,0,OZ)*CFrame.Angles(0,math.rad(-24),0)
  local BODY=Color3.fromRGB(206,204,196); local CELL=Color3.fromRGB(34,46,92)
  local DARKC=Color3.fromRGB(52,52,56)
  local function P(n,sz,cf,col,mat)
    local p=Instance.new("Part"); p.Name=n; p.Anchored=true; p.CanCollide=false
    p.Size=sz*M; p.CFrame=base*CFrame.new(cf.Position*M)*(cf-cf.Position)
    p.Color=col; p.Material=mat or Enum.Material.SmoothPlastic
    p.TopSurface=Enum.SurfaceType.Smooth; p.BottomSurface=Enum.SurfaceType.Smooth
    p.Parent=m; return p
  end
  P("Deck",Vector3.new(1.6,0.14,1.3),CFrame.new(0,0.72,0),BODY,Enum.Material.Metal)
  P("PanelC",Vector3.new(1.5,0.05,1.2),CFrame.new(0,0.82,0),CELL,Enum.Material.Glass)
  P("PanelL",Vector3.new(1.5,0.05,0.85),CFrame.new(0,0.80,-1.0)*CFrame.Angles(math.rad(6),0,0),CELL,Enum.Material.Glass)
  P("PanelR",Vector3.new(1.5,0.05,0.85),CFrame.new(0,0.80,1.0)*CFrame.Angles(math.rad(-6),0,0),CELL,Enum.Material.Glass)
  P("Mast",Vector3.new(0.09,1.0,0.09),CFrame.new(0.5,1.25,0),BODY,Enum.Material.Metal)
  P("PanCam",Vector3.new(0.5,0.16,0.14),CFrame.new(0.5,1.80,0),DARKC,Enum.Material.Metal)
  P("HGA",Vector3.new(0.42,0.08,0.42),CFrame.new(-0.45,0.92,0.3),Color3.fromRGB(200,198,192),Enum.Material.Foil)
  for _,wz in ipairs({0.72,-0.72}) do
    for _,wx in ipairs({0.62,0,-0.62}) do
      local w=P("Wheel",Vector3.new(0.18,0.52,0.52),CFrame.new(wx,0.3,wz),DARKC,Enum.Material.Metal)
      w.Shape=Enum.PartType.Cylinder
      w.CFrame=base*CFrame.new(Vector3.new(wx,0.3,wz)*M)*CFrame.Angles(math.rad(90),0,math.rad(90))
    end
  end
  -- it ended up bogged to the axles in soft soil, so bank it over and sink one side
  m:PivotTo(m:GetPivot()*CFrame.Angles(0,0,math.rad(9)))
  local soft=Instance.new("Part")
  soft.Name="SoftSoil"; soft.Anchored=true; soft.CanCollide=false
  soft.Size=Vector3.new(11,1.2,9); soft.Position=Vector3.new(OX,0.3,OZ)
  soft.Color=Color3.fromRGB(176,150,116); soft.Material=Enum.Material.Sand; soft.Parent=F
  attrs(m,{ArtifactId="spirit",Title="Spirit (MER-A)",
    Year="Landed 4 January 2004 · last transmission 22 March 2010",
    What="Opportunity's identical twin, landed on the other side of Mars three weeks earlier.",
    Why="Gusev Crater has a dry river valley running into it, so it looked like a crater lake that had drained. The idea was to read the bottom of it.",
    Science="It found what it was sent for in the hills above the crater floor: rocks altered by water, and almost pure silica of the kind that forms around hot springs. In 2009 it broke through a crust into soft sand and could not get out, and with one wheel already dead it could not be angled toward the winter Sun. It kept working where it stood until the cold took it."})
  anchorFor(m,Vector3.new(OX,2.6,OZ),"Spirit")
  sign(F,OX,OZ,"GUSEV CRATER","14.57 S, 175.48 E  ·  Spirit, 2004–2010",
    "A crater with a dry river valley draining into it.","Spirit is still here, bogged in the soft ground it broke through.")
end

-- ========== Phoenix · northern polar plains ==========
do
  local OX,OZ=-150,1210
  local F=site("VastitasBorealis",OX,OZ,Color3.fromRGB(176,158,134),Color3.fromRGB(128,108,88),34,true)
  local m=B.phoenix(CFrame.new(OX,0,OZ)*CFrame.Angles(0,math.rad(14),0),F)
  m.Name="Phoenix"
  attrs(m,{ArtifactId="phoenix",Title="Phoenix Mars Lander",
    Year="Landed 25 May 2008 · last signal 2 November 2008",
    What="A solar-powered lander with a digging arm, set down far enough north to reach ice a few centimetres below the surface.",
    Why="To touch Martian water directly instead of inferring it from orbit, and to find out whether the soil could support life.",
    Science="It dug down, found bright material, and watched it vanish over a few days — ice turning straight to vapour. Then it melted ice in an onboard oven and confirmed it was water. The icy soil was so sticky it clung inside the upside-down scoop and the team had to shake it loose. When the arctic winter came the sunlight ran out, exactly as planned."})
  anchorFor(m,Vector3.new(OX,3.4,OZ),"Phoenix")
  sign(F,OX,OZ,"NORTHERN POLAR PLAINS","68.15 N, 125.9 W  ·  Phoenix, 2008",
    "The cracked polygons underfoot are ice wedges.","There is water ice a few centimetres down.")
end

-- ========== InSight · Elysium Planitia ==========
do
  local OX,OZ=360,1740
  local F=site("Elysium",OX,OZ,Color3.fromRGB(152,96,62),DRK,40)
  local m=B.insight(CFrame.new(OX,0,OZ)*CFrame.Angles(0,math.rad(-16),0),F)
  m.Name="InSight"
  attrs(m,{ArtifactId="insight",Title="InSight",
    Year="Landed 26 November 2018 · last transmission 15 December 2022",
    What="A lander that never moved: two wide solar wings, and a seismometer it lifted off its own deck and set down on the ground under a wind shield.",
    Why="To listen to the inside of Mars. A seismometer reads a planet's interior the way the Apollo instruments read the Moon's.",
    Science="It recorded well over a thousand marsquakes and used them to measure the crust, mantle and core — the first time anyone has sounded the inside of another planet. Dust built up on its panels year after year until there was not enough power left to answer. The site was deliberately chosen to be boring: flat, safe and quiet, because the science was underground."})
  anchorFor(m,Vector3.new(OX,3.2,OZ),"InSight")
  sign(F,OX,OZ,"ELYSIUM PLANITIA","4.5 N, 135.62 E  ·  InSight, 2018–2022",
    "Chosen for being flat, safe and dull.","All of its science was underneath it.")
end

-- ========== Ingenuity · Jezero Crater ==========
do
  local OX,OZ=60,1830
  local F=site("Jezero",OX,OZ,Color3.fromRGB(144,88,56),DRK,54)
  local m=B.ingenuity(CFrame.new(OX,0,OZ)*CFrame.Angles(0,math.rad(38),0),F)
  m.Name="Ingenuity"
  attrs(m,{ArtifactId="ingenuity",Title="Ingenuity",
    Year="First flight 19 April 2021 · last flight 18 January 2024",
    What="A helicopter weighing under two kilograms, with two rotors turning in opposite directions at over 2,000 rpm because the air here is about one percent as thick as Earth's.",
    Why="To find out whether powered flight on another planet was possible at all. It carried no science instruments: it was there to prove the idea.",
    Science="Its first hop lasted 39 seconds and was the first powered, controlled flight anywhere but Earth. It was meant to fly five times. It flew 72, scouting routes for Perseverance, until a rotor blade was damaged on landing and it could not fly safely again. It is still standing where it came down."})
  anchorFor(m,Vector3.new(OX,2.4,OZ),"Ingenuity")
  sign(F,OX,OZ,"JEZERO CRATER","18.45 N, 77.45 E  ·  Ingenuity, 2021–2024",
    "An ancient river delta. Perseverance is still working here.","The air is about 1% of Earth's — and it flew anyway.")
end

return "Mars sites: "..table.concat(made,", ")

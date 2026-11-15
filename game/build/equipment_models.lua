-- Replicas of the equipment named in the Space Apps challenge, built from parts to real dimensions
-- (metres x M studs/m; M = 2.4, the same scale as the Eagle). Ground is y = 0 in each model's frame,
-- -Z is its front. Every builder returns a Model whose WorldPivot is its base.
-- Sources for dimensions: NSSDCA spacecraft records and NASA mission fact sheets (see game/archive_catalog.json).
local M = 2.4
local WHITE = Color3.fromRGB(228, 228, 222); local ALU = Color3.fromRGB(188, 188, 184)
local DARK = Color3.fromRGB(58, 58, 62); local BLACK = Color3.fromRGB(26, 26, 28)
local GOLD = Color3.fromRGB(212, 148, 56); local CELL = Color3.fromRGB(30, 42, 82)
local COPPER = Color3.fromRGB(150, 92, 54)

local function kit(name, base, parent)
  local m = Instance.new("Model"); m.Name = name; m.Parent = parent
  local K = {}
  function K.P(n, sz, cf, col, mat, cls)
    local p = Instance.new(cls or "Part"); p.Name = n; p.Anchored = true; p.CanCollide = true   -- solid: players bump into and stand on replicas
    p.Size = sz * M; p.CFrame = base * (cf - cf.Position + cf.Position * M)
    p.Color = col; p.Material = mat or Enum.Material.SmoothPlastic
    p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = m; return p
  end
  function K.C(n, len, dia, cf, col, mat)       -- cylinder along the local X of cf
    local p = K.P(n, Vector3.new(len, dia, dia), cf, col, mat); p.Shape = Enum.PartType.Cylinder; return p
  end
  function K.disc(n, dia, pos, col, mat, th, tilt)   -- flat disc lying horizontal
    th = th or 0.06
    return K.C(n, th, dia, CFrame.new(pos) * (tilt or CFrame.new()) * CFrame.Angles(0, 0, math.rad(90)), col, mat)
  end
  function K.ball(n, dia, pos, col, mat)
    local p = K.P(n, Vector3.new(dia, dia, dia), CFrame.new(pos), col, mat); p.Shape = Enum.PartType.Ball; return p
  end
  function K.rod(n, a, b, dia, col, mat)
    local mid = (a + b) / 2
    return K.P(n, Vector3.new(dia, dia, (b - a).Magnitude), CFrame.lookAt(mid, b), col or ALU, mat or Enum.Material.Metal)
  end
  function K.dish(n, dia, pos, aim, col)           -- shallow dish: rim disc + back cone step, facing `aim`
    local cf = CFrame.lookAt(pos, pos + aim) * CFrame.Angles(0, math.rad(90), 0)
    K.C(n, 0.04, dia, cf, col or WHITE, Enum.Material.SmoothPlastic)
    K.C(n .. "Back", 0.08, dia * 0.55, cf * CFrame.new(-0.05, 0, 0), col or WHITE, Enum.Material.SmoothPlastic)
    K.rod(n .. "Feed", pos, pos + aim.Unit * dia * 0.35, 0.03, ALU)
  end
  function K.done() m.WorldPivot = base; return m end
  return K, m
end

local B = {}

-- Surveyor 3 (1967): aluminium tripod, mast with solar panel and planar antenna, TV camera, two thermal
-- boxes, vernier tanks, crushable footpads. ~3 m tall, footpads spread over ~4.3 m.
function B.surveyor3(base, parent)
  local K, m = kit("Surveyor3", base, parent)
  local corners, pads = {}, {}
  for i = 0, 2 do
    local a = math.rad(90 + i * 120)
    corners[i] = Vector3.new(math.cos(a) * 0.75, 0.95, math.sin(a) * 0.75)
    pads[i] = Vector3.new(math.cos(a) * 2.15, 0.08, math.sin(a) * 2.15)
  end
  local apex = Vector3.new(0, 1.85, 0)
  for i = 0, 2 do
    local j = (i + 1) % 3
    K.rod("Frame", corners[i], corners[j], 0.05)
    K.rod("Tripod", corners[i], apex, 0.05)
    K.rod("Leg", corners[i], pads[i] + Vector3.new(0, 0.12, 0), 0.07)
    K.rod("LegBrace", Vector3.new(0, 0.85, 0), pads[i]:Lerp(corners[i], 0.35), 0.04)
    K.disc("Footpad", 0.32, pads[i], ALU, Enum.Material.Metal)
    K.ball("VernierTank", 0.3, corners[i]:Lerp(Vector3.new(0, 0.95, 0), 0.45) + Vector3.new(0, 0.18, 0), ALU, Enum.Material.Metal)
  end
  K.rod("Mast", apex, apex + Vector3.new(0, 1.05, 0), 0.06)
  K.P("SolarPanel", Vector3.new(0.92, 0.04, 0.93), CFrame.new(0.18, 2.95, 0.15) * CFrame.Angles(math.rad(25), math.rad(30), 0), CELL, Enum.Material.Glass)
  K.P("PlanarAntenna", Vector3.new(0.8, 0.8, 0.04), CFrame.new(-0.35, 2.75, -0.1) * CFrame.Angles(0, math.rad(-35), math.rad(10)), WHITE)
  K.P("CompartmentA", Vector3.new(0.5, 0.36, 0.45), CFrame.new(0.55, 1.15, 0.05) * CFrame.Angles(0, math.rad(30), 0), WHITE)
  K.P("CompartmentB", Vector3.new(0.5, 0.36, 0.45), CFrame.new(-0.55, 1.15, 0.05) * CFrame.Angles(0, math.rad(-30), 0), WHITE)
  K.C("TVCamera", 0.6, 0.2, CFrame.new(0, 1.3, -0.62) * CFrame.Angles(0, 0, math.rad(90)), WHITE, Enum.Material.SmoothPlastic)
  K.P("MirrorHood", Vector3.new(0.24, 0.22, 0.24), CFrame.new(0, 1.68, -0.62), ALU, Enum.Material.Metal)
  K.rod("SamplerArm", Vector3.new(0.3, 0.9, -0.55), Vector3.new(0.75, 0.55, -1.3), 0.04, ALU)
  K.P("Scoop", Vector3.new(0.12, 0.08, 0.15), CFrame.new(0.78, 0.5, -1.36), DARK, Enum.Material.Metal)
  return K.done()
end

-- Viking Lander (1976): hexagonal body ~0.46 m deep about 0.7 m off the ground, three legs, two
-- plutonium RTGs under windscreens, 0.76 m high-gain dish, twin camera turrets, sampler arm, met boom.
function B.viking(base, parent)
  local K, m = kit("VikingLander", base, parent)
  local s = 0.9; local a = s * math.sqrt(3) / 2
  for i = 0, 2 do   -- union of three rectangles = regular hexagon
    K.P("Body", Vector3.new(s, 0.46, 2 * a), CFrame.new(0, 0.7, 0) * CFrame.Angles(0, math.rad(i * 60), 0), WHITE)
  end
  for i = 0, 2 do
    local ang = math.rad(30 + i * 120)
    local top = Vector3.new(math.cos(ang) * s, 0.6, math.sin(ang) * s)
    local pad = Vector3.new(math.cos(ang) * 1.45, 0.06, math.sin(ang) * 1.45)
    K.rod("Leg", top, pad + Vector3.new(0, 0.1, 0), 0.08)
    K.rod("LegStrut", top + Vector3.new(0, -0.15, 0) - Vector3.new(math.cos(ang), 0, math.sin(ang)) * 0.4, pad:Lerp(top, 0.4), 0.04)
    K.disc("Footpad", 0.3, pad, ALU, Enum.Material.Metal)
  end
  for _, sx in ipairs({-1, 1}) do
    K.P("RTGWindscreen", Vector3.new(0.12, 0.62, 0.62), CFrame.new(sx * 1.05, 0.9, 0.2), Color3.fromRGB(170, 170, 166), Enum.Material.Metal)
    K.C("RTG", 0.55, 0.36, CFrame.new(sx * 0.93, 0.9, 0.2) * CFrame.Angles(0, 0, math.rad(90)), DARK, Enum.Material.Metal)
  end
  K.rod("AntennaMast", Vector3.new(0.25, 0.93, 0.35), Vector3.new(0.25, 1.85, 0.35), 0.06)
  K.dish("HighGain", 0.76, Vector3.new(0.25, 1.95, 0.35), Vector3.new(0.3, 0.8, -0.5))
  for _, sx in ipairs({-0.3, 0.3}) do
    K.C("CameraPost", 0.55, 0.12, CFrame.new(sx, 1.2, -0.6) * CFrame.Angles(0, 0, math.rad(90)), WHITE)
    K.C("CameraHead", 0.22, 0.22, CFrame.new(sx, 1.55, -0.6), Color3.fromRGB(200, 200, 196), Enum.Material.Metal)
  end
  K.P("SamplerHousing", Vector3.new(0.3, 0.2, 0.6), CFrame.new(-0.55, 0.95, -0.6), WHITE)
  K.rod("SamplerBoom", Vector3.new(-0.55, 0.95, -0.9), Vector3.new(-0.7, 0.3, -2.0), 0.06, ALU)
  K.P("SamplerHead", Vector3.new(0.12, 0.1, 0.18), CFrame.new(-0.7, 0.25, -2.05), DARK, Enum.Material.Metal)
  K.rod("MetBoom", Vector3.new(0.8, 0.5, -0.6), Vector3.new(1.0, 1.65, -0.8), 0.035, ALU)
  K.P("MetSensors", Vector3.new(0.2, 0.06, 0.06), CFrame.new(1.0, 1.68, -0.8), WHITE)
  return K.done()
end

-- Mars Pathfinder (1997): tetrahedral lander opened into three solar petals, deflated airbags,
-- IMP camera mast, ramps; Sojourner (0.65 m long, six wheels, rocker-bogie, flat solar panel) beside it.
function B.pathfinder(base, parent)
  local K, m = kit("Pathfinder", base, parent)
  K.disc("Base", 0.95, Vector3.new(0, 0.25, 0), WHITE, Enum.Material.SmoothPlastic)
  for i = 0, 2 do
    local ang = i * 120
    local R = CFrame.new(0, 0.25, 0) * CFrame.Angles(0, math.rad(ang), 0)
    K.P("Petal", Vector3.new(0.85, 0.06, 0.95), R * CFrame.new(0, 0, -0.95), WHITE)
    K.P("PetalCells", Vector3.new(0.75, 0.065, 0.8), R * CFrame.new(0, 0.005, -0.98), CELL, Enum.Material.Glass)
    for j = -1, 1 do
      K.P("Airbag", Vector3.new(0.55, 0.26, 0.5), R * CFrame.new(j * 0.38, -0.08, -1.55) * CFrame.Angles(0.2 * j, 0.4 * j, 0.15), Color3.fromRGB(196, 190, 176), Enum.Material.Fabric)
    end
  end
  K.rod("IMPMast", Vector3.new(0.1, 0.3, 0.1), Vector3.new(0.1, 1.05, 0.1), 0.05)
  K.P("IMPHead", Vector3.new(0.26, 0.14, 0.12), CFrame.new(0.1, 1.12, 0.1), WHITE)
  K.dish("HighGain", 0.28, Vector3.new(-0.25, 0.55, 0.15), Vector3.new(0.2, 1, 0.3))
  local R0 = CFrame.Angles(0, math.rad(120), 0)
  for _, sx in ipairs({-0.18, 0.18}) do
    K.P("Ramp", Vector3.new(0.08, 0.02, 0.8), R0 * CFrame.new(sx, 0.15, -1.75) * CFrame.Angles(math.rad(-12), 0, 0), ALU, Enum.Material.Metal)
  end
  -- Sojourner, parked against a rock a couple of metres away
  local S = CFrame.new(1.2, 0, -2.0) * CFrame.Angles(0, math.rad(-35), 0)
  local function sj(v) return (S * CFrame.new(v)).Position end
  K.P("SojournerBody", Vector3.new(0.48, 0.13, 0.62), S * CFrame.new(0, 0.24, 0), GOLD, Enum.Material.Foil)
  K.P("SojournerPanel", Vector3.new(0.48, 0.02, 0.62), S * CFrame.new(0, 0.315, 0), CELL, Enum.Material.Glass)
  K.rod("SojournerAntenna", sj(Vector3.new(0.15, 0.32, 0.2)), sj(Vector3.new(0.15, 0.6, 0.2)), 0.012, DARK)
  for _, sx in ipairs({-0.3, 0.3}) do
    for _, sz in ipairs({-0.26, 0, 0.26}) do
      K.C("SojournerWheel", 0.07, 0.13, S * CFrame.new(sx, 0.065, sz), ALU, Enum.Material.Metal)
    end
    K.rod("Rocker", sj(Vector3.new(sx, 0.2, -0.26)), sj(Vector3.new(sx, 0.2, 0.26)), 0.025)
  end
  local rock = K.P("Rock", Vector3.new(0.5, 0.35, 0.4), S * CFrame.new(0, 0.15, -0.6) * CFrame.Angles(0.3, 0.6, 0.2), Color3.fromRGB(110, 70, 52), Enum.Material.Basalt)
  return K.done()
end

-- Phoenix (2008): deck on three legs, two decagonal solar arrays (~1.8 m), robotic arm with scoop,
-- stereo camera mast, weather mast with telltale.
function B.phoenix(base, parent)
  local K, m = kit("Phoenix", base, parent)
  K.disc("Deck", 1.5, Vector3.new(0, 0.95, 0), GOLD, Enum.Material.Foil)
  K.disc("DeckTop", 1.4, Vector3.new(0, 1.02, 0), WHITE)
  for i = 0, 2 do
    local ang = math.rad(90 + i * 120)
    local top = Vector3.new(math.cos(ang) * 0.6, 0.9, math.sin(ang) * 0.6)
    local pad = Vector3.new(math.cos(ang) * 1.0, 0.05, math.sin(ang) * 1.0)
    K.rod("Leg", top, pad + Vector3.new(0, 0.08, 0), 0.07)
    K.disc("Footpad", 0.28, pad, ALU, Enum.Material.Metal)
  end
  for _, sx in ipairs({-1, 1}) do
    K.disc("SolarArray", 1.8, Vector3.new(sx * 1.7, 1.0, 0), CELL, Enum.Material.Glass)
    K.disc("ArrayRim", 1.86, Vector3.new(sx * 1.7, 0.985, 0), WHITE)
    K.rod("ArrayArm", Vector3.new(sx * 0.7, 1.0, 0), Vector3.new(sx * 0.85, 1.0, 0), 0.08)
  end
  K.rod("ArmUpper", Vector3.new(0.3, 1.05, -0.6), Vector3.new(0.6, 1.35, -1.5), 0.08, WHITE, Enum.Material.SmoothPlastic)
  K.rod("ArmLower", Vector3.new(0.6, 1.35, -1.5), Vector3.new(0.7, 0.12, -2.25), 0.07, WHITE, Enum.Material.SmoothPlastic)
  K.P("Scoop", Vector3.new(0.12, 0.1, 0.2), CFrame.new(0.7, 0.08, -2.32), DARK, Enum.Material.Metal)
  K.rod("SSIMast", Vector3.new(-0.3, 1.05, -0.35), Vector3.new(-0.3, 2.0, -0.35), 0.06)
  K.P("SSIHead", Vector3.new(0.3, 0.14, 0.14), CFrame.new(-0.3, 2.07, -0.35), WHITE)
  K.rod("METMast", Vector3.new(0.35, 1.05, 0.4), Vector3.new(0.35, 2.05, 0.4), 0.03)
  K.P("Telltale", Vector3.new(0.03, 0.1, 0.03), CFrame.new(0.35, 2.12, 0.4), DARK)
  K.P("TEGA", Vector3.new(0.5, 0.2, 0.3), CFrame.new(0.25, 1.15, -0.1), WHITE)
  return K.done()
end

-- InSight (2018): deck on three legs, two round solar arrays (~2.2 m), robotic arm, and on the ground
-- the seismometer under its domed wind-and-thermal shield and the HP3 heat-probe box with its tether.
function B.insight(base, parent)
  local K, m = kit("InSight", base, parent)
  K.disc("Deck", 1.56, Vector3.new(0, 0.95, 0), GOLD, Enum.Material.Foil)
  K.disc("DeckTop", 1.46, Vector3.new(0, 1.02, 0), WHITE)
  for i = 0, 2 do
    local ang = math.rad(90 + i * 120)
    local top = Vector3.new(math.cos(ang) * 0.62, 0.9, math.sin(ang) * 0.62)
    local pad = Vector3.new(math.cos(ang) * 1.0, 0.05, math.sin(ang) * 1.0)
    K.rod("Leg", top, pad + Vector3.new(0, 0.08, 0), 0.07)
    K.disc("Footpad", 0.28, pad, ALU, Enum.Material.Metal)
  end
  for _, sx in ipairs({-1, 1}) do
    K.disc("SolarArray", 2.15, Vector3.new(sx * 1.95, 1.0, 0), CELL, Enum.Material.Glass)
    K.disc("ArrayRim", 2.2, Vector3.new(sx * 1.95, 0.985, 0), WHITE)
    K.rod("ArrayArm", Vector3.new(sx * 0.72, 1.0, 0), Vector3.new(sx * 0.9, 1.0, 0), 0.08)
  end
  K.rod("IDAUpper", Vector3.new(0.2, 1.05, -0.65), Vector3.new(0.3, 1.5, -1.3), 0.07, WHITE, Enum.Material.SmoothPlastic)
  K.rod("IDALower", Vector3.new(0.3, 1.5, -1.3), Vector3.new(0.35, 1.0, -1.6), 0.06, WHITE, Enum.Material.SmoothPlastic)
  K.P("Grapple", Vector3.new(0.12, 0.12, 0.12), CFrame.new(0.35, 0.94, -1.62), DARK, Enum.Material.Metal)
  local dome = K.ball("WTSDome", 0.9, Vector3.new(-0.5, 0.0, -1.9), COPPER, Enum.Material.Metal)
  K.disc("WTSSkirt", 1.15, Vector3.new(-0.5, 0.02, -1.9), Color3.fromRGB(120, 76, 48), Enum.Material.Fabric)
  K.P("HP3", Vector3.new(0.3, 0.35, 0.25), CFrame.new(0.8, 0.18, -1.7), WHITE)
  K.rod("HP3Tether", Vector3.new(0.8, 0.05, -1.55), Vector3.new(0.3, 0.9, -0.6), 0.015, DARK)
  K.rod("SEISTether", Vector3.new(-0.5, 0.05, -1.45), Vector3.new(-0.3, 0.9, -0.6), 0.015, DARK)
  return K.done()
end

-- Ingenuity (2021): 1.8 kg, 0.49 m tall; 1.2 m coaxial counter-rotating rotors, solar panel on top,
-- small fuselage on four legs. Shown at true scale, so it is small.
function B.ingenuity(base, parent)
  local K, m = kit("Ingenuity", base, parent)
  K.P("Fuselage", Vector3.new(0.14, 0.16, 0.2), CFrame.new(0, 0.3, 0), WHITE)
  for i = 0, 3 do
    local ang = math.rad(45 + i * 90)
    K.rod("Leg", Vector3.new(math.cos(ang) * 0.06, 0.25, math.sin(ang) * 0.06), Vector3.new(math.cos(ang) * 0.32, 0.0, math.sin(ang) * 0.32), 0.012, ALU)
  end
  K.rod("Mast", Vector3.new(0, 0.38, 0), Vector3.new(0, 0.55, 0), 0.02, ALU)
  K.P("RotorLower", Vector3.new(1.2, 0.012, 0.08), CFrame.new(0, 0.42, 0) * CFrame.Angles(0, math.rad(20), 0), BLACK)
  K.P("RotorUpper", Vector3.new(1.2, 0.012, 0.08), CFrame.new(0, 0.47, 0) * CFrame.Angles(0, math.rad(-35), 0), BLACK)
  K.P("SolarPanel", Vector3.new(0.17, 0.01, 0.13), CFrame.new(0, 0.56, 0), CELL, Enum.Material.Glass)
  -- one blade end broken off: the damage from its last flight (18 Jan 2024)
  return K.done()
end

-- NEAR Shoemaker (landed on Eros 2001): octagonal-ish bus, four fixed solar panels, 1.5 m dish.
-- Shown resting tilted on a slab of asteroid, as it came to rest on the edges of two solar panels.
function B.near(base, parent)
  local K, m = kit("NEAR", base, parent)
  K.P("Eros", Vector3.new(3.4, 0.4, 3.0), CFrame.new(0, 0.2, 0) * CFrame.Angles(0.04, 0.3, -0.03), Color3.fromRGB(120, 108, 92), Enum.Material.Slate)
  local tilt = CFrame.new(0, 1.15, 0) * CFrame.Angles(math.rad(28), 0, math.rad(8))
  K.C("Bus", 1.7, 1.6, tilt * CFrame.Angles(0, 0, math.rad(90)), GOLD, Enum.Material.Foil)
  for i = 0, 3 do
    local R = tilt * CFrame.Angles(0, math.rad(i * 90), 0)
    K.P("SolarPanel", Vector3.new(1.2, 0.04, 1.8), R * CFrame.new(0, 0.9, -1.55) * CFrame.Angles(math.rad(-20), 0, 0), CELL, Enum.Material.Glass)
  end
  K.dish("HighGain", 1.5, (tilt * CFrame.new(0, 0.95, 0)).Position, tilt.UpVector, WHITE)
  return K.done()
end

-- Dawn (Vesta & Ceres): 1.6 m bus, two solar wings spanning 19.7 m, 1.5 m dish, xenon ion thrusters.
-- Hung overhead: its wings are wider than most of the gallery.
function B.dawn(base, parent)
  local K, m = kit("Dawn", base, parent)
  K.P("Bus", Vector3.new(1.64, 1.27, 1.77), CFrame.new(0, 0, 0), GOLD, Enum.Material.Foil)
  for _, sx in ipairs({-1, 1}) do
    K.rod("WingYoke", Vector3.new(sx * 0.82, 0, 0), Vector3.new(sx * 1.6, 0, 0), 0.1)
    for p = 0, 4 do
      K.P("WingPanel", Vector3.new(1.6, 0.04, 2.27), CFrame.new(sx * (2.45 + p * 1.66), 0, 0), CELL, Enum.Material.Glass)
    end
  end
  K.dish("HighGain", 1.52, Vector3.new(0, 0, -1.1), Vector3.new(0, 0, -1), WHITE)
  for i = -1, 1 do
    K.C("IonThruster", 0.3, 0.33, CFrame.new(i * 0.45, -0.8, 0) * CFrame.Angles(0, 0, math.rad(90)), DARK, Enum.Material.Metal)
  end
  return K.done()
end

-- Kepler (2009-2018): 4.7 m tall, 2.7 m across; telescope barrel with an angled sunshade, bus below,
-- fixed solar array wrapped round the Sun-facing side, small high-gain dish.
function B.kepler(base, parent)
  local K, m = kit("Kepler", base, parent)
  K.C("Bus", 0.9, 2.7, CFrame.new(0, 0.85, 0) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(160, 160, 156), Enum.Material.Metal)
  K.C("Barrel", 3.0, 1.9, CFrame.new(0, 2.8, 0) * CFrame.Angles(0, 0, math.rad(90)), WHITE)
  K.C("Sunshade", 0.25, 2.0, CFrame.new(0, 4.35, 0.15) * CFrame.Angles(math.rad(-22), 0, 0) * CFrame.Angles(0, 0, math.rad(90)), WHITE)
  for i = -2, 1 do
    local a = math.rad(i * 30 + 15)
    K.P("SolarPanel", Vector3.new(1.0, 3.2, 0.05), CFrame.new(math.sin(a) * 1.2, 2.7, math.cos(a) * 1.2) * CFrame.Angles(0, a, 0), CELL, Enum.Material.Glass)
  end
  K.dish("HighGain", 0.8, Vector3.new(0, 0.3, -1.3), Vector3.new(0, -0.4, -1), WHITE)
  return K.done()
end

-- Pioneer 10 / 11 (1972, 1973): 2.74 m dish over a hexagonal equipment compartment, two RTG booms with
-- two generators each, a long magnetometer boom, and the gold plaque on the antenna struts.
function B.pioneer(base, parent)
  local K, m = kit("Pioneer", base, parent)
  K.C("Compartment", 0.36, 1.42, CFrame.new(0, 0.6, 0) * CFrame.Angles(0, 0, math.rad(90)), GOLD, Enum.Material.Foil)
  K.dish("HighGain", 2.74, Vector3.new(0, 1.1, 0), Vector3.new(0, 1, 0), WHITE)
  for _, ang in ipairs({30, 150}) do
    local d = Vector3.new(math.cos(math.rad(ang)), 0, math.sin(math.rad(ang)))
    K.rod("RTGBoom", Vector3.new(0, 0.6, 0) + d * 0.6, Vector3.new(0, 0.6, 0) + d * 3.0, 0.05)
    for k = 0, 1 do
      K.C("RTG", 0.6, 0.3, CFrame.lookAt(Vector3.new(0, 0.6, 0) + d * (2.3 + k * 0.65), Vector3.new(0, 0.6, 0) + d * 4) * CFrame.Angles(0, math.rad(90), 0), DARK, Enum.Material.Metal)
    end
  end
  K.rod("MagBoom", Vector3.new(0, 0.6, -0.7), Vector3.new(0, 0.6, -6.6), 0.03)
  K.P("Plaque", Vector3.new(0.23, 0.15, 0.01), CFrame.new(0.4, 0.9, -0.5) * CFrame.Angles(math.rad(-30), 0, 0), Color3.fromRGB(230, 190, 90), Enum.Material.Foil)
  return K.done()
end

-- Voyager 1 (1977): recognizable deep-space probe silhouette. The high-gain dish is
-- mounted above the bus; three RTGs sit out on one boom and the magnetometer extends
-- in the opposite direction. No solar wings: Voyager is radioisotope powered.
function B.voyager(base, parent)
  local K, m = kit("Voyager 1", base, parent)
  K.P("EquipmentBus", Vector3.new(1.8, 1.6, 1.5), CFrame.new(0, 1.05, 0), GOLD, Enum.Material.Foil)
  K.P("InstrumentPlatform", Vector3.new(2.6, 0.18, 2.2), CFrame.new(0, 1.9, 0), ALU, Enum.Material.Metal)

  -- Large high-gain antenna, with its support truss and feed visible in thumbnail scale.
  local dishPos = Vector3.new(0, 2.3, -0.25)
  -- Present the dish face toward the archive camera so its silhouette reads at card size.
  K.dish("HighGainAntenna", 3.7, dishPos, Vector3.new(0.75, 0.42, -0.66), WHITE)
  K.rod("DishSupport", Vector3.new(0, 1.9, 0.25), dishPos, 0.1, ALU)
  for _, sx in ipairs({-1, 1}) do
    K.rod("DishTruss", Vector3.new(sx * 0.62, 1.9, 0.25), dishPos + Vector3.new(sx * 1.4, 0, 0), 0.055, ALU)
  end

  -- RTG boom and its three finned radioisotope generators.
  K.rod("RTGBoom", Vector3.new(0.7, 1.15, 0.25), Vector3.new(4.4, 1.15, 0.25), 0.12, ALU)
  for i = 0, 2 do
    local x = 1.65 + i * 1.15
    K.C("RTG", 0.72, 0.52, CFrame.new(x, 1.15, 0.25) * CFrame.Angles(0, 0, math.rad(90)), DARK, Enum.Material.Metal)
    for _, z in ipairs({-0.24, 0.24}) do
      K.P("RTGFins", Vector3.new(0.68, 0.035, 0.035), CFrame.new(x, 1.15, 0.25 + z), ALU, Enum.Material.Metal)
    end
  end

  -- Long magnetometer boom, plus a small science instrument cluster on the bus.
  K.rod("MagnetometerBoom", Vector3.new(-0.55, 1.65, 0.4), Vector3.new(-0.55, 1.65, 6.6), 0.055, ALU)
  K.P("Magnetometer", Vector3.new(0.42, 0.42, 0.5), CFrame.new(-0.55, 1.65, 6.6), DARK, Enum.Material.Metal)
  K.P("CameraPlatform", Vector3.new(0.48, 0.55, 0.5), CFrame.new(-0.82, 2.2, -0.65), ALU, Enum.Material.Metal)
  K.P("ScienceInstrument", Vector3.new(0.42, 0.5, 0.46), CFrame.new(0.72, 2.2, -0.55), GOLD, Enum.Material.Foil)
  K.rod("LowGainAntenna", Vector3.new(0.25, 1.85, 0.25), Vector3.new(0.25, 3.05, 0.25), 0.045, ALU)
  return K.done()
end

return B

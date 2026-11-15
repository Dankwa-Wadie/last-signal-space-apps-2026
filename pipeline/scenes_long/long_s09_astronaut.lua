local s = wipe(); moonLight(16.5, 22)
ground(s, Color3.fromRGB(150, 147, 140), Enum.Material.Sand, 1600)
rocks(s, 65, Color3.fromRGB(112, 108, 103), 14, 150, 64, 1)

-- LM in background
spawn("LM", -22, -18, 13, 25, 0.15)

-- Astronaut Mannequin (Scale ~ 5.5 studs tall)
local astro = Instance.new("Model")
astro.Name = "Astronaut"
astro.Parent = s

local WHITE = Color3.fromRGB(238, 238, 235)
local GOLD  = Color3.fromRGB(240, 195, 60)

local function mkPart(name, size, pos, col, mat)
  local p = Instance.new("Part")
  p.Name = name; p.Size = size; p.CFrame = CFrame.new(pos)
  p.Color = col; p.Material = mat or Enum.Material.SmoothPlastic
  p.Anchored = true; p.CanCollide = false
  p.Parent = astro
  return p
end

-- Legs
mkPart("LeftLeg", Vector3.new(0.8, 2.4, 0.9), Vector3.new(-0.55, 1.2, 0), WHITE)
mkPart("RightLeg", Vector3.new(0.8, 2.4, 0.9), Vector3.new(0.55, 1.2, 0), WHITE)

-- Torso
local torso = mkPart("Torso", Vector3.new(2.0, 2.2, 1.1), Vector3.new(0, 3.4, 0), WHITE)

-- PLSS Backpack
mkPart("PLSS", Vector3.new(1.8, 2.1, 0.85), Vector3.new(0, 3.5, 0.85), Color3.fromRGB(220, 220, 218))

-- Helmet bubble & gold visor
local head = mkPart("Helmet", Vector3.new(1.7, 1.7, 1.7), Vector3.new(0, 5.0, 0), WHITE)
head.Shape = Enum.PartType.Ball

local visor = mkPart("Visor", Vector3.new(1.3, 0.9, 0.7), Vector3.new(0, 5.0, -0.65), GOLD, Enum.Material.Glass)
visor.Reflectance = 0.85

-- Arms
mkPart("LeftArm", Vector3.new(0.7, 2.2, 0.7), Vector3.new(-1.4, 3.3, 0), WHITE)
mkPart("RightArm", Vector3.new(0.7, 2.2, 0.7), Vector3.new(1.4, 3.3, -0.3), WHITE)

-- Turn astronaut to face 3/4 toward camera
astro:PivotTo(CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(-35), 0))

return "long_s09_astronaut"


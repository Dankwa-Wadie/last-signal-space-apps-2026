local s = wipe(); moonLight(16.5, 22)
ground(s, Color3.fromRGB(150, 147, 140), Enum.Material.Sand, 1600)
rocks(s, 60, Color3.fromRGB(112, 108, 103), 14, 150, 48, 1)

-- LM descent stage
local lm = spawn("LM", 0, 0, 13, -25, 0.15)

-- The ascent stage (modeled as an octagonal cabin above the descent stage)
local ascent = Instance.new("Part")
ascent.Name = "AscentStage"
ascent.Size = Vector3.new(4.8, 3.8, 4.8)
ascent.CFrame = CFrame.new(0, 9.8, 0)
ascent.Anchored = true; ascent.Material = Enum.Material.Metal
ascent.Color = Color3.fromRGB(180, 182, 185)
ascent.Parent = s

-- Ascent thruster flame (starts small, animated in frame script)
local flame = Instance.new("Part")
flame.Name = "AscentFlame"
flame.Shape = Enum.PartType.Ball
flame.Size = Vector3.new(2.5, 5.0, 2.5)
flame.CFrame = CFrame.new(0, 7.5, 0)
flame.Anchored = true; flame.CanCollide = false
flame.Material = Enum.Material.Neon
flame.Color = Color3.fromRGB(255, 210, 120)
flame.Transparency = 0.2
flame.Parent = s

local light = Instance.new("PointLight")
light.Name = "FlameLight"
light.Brightness = 8
light.Range = 35
light.Color = Color3.fromRGB(255, 220, 150)
light.Parent = flame

return "long_s02_liftoff"


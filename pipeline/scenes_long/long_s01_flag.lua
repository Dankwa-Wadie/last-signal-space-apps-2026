local s = wipe(); moonLight(16.5, 22)
ground(s, Color3.fromRGB(150, 147, 140), Enum.Material.Sand, 1600)
rocks(s, 70, Color3.fromRGB(112, 108, 103), 14, 150, 42, 1)

-- LM in background
spawn("LM", -20, -18, 13, 30, 0.15)

-- Flag pole & assembly at (0, 0, 0)
local pole = Instance.new("Part")
pole.Name = "FlagPole"
pole.Size = Vector3.new(0.12, 6.5, 0.12)
pole.CFrame = CFrame.new(0, 3.25, 0)
pole.Anchored = true; pole.Material = Enum.Material.Metal
pole.Color = Color3.fromRGB(220, 220, 225)
pole.Parent = s

local crossbar = Instance.new("Part")
crossbar.Name = "FlagCrossbar"
crossbar.Size = Vector3.new(3.2, 0.08, 0.08)
crossbar.CFrame = CFrame.new(1.58, 6.45, 0)
crossbar.Anchored = true; crossbar.Material = Enum.Material.Metal
crossbar.Color = Color3.fromRGB(220, 220, 225)
crossbar.Parent = s

-- Flag cloth (crinkled Apollo flag appearance)
local flag = Instance.new("Part")
flag.Name = "FlagCloth"
flag.Size = Vector3.new(3.0, 1.8, 0.05)
flag.CFrame = CFrame.new(1.5, 5.5, 0)
flag.Anchored = true; flag.Material = Enum.Material.SmoothPlastic
flag.Color = Color3.fromRGB(210, 45, 45)
flag.Parent = s

-- Blue union canton
local canton = Instance.new("Part")
canton.Name = "Canton"
canton.Size = Vector3.new(1.2, 0.9, 0.06)
canton.CFrame = CFrame.new(0.6, 5.95, 0)
canton.Anchored = true; canton.Material = Enum.Material.SmoothPlastic
canton.Color = Color3.fromRGB(35, 60, 140)
canton.Parent = s

-- White stripes overlay
for i = 1, 3 do
  local stripe = Instance.new("Part")
  stripe.Size = Vector3.new(3.0, 0.22, 0.06)
  stripe.CFrame = CFrame.new(1.5, 4.75 + (i - 1) * 0.45, 0)
  stripe.Anchored = true; stripe.Material = Enum.Material.SmoothPlastic
  stripe.Color = Color3.fromRGB(240, 240, 240)
  stripe.Parent = s
end

-- Footprints radiating from the flag toward the lander
local rng = Random.new(11)
for i = 1, 14 do
  local p = Instance.new("Part")
  p.Size = Vector3.new(0.55, 0.05, 1.1)
  local z = -i * 1.3
  local x = -i * 1.4 + rng:NextNumber(-0.15, 0.15)
  p.CFrame = CFrame.new(x, 0.03, z) * CFrame.Angles(0, math.rad(30) + rng:NextNumber(-0.1, 0.1), 0)
  p.Anchored = true; p.Material = Enum.Material.Sand
  p.Color = Color3.fromRGB(105, 102, 98)
  p.Parent = s
end

return "long_s01_flag"


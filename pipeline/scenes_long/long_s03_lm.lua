local s = wipe(); moonLight(16.5, 20)
ground(s, Color3.fromRGB(150, 147, 140), Enum.Material.Sand, 1600)
rocks(s, 70, Color3.fromRGB(112, 108, 103), 14, 150, 11, 1)

-- LM descent stage standing alone
spawn("LM", 0, 0, 13, -25, 0.15)

-- A long line of bootprints leading away from the ladder
local rng = Random.new(7)
for i = 1, 24 do
  local p = Instance.new("Part")
  p.Size = Vector3.new(0.6, 0.05, 1.2)
  local side = (i % 2 == 0) and 0.7 or -0.7
  local z = 7 + i * 1.6
  p.CFrame = CFrame.new(side * 0.7 + rng:NextNumber(-0.06, 0.06), 0.03, z) * CFrame.Angles(0, rng:NextNumber(-0.1, 0.1), 0)
  p.Anchored = true; p.Material = Enum.Material.Sand
  p.Color = Color3.fromRGB(105, 102, 98)
  p.Parent = s
end

return "long_s03_lm"


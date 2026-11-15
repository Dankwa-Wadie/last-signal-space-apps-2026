local s = wipe(); moonLight(16.5, 20)
ground(s, Color3.fromRGB(150, 147, 140), Enum.Material.Sand, 1600)
rocks(s, 70, Color3.fromRGB(112, 108, 103), 14, 150, 88, 1)

-- Lunar Rover
spawn("LRV", 0, 0, 5.0, 18, 0.1)

-- Wheel tracks behind the rover
local rng = Random.new(22)
for i = 1, 28 do
  for _, trackX in ipairs({-1.3, 1.3}) do
    local p = Instance.new("Part")
    p.Size = Vector3.new(0.45, 0.04, 1.2)
    local z = -2.5 - i * 1.1
    p.CFrame = CFrame.new(trackX + rng:NextNumber(-0.04, 0.04), 0.02, z)
    p.Anchored = true; p.Material = Enum.Material.Sand
    p.Color = Color3.fromRGB(110, 106, 100)
    p.Parent = s
  end
end

return "long_s05_lrv"


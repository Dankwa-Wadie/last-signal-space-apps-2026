local s = workspace:FindFirstChild("Scene")
if not s then return end

local ascent = s:FindFirstChild("AscentStage")
local flame = s:FindFirstChild("AscentFlame")

if ascent and flame then
  -- u goes from 0.0 to 1.0
  local altitude = 9.8 + (u * u) * 45.0
  ascent.CFrame = CFrame.new(0, altitude, 0)
  flame.CFrame = CFrame.new(0, altitude - 3.2, 0)
  
  -- Flame flicker & scale
  local flicker = math.sin(u * 60) * 0.3
  flame.Size = Vector3.new(2.8 + flicker, 5.5 + flicker * 1.5, 2.8 + flicker)
  if u > 0.85 then
    flame.Transparency = 0.2 + (u - 0.85) * 5.0
  end
end


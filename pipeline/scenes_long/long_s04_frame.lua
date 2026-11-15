local s = workspace:FindFirstChild("Scene")
if not s then return end

local body = s:FindFirstChild("SeisBody")
if body then
  -- Ringing oscillation
  local wave = math.sin(u * 50) * math.exp(-u * 2.5) * 0.04
  body.CFrame = CFrame.new(0, 0.85, 0) * CFrame.Angles(0, 0, wave)
end


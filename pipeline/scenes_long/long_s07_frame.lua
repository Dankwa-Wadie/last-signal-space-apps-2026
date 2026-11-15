local s = workspace:FindFirstChild("Scene")
if not s then return end

local voy = s:FindFirstChild("VoyagerSpacecraft")
if voy then
  local baseAngle = math.rad(-25 + u * 18)
  voy:PivotTo(CFrame.new(0, 6, 0) * CFrame.Angles(math.rad(12), baseAngle, math.rad(8 + u * 6)))
end


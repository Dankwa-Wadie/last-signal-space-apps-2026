local s=workspace:FindFirstChild("Scene"); if not s then return "noscene" end
local v=s:FindFirstChild("VOYAGER")
if v then
  v:PivotTo(CFrame.new(0,5,0)*CFrame.Angles(math.rad(12),math.rad(26+u*30),math.rad(-8)))
end
return "ok"

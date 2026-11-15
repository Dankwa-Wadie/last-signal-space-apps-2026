local ship=S:FindFirstChild("SHIP"); if not ship then return "noship" end
local p0=ship:GetAttribute("P0")
local t=k/24
ship:PivotTo(p0*CFrame.new(0,math.sin(t*1.3)*0.18,-t*2.2)*CFrame.Angles(math.sin(t*1.1)*0.025,0,math.sin(t*0.9)*0.04))
return "ok"

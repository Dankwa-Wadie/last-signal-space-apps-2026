-- after the storm: the rover is stopped and the light is nearly gone
if not matte then
  local L=game:GetService("Lighting")
  local a=L:FindFirstChildOfClass("Atmosphere")
  if a then a.Density=0.76; a.Haze=7.9; a.Offset=0.25 end
  L.Brightness=1.25; L.ExposureCompensation=0.05
end
return "ok"

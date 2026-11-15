-- u is injected by the renderer as a number 0..1
local s=workspace:FindFirstChild("Scene"); if not s then return "noscene" end
local beam=s:FindFirstChild("Beam")
local base=s:FindFirstChild("RetroBase")
if beam and base then
  -- three sharp pulses across the shot
  local p=math.max(0,math.sin(u*math.pi*3))^6
  beam.Transparency=1-(p*0.40)
  local gl=base:FindFirstChild("BeamLight")
  if gl then gl.Brightness=p*1.1 end
end
return "ok"

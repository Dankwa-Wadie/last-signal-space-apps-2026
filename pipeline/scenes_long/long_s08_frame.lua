local s = workspace:FindFirstChild("Scene")
if not s then return end

local beam = s:FindFirstChild("LaserBeam")
local base = s:FindFirstChild("RetroBase")
local gl = base and base:FindFirstChild("BeamLight")

if beam and gl then
  -- Pulse 1 (incoming laser arrives at u ~ 0.25 to 0.35)
  -- Pulse 2 (return bounce at u ~ 0.60 to 0.75)
  local alpha = 1.0
  local lightBr = 0

  if u >= 0.25 and u <= 0.38 then
    local p = (u - 0.25) / 0.13
    alpha = 1.0 - math.sin(p * math.pi) * 0.85
    lightBr = math.sin(p * math.pi) * 8.0
  elseif u >= 0.60 and u <= 0.78 then
    local p = (u - 0.60) / 0.18
    alpha = 1.0 - math.sin(p * math.pi) * 0.95
    lightBr = math.sin(p * math.pi) * 12.0
  end

  beam.Transparency = alpha
  gl.Brightness = lightBr
end


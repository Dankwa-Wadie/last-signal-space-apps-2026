-- per-frame laser animation for the v3 retro shot. `k` (local frame) is injected.
-- Outgoing pulse leaves at frame 29 (10.4 s in the cut, on "retroreflectors");
-- the return pulse arrives 60 frames = 2.50 s later, the real Earth-Moon-Earth light time.
local s=workspace:FindFirstChild("Scene"); if not s then return "noscene" end
local beam=s:FindFirstChild("Beam"); local base=s:FindFirstChild("RetroBase")
if not (beam and base) then return "nobeam" end
local matte = s:GetAttribute("Matte") == true
local OUT, BACK = 29, 89
local function pulse(at) local d=k-at; if d<0 then return 0 end; return math.exp(-d/3.2) end
local p = math.max(pulse(OUT), pulse(BACK)*1.15)
beam.Transparency = 1 - math.min(0.85, p*0.85)
local gl=base:FindFirstChild("BeamLight"); if gl then gl.Brightness = p*0.6 end
if not matte then
  for _,c in ipairs(s:GetChildren()) do
    if c.Name=="Cube" then c.Material = (p>0.25) and Enum.Material.Neon or Enum.Material.SmoothPlastic end
  end
end
return "ok"

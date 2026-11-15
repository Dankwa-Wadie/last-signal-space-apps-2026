local g=S:FindFirstChild("Glow")
local HIT=70
local d=k-HIT
local p=(d>=0) and math.exp(-d/9) or 0
if matte then g.Transparency=1 else g.Transparency=1-0.9*p end
-- the seismometer trembles once the shock arrives (it rang for ~55 min; we see the first seconds)
local se=S:FindFirstChild("Seismometer")
if se then
  local b=se:FindFirstChild("SeisBody")
  if b then
    if not b:GetAttribute("C0") then b:SetAttribute("C0",b.CFrame) end
    local c0=b:GetAttribute("C0")
    local amp=(d>=12) and (0.06*math.exp(-(d-12)/60)) or 0
    b.CFrame=c0*CFrame.new(math.sin(k*2.3)*amp,0,math.cos(k*1.7)*amp)
  end
end
return "ok"

-- per-frame Mars animation. `k` (local frame 0..52) is injected.
-- Opportunity drives, slows, and stops as a dust storm thickens and the light fails:
-- the real end of the mission (the storm starved its solar panels; last signal 10 June 2018).
-- Speed is dramatised: the real rover topped out around 5 cm/s.
local s=workspace:FindFirstChild("Scene"); if not s then return "noscene" end
local r=s:FindFirstChild("ROVER"); if not r then return "norover" end
local matte = s:GetAttribute("Matte") == true
if r:GetAttribute("P0") == nil then r:SetAttribute("P0", r:GetPivot()) end
local p0 = r:GetAttribute("P0")

local STOP, DIST = 34, 6.0
local function travelled(t)
  local u = math.clamp(t / STOP, 0, 1)
  return DIST * (1 - (1 - u) ^ 2.2)          -- eases to a halt at frame STOP
end
local d = travelled(k)
local bob = (k < STOP) and math.sin(k * 1.7) * 0.025 * (1 - k / STOP) or 0
r:PivotTo(p0 * CFrame.new(0, bob, -d))

-- wheel tracks printed behind it while it moves
if k > 0 and k <= STOP then
  local prev = travelled(k - 1)
  local seg = d - prev
  if seg > 0.01 then
    for _, side in ipairs({-2.2, 2.2}) do
      local mid = p0 * CFrame.new(side, 0, -(prev + d) / 2)
      local t = Instance.new("Part")
      t.Name = "Track"; t.Anchored = true; t.CanCollide = false
      t.Size = Vector3.new(0.75, 0.05, seg + 0.05)
      t.CFrame = CFrame.new(mid.Position.X, 0.03, mid.Position.Z) * (p0 - p0.Position)
      if matte then t.Material = Enum.Material.Neon; t.Color = Color3.new(1, 1, 1)
      else t.Material = Enum.Material.Sand; t.Color = Color3.fromRGB(118, 66, 44) end
      t.Parent = s
    end
  end
end

-- the dust storm: only in the beauty pass (the matte must keep a dark, clean sky)
if not matte then
  local L = game:GetService("Lighting")
  local storm = math.clamp((k - 16) / 36, 0, 1)
  local a = L:FindFirstChildOfClass("Atmosphere")
  if a then
    a.Density = 0.34 + 0.40 * storm
    a.Haze = 2.2 + 5.5 * storm
    a.Offset = 0.55 - 0.30 * storm
  end
  L.Brightness = 3.4 * (1 - 0.58 * storm)
  L.ExposureCompensation = 0.35 - 0.35 * storm
end
return "ok"

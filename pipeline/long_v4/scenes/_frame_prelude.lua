-- per-frame helpers. `k` (frame index) and `n` (frame count) are injected before this.
local S = workspace:FindFirstChild("Scene")
local matte = S and S:GetAttribute("Matte") == true
local function ease(t) t = math.clamp(t, 0, 1); return t*t*t*(t*(t*6-15)+10) end
local function stepAll(dt)
  for _, h in ipairs(S:GetDescendants()) do
    if h:IsA("Animator") then h:StepAnimations(dt or 1/24) end
  end
end
-- move a rig's anchored root along a straight path, facing its direction of travel
local function walk(name, a, b, u, bob)
  local m = S:FindFirstChild(name); if not m then return end
  local p = a:Lerp(b, u)
  local dir = (b - a); dir = Vector3.new(dir.X, 0, dir.Z)
  if dir.Magnitude > 0.01 then dir = dir.Unit else dir = Vector3.new(0, 0, -1) end
  local y = (bob or 0) * math.abs(math.sin(k * 0.42))
  m.HumanoidRootPart.CFrame = CFrame.lookAt(p + Vector3.new(0, y, 0), p + dir + Vector3.new(0, y, 0))
end

-- spin Opportunity's overlay wheels: ang in radians, model pivot already moved
local OPPW={{-2.12,2.55},{2.12,2.55},{-2.12,-2.55},{2.12,-2.55}}
function oppSpin(r, ang)
  local W=r:FindFirstChild("Wheels"); if not W then return end
  local d=W:GetAttribute("d") or 1.95
  local pv=r:GetPivot()
  for i,p in ipairs(OPPW) do
    local wc=pv*CFrame.new(p[1],(d/2-0.12)-pv.Position.Y,p[2])
    local w=W:FindFirstChild("Wheel"..i); if w then w.CFrame=wc end
    local h=W:FindFirstChild("Hub"..i); if h then h.CFrame=wc end
    local sp=W:FindFirstChild("Spoke"..i); if sp then sp.CFrame=wc*CFrame.Angles(0,ang,0) end
    for t=0,11 do
      local tr=W:FindFirstChild("Tread_"..i.."_"..t)
      if tr then tr.CFrame=wc*CFrame.Angles(t*math.pi/6-ang,0,0)*CFrame.new(0,d/2-0.055,0) end
    end
  end
end

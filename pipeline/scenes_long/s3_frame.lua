local s=workspace:FindFirstChild("Scene"); if not s then return "noscene" end
local function ease(t) return t*t*t*(t*(t*6-15)+10) end
local e=ease(u)
local a=math.rad(-45+(54-(-45))*e)
local pos=Vector3.new(math.sin(a)*21, 9, math.cos(a)*21)
local rig=s:FindFirstChild("FillRig")
if not rig then
  rig=Instance.new("Part"); rig.Name="FillRig"; rig.Size=Vector3.new(0.2,0.2,0.2)
  rig.Transparency=1; rig.Anchored=true; rig.CanCollide=false; rig.Parent=s
  local pl=Instance.new("PointLight")
  pl.Name="Fill"; pl.Brightness=2.6; pl.Range=70
  pl.Color=Color3.fromRGB(255,250,238); pl.Parent=rig
end
rig.CFrame=CFrame.new(pos)
return "ok"

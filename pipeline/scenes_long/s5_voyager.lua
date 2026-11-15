local s=wipe()
clearAtmos()
L.ClockTime=8.2; L.GeographicLatitude=0
L.Brightness=2.0
L.Ambient=Color3.fromRGB(42,46,58)
L.OutdoorAmbient=Color3.fromRGB(34,38,50)
L.EnvironmentDiffuseScale=0
L.EnvironmentSpecularScale=0.35
L.ExposureCompensation=0.3
local sky=L:FindFirstChildOfClass("Sky")
if sky then sky.StarCount=12000 end
-- no ground at all: deep space
local v=spawn("VOYAGER",0,0,12,30,0)
if v then v:PivotTo(CFrame.new(0,6,0)*CFrame.Angles(math.rad(12),math.rad(30),math.rad(-8))) end
-- distant sun as a tiny hard point light source feel
local pl=Instance.new("PointLight")
pl.Brightness=5.5; pl.Range=190; pl.Color=Color3.fromRGB(255,246,224)
local anchor=Instance.new("Part"); anchor.Size=Vector3.new(0.2,0.2,0.2)
anchor.Transparency=1; anchor.Anchored=true; anchor.CanCollide=false
anchor.CFrame=CFrame.new(26,22,34); anchor.Parent=s
pl.Parent=anchor
-- cool rim light from behind to separate it from the starfield
local rim=Instance.new("Part"); rim.Size=Vector3.new(0.2,0.2,0.2)
rim.Transparency=1; rim.Anchored=true; rim.CanCollide=false
rim.CFrame=CFrame.new(-26,16,-30); rim.Parent=s
local rl=Instance.new("PointLight")
rl.Brightness=3.2; rl.Range=150; rl.Color=Color3.fromRGB(150,180,255); rl.Parent=rim
return "s5"

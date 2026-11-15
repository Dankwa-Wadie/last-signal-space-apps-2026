local s=wipe(); spaceSky()
clearAtmos(); L.ClockTime=21.6; L.GeographicLatitude=35; L.Brightness=1.2
L.Ambient=Color3.fromRGB(46,54,80); L.OutdoorAmbient=Color3.fromRGB(70,82,118); L.ExposureCompensation=0.55
local rim=Instance.new("Part"); rim.Name="Rim"; rim.Anchored=true; rim.CanCollide=false; rim.Transparency=1; rim.Size=Vector3.new(0.2,0.2,0.2)
rim.CFrame=CFrame.new(0,22,-30); rim.Parent=s
local rl=Instance.new("PointLight"); rl.Brightness=4; rl.Range=40; rl.Color=Color3.fromRGB(170,190,255); rl.Parent=rim
L.ColorShift_Top=Color3.new(0,0,0)
local fl=Instance.new("Part"); fl.Anchored=true; fl.Size=Vector3.new(2048,2,2048); fl.CFrame=CFrame.new(0,-1,0)
fl.Material=Enum.Material.Sand; fl.Color=Color3.fromRGB(46,42,36); fl.Parent=s
giza(s)
local m,an=explorer("Watcher",CFrame.new(0,2.9,-8)*CFrame.Angles(0,math.rad(180),0),Color3.fromRGB(70,80,110),Color3.fromRGB(40,40,50),Color3.fromRGB(170,120,80))
play(an,"idle",1,0.2)
m.HumanoidRootPart.CFrame=CFrame.lookAt(Vector3.new(0,2.9,-8),Vector3.new(0,11.9,-30))
return "L04"

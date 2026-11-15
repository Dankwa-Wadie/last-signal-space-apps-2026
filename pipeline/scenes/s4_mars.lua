local s=wipe()
clearAtmos()
local a=Instance.new("Atmosphere")
a.Density=0.34; a.Offset=0.55
a.Color=Color3.fromRGB(196,142,96)
a.Decay=Color3.fromRGB(128,86,58)
a.Glare=0.4; a.Haze=2.2
a.Parent=L
L.ClockTime=14.5; L.GeographicLatitude=10
L.Brightness=3.4
L.Ambient=Color3.fromRGB(92,62,44)
L.OutdoorAmbient=Color3.fromRGB(112,76,52)
L.EnvironmentDiffuseScale=0.4
L.ExposureCompensation=0.35
ground(s,Color3.fromRGB(150,86,56),Enum.Material.Sand,1600)
rocks(s,110,Color3.fromRGB(118,66,44),10,170,33,1.2)
local r=spawn("ROVER",0,0,6.0,-25,0.1)
return "s4"

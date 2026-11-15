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
ground(s,Color3.fromRGB(144,82,54),Enum.Material.Sand,1600)
rocks(s,22,Color3.fromRGB(110,64,44),14,170,33,0.4)   -- Meridiani is famously rock-poor
marsRipples(s,0,-20,95)
marsDunes(s,-230,0)
local r=spawn("ROVER",0,0,6.0,-25,0.1)
oppWheels(r)
return "s4"

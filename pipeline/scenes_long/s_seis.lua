local s=wipe(); moonLight(16.3,20)
ground(s,Color3.fromRGB(150,147,140),Enum.Material.Sand,1600)
rocks(s,65,Color3.fromRGB(112,108,103),12,140,33,1)

-- LM in background
spawn("LM", -28, -24, 13, 35, 0.15)

-- Passive Seismic Experiment Package (EASEP / PSE)
local skirt=Instance.new("Part")
skirt.Name="SeisSkirt"
skirt.Size=Vector3.new(4.6,0.12,4.2); skirt.CFrame=CFrame.new(0,0.06,0)
skirt.Anchored=true; skirt.Material=Enum.Material.Foil
skirt.Color=Color3.fromRGB(196,160,60); skirt.Parent=s

local body=Instance.new("Part")
body.Name="SeisBody"
body.Size=Vector3.new(2.6,1.5,2.2); body.CFrame=CFrame.new(0,0.85,0)
body.Anchored=true; body.Material=Enum.Material.Foil
body.Color=Color3.fromRGB(206,170,66); body.Parent=s

local mast=Instance.new("Part")
mast.Name="SeisMast"
mast.Size=Vector3.new(0.16,1.5,0.16); mast.CFrame=CFrame.new(0,2.3,0)
mast.Anchored=true; mast.Material=Enum.Material.Metal
mast.Color=Color3.fromRGB(190,190,195); mast.Parent=s

local panel=Instance.new("Part")
panel.Name="SeisPanel"
panel.Size=Vector3.new(3.2,0.14,2.6)
panel.CFrame=CFrame.new(0,1.7,-1.5)*CFrame.Angles(math.rad(25),0,0)
panel.Anchored=true; panel.Material=Enum.Material.Glass
panel.Color=Color3.fromRGB(40,52,86); panel.Parent=s

return "s_seis"


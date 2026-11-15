local s=wipe(); moonLight(16.4,20)
ground(s,Color3.fromRGB(150,147,140),Enum.Material.Sand,1600)
rocks(s,60,Color3.fromRGB(112,108,103),14,150,55,1)
-- laser retroreflector array: panel of corner cubes on a low stand
local base=Instance.new("Part")
base.Size=Vector3.new(9.0,0.7,7.0); base.CFrame=CFrame.new(0,2.4,0)*CFrame.Angles(math.rad(-14),math.rad(16),0)
base.Anchored=true; base.Material=Enum.Material.Metal
base.Color=Color3.fromRGB(58,58,64); base.Name="RetroBase"; base.Parent=s
for ix=-4,4 do
  for iz=-3,3 do
    local c=Instance.new("Part")
    c.Size=Vector3.new(0.78,0.3,0.78)
    c.CFrame=base.CFrame*CFrame.new(ix*0.88,0.48,iz*0.88)
    c.Anchored=true; c.Material=Enum.Material.SmoothPlastic
    c.Color=Color3.fromRGB(120,170,220); c.Reflectance=0.65; c.Transparency=0.05
    c.Name="Cube"; c.Parent=s
  end
end
for _,off in ipairs({Vector3.new(-3.9,0,-2.9),Vector3.new(3.9,0,-2.9),Vector3.new(-3.9,0,2.9),Vector3.new(3.9,0,2.9)}) do
  local lgp=Instance.new("Part")
  lgp.Size=Vector3.new(0.42,2.4,0.42); lgp.CFrame=CFrame.new(off.X,1.2,off.Z)
  lgp.Anchored=true; lgp.Material=Enum.Material.Metal
  lgp.Color=Color3.fromRGB(150,150,156); lgp.Parent=s
end
-- the laser beam from Earth, starts invisible; animated per frame
local beam=Instance.new("Part")
beam.Name="Beam"
beam.Size=Vector3.new(0.09,260,0.09)
beam.CFrame=CFrame.new(0,132.4,0)
beam.Anchored=true; beam.CanCollide=false
beam.Material=Enum.Material.Neon
beam.Color=Color3.fromRGB(80,255,120)   -- 532 nm green, like the APOLLO observatory laser
beam.Transparency=1
beam.Parent=s
local gl=Instance.new("PointLight")
gl.Name="BeamLight"; gl.Brightness=0; gl.Range=11
gl.Color=Color3.fromRGB(120,255,150); gl.Parent=base
return "s6"

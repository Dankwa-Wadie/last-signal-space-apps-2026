local s=wipe(); moonLight(16.2,20)
ground(s,Color3.fromRGB(150,147,140),Enum.Material.Sand,1600)
rocks(s,50,Color3.fromRGB(112,108,103),16,140,12,1)
spawn("LM",0,0,13,-25,0.15)
-- a line of bootprints walking away from the lander
local rng=Random.new(7)
for i=1,22 do
  local p=Instance.new("Part")
  p.Size=Vector3.new(0.62,0.06,1.25)
  local side=(i%2==0) and 0.75 or -0.75
  local z=8+i*1.7
  p.CFrame=CFrame.new(side*0.7+rng:NextNumber(-0.08,0.08),0.03,z)*CFrame.Angles(0,rng:NextNumber(-0.12,0.12),0)
  p.Anchored=true; p.Material=Enum.Material.Sand
  p.Color=Color3.fromRGB(104,101,96); p.Parent=s
end
return "s2"

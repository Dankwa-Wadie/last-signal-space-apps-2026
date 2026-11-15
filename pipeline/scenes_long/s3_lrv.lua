local s=wipe(); moonLight(17.1,25)
ground(s,Color3.fromRGB(148,145,138),Enum.Material.Sand,1600)
rocks(s,80,Color3.fromRGB(110,106,101),12,160,21,1.1)
spawn("LRV",0,0,7.0,35,0.1)
-- wheel tracks curving in behind it
for i=1,34 do
  for _,off in ipairs({-1.5,1.5}) do
    local p=Instance.new("Part")
    p.Size=Vector3.new(0.75,0.1,2.0)
    local z=4+i*2.0
    local bend=math.sin(i/9)*4
    p.CFrame=CFrame.new(off+bend,0.05,z)*CFrame.Angles(0,math.rad(bend*1.6),0)
    p.Anchored=true; p.Material=Enum.Material.Sand
    p.Color=Color3.fromRGB(100,97,92); p.Parent=s
  end
end
return "s3"

-- End-card key art: Tranquility Base as the game shows it today, one astronaut, Earth overhead
-- (Earth is added in compose). Wide, low hero angle with plenty of sky for the title.
local s=wipe(); spaceSky(); moonLight(9.5,60)
ground(s,Color3.fromRGB(150,147,140),Enum.Material.Sand,1600)
rocks(s,70,Color3.fromRGB(112,108,103),16,160,21,1)
local lm,asc=procLM(0,0,155)
asc:Destroy()                                     -- only the descent stage is still there
flag(CFrame.new(-9,0,6)*CFrame.Angles(0,math.rad(30),0))
local a,an=astronaut("Explorer",CFrame.new(6.5,2.9,4),true)
a.HumanoidRootPart.CFrame=CFrame.lookAt(Vector3.new(6.5,2.9,4),Vector3.new(-2,9,-30))
play(an,"idle",1,0.6)
-- a line of bootprints leading to the explorer
for i=1,16 do
  local p=Instance.new("Part"); p.Size=Vector3.new(0.5,0.04,1.05)
  p.CFrame=CFrame.new(6.5+(i%2==0 and 0.45 or -0.45)+i*0.55,0.02,4+i*1.35)*CFrame.Angles(0,math.rad(20),0)
  p.Anchored=true; p.CanCollide=false; p.Material=Enum.Material.Sand; p.Color=Color3.fromRGB(122,119,113); p.Parent=s
end
return "L33"

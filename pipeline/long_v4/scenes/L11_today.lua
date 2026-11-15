local s=wipe(); spaceSky(); moonLight(9.5,60)
ground(s,Color3.fromRGB(150,147,140),Enum.Material.Sand,1600)
rocks(s,70,Color3.fromRGB(112,108,103),16,160,21,1)
local lm,asc=procLM(0,0,155)
asc:Destroy()                                   -- the cabin left in 1969
-- the flag: Aldrin saw the liftoff blast knock it over
local f=flag(CFrame.new(-12,0.25,14)*CFrame.Angles(math.rad(-86),math.rad(30),0))
for i=1,22 do
  local p=Instance.new("Part"); p.Size=Vector3.new(0.5,0.04,1.05)
  p.CFrame=CFrame.new((i%2==0 and 0.5 or -0.5)-4+i*0.3,0.02,8+i*1.6); p.Anchored=true; p.CanCollide=false
  p.Material=Enum.Material.Sand; p.Color=Color3.fromRGB(126,123,117); p.Parent=s
end
return "L11"

local s=wipe(); spaceSky(); moonLight(9.5,60)
ground(s,Color3.fromRGB(150,147,140),Enum.Material.Sand,1600)
rocks(s,70,Color3.fromRGB(112,108,103),16,160,21,1)
procLM(0,0,155)
flag(CFrame.new(-12,0,14)*CFrame.Angles(0,math.rad(30),0))
local a1,an1=astronaut("Armstrong",CFrame.new(-3,2.9,12),true)
local a2,an2=astronaut("Aldrin",CFrame.new(2,2.9,13),false)
play(an1,"walk",0.55,0.0); play(an2,"walk",0.55,0.4)
return "L08"

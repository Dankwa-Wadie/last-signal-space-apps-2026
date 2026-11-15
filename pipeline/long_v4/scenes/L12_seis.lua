local s=wipe(); spaceSky(); moonLight(9.5,60)
ground(s,Color3.fromRGB(150,147,140),Enum.Material.Sand,1600)
rocks(s,40,Color3.fromRGB(112,108,103),16,150,61,1)
procLM(-14,-12,-25)
local g=game:GetService("ServerStorage"):FindFirstChild("Game")
local src=g and g.Tranquility:FindFirstChild("Seismometer")
if src then
  local se=src:Clone(); local a=se:FindFirstChild("Anchor"); if a then a:Destroy() end
  se:PivotTo(CFrame.new(0,se:GetPivot().Position.Y,0)); se.Parent=s
end
local m,an=astronaut("Aldrin",CFrame.new(-2.4,2.9,-2.2)*CFrame.Angles(0,math.rad(45),0),false)
play(an,"idle",0.7,1.1)
return "L12"

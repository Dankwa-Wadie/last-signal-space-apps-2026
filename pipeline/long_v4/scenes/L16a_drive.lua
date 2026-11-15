-- "It was an electric space buggy with wire-mesh tires": Apollo 15's rover driving along the rille rim
-- in 1971 (reference AS15-88-11901; Apollo 16 "Grand Prix" film for the dust). Two crew seated;
-- dust thrown from the wheels flies in clean parabolas, since there is no air to make it billow.
local s=wipe(); spaceSky(); moonLight(9.5,60); rille(); rilleRocks(s,15)
local m=procLRV(14,40,180)            -- heading -Z (yaw 180 so the front faces -Z)
m:SetAttribute("P0",m:GetPivot())
local pv=m:GetPivot()
for i,sx in ipairs({-1.05,1.05}) do
  local a,an=astronaut(i==1 and "Scott" or "Irwin",pv*CFrame.new(sx,2.05+2.15,0.15),i==1)
  a.Parent=m
  play(an,"rbxassetid://2506281703",1,0)          -- R15 sit
  a:SetAttribute("Seat",pv:ToObjectSpace(a.HumanoidRootPart.CFrame))
end
local r=Random.new(3)
for i=1,140 do
  local p=Instance.new("Part"); p.Name="Dust"; p.Anchored=true; p.CanCollide=false
  local sz=r:NextNumber(0.08,0.22); p.Size=Vector3.new(sz,sz,sz)
  p.Material=Enum.Material.Sand; p.Color=Color3.fromRGB(150,147,140); p.Transparency=1; p.Parent=s
  p:SetAttribute("W",(i%4)+1); p:SetAttribute("B",i*0.21 % 1.3)          -- wheel, birth phase
  p:SetAttribute("V",Vector3.new(r:NextNumber(-0.8,0.8),r:NextNumber(2.5,5.5),r:NextNumber(3.5,7.5)))
end
return "L16a"

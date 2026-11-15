local s=wipe(); daySky(17.75, Color3.fromRGB(232,204,160)); dunes(4)
local skin={Color3.fromRGB(141,85,36),Color3.fromRGB(198,134,66),Color3.fromRGB(224,172,105),Color3.fromRGB(110,68,40)}
local shirt={Color3.fromRGB(236,226,206),Color3.fromRGB(120,72,40),Color3.fromRGB(200,180,150),Color3.fromRGB(70,90,110)}
for i=1,4 do
  local m,an=explorer("Walker"..i,CFrame.new(-8+i*4.2,2.9,-2*i),shirt[i],Color3.fromRGB(150,120,86),skin[i])
  local hat=Instance.new("Part"); hat.Name="Hat"; hat.Shape=Enum.PartType.Cylinder; hat.Size=Vector3.new(0.25,2.0,2.0)
  hat.Color=Color3.fromRGB(205,180,140); hat.Material=Enum.Material.Fabric; hat.CanCollide=false; hat.Massless=true
  hat.CFrame=m.Head.CFrame*CFrame.new(0,0.62,0)*CFrame.Angles(0,0,math.rad(90)); hat.Parent=m
  local w=Instance.new("Weld"); w.Part0=m.Head; w.Part1=hat; w.C0=CFrame.new(0,0.62,0)*CFrame.Angles(0,0,math.rad(90)); w.Parent=hat
  local pack=Instance.new("Part"); pack.Name="Pack"; pack.Size=Vector3.new(1.4,1.6,0.7); pack.Color=Color3.fromRGB(120,90,60)
  pack.Material=Enum.Material.Fabric; pack.CanCollide=false; pack.Massless=true; pack.Parent=m
  local w2=Instance.new("Weld"); w2.Part0=m.UpperTorso; w2.Part1=pack; w2.C0=CFrame.new(0,0,0.7); w2.Parent=pack
  play(an,"walk",0.9,i*0.17)
end
return "L03"

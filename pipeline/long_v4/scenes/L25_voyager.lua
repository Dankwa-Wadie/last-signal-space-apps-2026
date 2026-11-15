local s=wipe(); spaceSky()
clearAtmos(); L.ColorShift_Top=Color3.new(0,0,0)
L.ClockTime=7.2; L.GeographicLatitude=0; L.Brightness=2.2
L.Ambient=Color3.fromRGB(38,40,48); L.OutdoorAmbient=Color3.fromRGB(30,32,40); L.ExposureCompensation=0.25
local v=Instance.new("Model"); v.Name="VOYAGER1"; v.Parent=s
local function P(n,sz,cf,col,mat,shape)
  local p=Instance.new("Part"); p.Name=n; p.Size=sz; p.CFrame=cf; p.Anchored=true; p.CanCollide=false
  p.Color=col; p.Material=mat or Enum.Material.SmoothPlastic; if shape then p.Shape=shape end; p.Parent=v; return p
end
local W=Color3.fromRGB(232,232,228)
-- 3.7 m high-gain antenna (dish faces Earth), 10-sided bus below it
-- the dish: a flat face toward Earth with a stepped, convex back so it reads as a bowl
P("Dish",Vector3.new(0.18,9.2,9.2),CFrame.new(0,4.75,0)*CFrame.Angles(0,0,math.rad(90)),W,Enum.Material.SmoothPlastic,Enum.PartType.Cylinder)
for i=1,6 do
  local d=9.2*(1-i/7.5); local y=4.75-0.16*i-0.02*i*i
  P("DishBack"..i,Vector3.new(0.2,d,d),CFrame.new(0,y,0)*CFrame.Angles(0,0,math.rad(90)),Color3.fromRGB(236-i*6,236-i*6,230-i*6),Enum.Material.SmoothPlastic,Enum.PartType.Cylinder)
end
P("DishRim",Vector3.new(0.3,9.3,9.3),CFrame.new(0,4.9,0)*CFrame.Angles(0,0,math.rad(90)),Color3.fromRGB(205,205,200),Enum.Material.SmoothPlastic,Enum.PartType.Cylinder)
P("Feed",Vector3.new(0.35,2.6,0.35),CFrame.new(0,5.6,0),Color3.fromRGB(180,180,176),Enum.Material.Metal)
for i=0,9 do
  local a=i*math.pi/5
  P("Bus"..i,Vector3.new(1.55,1.5,0.4),CFrame.new(math.cos(a)*2.05,2.2,math.sin(a)*2.05)*CFrame.Angles(0,-a+math.pi/2,0),Color3.fromRGB(70,64,52),Enum.Material.Foil)
end
P("BusTop",Vector3.new(4.3,0.3,4.3),CFrame.new(0,2.95,0),Color3.fromRGB(40,40,40),Enum.Material.Metal)
P("GoldenRecord",Vector3.new(0.08,1.0,1.0),CFrame.new(2.6,2.2,0)*CFrame.Angles(0,0,math.rad(0)),Color3.fromRGB(214,176,70),Enum.Material.Foil,Enum.PartType.Cylinder)
-- science boom one way, RTG (nuclear power) boom the other, 13 m magnetometer boom
P("SciBoom",Vector3.new(7.5,0.22,0.22),CFrame.new(5.5,2.1,0),Color3.fromRGB(150,150,150),Enum.Material.Metal)
P("Scan",Vector3.new(1.4,1.0,1.0),CFrame.new(9.2,2.1,0),Color3.fromRGB(60,60,60),Enum.Material.Metal)
P("RTGBoom",Vector3.new(6.0,0.22,0.22),CFrame.new(-4.8,1.9,0),Color3.fromRGB(150,150,150),Enum.Material.Metal)
for i=0,2 do P("RTG"..i,Vector3.new(1.0,0.9,0.9),CFrame.new(-6.4-i*1.05,1.9,0),Color3.fromRGB(56,56,58),Enum.Material.Metal,Enum.PartType.Cylinder) end
P("MagBoom",Vector3.new(0.12,0.12,26),CFrame.new(-1.0,1.6,-13.5),Color3.fromRGB(170,170,170),Enum.Material.Metal)
v.WorldPivot=CFrame.new(0,3,0)  -- default pivot is the (rotated) first part
v:PivotTo(CFrame.new(0,0,0)*CFrame.Angles(math.rad(8),math.rad(25),math.rad(-6)))
v:SetAttribute("P0",v:GetPivot())
local sun=Instance.new("PointLight"); local a=Instance.new("Part"); a.Name="Fill"; a.Anchored=true; a.Transparency=1; a.CanCollide=false
a.Size=Vector3.new(0.2,0.2,0.2); a.CFrame=CFrame.new(18,14,26); a.Parent=s; sun.Brightness=1.2; sun.Range=120; sun.Parent=a
return "L23"

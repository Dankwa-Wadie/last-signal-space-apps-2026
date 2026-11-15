local s=wipe(); spaceSky(); moonLight(9.5,60)
L.ClockTime=7.2   -- low sun: raking light picks out the tread
ground(s,Color3.fromRGB(150,147,140),Enum.Material.Sand,400)
local base=CFrame.new(0,0.012,0)*CFrame.Angles(0,math.rad(18),0)
local press=Color3.fromRGB(128,125,119); local ridge=Color3.fromRGB(136,133,126)
local function P(sz,cf,col,shape)
  local p=Instance.new("Part"); p.Size=sz; p.CFrame=base*cf; p.Anchored=true; p.CanCollide=false
  p.Material=Enum.Material.Sand; p.Color=col; if shape then p.Shape=shape end; p.Parent=s; return p
end
-- sole: rounded heel and toe (cylinders) joined by the arch
P(Vector3.new(0.02,1.15,1.15),CFrame.new(0,0,1.05)*CFrame.Angles(0,0,math.rad(90)),press,Enum.PartType.Cylinder)
P(Vector3.new(0.02,1.30,1.30),CFrame.new(0,0,-1.0)*CFrame.Angles(0,0,math.rad(90)),press,Enum.PartType.Cylinder)
P(Vector3.new(1.10,0.02,2.0),CFrame.new(0,0,0),press)
-- overshoe tread: shallow bars, barely lighter than the pressed dust
for i=0,15 do
  local z=-1.55+i*0.2
  local w=(math.abs(z)<0.7) and 1.0 or 1.12
  P(Vector3.new(w,0.025,0.05),CFrame.new(0,0.010,z),ridge)
end
for i=1,7 do
  local side=(i%2==0) and 0.8 or -0.8
  P(Vector3.new(1.0,0.02,2.6),CFrame.new(side,0,-4.2-i*2.4),press)
end
return "L07"

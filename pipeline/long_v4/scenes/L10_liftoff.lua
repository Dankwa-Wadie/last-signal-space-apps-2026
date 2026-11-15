local s=wipe(); spaceSky(); moonLight(9.5,60)
ground(s,Color3.fromRGB(150,147,140),Enum.Material.Sand,1600)
rocks(s,60,Color3.fromRGB(112,108,103),16,160,21,1)
local lm,asc=procLM(0,0,155)
asc:SetAttribute("P0",asc:GetPivot())
flag(CFrame.new(-12,0,14)*CFrame.Angles(0,math.rad(30),0))
-- ascent-engine glow: the hypergolic flame is nearly invisible; a faint flickering cone at the nozzle
local ds=s:FindFirstChild("DescentStage",true)
local top=ds.Position.Y+ds.Size.X/2
s:SetAttribute("Top",top)
local glow=Instance.new("Part"); glow.Name="Glow"; glow.Anchored=true; glow.CanCollide=false
glow.Shape=Enum.PartType.Cylinder; glow.Size=Vector3.new(2.6,1.3,1.3)
glow.Material=Enum.Material.Neon; glow.Color=Color3.fromRGB(255,206,150); glow.Transparency=1; glow.Parent=s
-- separation burst: gold Kapton foil and white insulation thrown out (seen in every Apollo liftoff film)
local r=Random.new(9)
for i=1,140 do
  local f=Instance.new("Part"); f.Name="Fleck"; f.Anchored=true; f.CanCollide=false
  local gold=r:NextNumber()<0.65
  f.Size=Vector3.new(r:NextNumber(0.12,0.45),0.03,r:NextNumber(0.1,0.35))
  f.Material=gold and Enum.Material.Foil or Enum.Material.SmoothPlastic
  f.Color=gold and Color3.fromRGB(226,184,80) or Color3.fromRGB(236,236,230)
  f.Transparency=1; f.Parent=s
  local az=r:NextNumber(0,math.pi*2); local el=r:NextNumber(0.05,1.2); local sp=r:NextNumber(5,19)
  f:SetAttribute("V",Vector3.new(math.cos(az)*math.cos(el),math.sin(el),math.sin(az)*math.cos(el))*sp)
  f:SetAttribute("S",Vector3.new(r:NextNumber(-8,8),r:NextNumber(-8,8),r:NextNumber(-8,8)))
end
for i=1,26 do      -- a brief sparkle of bright specks at the moment of separation
  local f=Instance.new("Part"); f.Name="Spark"; f.Anchored=true; f.CanCollide=false; f.Shape=Enum.PartType.Ball
  f.Size=Vector3.new(0.14,0.14,0.14); f.Material=Enum.Material.Neon; f.Color=Color3.fromRGB(255,240,210)
  f.Transparency=1; f.Parent=s
  local az=r:NextNumber(0,math.pi*2); local el=r:NextNumber(-0.2,0.9); local sp=r:NextNumber(10,26)
  f:SetAttribute("V",Vector3.new(math.cos(az)*math.cos(el),math.sin(el),math.sin(az)*math.cos(el))*sp)
end
return "L10"

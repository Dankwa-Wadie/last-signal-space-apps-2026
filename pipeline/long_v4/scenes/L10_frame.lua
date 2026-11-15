-- ignition at IG: the cabin separates and climbs SLOWLY (net ~1.6 m/s^2 = ~3 studs/s^2 at this scale),
-- foil and insulation fly out in clean parabolas (no air on the Moon), the flame is a faint glow
local asc=S:FindFirstChild("AscentStage",true); local glow=S:FindFirstChild("Glow")
local p0=asc:GetAttribute("P0")
local IG=14
local t=math.max(0,(k-IG)/24)
local h=1.5*t*t
asc:PivotTo(p0+Vector3.new(0,h,0))
local top=S:GetAttribute("Top")
local ds=S:FindFirstChild("DescentStage",true).Position
local G=3.0                                         -- lunar gravity in studs/s^2 (1.62 m/s^2)
if k>=IG then
  local fl=0.55+0.12*math.sin(k*2.7)+0.08*math.sin(k*5.3)
  glow.CFrame=CFrame.new(ds.X,top+h+0.2,ds.Z)*CFrame.Angles(0,0,math.rad(90))
  glow.Size=Vector3.new(1.6+math.min(h,6)*0.5,1.1,1.1)
  glow.Transparency=matte and 0.6 or fl
  if matte then glow.Color=Color3.new(1,1,1) end
else glow.Transparency=1 end
if not matte then
  local flash=(k>=IG) and math.exp(-(k-IG)/3) or 0
  game:GetService("Lighting").ExposureCompensation=0.05+0.55*flash
end
local origin=Vector3.new(ds.X,top+0.3,ds.Z)
for _,f in ipairs(S:GetChildren()) do
  if f.Name=="Fleck" or f.Name=="Spark" then
    if k>=IG then
      local v=f:GetAttribute("V")
      local p=origin+v*t+Vector3.new(0,-0.5*G*t*t,0)
      if p.Y<0.05 then p=Vector3.new(p.X,0.05,p.Z) end    -- landed: lies on the dust
      if f.Name=="Fleck" then
        local sp=f:GetAttribute("S")*math.min(t,(p.Y<=0.06) and t or 99)
        f.CFrame=CFrame.new(p)*CFrame.Angles(sp.X,sp.Y,sp.Z)
        f.Transparency=0
      else
        f.CFrame=CFrame.new(p); f.Transparency=(t<0.55) and (t/0.55) or 1
      end
      if matte then f.Material=Enum.Material.Neon; f.Color=Color3.new(1,1,1); if f.Name=="Spark" and t>=0.55 then f.Transparency=1 end end
    else f.Transparency=1 end
  end
end
return "ok"

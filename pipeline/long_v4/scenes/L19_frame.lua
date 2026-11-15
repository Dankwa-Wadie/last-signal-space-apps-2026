-- Opportunity drives steadily (no storm yet). Speed dramatised; real top speed ~5 cm/s.
local r=S:FindFirstChild("ROVER"); if not r then return "norover" end
if r:GetAttribute("P0")==nil then r:SetAttribute("P0",r:GetPivot()) end
local p0=r:GetAttribute("P0")
local d=k*0.06
r:PivotTo(p0*CFrame.new(0,math.sin(k*1.7)*0.02,-d))
oppSpin(r, d/0.975)
if k>0 then
  for _,side in ipairs({-2.2,2.2}) do
    local mid=p0*CFrame.new(side,0,-(d-0.03))
    local t=Instance.new("Part"); t.Name="Track"; t.Anchored=true; t.CanCollide=false
    t.Size=Vector3.new(0.75,0.05,0.12); t.CFrame=CFrame.new(mid.Position.X,0.03,mid.Position.Z)*(p0-p0.Position)
    if matte then t.Material=Enum.Material.Neon; t.Color=Color3.new(1,1,1) else t.Material=Enum.Material.Sand; t.Color=Color3.fromRGB(118,66,44) end
    t.Parent=S
  end
end
return "ok"

-- Apollo 12 site, Ocean of Storms. The crash was 73 km away - well beyond the ~2.4 km
-- lunar horizon - so we show its glow lighting the horizon, not the impact itself.
local s=wipe(); spaceSky(); moonLight(9.5,60)
ground(s,Color3.fromRGB(146,143,137),Enum.Material.Sand,1600)
rocks(s,80,Color3.fromRGB(110,106,101),10,200,71,1.1)
local g=game:GetService("ServerStorage"):FindFirstChild("Game")
local src=g and g.Tranquility:FindFirstChild("Seismometer")
if src then
  local se=src:Clone(); local a=se:FindFirstChild("Anchor"); if a then a:Destroy() end
  se:PivotTo(CFrame.new(0,se:GetPivot().Position.Y,6)); se.Parent=s
end
local glow=Instance.new("Part"); glow.Name="Glow"; glow.Shape=Enum.PartType.Ball; glow.Size=Vector3.new(60,30,60)
glow.Material=Enum.Material.Neon; glow.Color=Color3.fromRGB(255,236,200); glow.Anchored=true; glow.CanCollide=false
glow.CFrame=CFrame.new(40,-14,-700); glow.Transparency=1; glow.Parent=s
return "L13"

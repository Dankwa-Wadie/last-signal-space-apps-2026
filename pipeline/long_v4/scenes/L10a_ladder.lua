-- "When it was time to leave": the commander climbs the ladder on the front leg to the hatch
-- (reference: AS11-40-5868). The ladder side is in shadow; a soft bounce light stands in for
-- sunlight reflected off the regolith, as in the real photos.
local s=wipe(); spaceSky(); moonLight(9.5,60)
ground(s,Color3.fromRGB(150,147,140),Enum.Material.Sand,1600)
rocks(s,60,Color3.fromRGB(112,108,103),16,160,21,1)
local lm,asc=procLM(0,0,155)
flag(CFrame.new(-12,0,14)*CFrame.Angles(0,math.rad(30),0))
local lad=s:FindFirstChild("Ladder",true)
local rs={}
for _,r in ipairs(lad:GetChildren()) do table.insert(rs,r) end
table.sort(rs,function(a,b) return a.Position.Y<b.Position.Y end)
local b,t=rs[1].Position,rs[#rs].Position
local out=Vector3.new(b.X,0,b.Z).Unit                     -- away from the lander
s:SetAttribute("LB",b); s:SetAttribute("LT",t); s:SetAttribute("LO",out)
local a,an=astronaut("Armstrong",CFrame.new(b+out*0.45+Vector3.new(0,2.75,0)),true)
play(an,"rbxassetid://507765644",0.9,0)                   -- R15 climb
local bounce=Instance.new("Part"); bounce.Name="Bounce"; bounce.Anchored=true; bounce.CanCollide=false; bounce.Transparency=1
bounce.Size=Vector3.new(0.2,0.2,0.2); bounce.CFrame=CFrame.new(b+out*7+Vector3.new(0,2,0)); bounce.Parent=s
local pl=Instance.new("PointLight"); pl.Brightness=1.4; pl.Range=16; pl.Color=Color3.fromRGB(230,228,220); pl.Parent=bounce
return "L10a"

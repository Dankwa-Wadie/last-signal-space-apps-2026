local m=S:FindFirstChild("LRV"); if not m then return "nolrv" end
local p0=m:GetAttribute("P0")
local SPEED=7.0                                    -- studs/s (~2.3 m/s; the real LRV topped out ~3.3 m/s)
local t=k/24; local d=SPEED*t
local bob=math.sin(t*9)*0.04
m:PivotTo(p0*CFrame.new(0,bob,-d)*CFrame.Angles(math.sin(t*7)*0.01,0,math.sin(t*5)*0.012))
local pv=m:GetPivot()
local D=m:GetAttribute("D") or 2.0
local ang=d/(D/2)
local W={{-2.6,2.65},{2.6,2.65},{-2.6,-2.65},{2.6,-2.65}}
for i,w in ipairs(W) do
  local wc=pv*CFrame.new(w[1],D/2,w[2])
  for tt=0,7 do
    local tr=m:FindFirstChild("Tread_"..i.."_"..tt)
    if tr then tr.CFrame=wc*CFrame.Angles(tt*math.pi/4+0.3-ang,0,0)*CFrame.new(0,D/2-0.035,0) end
  end
end
for _,a in ipairs(m:GetChildren()) do
  if a:IsA("Model") and a:GetAttribute("Seat") then a.HumanoidRootPart.CFrame=pv*a:GetAttribute("Seat") end
end
stepAll(1/24)
-- dust: each grain is reborn at its wheel every 1.3 s and flies a parabola under lunar gravity
local G=3.0
for _,p in ipairs(S:GetChildren()) do
  if p.Name=="Dust" then
    local w=W[p:GetAttribute("W")]; local life=1.3
    local age=(t+p:GetAttribute("B"))%life
    local born=t-age
    if born<0 then p.Transparency=1 else
      local bpv=p0*CFrame.new(0,0,-SPEED*born)
      local o=(bpv*CFrame.new(w[1],0.15,w[2]+0.6)).Position
      local v=bpv:VectorToWorldSpace(p:GetAttribute("V"))
      local pos=o+v*age+Vector3.new(0,-0.5*G*age*age,0)
      local gy=2.0
      if pos.Y<gy then p.Transparency=1 else
        p.CFrame=CFrame.new(pos); p.Transparency=matte and 0 or 0.15
        if matte then p.Material=Enum.Material.Neon; p.Color=Color3.new(1,1,1) end
      end
    end
  end
end
return "ok"

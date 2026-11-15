-- SHELTER DOMES on every world. Storms are real hazards:
--  Mars  : planet-wide dust storms (2018 storm blocked the sun and ended Opportunity)
--  Moon/Eros: solar particle events (radiation storms) -- no air, so no dust storms there
local game_=workspace:WaitForChild("Game")
local old=game_:FindFirstChild("Shelters"); if old then old:Destroy() end
local F=Instance.new("Folder"); F.Name="Shelters"; F.Parent=game_
local WL=(function()
WORLD_LAYOUT
end)()
-- one dome beside every site, plus a grid across each ring so a dome is never more than
-- about 30 seconds' run away (the storm warning is 30 s)
local SPOTS={{"moon",0,150,30,"Station"}}
for name,st in pairs(WL.SITES) do
  if name~="Tranquility" then
    local c=WL.pos(st[1],st[2],st[3])
    table.insert(SPOTS,{st[1],c.X+60,c.Z+40,st[1]=="eros" and 14 or 18})
  end
end
for wn,w in pairs(WL.WORLDS) do
  local step=wn=="eros" and 300 or 700
  for x=w.xmin+step/2,w.xmin+w.W-1,step do
    for z=w.zmin+step/2,w.zmin+w.D-1,step do
      local near=false
      for _,sp in ipairs(SPOTS) do if sp[1]==wn and (Vector3.new(sp[2],0,sp[3])-Vector3.new(x,0,z)).Magnitude<200 then near=true end end
      if not near then table.insert(SPOTS,{wn,x,z,18}) end
    end
  end
end
local rp=RaycastParams.new(); rp.FilterType=Enum.RaycastFilterType.Exclude; rp.FilterDescendantsInstances={F}
for i,s in ipairs(SPOTS) do
  local w,x,z,r,existing=s[1],s[2],s[3],s[4],s[5]
  local y=0
  local m=Instance.new("Model"); m.Name="Shelter"..i; m:SetAttribute("World",w); m:SetAttribute("Radius",r); m.Parent=F
  local c=Instance.new("Part"); c.Name="Centre"; c.Anchored=true; c.CanCollide=false; c.Transparency=1
  c.Size=Vector3.new(1,1,1); c.Position=Vector3.new(x,y+3,z); c.Parent=m; m.PrimaryPart=c
  if not existing then
    local dome=Instance.new("Part"); dome.Name="Dome"; dome.Shape=Enum.PartType.Ball; dome.Anchored=true
    dome.CanCollide=false; dome.CastShadow=false; dome.Material=Enum.Material.Glass; dome.Transparency=0.55
    dome.Color=Color3.fromRGB(150,205,255); dome.Size=Vector3.new(r*2,r*2,r*2); dome.Position=Vector3.new(x,y,z); dome.Parent=m
    local floor=Instance.new("Part"); floor.Name="Floor"; floor.Shape=Enum.PartType.Cylinder; floor.Anchored=true
    floor.Size=Vector3.new(0.4,r*2-1,r*2-1); floor.CFrame=CFrame.new(x,y+0.2,z)*CFrame.Angles(0,0,math.rad(90))
    floor.Material=Enum.Material.DiamondPlate; floor.Color=Color3.fromRGB(70,74,80); floor.Parent=m
    local l=Instance.new("PointLight"); l.Range=r*1.6; l.Brightness=1.4; l.Color=Color3.fromRGB(200,230,255); l.Parent=c
  end
  -- No floating labels: shelters should be identified by their shape and light.
end
return "shelters "..#SPOTS

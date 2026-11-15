-- Copies of every artifact, kept in ReplicatedStorage so the trophy room can show a real
-- 3D model of each one. They cannot be read out of the world directly: StreamingEnabled
-- means a site 1,700 studs away simply is not on the client.
local B=(function()
EQUIPMENT_MODELS
end)()

local RS=game:GetService("ReplicatedStorage")
local game_=workspace:WaitForChild("Game")
local old=RS:FindFirstChild("TrophyModels"); if old then old:Destroy() end
local TM=Instance.new("Folder"); TM.Name="TrophyModels"; TM.Parent=RS

-- artifact id -> {site folder, model name}
local FROM_WORLD={
  lm={"Tranquility","LM_DescentStage"}, seis={"Tranquility","Seismometer"},
  retro={"Tranquility","Retroreflector"},
  surv3={"Procellarum","Surveyor3"}, a12alsep={"Procellarum","Apollo12_ALSEP"},
  falcon={"Hadley","Falcon_DescentStage"}, lrv={"Hadley","LunarRover"},
  lrrr15={"Hadley","Retroreflector15"},
  oppy={"Meridiani","Opportunity"}, heatshield={"Meridiani","HeatShield"},
  pathfinder={"AresVallis","Pathfinder"}, sojourner={"AresVallis","Sojourner"},
  viking1={"Chryse","Viking1"}, viking2={"Utopia","Viking2"},
  spirit={"Gusev","Spirit"}, phoenix={"VastitasBorealis","Phoenix"},
  insight={"Elysium","InSight"}, ingenuity={"Jezero","Ingenuity"},
  ranger4={"Farside","Ranger4"},
}
-- the ones with no site: built fresh from the same part recipes
local FROM_KIT={near=B.near, dawn=B.dawn, kepler=B.kepler, pioneer10=B.pioneer, pioneer11=B.pioneer,
  voyager1=B.voyager}

local function tidy(m)
  -- a trophy needs no prompts, no invisible anchors and no collisions
  for _,d in ipairs(m:GetDescendants()) do
    if d:IsA("ProximityPrompt") or d:IsA("SurfaceGui") or d:IsA("BillboardGui") then
      d:Destroy()
    end
  end
  for _,d in ipairs(m:GetDescendants()) do
    if d:IsA("BasePart") then
      d.Anchored=true; d.CanCollide=false; d.CanQuery=false; d.CanTouch=false
      if d.Name=="Anchor" or d.Name=="ImpactScar" or d.Name=="SoftSoil" then d:Destroy() end
    end
  end
  -- centre it on its own origin so the viewport camera can frame it predictably
  local ok,cf,size=pcall(function() return m:GetBoundingBox() end)
  if ok and cf then
    m:PivotTo(CFrame.new())
    local cf2,sz2=m:GetBoundingBox()
    m:PivotTo(m:GetPivot()*CFrame.new(-(cf2.Position)))
    m:SetAttribute("Extent",math.max(sz2.X,sz2.Y,sz2.Z))
  end
  return m
end

local n=0
for id,where in pairs(FROM_WORLD) do
  local f=game_:FindFirstChild(where[1])
  local src=f and f:FindFirstChild(where[2])
  if src then
    local c=src:Clone()
    c.Name=id
    c.Parent=TM
    tidy(c)
    n+=1
  else
    warn("trophy_models: missing "..where[1].."/"..where[2])
  end
end
for id,builder in pairs(FROM_KIT) do
  local holder=Instance.new("Model"); holder.Name=id; holder.Parent=TM
  local m=builder(CFrame.new(),holder)
  if m and m~=holder then m.Parent=holder end
  tidy(holder)
  n+=1
end

return "trophy models: "..n

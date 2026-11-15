-- STORMS AND SHELTERS (server). Facts behind each storm:
--  Mars: dust storms can grow to cover the whole planet (NASA, 2018). The thin air cannot
--        knock you over (about 1% of Earth's pressure), but the dust blocks sunlight: that is
--        what ended solar-powered Opportunity. So in game the danger is SUIT POWER.
--        Dust slowly accumulated on arrays. Rare wind events sometimes cleaned
--        Spirit and Opportunity's panels; InSight's panels accumulated dust over years.
--  Moon & Eros: no air, so no dust storms. The real hazard is a solar particle event
--        (a radiation storm from the Sun); astronauts would shelter behind shielding.
-- Nobody is ever hurt: at zero power your suit walks you to the nearest dome.
local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local rem=RS:WaitForChild("Remotes")
local StormState=rem:WaitForChild("StormState")
local Notice=rem:WaitForChild("Notice")
local game_=workspace:WaitForChild("Game")
local Shelters=game_:WaitForChild("Shelters")

-- Gameplay phases are compressed to seconds. Real global Martian storms last weeks to months.
local WARN,ACTIVE=30,45
local GAP={mars={210,330},moon={260,380},eros={300,420}}
local KIND={mars="dust",moon="solar",eros="solar"}
local WL=require(game:GetService("ReplicatedStorage"):WaitForChild("WorldLayout"))
local function worldAt(p) return WL.worldAt(p) end
local function nearestShelter(w,pos)
  local best,bd
  for _,s in ipairs(Shelters:GetChildren()) do
    if s:GetAttribute("World")==w and s.PrimaryPart then
      local d=(s.PrimaryPart.Position-pos).Magnitude
      if not bd or d<bd then best,bd=s,d end
    end
  end
  return best,bd
end
local function sheltered(w,pos)
  local s,d=nearestShelter(w,pos)
  if not s or not d then return false end
  local radius=s:GetAttribute("Radius")
  return type(radius)=="number" and d<=radius+1
end

-- ---------- panel dust and occasional clearing (Mars only) ----------
local MARS={oppy={"Meridiani","Opportunity"},heatshield={"Meridiani","HeatShield"},
  pathfinder={"AresVallis","Pathfinder"},sojourner={"AresVallis","Sojourner"},
  viking1={"Chryse","Viking1"},viking2={"Utopia","Viking2"},spirit={"Gusev","Spirit"},
  phoenix={"VastitasBorealis","Phoenix"},insight={"Elysium","InSight"},ingenuity={"Jezero","Ingenuity"}}
local function anchorOf(id)
  local e=MARS[id]; local f=game_:FindFirstChild(e[1]); local m=f and f:FindFirstChild(e[2])
  return m and m:FindFirstChild("Anchor")
end
local function addDust(id)
  local a=anchorOf(id); if not a or a:FindFirstChild("PanelDust") then return false end
  local d=Instance.new("Part"); d.Name="PanelDust"; d.Shape=Enum.PartType.Ball; d.Anchored=true; d.CanCollide=false
  d.Material=Enum.Material.Sand; d.Color=Color3.fromRGB(176,110,66); d.Size=Vector3.new(9,3.5,9)
  d.Position=a.Position-Vector3.new(0,1,0); d.Parent=a
  local b=Instance.new("ProximityPrompt"); b.Name="Brush"; b.ActionText="Brush solar panel"; b.ObjectText="Accumulated Martian dust"
  b.HoldDuration=2; b.MaxActivationDistance=12; b.RequiresLineOfSight=false; b.KeyboardKeyCode=Enum.KeyCode.E; b.Parent=d
  b.Triggered:Connect(function(pl)
    d:Destroy()
    Notice:FireClient(pl,"Panel dust cleared. Array output restored.",3)
  end)
  return true
end
-- These two artifacts are already dust-covered in the present-day exhibit.
task.defer(function() task.wait(8); addDust("insight"); addDust("oppy") end)

local function ensurePresentDayDust()
  for _,id in ipairs({"insight","oppy"}) do
    local a=anchorOf(id); if a and not a:FindFirstChild("PanelDust") then addDust(id) end
  end
end

local function panelDustEvent()
  local pool={"oppy","spirit","insight"}
  local eligible={}
  for _,id in ipairs(pool) do
    local a=anchorOf(id)
    if a then table.insert(eligible,id) end
  end
  if #eligible==0 then return end
  local id=eligible[math.random(#eligible)]
  local a=anchorOf(id); local d=a and a:FindFirstChild("PanelDust")
  if d then
    d:Destroy()
    for _,pl in ipairs(Players:GetPlayers()) do
      local hrp=pl.Character and pl.Character:FindFirstChild("HumanoidRootPart")
      if hrp and worldAt(hrp.Position)=="mars" and (hrp.Position-a.Position).Magnitude<160 then
        Notice:FireClient(pl,"A passing wind cleared dust from a solar array. Output improved.",4)
      end
    end
  elseif math.random()<0.35 then
    addDust(id)
  end
end

task.spawn(function()
  task.wait(12)
  while true do
    -- Dust accumulation is a slow state change across sols in reality. This
    -- exhibition compresses the time between gradual accumulation and cleaning.
    task.wait(math.random(210,330))
    if math.random()<0.35 then
      local id=({"oppy","spirit","insight"})[math.random(3)]
      addDust(id)
    end
  end
end)

-- ---------- storm loop per world ----------
local state={}
local function run(w)
  task.wait(math.random(GAP[w][1],GAP[w][2])*(w=="mars" and 0.5 or 1))
  while true do
    state[w]="warn"; StormState:FireAllClients(w,KIND[w],"warn",WARN)
    task.wait(WARN)
    state[w]="active"; StormState:FireAllClients(w,KIND[w],"active",ACTIVE)
    local t0=os.clock()
    while os.clock()-t0<ACTIVE do
      for _,pl in ipairs(Players:GetPlayers()) do
        local hrp=pl.Character and pl.Character:FindFirstChild("HumanoidRootPart")
        if hrp and worldAt(hrp.Position)==w then
          -- On Mars the storm dims sunlight for solar-powered hardware. It does
          -- not drain a player's suit battery or force an astronaut into shelter.
          if w~="mars" then
            local pw=pl:GetAttribute("SuitPower") or 100
            if sheltered(w,hrp.Position) then pw=math.min(100,pw+6) else pw=math.max(0,pw-4) end
            if pw<=0 then
              local s=nearestShelter(w,hrp.Position)
              if s then pl.Character:PivotTo(CFrame.new(s.PrimaryPart.Position+Vector3.new(0,2,0))) end
              Notice:FireClient(pl,"Suit power ran out -- autopilot walked you to a shelter.",4); pw=35
            end
            pl:SetAttribute("SuitPower",pw)
          end
        end
      end
      task.wait(1)
    end
    state[w]="clear"; StormState:FireAllClients(w,KIND[w],"clear",0)
    if w=="mars" then
      panelDustEvent()
      -- Restore InSight and Opportunity to their present-day archive condition
      -- after the brief interactive panel-cleaning moment.
      task.delay(30,ensurePresentDayDust)
    end
    task.wait(math.random(GAP[w][1],GAP[w][2]))
  end
end
for w in pairs(GAP) do task.spawn(run,w) end
-- recharge slowly in calm weather
task.spawn(function() while true do task.wait(2)
  for _,pl in ipairs(Players:GetPlayers()) do pl:SetAttribute("SuitPower",math.min(100,(pl:GetAttribute("SuitPower") or 100)+2)) end
end end)
Players.PlayerAdded:Connect(function(pl) pl:SetAttribute("SuitPower",100) end)

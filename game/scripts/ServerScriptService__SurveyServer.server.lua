-- Script  ServerScriptService/SurveyServer
-- Authoritative survey state. The crew shares one mission log, and a REMEMBER
-- vignette is witnessed by everyone standing near that artifact.
local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local rem=RS:WaitForChild("Remotes")
local ShowCard=rem.ShowCard
local LogUpdate=rem.LogUpdate
local RequestRemember=rem.RequestRemember
local PlayVignette=rem.PlayVignette
local Notice=rem.Notice

local Rules=require(script.Parent:WaitForChild("SurveyRules"))
local Progress=require(script.Parent:WaitForChild("Progress"))
local game_=workspace:WaitForChild("Game")

-- Artifacts now live at more than one site, so each id carries the folder it stands in.
local ORDER={"lm","seis","retro","surv3","a12alsep","falcon","lrv","lrrr15","oppy","heatshield","pathfinder","sojourner",
  "viking1","viking2","spirit","phoenix","insight","ingenuity","ranger4","near"}
local MODEL={
  lm        ={"Tranquility","LM_DescentStage"},
  seis      ={"Tranquility","Seismometer"},
  retro     ={"Tranquility","Retroreflector"},
  surv3     ={"Procellarum","Surveyor3"},
  a12alsep  ={"Procellarum","Apollo12_ALSEP"},
  falcon    ={"Hadley","Falcon_DescentStage"},
  lrv       ={"Hadley","LunarRover"},
  lrrr15    ={"Hadley","Retroreflector15"},
  oppy      ={"Meridiani","Opportunity"},
  heatshield={"Meridiani","HeatShield"},
  pathfinder={"AresVallis","Pathfinder"},
  sojourner ={"AresVallis","Sojourner"},
  viking1   ={"Chryse","Viking1"},
  viking2   ={"Utopia","Viking2"},
  spirit    ={"Gusev","Spirit"},
  phoenix   ={"VastitasBorealis","Phoenix"},
  insight   ={"Elysium","InSight"},
  ingenuity ={"Jezero","Ingenuity"},
  ranger4   ={"Farside","Ranger4"},
  near      ={"Eros","NEARShoemaker"},
}

local WITNESS_RADIUS=22   -- studs: who sees a vignette
local TRIGGER_RADIUS=14   -- studs: who may start one
local COOLDOWN=22         -- seconds per artifact

local discovered={}       -- shared across the whole server
local busyUntil={}

local function snapshot()
  return Rules.snapshot(ORDER,discovered)
end

local function modelOf(id)
  local e=MODEL[id]; if not e then return nil end
  local folder=game_:FindFirstChild(e[1])
  return folder and folder:FindFirstChild(e[2])
end

local function anchorOf(id)
  local m=modelOf(id)
  return m and m:FindFirstChild("Anchor"), m
end

local function hrpOf(p)
  local c=p.Character
  return c and c:FindFirstChild("HumanoidRootPart")
end

local function cardData(m)
  return {
    id=m:GetAttribute("ArtifactId"),
    Title=m:GetAttribute("Title"),
    Year=m:GetAttribute("Year"),
    What=m:GetAttribute("What"),
    Why=m:GetAttribute("Why"),
    Science=m:GetAttribute("Science"),
  }
end

-- prompts fire on the SERVER with the player who triggered them
for id,entry in pairs(MODEL) do
  task.spawn(function()
    local folder=game_:WaitForChild(entry[1],30)
    if not folder then warn("SurveyServer: no site "..entry[1]) return end
    local name=entry[2]
    local m=folder:WaitForChild(name,30); if not m then warn("SurveyServer: no "..name) return end
    local a=m:WaitForChild("Anchor",30); if not a then return end
    local pp=a:WaitForChild("ProximityPrompt",30); if not pp then return end
    pp.Triggered:Connect(function(player)
      ShowCard:FireClient(player,cardData(m))
      if not discovered[id] then
        discovered[id]={title=m:GetAttribute("Title"), by=player.DisplayName}
        Progress.fromArtifact(id)   -- fills its plinth in the trophy hall, if it has one
        LogUpdate:FireAllClients(snapshot())
        for _,p in ipairs(Players:GetPlayers()) do
          if p~=player then
            Notice:FireClient(p,player.DisplayName.." recovered "..m:GetAttribute("Title"),4)
          end
        end
      end
    end)
    print("SurveyServer: hooked "..name)
  end)
end

RequestRemember.OnServerEvent:Connect(function(player,id)
  if type(id)~="string" or not MODEL[id] then return end
  local a,m=anchorOf(id); if not a then return end
  local hrp=hrpOf(player); if not hrp then return end
  if not Rules.canTrigger(hrp.Position,a.Position,TRIGGER_RADIUS) then return end
  if Rules.onCooldown(busyUntil,id,os.clock()) then
    Notice:FireClient(player,"Already running.",2)
    return
  end
  busyUntil[id]=os.clock()+COOLDOWN

  local crew={}
  for _,p in ipairs(Players:GetPlayers()) do
    local h=hrpOf(p)
    table.insert(crew,{key=p,pos=h and h.Position or nil})
  end
  local witnesses=Rules.selectWitnesses(crew,a.Position,WITNESS_RADIUS)
  -- a two second beat so nobody is yanked into a vignette mid-sentence
  for _,p in ipairs(witnesses) do
    if p==player then
      Notice:FireClient(p,"REMEMBERING...",2)
    else
      Notice:FireClient(p,player.DisplayName.." is remembering. Stand by.",2)
    end
  end
  task.wait(2)
  for _,p in ipairs(witnesses) do
    if p.Parent then PlayVignette:FireClient(p,id,p==player) end
  end
end)

Players.PlayerAdded:Connect(function(p)
  task.wait(1)
  LogUpdate:FireClient(p,snapshot())
end)

-- Script  ServerScriptService/ReactivateServer
-- Which experiments the crew has brought back online. Server-authoritative.
local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local rem=RS:WaitForChild("Remotes")
local RequestReactivate=rem.RequestReactivate
local OpenPuzzle=rem.OpenPuzzle
local SolvePuzzle=rem.SolvePuzzle
local OnlineUpdate=rem.OnlineUpdate
local Notice=rem.Notice

local Rules=require(script.Parent:WaitForChild("SurveyRules"))
local game_=workspace:WaitForChild("Game")
local MODEL={
  seis ={"Tranquility","Seismometer"},
  retro={"Tranquility","Retroreflector"},
  lrv  ={"Hadley","LunarRover"},
  oppy ={"Meridiani","Opportunity"},
  relay={"Farside","RelayConsole"},
  sojourner={"AresVallis","Sojourner"},
}
local function modelOf(id)
  local e=MODEL[id]; if not e then return nil end
  local f=game_:FindFirstChild(e[1])
  return f and f:FindFirstChild(e[2])
end
-- every one of these now has a panel in the Reactivate LocalScript
local HAS_PUZZLE={seis=true, retro=true, lrv=true, oppy=true, relay=true, sojourner=true}
local TRIGGER_RADIUS=14

local online={}        -- id -> player display name who brought it back
local inUse={}         -- id -> userId currently working it

local function snapshot()
  local s={}
  for id in pairs(HAS_PUZZLE) do s[id]=online[id] or false end
  return s
end

local function hrpOf(p)
  local c=p.Character
  return c and c:FindFirstChild("HumanoidRootPart")
end

local function openFor(player,id)
  if type(id)~="string" or not HAS_PUZZLE[id] then return end
  if online[id] then
    Notice:FireClient(player,(id=="relay") and "The link is already up." or "Already back online.",2.5)
    return
  end
  local m=modelOf(id); if not m then return end
  local a=m:FindFirstChild("Anchor"); if not a then return end
  local hrp=hrpOf(player); if not hrp then return end
  if not Rules.canTrigger(hrp.Position,a.Position,TRIGGER_RADIUS) then
    Notice:FireClient(player,"Too far from the instrument.",2.5)
    return
  end
  local got=Rules.acquireLock(inUse,id,player.UserId)
  if not got then
    Notice:FireClient(player,"Someone else is working on it.",2.5)
    return
  end
  OpenPuzzle:FireClient(player,id)
end

RequestReactivate.OnServerEvent:Connect(openFor)

SolvePuzzle.OnServerEvent:Connect(function(player,id,abandoned)
  if type(id)~="string" or not HAS_PUZZLE[id] then return end
  if inUse[id]~=player.UserId then return end
  if abandoned==true then Rules.releaseLock(inUse,id,player.UserId); return end
  if abandoned~=false or online[id] then Rules.releaseLock(inUse,id,player.UserId); return end
  local hrp=hrpOf(player)
  local m=modelOf(id)
  local anchor=m and m:FindFirstChild("Anchor")
  if not hrp or not anchor or not Rules.canTrigger(hrp.Position,anchor.Position,TRIGGER_RADIUS) then
    Rules.releaseLock(inUse,id,player.UserId); return
  end

  online[id]=player.DisplayName
  Rules.releaseLock(inUse,id,player.UserId)
  OnlineUpdate:FireAllClients(snapshot())
  for _,p in ipairs(Players:GetPlayers()) do
    if p==player then
      Notice:FireClient(p,"Experiment back online.",4)
    else
      Notice:FireClient(p,player.DisplayName.." brought an experiment back online.",4)
    end
  end
end)

-- the far-side relay console asks for its panel through ConsoleServer
task.spawn(function()
  local cs=script.Parent:WaitForChild("ConsoleServer",30)
  local ev=cs and cs:WaitForChild("OpenRelay",30)
  if not ev then warn("ReactivateServer: no OpenRelay signal") return end
  ev.Event:Connect(function(player)
    openFor(player,"relay")
  end)
end)

Players.PlayerAdded:Connect(function(p)
  task.wait(1.2)
  OnlineUpdate:FireClient(p,snapshot())
end)

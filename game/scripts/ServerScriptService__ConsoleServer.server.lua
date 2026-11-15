-- Script  ServerScriptService/ConsoleServer
-- The station consoles: the Deep Space Network link, and transit between the Moon and Mars.
-- Travel is server-authoritative: the client asks, the server moves the character.
local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local rem=RS:WaitForChild("Remotes")
local function ensure(cls,name)
  local o=rem:FindFirstChild(name)
  if o and o.ClassName~=cls then o:Destroy(); o=nil end
  if not o then o=Instance.new(cls); o.Name=name; o.Parent=rem end
  return o
end
local OpenConsole=ensure("RemoteEvent","OpenConsole")
local RequestTransit=ensure("RemoteEvent","RequestTransit")
local ArrivedAt=ensure("RemoteEvent","ArrivedAt")
-- Tells a client to drop its Eros tether BEFORE the server moves the character. A client
-- normally unclips itself when it boards, but the server must never rely on that: a rope
-- still attached when the character is moved drags it straight back to the stake.
local Unclip=ensure("RemoteEvent","Unclip")
-- server-side signal: ReactivateServer listens and runs its own range + lock checks
local OpenRelay=Instance.new("BindableEvent")
OpenRelay.Name="OpenRelay"; OpenRelay.Parent=script

local game_=workspace:WaitForChild("Game")

-- where each world drops you, and what the client should call it
local PADS={
  moon={folder="Tranquility", pos=Vector3.new(0,6,150),   title="TRANQUILITY STATION",
        sub="The Moon · Mare Tranquillitatis · outside the heritage boundary"},
  mars={folder="Meridiani",   pos=Vector3.new(20018,6,46), title="MERIDIANI PLANUM",
        sub="Mars · 1.95 S, 5.53 W · Meridiani Outpost"},
  eros={folder="Eros",        pos=Vector3.new(40010,6,12), title="433 EROS",
        sub="Asteroid · 41.626 S, 80.421 E · NEAR Shoemaker landing site"},
}

local hooked={}
local function hook(d)
  if hooked[d] or not d:IsA("ProximityPrompt") then return end
  local anc=d.Parent
  local id=anc and anc:GetAttribute("ConsoleId")
  if not id then return end
  hooked[d]=true
  d.Triggered:Connect(function(player)
    if id=="relay" then
      -- the far-side relay is a REACTIVATE panel, not a station console: hand it to
      -- ReactivateServer so it gets the same proximity check and one-player lock.
      OpenRelay:Fire(player)
      return
    end
    -- which world is this console standing in? that decides where it sends you
    local site=anc:FindFirstAncestorWhichIsA("Folder")
    local WORLD_OF={Meridiani="mars",Eros="eros"}
    local world = (site and WORLD_OF[site.Name]) or "moon"
    OpenConsole:FireClient(player,id,world)
  end)
end
for _,d in ipairs(game_:GetDescendants()) do hook(d) end
game_.DescendantAdded:Connect(hook)

local busy={}
RequestTransit.OnServerEvent:Connect(function(player,dest)
  if type(dest)~="string" or not PADS[dest] then return end
  if busy[player.UserId] then return end
  local pad=PADS[dest]
  local c=player.Character
  local hrp=c and c:FindFirstChild("HumanoidRootPart")
  if not hrp then return end
  -- Validate against the actual transit console. The client plays a short travel
  -- animation after boarding, so allow enough radius for that animation while
  -- preventing remote requests from elsewhere in the world.
  local nearestDistance
  for _,d in ipairs(game_:GetDescendants()) do
    if d:IsA("ProximityPrompt") then
      local anc=d.Parent
      local consoleId=anc and anc:GetAttribute("ConsoleId")
      if consoleId=="transit" then
        local part=anc:IsA("BasePart") and anc or anc:FindFirstChildWhichIsA("BasePart")
        if part then
          local distance=(hrp.Position-part.Position).Magnitude
          if not nearestDistance or distance<nearestDistance then nearestDistance=distance end
        end
      end
    end
  end
  if not nearestDistance or nearestDistance>28 then
    rem.Notice:FireClient(player,"Use the transit console you just boarded.",3)
    return
  end
  busy[player.UserId]=true
  local originalCharacter=c
  local ok,err=pcall(function()
    Unclip:FireClient(player)
    task.wait(0.35)
    if player.Parent and player.Character==originalCharacter then
      local current=originalCharacter:FindFirstChild("HumanoidRootPart")
      if current then current.AssemblyLinearVelocity=Vector3.zero; current.CFrame=CFrame.new(pad.pos) end
    end
    task.wait(0.1)
    if player.Parent and player.Character==originalCharacter then
      ArrivedAt:FireClient(player,dest,pad.title,pad.sub)
      for _,p in ipairs(Players:GetPlayers()) do
        if p~=player then rem.Notice:FireClient(p,player.DisplayName.." left for "..pad.title:lower()..".",3.5) end
      end
    end
  end)
  if not ok then warn("ConsoleServer transit failed: "..tostring(err)) end
  task.delay(1.5,function() busy[player.UserId]=nil end)
end)

Players.PlayerRemoving:Connect(function(p) busy[p.UserId]=nil end)
print("ConsoleServer ready")

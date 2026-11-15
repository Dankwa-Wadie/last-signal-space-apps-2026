-- LocalScript  StarterPlayerScripts/StarterPlayerScripts.Sound
-- What you would really hear.
--
-- THE MOON AND EROS are vacuum. No sound travels through the air at all -- someone a few
-- feet away could drop a rock and you would hear nothing. Inside the suit you hear the
-- life-support fan, your own breathing, the radio, and your footsteps as muffled thuds that
-- come up through your boots and the suit itself, not through air.
--
-- MARS has air, but about 100x thinner than Earth's. Measured by Perseverance's microphones
-- (Maurice et al., Nature 2022): sound is ~20 dB weaker; the thin CO2 cuts high pitches, so
-- everything is muffled and bass-heavy; a voice that carries ~60 m on Earth fades out after
-- ~8 m; the wind is a "thick, burbling murmur". There are even two speeds of sound: ~240 m/s
-- below 240 Hz and ~250 m/s above it.
--
-- Roblox's default character sounds (airborne footsteps, jump and landing thumps) assume
-- air, so they are switched off -- see the empty RbxCharacterSounds script.
local Players=game:GetService("Players")
local RS=game:GetService("RunService")
local TS=game:GetService("TweenService")
local SoundService=game:GetService("SoundService")
local RSrv=game:GetService("ReplicatedStorage")
local plr=Players.LocalPlayer
local rem=RSrv:WaitForChild("Remotes")

local ID={
  breathing="rbxassetid://130315519842005",   -- "Breathing in space helmet"
  fan      ="rbxassetid://123914301138193",   -- air fan hum loop  -> the PLSS fan
  step     ="rbxassetid://98912102275037",    -- sand footstep, filtered into a boot thud
  wind     ="rbxassetid://9113286969",        -- Pro Sound Effects, light blustery wind
  quindar  ="rbxassetid://320994270",         -- Apollo's Quindar tone
}

local function group(name,vol)
  local g=SoundService:FindFirstChild(name) or Instance.new("SoundGroup")
  g.Name=name; g.Volume=vol; g.Parent=SoundService
  return g
end
local SUIT=group("Suit",1)
local OUTSIDE=group("Outside",1)

local function eq(parent,low,mid,high)
  local e=Instance.new("EqualizerSoundEffect")
  e.LowGain=low; e.MidGain=mid; e.HighGain=high; e.Parent=parent
  return e
end
local function sound(name,id,vol,looped,grp)
  local s=Instance.new("Sound")
  s.Name=name; s.SoundId=id; s.Volume=vol; s.Looped=looped and true or false
  s.SoundGroup=grp; s.Parent=SoundService
  return s
end

-- ---------- inside the suit: always ----------
local fan=sound("PLSSFan",ID.fan,0.10,true,SUIT)
eq(fan,2,-6,-14)                         -- a soft, low hum, not a desk fan
local breath=sound("Breathing",ID.breathing,0.16,true,SUIT)
eq(breath,0,-2,-8)

-- footsteps: conducted through the boots and suit, so all body and no bite
local stepPool={}
for i=1,3 do
  local s=sound("Step"..i,ID.step,0.5,false,SUIT)
  s.PlaybackSpeed=0.72                   -- heavier, deeper
  local e=eq(s,6,-12,-40)                -- strip the high crunch you would only hear in air
  stepPool[i]={s,e}
end

-- ---------- outside: Mars only ----------
local wind=sound("MarsWind",ID.wind,0,true,OUTSIDE)
eq(wind,6,-10,-40)                       -- thin air drops the highs: a muffled, bass-heavy murmur

-- the radio
local quindar=sound("Quindar",ID.quindar,0.35,false,SUIT)

-- ---------- which world ----------
local WL=require(game:GetService("ReplicatedStorage"):WaitForChild("WorldLayout"))
local function onMars()
  local c=plr.Character
  local hrp=c and c:FindFirstChild("HumanoidRootPart")
  return hrp and WL.worldAt(hrp.Position)=="mars"
end

local mars=false
local function setWorld(isMars)
  if isMars==mars then return end
  mars=isMars
  -- vacuum is total silence outside the suit; Mars has a faint, gusting murmur
  TS:Create(wind,TweenInfo.new(2.5),{Volume=isMars and 0.22 or 0}):Play()
  for _,t in ipairs(stepPool) do
    -- a little air on Mars lets a touch more of the step through
    t[2].HighGain=isMars and -28 or -40
    t[1].Volume=isMars and 0.6 or 0.5
  end
end

fan:Play(); breath:Play(); wind:Play()
-- gusts: the wind rises and falls rather than droning
task.spawn(function()
  while true do
    task.wait(3+math.random()*5)
    if mars then
      local v=0.12+math.random()*0.2
      TS:Create(wind,TweenInfo.new(1.5+math.random()*2,Enum.EasingStyle.Sine),{Volume=v}):Play()
    end
  end
end)

-- footstep timing: a slow lunar lope, a bit brisker on Mars
local acc,idx=0,1
RS.Heartbeat:Connect(function(dt)
  local c=plr.Character
  local h=c and c:FindFirstChildOfClass("Humanoid")
  if not h then return end
  local moving=h.MoveDirection.Magnitude>0.1 and h.FloorMaterial~=Enum.Material.Air
  if true then return end  -- footsteps removed at the team's request (v132)
  if not moving then acc=0.4 return end
  acc+=dt
  local gap=mars and 0.46 or 0.58
  if acc>=gap then
    acc=0
    local s=stepPool[idx][1]
    s.PlaybackSpeed=0.68+math.random()*0.1
    s:Play()
    idx=idx%#stepPool+1
  end
end)

-- world check, twice a second (cheap)
task.spawn(function()
  while true do
    setWorld(onMars() and true or false)
    task.wait(0.5)
  end
end)

-- anything that speaks on the radio can ask for the tone first
rem:WaitForChild("RadioBeep").Event:Connect(function()
  quindar:Play()
end)

-- Roblox still gives every character its stock sounds (flat-ground plastic footsteps, jump,
-- landing). There is no air on the Moon or Eros to carry them, and they never matched a
-- low-gravity hop, so silence them on every character, ours and other players'.
local STOCK={Running=true,Jumping=true,Landing=true,Climbing=true,FreeFalling=true,GettingUp=true,Splash=true,Swimming=true,Died=true}
local function hush(s)
  if s:IsA("Sound") and STOCK[s.Name] and s.Parent and s.Parent.Name=="HumanoidRootPart" then
    s.Volume=0
    s:GetPropertyChangedSignal("Volume"):Connect(function() if s.Volume~=0 then s.Volume=0 end end)
  end
end
local function watchChar(c)
  if not c then return end
  for _,d in ipairs(c:GetDescendants()) do hush(d) end
  c.DescendantAdded:Connect(hush)
end
local function watchPlayer(p) watchChar(p.Character); p.CharacterAdded:Connect(watchChar) end
for _,p in ipairs(game:GetService("Players"):GetPlayers()) do watchPlayer(p) end
game:GetService("Players").PlayerAdded:Connect(watchPlayer)

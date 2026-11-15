-- LocalScript  StarterPlayerScripts/StarterPlayerScripts.Worlds
-- Two worlds in one place. Mars sits far from the Moon sites on the same baseplate, so:
--   * gravity is corrected per player with a VectorForce (workspace.Gravity is global, and
--     the lunar value is already tuned and play-tested -- do not touch it),
--   * the sky, fog and light are restyled client-side, which only this player sees,
--   * arriving anywhere plays the same ARRIVE beat.
-- The DSN console and the transit module live here too.
local Players=game:GetService("Players")
local RS=game:GetService("RunService")
local TS=game:GetService("TweenService")
local UIS=game:GetService("UserInputService")
local RSrv=game:GetService("ReplicatedStorage")
local L=game:GetService("Lighting")
local plr=Players.LocalPlayer
local pg=plr:WaitForChild("PlayerGui")
local rem=RSrv:WaitForChild("Remotes")
local OpenConsole=rem:WaitForChild("OpenConsole")
local RequestTransit=rem:WaitForChild("RequestTransit")
local ArrivedAt=rem:WaitForChild("ArrivedAt")

local YEL=Color3.fromRGB(245,231,60)
local CYAN=Color3.fromRGB(150,205,255)
local DIM=Color3.fromRGB(154,160,166)
local function mk(c,p,par) local o=Instance.new(c)
  for k,v in pairs(p) do o[k]=v end
  -- A UIStroke on a text object outlines the letters, not the box. We always mean the box.
  if c=="UIStroke" and p.ApplyStrokeMode==nil and par
     and (par:IsA("TextButton") or par:IsA("TextLabel") or par:IsA("TextBox")) then
    o.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
  end
  o.Parent=par return o end

-- ---------- which world am I standing in ----------
local WL=require(game:GetService("ReplicatedStorage"):WaitForChild("WorldLayout"))
local world="moon"
local function worldAt(p) return WL.worldAt(p) end

-- Roblox gravity is 196.2 studs/s^2 for 9.81 m/s^2. The game runs the Moon at a stylised
-- 16.2 (half true scale) because it feels right and is tested; Mars keeps the real 2.3x
-- ratio to the Moon, so 37.
-- Eros: the real figure is 0.0059 m/s^2, about 1/275 of the Moon's. At the game's lunar
-- scale that would be 0.06 studs/s^2 and a single hop would leave the map, so it is set to
-- 1.8 -- still unmistakably floaty -- and the tether keeps you from drifting off. The sign
-- at the site says plainly that it is exaggerated.
-- Jump targets use observed suited-locomotion evidence where available:
--  Moon: Apollo 16 astronaut Charlie Duke reached about 2.7 ft (0.82 m) in a
--  high jump, then fell backward. At 1.62 m/s^2 ideal airtime at this height is
--  about 2.0 s. This was a single high jump, not a recommended routine stride.
--  Mars: no human has performed a suited surface jump there. 0.55 m is a clearly
--  labelled gameplay estimate, not a measured or validated human-performance value.
-- Roblox gravity and stud-to-metre scaling are stylized, so these are tuning targets,
-- not a validated biomechanical simulation. Eros stays exaggerated, as its sign says.
local G={moon=4.5, mars=10.3, eros=1.8}
local JUMP={moon=4.5, mars=5.6, eros=10}
local vf,att=nil,nil
local function applyGravity(c)
  local hrp=c and c:FindFirstChild("HumanoidRootPart")
  if not hrp then return end
  if not att or att.Parent~=hrp then
    if vf then vf:Destroy() end
    if att then att:Destroy() end
    att=Instance.new("Attachment"); att.Name="WorldG"; att.Parent=hrp
    vf=Instance.new("VectorForce"); vf.Name="WorldGravity"; vf.Attachment0=att
    vf.RelativeTo=Enum.ActuatorRelativeTo.World
    vf.ApplyAtCenterOfMass=true; vf.Parent=hrp
  end
  local extra=(G[world] or 16.2)-workspace.Gravity
  vf.Force=Vector3.new(0,-hrp.AssemblyMass*extra,0)
end

-- ---------- Eros: softer jumps, and the tether ----------
local jumpConn,jumpHum=nil,nil
local function setJump()
  local c=plr.Character; local h=c and c:FindFirstChildOfClass("Humanoid")
  if not h then return end
  local function apply()
    -- 0 means a scene has frozen the player; leave that alone
    if h.JumpPower~=0 and h.JumpPower~=JUMP[world] then h.UseJumpPower=true; h.JumpPower=JUMP[world] end
  end
  apply()
  if jumpHum~=h then
    if jumpConn then jumpConn:Disconnect() end
    jumpHum=h; jumpConn=h:GetPropertyChangedSignal("JumpPower"):Connect(apply)
  end
end

-- A safety line from your suit to the stake by NEAR. Built on this client only: the
-- character is simulated here, so the rope holds you here, and nobody else pays for it.
local tether=nil
local function setTether(on)
  if tether then
    for _,o in ipairs(tether) do if o and o.Parent then o:Destroy() end end
    tether=nil
  end
  if not on then return end
  local c=plr.Character; local hrp=c and c:FindFirstChild("HumanoidRootPart")
  local site=workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Eros")
  local stake=site and site:FindFirstChild("TetherStake")
  local clip=stake and stake:FindFirstChild("Clip")
  if not (hrp and clip) then return end     -- not streamed in yet: the loop will retry
  local a0=Instance.new("Attachment"); a0.Name="TetherHarness"
  a0.Position=Vector3.new(0,0.4,0.6); a0.Parent=hrp
  local a1=Instance.new("Attachment"); a1.Name="TetherClip"; a1.Parent=clip
  local rope=Instance.new("RopeConstraint")
  rope.Attachment0=a0; rope.Attachment1=a1
  rope.Length=72; rope.Visible=true; rope.Thickness=0.12
  rope.Color=BrickColor.new("New Yeller")
  rope.Parent=hrp
  tether={rope,a0,a1}
end

-- ---------- per-world look (client-only: nobody else sees these changes) ----------
local SAVED={Ambient=L.Ambient,OutdoorAmbient=L.OutdoorAmbient,Brightness=L.Brightness,
  FogColor=L.FogColor,FogEnd=L.FogEnd,FogStart=L.FogStart,ClockTime=L.ClockTime}
local function dressFor(w)
  if w=="mars" then
    L.Ambient=Color3.fromRGB(70,44,30)
    L.OutdoorAmbient=Color3.fromRGB(104,68,44)
    L.Brightness=2.4
    L.FogColor=Color3.fromRGB(176,124,80)
    L.FogStart=90; L.FogEnd=620           -- Mars has air, and it is full of dust
  else
    L.Ambient=SAVED.Ambient
    L.OutdoorAmbient=SAVED.OutdoorAmbient
    L.Brightness=SAVED.Brightness
    L.FogColor=SAVED.FogColor
    L.FogStart=SAVED.FogStart; L.FogEnd=9e9   -- vacuum: nothing to scatter light
  end
end

-- (v138) which parts are drawn is now handled by the Ground script: other worlds are
-- 20,000 studs away, and on your own world only what is above your horizon is drawn.
local function hideOtherWorlds() end
local function enterWorld(w)
  world=w
  dressFor(w)            -- Eros is airless, so it dresses like the Moon
  applyGravity(plr.Character)
  setJump()
  hideOtherWorlds(w)
  setTether(w=="eros")
end

-- ---------- ARRIVE beat ----------
local arr=mk("ScreenGui",{Name="Arrive",ResetOnSpawn=false,IgnoreGuiInset=true,
  Enabled=false,DisplayOrder=12},pg)
local veil=mk("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(0,0,0),
  BorderSizePixel=0},arr)
local aTitle=mk("TextLabel",{Size=UDim2.new(1,-80,0,46),Position=UDim2.new(0,40,0.42,0),
  BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=34,TextColor3=Color3.new(1,1,1),
  Text="",TextXAlignment=Enum.TextXAlignment.Left},arr)
local aSub=mk("TextLabel",{Size=UDim2.new(1,-80,0,26),Position=UDim2.new(0,40,0.42,50),
  BackgroundTransparency=1,Font=Enum.Font.GothamMedium,TextSize=16,TextColor3=YEL,
  Text="",TextXAlignment=Enum.TextXAlignment.Left},arr)

local function arrive(title,sub)
  aTitle.Text=title; aSub.Text=sub
  veil.BackgroundTransparency=0
  arr.Enabled=true
  task.wait(1.6)
  TS:Create(veil,TweenInfo.new(1.6),{BackgroundTransparency=1}):Play()
  TS:Create(aTitle,TweenInfo.new(1.2),{TextTransparency=1}):Play()
  TS:Create(aSub,TweenInfo.new(1.2),{TextTransparency=1}):Play()
  task.wait(1.7)
  arr.Enabled=false
  aTitle.TextTransparency=0; aSub.TextTransparency=0
end

-- the server is about to move us: let go of the stake first
local unclipUntil=0
rem:WaitForChild("Unclip").OnClientEvent:Connect(function()
  setTether(false)
  unclipUntil=os.clock()+3      -- and do not re-clip while still standing at the old site
end)

ArrivedAt.OnClientEvent:Connect(function(dest,title,sub)
  enterWorld(dest)
  arrive(title,sub)
end)

-- keep the world right even if the player walks, falls or respawns
task.spawn(function()
  while true do
    task.wait(0.5)
    local c=plr.Character
    local hrp=c and c:FindFirstChild("HumanoidRootPart")
    if hrp then
      local w=worldAt(hrp.Position)
      if w~=world then enterWorld(w) end
      applyGravity(c); setJump()
      -- the stake may not have streamed in on arrival; keep trying until it has
      if world=="eros" and not tether and os.clock()>unclipUntil then setTether(true) end
    end
  end
end)
plr.CharacterAdded:Connect(function(c)
  -- a new body: the old harness and jump settings went with the old one
  setTether(false)
  task.wait(0.6); applyGravity(c)
end)
dressFor("moon")

-- ============================================================
--  CONSOLES
-- ============================================================
local gui=mk("ScreenGui",{Name="Console",ResetOnSpawn=false,IgnoreGuiInset=true,
  Enabled=false,DisplayOrder=11},pg)
mk("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(0,0,0),
  BackgroundTransparency=0.35,BorderSizePixel=0},gui)
local panel=mk("Frame",{Size=UDim2.fromOffset(660,470),AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),
  BackgroundColor3=Color3.fromRGB(8,8,10),BorderSizePixel=0},gui)
mk("UICorner",{CornerRadius=UDim.new(0,10)},panel)
mk("UIStroke",{Color=Color3.fromRGB(60,64,72),Thickness=1},panel)
local pscale=mk("UIScale",{},panel)
local function pfit()
  local vp=workspace.CurrentCamera.ViewportSize
  pscale.Scale=math.min(1,(vp.X-20)/660,(vp.Y-20)/470)
end
pfit(); workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(pfit)

local cKicker=mk("TextLabel",{Size=UDim2.fromOffset(600,20),Position=UDim2.fromOffset(22,16),
  BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=13,TextColor3=CYAN,
  TextXAlignment=Enum.TextXAlignment.Left,Text=""},panel)
local cTitle=mk("TextLabel",{Size=UDim2.fromOffset(600,32),Position=UDim2.fromOffset(22,36),
  BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=25,TextColor3=Color3.new(1,1,1),
  TextXAlignment=Enum.TextXAlignment.Left,Text=""},panel)
local cBody=mk("TextLabel",{Size=UDim2.fromOffset(616,250),Position=UDim2.fromOffset(22,76),
  BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=14,TextColor3=Color3.fromRGB(210,210,215),
  TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,
  Text=""},panel)
local cBig=mk("TextLabel",{Size=UDim2.fromOffset(616,40),Position=UDim2.fromOffset(22,332),
  BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=22,TextColor3=YEL,
  TextXAlignment=Enum.TextXAlignment.Left,Text=""},panel)
local cBtn=mk("TextButton",{Size=UDim2.fromOffset(616,44),Position=UDim2.fromOffset(22,382),
  BackgroundColor3=Color3.fromRGB(70,64,20),AutoButtonColor=true,Font=Enum.Font.GothamBold,
  TextSize=16,TextColor3=YEL,Text=""},panel)
mk("UICorner",{CornerRadius=UDim.new(0,8)},cBtn)

mk("TextLabel",{Size=UDim2.fromOffset(616,20),Position=UDim2.fromOffset(22,434),
  BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=12,TextColor3=DIM,
  TextXAlignment=Enum.TextXAlignment.Left,Text="[ Q ]  step back"},panel)

local busy=false
local function closeConsole()
  gui.Enabled=false
  local c=plr.Character; local h=c and c:FindFirstChildOfClass("Humanoid")
  if h and not busy then h.WalkSpeed=11 end
end

-- ---------- Voyager: the light-day countdown ----------
-- NASA: Voyager 1 passes one light-day from Earth on 18 Nov 2026, 02:16:07 PST
-- (= 10:16:07 UTC), at 16.094 billion miles / 25.902 billion km.
local LIGHTDAY=DateTime.fromIsoDate("2026-11-18T10:16:07Z").UnixTimestamp
local function dsnText()
  local now=DateTime.now().UnixTimestamp
  local d=LIGHTDAY-now
  if d>0 then
    local days=math.floor(d/86400)
    local hrs=math.floor((d%86400)/3600)
    local mins=math.floor((d%3600)/60)
    return ("ONE LIGHT-DAY IN  %dd %02dh %02dm"):format(days,hrs,mins)
  end
  return "ONE LIGHT-DAY: PASSED. The first object we made to get that far."
end

local function openDSN()
  cKicker.Text="DEEP SPACE NETWORK  ·  LINK ESTABLISHED"
  cTitle.Text="Voyager 1"
  cBody.Text=
    "Launched 5 September 1977. It flew past Jupiter and Saturn by 1980 and has been "..
    "leaving ever since. In August 2012 it crossed the heliopause into interstellar space, "..
    "the first human-made object to do so.\n\n"..
    "Two of its ten instruments are still on — the magnetometer and the plasma wave "..
    "instrument. Its generator loses about 4 watts a year, so the team switches instruments "..
    "off one at a time to keep the rest alive.\n\n"..
    "It carries a gold-plated record of sounds and pictures from Earth, in case anyone ever "..
    "finds it.\n\n"..
    "Pioneer 10 went silent in 2003 and Pioneer 11 in 1995. They are still out there too, "..
    "heading the other way. Nothing is wrong with them either. They simply ran out of power."
  cBig.Text=dsnText()
  cBtn.Text="SEND A PING"
  cBtn.Active=true
  gui.Enabled=true
end

local pinging=false
local function ping()
  if pinging then return end
  pinging=true
  cBtn.Text="SENT"
  cBtn.Active=false
  local steps={
    {"Command away. Climbing out of the solar system at 17 km/s...",1.6},
    {"Round-trip light time: about 46 hours. The clock below runs at x20,000 — "..
     "real time would take you two days.",2.6},
    {"...",1.4},
    {"Carrier detected. Signal strength: less than a billionth of a billionth of a watt.",2.4},
    {"It answered.",2.0},
  }
  for _,s in ipairs(steps) do
    cBig.Text=s[1]
    task.wait(s[2])
  end
  cBig.TextColor3=Color3.fromRGB(120,230,150)
  cBig.Text="Nothing is broken. It is just very far away."
  task.wait(3)
  cBig.TextColor3=YEL
  cBig.Text=dsnText()
  cBtn.Text="SEND A PING"
  cBtn.Active=true
  pinging=false
end

-- ---------- transit ----------
-- ============================================================
--  TRANSIT: a destination picker
--  Built to the figma-to-roblox-ui rules (via UIKit): Scale only, centred anchors, scaled
--  corners/strokes/text, proportions held by an aspect constraint. Design frame 1280x720,
--  panel 900x540. Replaces a panel that was mostly paragraphs.
-- ============================================================
local UI=require(RSrv:WaitForChild("UIKit"))
local DEST={
  moon={name="THE MOON",place="Tranquility Station",time="3 days",note="about as long as Apollo took",
    steps={"launch","day 1","day 2","approach"},
    c1=Color3.fromRGB(196,196,200),c2=Color3.fromRGB(104,104,112)},
  mars={name="MARS",place="Meridiani Planum",time="7 months",note="only when the planets line up",
    steps={"launch","1 month","2 months","3 months","4 months","5 months","6 months","approach"},
    c1=Color3.fromRGB(222,124,74),c2=Color3.fromRGB(128,54,30)},
  eros={name="EROS",place="NEAR Shoemaker",time="4 years",note="NEAR's looping route there",
    steps={"launch","year 1","year 2","year 3","rendezvous"},
    c1=Color3.fromRGB(168,146,118),c2=Color3.fromRGB(88,74,60)},
}
local ORDER={"moon","mars","eros"}
local SW,SH,W,H=1280,720,900,540
local INKC=Color3.fromRGB(10,11,14)
local EDGE=Color3.fromRGB(64,68,78)

local tg=UI.new("ScreenGui",{Name="Transit",ResetOnSpawn=false,IgnoreGuiInset=true,Enabled=false,
  DisplayOrder=11,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
  ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets},pg)
local tdim=UI.new("Frame",{Name="Dim",BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=0.3,
  BorderSizePixel=0},tg)
UI.place(tdim,0,0,SW,SH,SW,SH)
-- 2.5x the frame so it covers any screen shape, centred
tdim.Size=UDim2.fromScale(2.5,2.5)
local tp=UI.new("Frame",{Name="Panel",BackgroundColor3=INKC,BorderSizePixel=0},tg)
tp:SetAttribute("LayoutRoot",true)
UI.place(tp,(SW-W)/2,(SH-H)/2,W,H,SW,SH)
UI.aspect(tp,W,H)            -- FitWithinMaxSize: always fits the screen, never stretches
UI.corner(tp,18,W,H)
UI.stroke(tp,1.5,W,H,EDGE)

UI.label(tp,"Kicker","TRANSIT  ·  DEPARTURES",Enum.Font.GothamBold,CYAN,14,40,30,500,20,W,H)
UI.label(tp,"Heading","Where to?",Enum.Font.GothamBold,Color3.new(1,1,1),34,40,54,500,44,W,H)
local tclose=UI.new("TextButton",{Name="Close",BackgroundColor3=Color3.fromRGB(30,32,38),
  AutoButtonColor=true,Font=Enum.Font.GothamBold,TextColor3=YEL,Text="X"},tp)
UI.place(tclose,836,26,40,40,W,H); UI.corner(tclose,20,40,40); UI.text(tclose,15)
UI.new("UIPadding",{PaddingTop=UDim.new(0.22,0),PaddingBottom=UDim.new(0.22,0)},tclose)
UI.aspect(tclose,1,1)

local cards={}
local CWd,CHd=256,326
for i,key in ipairs(ORDER) do
  local d=DEST[key]
  local x=40+(i-1)*(CWd+26)
  local cd=UI.new("Frame",{Name="Card_"..key,BackgroundColor3=Color3.fromRGB(20,22,27),BorderSizePixel=0},tp)
  UI.place(cd,x,116,CWd,CHd,W,H); UI.corner(cd,14,CWd,CHd)
  local cs=UI.stroke(cd,1.5,CWd,CHd,EDGE)
  -- the world itself: a lit disc, not a word
  local disc=UI.new("Frame",{Name="World",BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0},cd)
  UI.place(disc,62,22,132,132,CWd,CHd); UI.corner(disc,66,132,132); UI.aspect(disc,1,1)
  UI.new("UIGradient",{Rotation=135,Color=ColorSequence.new(d.c1,d.c2)},disc)
  UI.label(cd,"Name",d.name,Enum.Font.GothamBold,Color3.new(1,1,1),22,14,166,CWd-28,28,CWd,CHd,Enum.TextXAlignment.Center)
  UI.label(cd,"Place",d.place,Enum.Font.GothamMedium,CYAN,13,14,194,CWd-28,18,CWd,CHd,Enum.TextXAlignment.Center)
  UI.label(cd,"Time",d.time,Enum.Font.GothamBold,YEL,26,14,214,CWd-28,32,CWd,CHd,Enum.TextXAlignment.Center)
  UI.label(cd,"Note",d.note,Enum.Font.Gotham,Color3.fromRGB(150,156,164),12,14,246,CWd-28,18,CWd,CHd,Enum.TextXAlignment.Center)
  local go=UI.new("TextButton",{Name="Go",AutoButtonColor=true,Font=Enum.Font.GothamBold,
    BackgroundColor3=Color3.fromRGB(70,64,20),TextColor3=YEL,Text="GO"},cd)
  UI.place(go,24,270,CWd-48,42,CWd,CHd); UI.corner(go,10,CWd-48,42); UI.text(go,13)
  UI.new("UIPadding",{PaddingTop=UDim.new(0.24,0),PaddingBottom=UDim.new(0.24,0),PaddingLeft=UDim.new(0.08,0),PaddingRight=UDim.new(0.08,0)},go)
  cards[key]={card=cd,stroke=cs,go=go,disc=disc}
end

local tfoot=UI.label(tp,"Footer","Every crossing is compressed — a few seconds stand in for days, months or years.",
  Enum.Font.Gotham,Color3.fromRGB(150,156,164),13,40,458,820,22,W,H)
local track=UI.new("Frame",{Name="Track",BackgroundColor3=Color3.fromRGB(30,32,38),BorderSizePixel=0,Visible=false},tp)
UI.place(track,40,494,820,14,W,H); UI.corner(track,7,820,14)
local fill=UI.new("Frame",{Name="Fill",BackgroundColor3=YEL,BorderSizePixel=0},track)
fill:SetAttribute("AnchorReason","progress fill grows from the left")
fill.AnchorPoint=Vector2.new(0,0.5); fill.Position=UDim2.fromScale(0,0.5); fill.Size=UDim2.fromScale(0,1)
UI.corner(fill,7,820,14)

local here="moon"
local function setWalk(n)
  local c=plr.Character; local h=c and c:FindFirstChildOfClass("Humanoid")
  if h then h.WalkSpeed=n end
end
local function closeTransit()
  if busy then return end
  tg.Enabled=false
  setWalk(11)
end
tclose.MouseButton1Click:Connect(closeTransit)

local function openTransit(fromWorld)
  here=fromWorld or "moon"
  for key,c in pairs(cards) do
    local isHere=(key==here)
    c.go.Text=isHere and "YOU ARE HERE" or "GO"
    c.go.Active=not isHere
    c.go.AutoButtonColor=not isHere
    c.go.BackgroundColor3=isHere and Color3.fromRGB(34,36,42) or Color3.fromRGB(70,64,20)
    c.go.TextColor3=isHere and Color3.fromRGB(130,136,146) or YEL
    c.stroke.Color=isHere and Color3.fromRGB(110,116,126) or EDGE
    c.card.BackgroundTransparency=isHere and 0.35 or 0
  end
  tfoot.Text="Every crossing is compressed — a few seconds stand in for days, months or years."
  track.Visible=false; fill.Size=UDim2.fromScale(0,1)
  tg.Enabled=true
end

local function doTransit(dest)
  if busy or dest==here or not DEST[dest] then return end
  busy=true
  for _,c in pairs(cards) do c.go.Active=false end
  setWalk(0)
  -- unclip first, or the line would drag you straight back across the solar system
  setTether(false)
  track.Visible=true
  local steps=DEST[dest].steps
  for i,m in ipairs(steps) do
    tfoot.Text=("TO %s  ·  %s  ·  compressed"):format(DEST[dest].name,m)
    TS:Create(fill,TweenInfo.new(0.32),{Size=UDim2.fromScale(i/#steps,1)}):Play()
    task.wait(0.38)
  end
  tfoot.Text="ARRIVAL"
  tg.Enabled=false
  RequestTransit:FireServer(dest)
  task.wait(2.2)
  busy=false
  setWalk(11)
end
for key,c in pairs(cards) do
  c.go.MouseButton1Click:Connect(function() doTransit(key) end)
end
-- Studio only: a test hook that runs exactly what a GO click runs. Tooling can't send real
-- clicks, and this never exists in a live game.
if game:GetService("RunService"):IsStudio() then
  local hook=Instance.new("BindableEvent"); hook.Name="_StudioTest"; hook.Parent=tg
  hook.Event:Connect(function(dest) task.spawn(doTransit,dest) end)
end

-- the old panel is the DSN radio only now
cBtn.MouseButton1Click:Connect(function() task.spawn(ping) end)

OpenConsole.OnClientEvent:Connect(function(id,fromWorld)
  if busy then return end
  local c=plr.Character; local h=c and c:FindFirstChildOfClass("Humanoid")
  if h then h.WalkSpeed=0 end
  cBig.TextColor3=YEL
  if id=="dsn" then openDSN() else openTransit(fromWorld) end
end)

UIS.InputBegan:Connect(function(i,gpe)
  if gpe then return end
  if i.KeyCode==Enum.KeyCode.Q and gui.Enabled and not busy then closeConsole() end
  if i.KeyCode==Enum.KeyCode.Q and tg.Enabled then closeTransit() end
end)
rem:WaitForChild("LocalKey").Event:Connect(function(code,phase)
  if code==Enum.KeyCode.Q and phase~="up" and gui.Enabled and not busy then closeConsole() end
  if code==Enum.KeyCode.Q and phase~="up" and tg.Enabled then closeTransit() end
end)

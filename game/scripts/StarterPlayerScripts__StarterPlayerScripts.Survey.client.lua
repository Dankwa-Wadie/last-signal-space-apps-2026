-- LocalScript  StarterPlayerScripts/StarterPlayerScripts.Survey
-- LAST SIGNAL : client view. The server owns the log; this only renders.
local Players=game:GetService("Players")
local TS=game:GetService("TweenService")
local UIS=game:GetService("UserInputService")
local RSrv=game:GetService("ReplicatedStorage")
local L=game:GetService("Lighting")
local plr=Players.LocalPlayer
local pg=plr:WaitForChild("PlayerGui")

local rem=RSrv:WaitForChild("Remotes")
local ShowCard=rem:WaitForChild("ShowCard")
local LogUpdate=rem:WaitForChild("LogUpdate")
local RequestRemember=rem:WaitForChild("RequestRemember")
local PlayVignette=rem:WaitForChild("PlayVignette")
local Notice=rem:WaitForChild("Notice")

local site=workspace:WaitForChild("Game"):WaitForChild("Tranquility")
local IDX=require(RSrv:WaitForChild("ArtifactIndex"))
local ORDER,SHORT,SITEOF=IDX.ORDER,IDX.SHORT,IDX.SITEOF
local ONLINE_LABEL=IDX.ONLINE_LABEL
local current=nil
local busy=false
local PUZZLE=IDX.PUZZLE
-- the relay console is its own object, reached with F from the Ranger 4 card
local RELAY_SITE={ranger4=true}

local YEL=Color3.fromRGB(245,231,60)
local function mk(cls,props,parent)
  local o=Instance.new(cls)
  for k,v in pairs(props) do o[k]=v end
  -- A UIStroke on a text object outlines the letters, not the box. We always mean the box.
  if cls=="UIStroke" and props.ApplyStrokeMode==nil and parent
     and (parent:IsA("TextButton") or parent:IsA("TextLabel") or parent:IsA("TextBox")) then
    o.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
  end
  o.Parent=parent; return o
end

local gui=mk("ScreenGui",{Name="HUD",ResetOnSpawn=false,IgnoreGuiInset=true},pg)

local log=mk("Frame",{Size=UDim2.fromOffset(300,120),Position=UDim2.fromOffset(28,28),
  BackgroundColor3=Color3.fromRGB(8,8,10),BackgroundTransparency=0.25,BorderSizePixel=0},gui)
mk("UICorner",{CornerRadius=UDim.new(0,8)},log)
mk("TextLabel",{Size=UDim2.new(1,-20,0,22),Position=UDim2.fromOffset(12,8),BackgroundTransparency=1,
  Font=Enum.Font.GothamBold,TextSize=13,TextColor3=YEL,
  TextXAlignment=Enum.TextXAlignment.Left,Text="ASTROLOG"},log)
log.Visible=false   -- replaced by the Logbook pill; kept only to drive the ending
local logList=mk("TextLabel",{Size=UDim2.new(1,-20,1,-36),Position=UDim2.fromOffset(12,30),
  BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=13,
  TextColor3=Color3.fromRGB(205,205,210),TextXAlignment=Enum.TextXAlignment.Left,
  TextYAlignment=Enum.TextYAlignment.Top,Text=""},log)

local card=mk("Frame",{Size=UDim2.fromOffset(430,0),Position=UDim2.new(1,-460,0,28),
  BackgroundColor3=Color3.fromRGB(8,8,10),BackgroundTransparency=0.15,BorderSizePixel=0,
  Visible=false,ClipsDescendants=true},gui)
mk("UICorner",{CornerRadius=UDim.new(0,8)},card)
local pad=mk("Frame",{Size=UDim2.new(1,-32,1,-28),Position=UDim2.fromOffset(16,14),
  BackgroundTransparency=1},card)
local lay=mk("UIListLayout",{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},pad)
local function row(f,sz,col,order)
  return mk("TextLabel",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
    BackgroundTransparency=1,Font=f,TextSize=sz,TextColor3=col,TextWrapped=true,
    TextXAlignment=Enum.TextXAlignment.Left,Text="",LayoutOrder=order},pad)
end
-- the card leads with the object itself, turning slowly, rather than a block of prose
local MODELS=RSrv:WaitForChild("TrophyModels",20)
local cardVp=mk("ViewportFrame",{Size=UDim2.new(1,0,0,150),BackgroundColor3=Color3.fromRGB(11,13,17),
  BorderSizePixel=0,LayoutOrder=0,Ambient=Color3.fromRGB(150,150,160),
  LightColor=Color3.fromRGB(255,250,240),LightDirection=Vector3.new(-0.4,-1,-0.6)},pad)
mk("UICorner",{CornerRadius=UDim.new(0,8)},cardVp)
local cardSpin=nil
local function mountCard(id)
  for _,c in ipairs(cardVp:GetChildren()) do
    if not c:IsA("UICorner") then c:Destroy() end
  end
  cardSpin=nil
  local src=MODELS and MODELS:FindFirstChild(id)
  if not src then cardVp.Visible=false return end
  cardVp.Visible=true
  local m=src:Clone(); m.Parent=cardVp
  local cam=Instance.new("Camera"); cam.Parent=cardVp; cardVp.CurrentCamera=cam
  local extent=src:GetAttribute("Extent") or 10
  cardSpin={cam=cam,dist=math.max(2.5,extent*0.95)}
end
local cardAcc=0
game:GetService("RunService").RenderStepped:Connect(function(dt)
  cardAcc+=dt
  if cardAcc<1/24 then return end
  cardAcc=0
  if cardSpin and card.Visible then
    local a=tick()*0.4
    cardSpin.cam.CFrame=CFrame.new(
      Vector3.new(math.sin(a)*cardSpin.dist,cardSpin.dist*0.4,math.cos(a)*cardSpin.dist),
      Vector3.new(0,0,0))
  end
end)

local cTitle=row(Enum.Font.GothamBold,19,Color3.new(1,1,1),1)
local cYear =row(Enum.Font.GothamMedium,13,YEL,2)
local cWhat =row(Enum.Font.Gotham,14,Color3.fromRGB(210,210,215),3)
local cWhy  =row(Enum.Font.Gotham,14,Color3.fromRGB(210,210,215),4)
local cSci  =row(Enum.Font.GothamMedium,14,Color3.fromRGB(150,205,255),5)
local cHint =row(Enum.Font.GothamBold,13,YEL,6)

local toast=mk("TextLabel",{Size=UDim2.new(0,820,0,44),Position=UDim2.new(0.5,-410,0.76,0),
  BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=24,TextColor3=YEL,
  TextStrokeTransparency=0.15,TextStrokeColor3=Color3.new(0,0,0),Text="",TextWrapped=true},gui)

local toastToken=0
local function say(t,secs)
  toastToken+=1
  local my=toastToken
  toast.Text=t
  task.delay(secs or 3,function() if toastToken==my then toast.Text="" end end)
end

local state={}
local onlineState={}
local allFound=false
local onComplete=nil
-- The log used to list every object at every site. At 13 sites that is 45 lines down the
-- left of the screen -- unreadable on a phone, and it ran off its own panel. The map and
-- the trophy room hold the full picture now, so the corner log shows only the site you are
-- standing at, plus one line of overall progress.
local function siteHereName()
  local c=plr.Character
  local hrp=c and c:FindFirstChild("HumanoidRootPart")
  if not hrp or not IDX.MAP then return nil end
  local p=Vector3.new(hrp.Position.X,0,hrp.Position.Z)
  local best,bd=nil,260
  for name,m in pairs(IDX.MAP) do
    local d=(p-m.pos).Magnitude
    if d<bd then best,bd=name,d end
  end
  return best
end

local function renderLog()
  local n=0
  for _,id in ipairs(ORDER) do if state[id] then n+=1 end end
  local here=siteHereName()
  local parts={}
  if here then
    table.insert(parts,string.upper(here))
    for _,id in ipairs(ORDER) do
      if SITEOF[id]==here then
        local d=state[id]
        if d then
          local on = onlineState[id] and ("  · "..(ONLINE_LABEL[id] or "ONLINE")) or ""
          table.insert(parts,"  ✓  "..SHORT[id]..on)
        else
          table.insert(parts,"  ?  unidentified object")
        end
      end
    end
  else
    table.insert(parts,"BETWEEN SITES")
  end
  table.insert(parts,"")
  table.insert(parts,("  %d of %d found  ·  [M] map"):format(n,#ORDER))
  logList.Text=table.concat(parts,"\n")
  -- fit the panel to what it says
  log.Size=UDim2.fromOffset(300,36+(#parts*17)+10)
  if n==#ORDER and not allFound then
    allFound=true
    if onComplete then task.spawn(onComplete) end
  end
end
renderLog()
-- you walk between sites, so the log follows you
task.spawn(function()
  local last=nil
  while true do
    task.wait(1)
    local h=siteHereName()
    if h~=last then last=h; renderLog() end
  end
end)

local function hideCard()
  TS:Create(card,TweenInfo.new(0.22),{Size=UDim2.fromOffset(430,0)}):Play()
  task.delay(0.23,function() card.Visible=false end)
end

ShowCard.OnClientEvent:Connect(function(d)
  current=d.id
  mountCard(d.id)
  cTitle.Text=d.Title; cYear.Text=d.Year; cWhat.Text=d.What
  cWhy.Text="Why it was sent: "..d.Why
  cSci.Text=d.Science
  local verb = (d.id=="oppy") and "[ F ]  LAST SOLS"
    or (d.id=="sojourner") and "[ F ]  PLAN A DRIVE" or "[ F ]  REACTIVATE"
  cHint.Text = (PUZZLE[d.id] and ("[ R ]  REMEMBER      "..verb.."      [ Q ]  close"))
    or "[ R ]  REMEMBER      [ Q ]  close"
  card.Visible=true; card.Size=UDim2.fromOffset(430,0)
  -- wrapped text with AutomaticSize only settles its height after layout runs,
  -- so measuring on the very next frame clips the card. Wait for it, then keep
  -- the card fitted if the content grows afterwards.
  task.wait(); task.wait()
  local function fit() return UDim2.fromOffset(430,lay.AbsoluteContentSize.Y+28) end
  TS:Create(card,TweenInfo.new(0.33,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),
    {Size=fit()}):Play()
  task.delay(0.4,function() if card.Visible and current==d.id then card.Size=fit() end end)
end)

LogUpdate.OnClientEvent:Connect(function(snap)
  state=snap or {}
  renderLog()
end)

Notice.OnClientEvent:Connect(function(text,secs) say(text,secs) end)

-- ---------- vignettes (client-local: nothing here touches the shared world) ----------
local function flash(dur)
  local b,a,e=L.Brightness,L.Ambient,L.ExposureCompensation
  TS:Create(L,TweenInfo.new(0.8),{Brightness=7,Ambient=Color3.fromRGB(60,58,54),
    ExposureCompensation=0.5}):Play()
  task.delay(dur,function()
    TS:Create(L,TweenInfo.new(1.2),{Brightness=b,Ambient=a,ExposureCompensation=e}):Play()
  end)
end

local V={}

V.lm=function()
  flash(6)
  say("21 July 1969. The ascent stage lifts off, and leaves this behind.",6)
  local f=Instance.new("Part")
  f.Shape=Enum.PartType.Ball; f.Size=Vector3.new(5,5,5)
  f.Position=Vector3.new(0,1.2,0); f.Anchored=true; f.CanCollide=false
  f.Material=Enum.Material.Neon; f.Color=Color3.fromRGB(255,214,150)
  f.Transparency=1; f.Parent=workspace
  TS:Create(f,TweenInfo.new(0.5),{Transparency=0.15,Size=Vector3.new(11,11,11)}):Play()
  task.wait(1.4)
  TS:Create(f,TweenInfo.new(2.4),{Transparency=1,Size=Vector3.new(26,26,26)}):Play()
  task.wait(3.2); f:Destroy()
end

V.seis=function()
  flash(7)
  say("Apollo 11 began lunar seismology. When Apollo 12's stage crashed 73 km away, the Moon rang like a bell for 55 minutes.",7)
  local body=site.Seismometer:FindFirstChild("SeisBody")
  local home=body.CFrame                     -- restore afterwards, or it stays crooked
  for i=1,26 do
    local k=math.sin(i*0.8)*math.exp(-i/16)
    body.CFrame=home*CFrame.Angles(0,0,math.rad(k*4))
    task.wait(0.09)
  end
  body.CFrame=home
  say("That long ringing told us the crust is dry and deeply fractured.",5)
  task.wait(2)
end

V.retro=function()
  flash(9)
  say("A laser leaves an observatory on Earth.",2.4)
  task.wait(2.4)
  local beam=Instance.new("Part")
  beam.Size=Vector3.new(0.3,420,0.3); beam.CFrame=CFrame.new(36.0,211,-26.0)
  beam.Anchored=true; beam.CanCollide=false
  beam.Material=Enum.Material.Neon; beam.Color=Color3.fromRGB(190,235,255)
  beam.Transparency=1; beam.Parent=workspace
  TS:Create(beam,TweenInfo.new(0.15),{Transparency=0.25}):Play()
  task.wait(0.3); TS:Create(beam,TweenInfo.new(0.4),{Transparency=1}):Play()
  say("Now wait. Light takes 1.25 seconds to get there. And 1.25 seconds back.",3)
  task.wait(2.5)
  TS:Create(beam,TweenInfo.new(0.12),{Transparency=0.1}):Play()
  task.wait(0.25); TS:Create(beam,TweenInfo.new(0.9),{Transparency=1}):Play()
  say("Return pulse. 2.5 seconds. We still do this several times a month.",4)
  task.wait(4)
  say("The Moon is 3.8 cm further away than it was last year.",5)
  task.wait(3); beam:Destroy()
end

V.surv3=function()
  flash(8)
  say("April 1967. Surveyor 3 lands here, to prove a soft landing was possible at all.",5)
  task.wait(5)
  say("November 1969. Apollo 12 comes down 180 metres away — the only time anyone went back to something we had left.",7)
  task.wait(7)
  say("Conrad and Bean cut pieces off it and carried them home. Its TV camera is in the Smithsonian.",6)
  task.wait(4)
end

V.a12alsep=function()
  flash(9)
  say("This one had a nuclear generator, so it did not die at sunset like Apollo 11's.",5)
  local body=site.Parent:FindFirstChild("Procellarum")
  body=body and body:FindFirstChild("Apollo12_ALSEP")
  body=body and body:FindFirstChild("Central")
  task.wait(5)
  say("Days later the crew's ascent stage was crashed into the Moon on purpose, 73 km away.",5)
  if body then
    local home=body.CFrame
    for i=1,30 do
      local k=math.sin(i*0.7)*math.exp(-i/19)
      body.CFrame=home*CFrame.Angles(0,0,math.rad(k*3))
      task.wait(0.09)
    end
    body.CFrame=home
  else
    task.wait(2.7)
  end
  say("The Moon rang for 55 minutes. Dry rock, deeply fractured, with no water to damp it.",6)
  task.wait(4)
  say("It kept listening until every ALSEP station was switched off in September 1977.",5)
  task.wait(3)
end

V.falcon=function()
  flash(7)
  say("30 July 1971. Falcon comes down between a mountain range and a canyon.",5)
  task.wait(5)
  say("Apollo 15 was the first of the long stays: three days on the surface, and a car in the hold.",6)
  task.wait(4)
end

V.lrv=function()
  flash(11)
  local cam=workspace.CurrentCamera
  local m=site.Parent:FindFirstChild("Hadley")
  m=m and m:FindFirstChild("LunarRover")
  say("31 July 1971. The first wheels on another world.",3.5)
  task.wait(3.5)
  if m then
    -- ride out from the lander: the camera takes the driver's seat for a moment
    local ok=pcall(function()
      local start=m:GetPivot()
      cam.CameraType=Enum.CameraType.Scriptable
      for i=0,120 do
        local t=i/120
        local p=start.Position+start.LookVector*(t*120)+Vector3.new(0,4.5+math.sin(i*0.7)*0.22,0)
        cam.CFrame=CFrame.lookAt(p,p+start.LookVector*20-Vector3.new(0,2,0))
        task.wait(0.03)
      end
    end)
    cam.CameraType=Enum.CameraType.Custom
    if not ok then task.wait(1) end
  else
    task.wait(3.6)
  end
  say("It drove about 28 kilometres in three days, out to the mountain front and the rille.",5)
  task.wait(5)
  say("Then they parked it facing the lander, and left it running its camera.",4)
  task.wait(3)
end

V.lrrr15=function()
  flash(8)
  say("Three hundred prisms. Three times the array at Tranquility.",4)
  task.wait(4)
  say("Set down by hand, levelled, aimed at Earth, and never touched again.",4.5)
  task.wait(4.5)
  say("With 300 corner cubes, it is the largest Apollo reflector array.",4)
  task.wait(3)
end

V.oppy=function()
  flash(13)
  say("25 January 2004. Ninety sols, that was the plan.",4)
  task.wait(4)
  say("It found water-laid rock in its first weeks, then kept going for fourteen years.",5)
  task.wait(5)
  -- the sky closes in: client-only, so nobody else's Mars goes dark
  local L2=game:GetService("Lighting")
  local f0,b0=L2.FogEnd,L2.Brightness
  game:GetService("TweenService"):Create(L2,TweenInfo.new(6),
    {FogEnd=120,Brightness=0.7}):Play()
  say("June 2018. A dust storm goes global. The sky closes over.",5)
  task.wait(5)
  say("Opacity reaches 10.8 — the thickest ever measured from the surface of Mars.",5)
  task.wait(5)
  game:GetService("TweenService"):Create(L2,TweenInfo.new(4),
    {FogEnd=f0,Brightness=b0}):Play()
  say("10 June 2018. The last signal.",4)
  task.wait(4)
end

V.heatshield=function()
  flash(8)
  say("It threw this away at about 7 kilometres up, so that it could land at all.",5)
  task.wait(5)
  say("Years later it drove back to photograph it — and found an iron meteorite lying beside it.",6)
  task.wait(5)
  say("The first meteorite ever identified on another planet.",4)
  task.wait(3)
end

V.pathfinder=function()
  flash(9)
  say("4 July 1997. It came in under a parachute, wrapped in airbags.",4.5)
  task.wait(4.5)
  say("It hit the plain and bounced — at least fifteen times, the first rebounds about fifteen metres high.",6)
  task.wait(6)
  say("Then it rolled to a stop, and opened like a flower.",4)
  task.wait(4)
end

V.sojourner=function()
  flash(9)
  say("5 July 1997. A rover the size of a microwave oven rolls down the ramp.",5)
  task.wait(5)
  say("Nobody had ever driven anything on another planet before.",4.5)
  task.wait(4.5)
  say("It went about a hundred metres in 83 sols, and never strayed far from the lander.",5)
  task.wait(4)
end

V.viking1=function()
  flash(8)
  say("20 July 1976. Seven years to the day after Apollo 11, something lands on Mars and stays working.",6)
  task.wait(6)
  say("It sent back the first photographs ever taken from the surface of another planet.",5)
  task.wait(4)
end

V.viking2=function()
  flash(7)
  say("Its twin, deliberately set down on the far side of the planet.",4.5)
  task.wait(4.5)
  say("One winter morning it photographed frost on the ground — weather, on another world.",5)
  task.wait(4)
end

V.spirit=function()
  flash(10)
  say("Opportunity had a twin, and this is where it landed.",4)
  task.wait(4)
  say("It climbed into the hills and found rock that had been cooked by hot water.",5)
  task.wait(5)
  say("Then in 2009 it broke through a crust into soft sand, and could not get out.",5)
  task.wait(5)
  say("It kept working where it stood, until the winter came and the Sun was too low.",5)
  task.wait(4)
end

V.phoenix=function()
  flash(9)
  say("It dug a trench, and something bright showed at the bottom.",4.5)
  task.wait(4.5)
  say("Four days later the bright patches were gone. Ice, turning straight to vapour.",5)
  task.wait(5)
  say("Then it melted some in an oven, and confirmed it: water.",4.5)
  task.wait(4)
end

V.insight=function()
  flash(9)
  say("It lifted its seismometer off its own deck and set it down on the ground.",5)
  task.wait(5)
  say("Then it listened. Over a thousand marsquakes, over four years.",5)
  task.wait(5)
  say("That is how we learned the size of the core of Mars.",4)
  task.wait(3)
end

V.ingenuity=function()
  flash(8)
  say("19 April 2021. Two rotors wind up to over two thousand revolutions a minute.",5)
  task.wait(5)
  say("The air here is about one percent as thick as Earth's. It flew anyway.",5)
  task.wait(5)
  say("Thirty-nine seconds. Then it did it another seventy-one times.",4.5)
  task.wait(4)
end

V.near=function()
  flash(9)
  say("It was built to circle this asteroid, not to land on it. It had no legs.",5)
  task.wait(5)
  say("After a year of mapping, the team brought it down anyway — at about walking pace.",5)
  task.wait(5)
  say("It survived, and kept talking from the surface for more than two weeks.",5)
  task.wait(4)
end

PlayVignette.OnClientEvent:Connect(function(id,isMine)
  if busy then return end
  local fn=V[id]; if not fn then return end
  busy=true
  hideCard()
  local ok,err=pcall(fn)
  if not ok then warn("vignette "..id..": "..tostring(err)) end
  busy=false
end)

local function onKey(code)
  if code==Enum.KeyCode.R and current and not busy then
    RequestRemember:FireServer(current)
  elseif code==Enum.KeyCode.F and current and not busy then
    RSrv.Remotes.RequestReactivate:FireServer(current)
  elseif code==Enum.KeyCode.Q then
    hideCard(); current=nil
  end
end

UIS.InputBegan:Connect(function(i,gpe)
  if gpe then return end
  onKey(i.KeyCode)
end)
-- the touchscreen buttons arrive here as well (Remotes.LocalKey, a BindableEvent)
rem:WaitForChild("LocalKey").Event:Connect(function(code,phase)
  if phase~="up" then onKey(code) end
end)

task.wait(1)
-- the opening is the Intro script now: the station speaks to you on the radio

rem:WaitForChild("OnlineUpdate").OnClientEvent:Connect(function(snap)
  onlineState = snap or {}
  renderLog()
end)

-- ---------- THE HANDOVER: what happens when the log is full ----------
-- The happy ending. Nothing here is invented: the four live entries below were checked
-- on 14 Nov 2026 and each is still returning data. Re-check before any public release.
local PlaceMarker=rem:WaitForChild("PlaceMarker")
local MarkerUpdate=rem:WaitForChild("MarkerUpdate")

local STILL_ANSWERING={
  {"The Apollo retroreflectors","Apollo 11, 14 and 15. No power, no moving parts. Observatories still range on them several times a month."},
  {"Voyager 1","2 of its 10 instruments are still on, 25.9 billion km out. It passes one light-day from Earth on 18 Nov 2026."},
  {"Curiosity","Still driving in Gale Crater. It passed 5,000 sols in September 2026."},
  {"Perseverance","Still collecting samples in Jezero Crater."},
}

local fin=mk("ScreenGui",{Name="Handover",ResetOnSpawn=false,IgnoreGuiInset=true,
  Enabled=false,DisplayOrder=9},pg)
mk("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(0,0,0),
  BackgroundTransparency=0.25,BorderSizePixel=0},fin)
local fp=mk("Frame",{Size=UDim2.fromOffset(620,520),AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),
  BackgroundColor3=Color3.fromRGB(8,8,10),BackgroundTransparency=0.04,BorderSizePixel=0},fin)
mk("UICorner",{CornerRadius=UDim.new(0,10)},fp)
mk("UIStroke",{Color=Color3.fromRGB(60,64,72),Thickness=1},fp)
local fscale=mk("UIScale",{},fp)
local function ffit()
  local vp=workspace.CurrentCamera.ViewportSize
  fscale.Scale=math.min(1,(vp.X-24)/620,(vp.Y-24)/520)
end
ffit(); workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(ffit)

local fpad=mk("Frame",{Size=UDim2.new(1,-44,1,-40),Position=UDim2.fromOffset(22,20),
  BackgroundTransparency=1},fp)
mk("UIListLayout",{Padding=UDim.new(0,9),SortOrder=Enum.SortOrder.LayoutOrder},fpad)
local function frow(txt,font,size,col,order)
  return mk("TextLabel",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
    BackgroundTransparency=1,Font=font,TextSize=size,TextColor3=col,TextWrapped=true,
    TextXAlignment=Enum.TextXAlignment.Left,Text=txt,LayoutOrder=order},fpad)
end
frow("SURVEY COMPLETE",Enum.Font.GothamBold,13,Color3.fromRGB(150,205,255),1)
local fTitle=frow("Everything we left here, found.",Enum.Font.GothamBold,26,Color3.new(1,1,1),2)
local fCount=frow("",Enum.Font.GothamMedium,15,YEL,3)
frow("STILL ANSWERING TODAY",Enum.Font.GothamBold,13,Color3.fromRGB(120,230,150),4)
local fList=frow("",Enum.Font.Gotham,14,Color3.fromRGB(210,210,215),5)
local fClose=frow("",Enum.Font.GothamBold,17,YEL,6)
local btn=mk("TextButton",{Size=UDim2.new(1,0,0,46),BackgroundColor3=Color3.fromRGB(70,64,20),
  AutoButtonColor=true,Font=Enum.Font.GothamBold,TextSize=16,TextColor3=YEL,
  Text="LEAVE YOUR OWN MARKER",LayoutOrder=7},fpad)
mk("UICorner",{CornerRadius=UDim.new(0,8)},btn)
local dismiss=mk("TextButton",{Size=UDim2.new(1,0,0,30),BackgroundTransparency=1,
  Font=Enum.Font.Gotham,TextSize=13,TextColor3=Color3.fromRGB(150,160,166),
  Text="[Q]  back to the surface",LayoutOrder=8},fpad)

local function closeFinale()
  fin.Enabled=false
  local c=plr.Character; local h=c and c:FindFirstChildOfClass("Humanoid")
  if h then h.WalkSpeed=11 end
end
dismiss.MouseButton1Click:Connect(closeFinale)

btn.MouseButton1Click:Connect(function()
  PlaceMarker:FireServer()
  btn.Text="MARKER PLACED"
  btn.Active=false
  fClose.Text="Yours is beside the Eagle now. Nothing out here is lost. It's waiting."
  task.wait(3.5)
  closeFinale()
end)

MarkerUpdate.OnClientEvent:Connect(function(n,who)
  if n and n>0 then
    fCount.Text=n.." marker"..(n==1 and "" or "s").." left at Tranquility by this crew."
  end
end)

onComplete=function()
  task.wait(2.5)
  local lines={}
  for _,e in ipairs(STILL_ANSWERING) do
    table.insert(lines,"  "..e[1].."\n     "..e[2])
  end
  fList.Text=table.concat(lines,"\n\n")
  fClose.Text="Artemis is going back. The mirrors Apollo set down need no power and have no "..
    "moving parts, so they will still be working when the next crew arrives — and someone "..
    "will range a laser off the same glass Armstrong and Aldrin left."
  fin.Enabled=true
  local c=plr.Character; local h=c and c:FindFirstChildOfClass("Humanoid")
  if h then h.WalkSpeed=0 end
end

UIS.InputBegan:Connect(function(i,gpe)
  if gpe then return end
  if i.KeyCode==Enum.KeyCode.Q and fin.Enabled then closeFinale() end
end)
rem.LocalKey.Event:Connect(function(code,phase)
  if code==Enum.KeyCode.Q and phase~="up" and fin.Enabled then closeFinale() end
end)

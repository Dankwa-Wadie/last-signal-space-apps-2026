-- LocalScript  StarterPlayerScripts/StarterPlayerScripts.Intro
-- THE OPENING. You come round on your back on the station pad, looking straight up at
-- Earth hanging in a black sky. The station talks to you on the radio. You get up, and you
-- are facing the Eagle across the heritage boundary.
--
-- Nothing went wrong -- there is no crash and no amnesia. You came down by transit, like
-- everyone does, and the first thing you see on the Moon is home.
--
-- Rules: plays once, on your first spawn only; never on respawn; any key, click or tap skips
-- it; and it is client-local, so it never holds up anyone else on the server.
local Players=game:GetService("Players")
local RS=game:GetService("RunService")
local TS=game:GetService("TweenService")
local UIS=game:GetService("UserInputService")
local RSrv=game:GetService("ReplicatedStorage")
local plr=Players.LocalPlayer
if plr:GetAttribute("IntroSeen") then return end
plr:SetAttribute("IntroSeen",true)

local pg=plr:WaitForChild("PlayerGui")
local rem=RSrv:WaitForChild("Remotes")
local c=plr.Character or plr.CharacterAdded:Wait()
local hrp=c:WaitForChild("HumanoidRootPart")
local hum=c:WaitForChild("Humanoid")

local YEL=Color3.fromRGB(245,231,60)
local CYAN=Color3.fromRGB(150,205,255)
local function mk(cls,props,parent)
  local o=Instance.new(cls); for k,v in pairs(props) do o[k]=v end; o.Parent=parent; return o
end

-- ---------- the overlay ----------
local gui=mk("ScreenGui",{Name="Intro",ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=30},pg)
local black=mk("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(0,0,0),
  BorderSizePixel=0},gui)
local radio=mk("Frame",{Size=UDim2.new(0,560,0,96),AnchorPoint=Vector2.new(0.5,1),
  Position=UDim2.new(0.5,0,1,-46),BackgroundColor3=Color3.fromRGB(8,9,12),
  BackgroundTransparency=0.15,BorderSizePixel=0,Visible=false},gui)
mk("UICorner",{CornerRadius=UDim.new(0,10)},radio)
mk("UIStroke",{Color=Color3.fromRGB(60,64,72),Thickness=1},radio)
local rsc=mk("UIScale",{},radio)
local function fit()
  local vp=workspace.CurrentCamera.ViewportSize
  rsc.Scale=math.min(1,(vp.X-24)/560)
end
fit(); workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fit)
local who=mk("TextLabel",{Size=UDim2.new(1,-28,0,18),Position=UDim2.fromOffset(14,10),
  BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=12,TextColor3=CYAN,
  TextXAlignment=Enum.TextXAlignment.Left,Text="●  TRANQUILITY STATION  ·  RADIO"},radio)
local line=mk("TextLabel",{Size=UDim2.new(1,-28,0,56),Position=UDim2.fromOffset(14,30),
  BackgroundTransparency=1,Font=Enum.Font.GothamMedium,TextSize=19,TextColor3=Color3.new(1,1,1),
  TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,
  Text=""},radio)
local skip=mk("TextLabel",{Size=UDim2.fromOffset(240,18),AnchorPoint=Vector2.new(1,0),
  Position=UDim2.new(1,-18,0,18),BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=12,
  TextColor3=Color3.fromRGB(140,146,154),TextXAlignment=Enum.TextXAlignment.Right,
  Text=UIS.TouchEnabled and "tap to skip" or "press any key to skip"},gui)

-- ---------- skipping ----------
local skipped=false
local conns={}
table.insert(conns,UIS.InputBegan:Connect(function(i)
  if i.UserInputType==Enum.UserInputType.Keyboard or i.UserInputType==Enum.UserInputType.Touch
    or i.UserInputType==Enum.UserInputType.MouseButton1 then skipped=true end
end))
table.insert(conns,rem:WaitForChild("LocalKey").Event:Connect(function() skipped=true end))

-- wait in small steps so a skip lands immediately
local function hold(t)
  local t0=os.clock()
  while os.clock()-t0<t do
    if skipped then return false end
    RS.RenderStepped:Wait()
  end
  return true
end
-- type the line out, the way a radio transcript would come in
local beep=rem:WaitForChild("RadioBeep")
local function say(text,after)
  beep:Fire()             -- the Quindar tone: how Apollo keyed every transmission
  radio.Visible=true
  line.Text=""
  for i=1,#text do
    if skipped then line.Text=text; return false end
    line.Text=string.sub(text,1,i)
    if i%2==0 then RS.RenderStepped:Wait() end
  end
  return hold(after or 1.6)
end

-- ---------- where Earth is ----------
-- The Sky script rebuilds Earth around the camera every frame, so its POSITION is meaningless
-- until it has run; what is fixed is its DIRECTION. Read that, every frame, from the sky's
-- own geometry -- and only trust it once the sky has actually placed Earth near the camera.
local function earthDir()
  local sky=workspace:FindFirstChild("LocalSky")
  local e=sky and sky:FindFirstChild("Earth")
  local o=e and e:FindFirstChild("Ocean")
  local eye=workspace.CurrentCamera.CFrame.Position
  if o and o.Transparency<1 then
    local v=o.Position-eye
    if v.Magnitude>200 and v.Magnitude<700 then return v.Unit end
  end
  return nil
end
-- from Tranquility the true answer: 66.5 degrees up, towards the west
local FALLBACK_DIR=Vector3.new(-math.cos(math.rad(66.5)),math.sin(math.rad(66.5)),0).Unit
local EAGLE=Vector3.new(0,5,8)

-- ---------- run it ----------
local cam=workspace.CurrentCamera
local savedWalk,savedJump=hum.WalkSpeed,hum.JumpPower
hum.WalkSpeed=0; hum.JumpPower=0
local hudHidden={}
local OURS={HUD=true,Logbook=true,Settings=true,TouchControls=true,HelmetView=true,ViewToggle=true}
for _,g in ipairs(pg:GetChildren()) do
  if g:IsA("ScreenGui") and OURS[g.Name] and g.Enabled then g.Enabled=false; table.insert(hudHidden,g) end
end

-- the sky builds itself on the client; give it a moment so Earth is really there
-- The camera lies where the astronaut is standing, so it would be inside the suit looking
-- out through the backpack. Hide the body on this screen only, for the length of the scene.
local bodyHidden={}
for _,d in ipairs(c:GetDescendants()) do
  if (d:IsA("BasePart") or d:IsA("Decal")) and d.Transparency<1 then
    table.insert(bodyHidden,{d,d.Transparency}); d.Transparency=1
  end
end

local camHold=true
local eyeLying,lookDir=nil,nil

-- flat on your back: eyes a hand's width above the regolith, looking up at Earth.
-- lookDir is nil while lying (follow Earth live); during the rise it is set explicitly.
eyeLying=Vector3.new(hrp.Position.X,0.9,hrp.Position.Z)
local liveEarth=true
task.spawn(function()
  while camHold do
    cam.CameraType=Enum.CameraType.Scriptable
    local d=lookDir
    if liveEarth or not d then d=earthDir() or lookDir or FALLBACK_DIR end
    cam.CFrame=CFrame.lookAt(eyeLying,eyeLying+d*100)
    RS.RenderStepped:Wait()
  end
end)
-- let the sky place Earth around the lying camera before anything is revealed
local t0=os.clock()
while os.clock()-t0<3 and not earthDir() do RS.RenderStepped:Wait() end

local function sequence()
  if not hold(0.8) then return end
  if not say("Surveyor, your transit is down safe. Welcome to the Moon.",1.4) then return end
  if not say("Before you do anything else — look up.",0.6) then return end
  TS:Create(black,TweenInfo.new(2.4,Enum.EasingStyle.Sine),{BackgroundTransparency=1}):Play()
  if not hold(2.6) then return end
  if not say("That's home. From here it never moves. It never rises and it never sets.",2.2) then return end
  -- get up: from lying on the pad to standing, turning from Earth to the Eagle
  local fromDir=earthDir() or FALLBACK_DIR
  lookDir=fromDir          -- set before letting go of Earth, or the camera loop has nothing
  liveEarth=false
  local from=eyeLying
  local to=hrp.Position+Vector3.new(0,1.6,0)
  local toDir=(EAGLE-to).Unit
  local tr=0
  while tr<1 do
    if skipped then return end
    tr=math.min(1,tr+RS.RenderStepped:Wait()/3.2)
    local k=1-(1-tr)^3
    eyeLying=from:Lerp(to,k)
    lookDir=fromDir:Lerp(toDir,k).Unit
  end
  say("Everything out there is exactly where they left it. Walk out to the Eagle.",2.4)
end
sequence()

-- ---------- hand back control, skipped or not ----------
camHold=false
for _,cn in ipairs(conns) do cn:Disconnect() end
black.BackgroundTransparency=1
cam.CameraType=Enum.CameraType.Custom
-- face the Eagle when you get control, whatever happened above
hrp.CFrame=CFrame.lookAt(hrp.Position,Vector3.new(EAGLE.X,hrp.Position.Y,EAGLE.Z))
hum.WalkSpeed=savedWalk; hum.JumpPower=savedJump
for _,t in ipairs(bodyHidden) do if t[1].Parent then t[1].Transparency=t[2] end end
for _,g in ipairs(hudHidden) do g.Enabled=true end
if skipped then
  line.Text="Everything out there is exactly where they left it. Walk out to the Eagle."
  radio.Visible=true
end
skip.Visible=false
task.wait(4)
TS:Create(radio,TweenInfo.new(0.8),{BackgroundTransparency=1}):Play()
TS:Create(line,TweenInfo.new(0.8),{TextTransparency=1}):Play()
TS:Create(who,TweenInfo.new(0.8),{TextTransparency=1}):Play()
task.wait(0.9)
gui:Destroy()

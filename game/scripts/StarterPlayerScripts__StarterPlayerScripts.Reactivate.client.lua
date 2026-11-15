-- LocalScript  StarterPlayerScripts/StarterPlayerScripts.Reactivate
-- REACTIVATE panels. One shared frame, one module-ish table per instrument.
--   seis_level     Apollo 11 seismometer : level it, set the gain, hear the Moon ring
--   retro_ranging  Apollo 11 retroreflector : gate the detector on the 2.5 s round trip
--   lrv_dish       Apollo 15 rover : aim the high-gain dish at an Earth that never moves
--   oppy_power     Opportunity : keep it alive as long as JPL did. It still ends.
local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local RS=game:GetService("RunService")
local RSrv=game:GetService("ReplicatedStorage")
local plr=Players.LocalPlayer
local pg=plr:WaitForChild("PlayerGui")
local rem=RSrv:WaitForChild("Remotes")

local YEL=Color3.fromRGB(245,231,60)
local GRN=Color3.fromRGB(120,230,150)
local RED=Color3.fromRGB(230,90,70)
local CYAN=Color3.fromRGB(150,205,255)
local DIM=Color3.fromRGB(150,150,158)
local function mk(c,p,par) local o=Instance.new(c)
  for k,v in pairs(p) do o[k]=v end
  -- A UIStroke on a text object outlines the letters, not the box. We always mean the box.
  if c=="UIStroke" and p.ApplyStrokeMode==nil and par
     and (par:IsA("TextButton") or par:IsA("TextLabel") or par:IsA("TextBox")) then
    o.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
  end
  o.Parent=par return o end

-- ---------- shared chrome ----------
local gui=mk("ScreenGui",{Name="Panel",ResetOnSpawn=false,IgnoreGuiInset=true,
  Enabled=false,DisplayOrder=10},pg)
mk("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(0,0,0),
  BackgroundTransparency=0.45,BorderSizePixel=0},gui)
local box=mk("Frame",{Size=UDim2.fromOffset(620,470),AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),
  BackgroundColor3=Color3.fromRGB(12,12,14),BorderSizePixel=0},gui)
mk("UICorner",{CornerRadius=UDim.new(0,10)},box)
mk("UIStroke",{Color=Color3.fromRGB(70,70,78),Thickness=1},box)
local scale=mk("UIScale",{},box)
local function fit()
  local vp=workspace.CurrentCamera.ViewportSize
  scale.Scale=math.min(1,(vp.X-20)/620,(vp.Y-20)/470)
end
fit(); workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fit)

local title=mk("TextLabel",{Size=UDim2.new(1,-28,0,24),Position=UDim2.fromOffset(20,16),
  BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=16,TextColor3=YEL,
  TextXAlignment=Enum.TextXAlignment.Left,Text=""},box)
local sub=mk("TextLabel",{Size=UDim2.new(1,-40,0,40),Position=UDim2.fromOffset(20,42),
  BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=13,TextColor3=DIM,TextWrapped=true,
  TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,Text=""},box)
local status=mk("TextLabel",{Size=UDim2.new(1,-40,0,106),Position=UDim2.fromOffset(20,318),
  BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=14,TextColor3=RED,
  TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,
  TextYAlignment=Enum.TextYAlignment.Top,Text=""},box)
mk("TextLabel",{Size=UDim2.new(1,-40,0,20),Position=UDim2.fromOffset(20,430),
  BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=12,TextColor3=DIM,
  TextXAlignment=Enum.TextXAlignment.Left,Text="[ Q ] or X to leave the instrument"},box)
local xBtn=mk("TextButton",{Name="Close",Size=UDim2.fromOffset(36,36),Position=UDim2.new(1,-50,0,12),
  BackgroundColor3=Color3.fromRGB(30,32,38),Font=Enum.Font.GothamBold,TextSize=18,TextColor3=Color3.new(1,1,1),Text="X",AutoButtonColor=true},box)
mk("UICorner",{CornerRadius=UDim.new(0.5,0)},xBtn)

local stage=mk("Frame",{Size=UDim2.fromOffset(580,210),Position=UDim2.fromOffset(20,100),
  BackgroundTransparency=1},box)

-- ---------- player freeze ----------
local savedWalk,savedJump=nil,nil
local function freeze(on)
  local c=plr.Character; if not c then return end
  local hum=c:FindFirstChildOfClass("Humanoid"); if not hum then return end
  if on then
    if savedWalk==nil then savedWalk=hum.WalkSpeed; savedJump=hum.JumpPower end
    hum.WalkSpeed=0; hum.JumpPower=0; hum:Move(Vector3.new(0,0,0),false)
  else
    if savedWalk~=nil then hum.WalkSpeed=savedWalk; hum.JumpPower=savedJump end
    savedWalk,savedJump=nil,nil
  end
end

-- ---------- input ----------
local keys={}
local function down(k) return keys[k]==true or UIS:IsKeyDown(k) end
local tapped={}
local function takeTap(k) if tapped[k] then tapped[k]=nil return true end return false end

-- ---------- puzzle registry ----------
local P={}
local openId,running,solved=nil,false,false

local function panel(h)
  local f=mk("Frame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Visible=false},stage)
  return f
end

-- ============ 1. seismometer ============
do
  local f=panel()
  local lvlBox=mk("Frame",{Size=UDim2.fromOffset(190,190),Position=UDim2.fromOffset(8,0),
    BackgroundColor3=Color3.fromRGB(20,20,24),BorderSizePixel=0},f)
  mk("UICorner",{CornerRadius=UDim.new(1,0)},lvlBox)
  mk("UIStroke",{Color=Color3.fromRGB(70,70,78),Thickness=1},lvlBox)
  local ring=mk("Frame",{Size=UDim2.fromOffset(54,54),Position=UDim2.fromOffset(68,68),
    BackgroundTransparency=1},lvlBox)
  mk("UICorner",{CornerRadius=UDim.new(1,0)},ring)
  mk("UIStroke",{Color=Color3.fromRGB(90,90,100),Thickness=1},ring)
  local bubble=mk("Frame",{Size=UDim2.fromOffset(26,26),BackgroundColor3=RED,
    BorderSizePixel=0,AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5)},lvlBox)
  mk("UICorner",{CornerRadius=UDim.new(1,0)},bubble)
  local gBox=mk("Frame",{Size=UDim2.fromOffset(44,190),Position=UDim2.fromOffset(230,0),
    BackgroundColor3=Color3.fromRGB(20,20,24),BorderSizePixel=0},f)
  mk("UICorner",{CornerRadius=UDim.new(0,6)},gBox)
  mk("UIStroke",{Color=Color3.fromRGB(70,70,78),Thickness=1},gBox)
  local band=mk("Frame",{Size=UDim2.new(1,0,0,30),Position=UDim2.new(0,0,0.34,0),
    BackgroundColor3=Color3.fromRGB(40,80,55),BorderSizePixel=0},gBox)
  local needle=mk("Frame",{Size=UDim2.new(1,8,0,3),Position=UDim2.new(0,-4,0.9,0),
    BackgroundColor3=YEL,BorderSizePixel=0},gBox)
  local trace=mk("Frame",{Size=UDim2.fromOffset(290,190),Position=UDim2.fromOffset(290,0),
    BackgroundColor3=Color3.fromRGB(16,18,16),BorderSizePixel=0,ClipsDescendants=true},f)
  mk("UICorner",{CornerRadius=UDim.new(0,6)},trace)
  mk("UIStroke",{Color=Color3.fromRGB(70,70,78),Thickness=1},trace)
  mk("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,0.5,0),
    BackgroundColor3=Color3.fromRGB(60,80,60),BorderSizePixel=0},trace)

  local tiltX,tiltZ,gain,held=0.62,-0.48,0.9,0
  local bars={}
  local function clearTrace() for _,b in ipairs(bars) do b:Destroy() end bars={} end
  local function draw()
    clearTrace()
    for i=0,144 do
      local t=i/144
      local env = (t<0.12) and (t/0.12) or math.exp(-(t-0.12)*2.1)
      local a=math.sin(i*1.17)*math.sin(i*0.41)*env
      local h=math.max(1,math.abs(a)*78)
      table.insert(bars,mk("Frame",{Size=UDim2.fromOffset(2,h),Position=UDim2.new(0,i*2,0.5,-h/2),
        BackgroundColor3=Color3.fromRGB(130,235,140),BorderSizePixel=0},trace))
      if i%3==0 then task.wait(0.012) end
    end
  end
  P.seis={
    frame=f,
    title="PASSIVE SEISMIC EXPERIMENT",
    sub="It only hears the Moon if it is level and the gain is right.  W A S D to level  ·  + / - for gain.",
    start=function() tiltX,tiltZ,gain,held=0.62,-0.48,0.9,0; clearTrace()
      status.TextColor3=RED; status.Text="NOT LEVEL" end,
    step=function(dt)
      local sp=0.55*dt
      if down(Enum.KeyCode.A) then tiltX-=sp end
      if down(Enum.KeyCode.D) then tiltX+=sp end
      if down(Enum.KeyCode.W) then tiltZ-=sp end
      if down(Enum.KeyCode.S) then tiltZ+=sp end
      if down(Enum.KeyCode.Up) then gain=math.min(1,gain+sp*0.8) end
      if down(Enum.KeyCode.Down) then gain=math.max(0,gain-sp*0.8) end
      tiltX=math.clamp(tiltX,-1,1); tiltZ=math.clamp(tiltZ,-1,1)
      bubble.Position=UDim2.new(0.5+tiltX*0.42,0,0.5+tiltZ*0.42,0)
      local off=math.sqrt(tiltX^2+tiltZ^2)
      bubble.BackgroundColor3 = off<0.12 and GRN or RED
      needle.Position=UDim2.new(0,-4,1-gain,0)
      local gOk=gain>0.34 and gain<0.50
      band.BackgroundColor3 = gOk and Color3.fromRGB(60,130,80) or Color3.fromRGB(40,80,55)
      if off<0.12 and gOk then
        held+=dt
        status.TextColor3=YEL; status.Text=("ARMED — holding %.1fs"):format(held)
        if held>1.2 then
          running=false
          status.TextColor3=GRN; status.Text="LISTENING..."
          task.spawn(function()
            task.wait(0.7); draw()
            status.TextColor3=GRN
            status.Text="MOONQUAKE RECORDED. The ringing lasts far longer than it would on Earth — the crust is dry and deeply fractured, so there is no water in it to damp the shaking."
            P.finish()
          end)
        end
      else
        held=0; status.TextColor3=RED
        status.Text=(off>=0.12) and "NOT LEVEL" or "GAIN OUT OF RANGE"
      end
    end,
  }
end

-- ============ 2. retroreflector ranging ============
do
  local f=panel()
  mk("TextLabel",{Size=UDim2.fromOffset(560,18),Position=UDim2.fromOffset(8,0),
    BackgroundTransparency=1,Font=Enum.Font.GothamMedium,TextSize=12,TextColor3=DIM,
    TextXAlignment=Enum.TextXAlignment.Left,Text="DETECTOR GATE  ·  the return arrives 2.5 s after you fire"},f)
  local rail=mk("Frame",{Size=UDim2.fromOffset(560,56),Position=UDim2.fromOffset(8,26),
    BackgroundColor3=Color3.fromRGB(20,20,24),BorderSizePixel=0},f)
  mk("UICorner",{CornerRadius=UDim.new(0,6)},rail)
  mk("UIStroke",{Color=Color3.fromRGB(70,70,78),Thickness=1},rail)
  -- the window the photons come home in
  local win=mk("Frame",{Size=UDim2.new(0.088,0,1,0),Position=UDim2.new(0.868,0,0,0),
    BackgroundColor3=Color3.fromRGB(38,70,52),BorderSizePixel=0},rail)
  local sweep=mk("Frame",{Size=UDim2.fromOffset(3,56),Position=UDim2.new(0,0,0,0),
    BackgroundColor3=YEL,BorderSizePixel=0,Visible=false},rail)
  local pulse=mk("Frame",{Size=UDim2.fromOffset(10,10),AnchorPoint=Vector2.new(0.5,0.5),
    Position=UDim2.new(0.912,0,0.5,0),BackgroundColor3=CYAN,BorderSizePixel=0,
    BackgroundTransparency=1},rail)
  mk("UICorner",{CornerRadius=UDim.new(1,0)},pulse)
  local tally=mk("TextLabel",{Size=UDim2.fromOffset(560,24),Position=UDim2.fromOffset(8,92),
    BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=15,TextColor3=YEL,
    TextXAlignment=Enum.TextXAlignment.Left,Text=""},f)
  local plot=mk("TextLabel",{Size=UDim2.fromOffset(560,70),Position=UDim2.fromOffset(8,122),
    BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=14,TextColor3=CYAN,TextWrapped=true,
    TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,Text=""},f)

  local TRIP=2.5
  local phase,t,hits,shots="idle",0,0,0
  local TOL={0.26,0.20,0.15}     -- the third return is meant to be hard
  P.retro={
    frame=f,
    title="LUNAR LASER RANGING  ·  observatory link",
    sub="Fire, then open the detector gate exactly when the light gets back. Out of every pulse we send, about one photon returns — gate early or late and you collect noise.  [ W ] fire / gate.",
    start=function()
      phase,t,hits,shots="idle",0,0,0
      sweep.Visible=false; pulse.BackgroundTransparency=1; plot.Text=""
      tally.Text="RETURNS  0 / 3"
      status.TextColor3=YEL; status.Text="Press W to fire the laser."
      local tol=TOL[1]
      win.Size=UDim2.new(tol*2/3.0,0,1,0)
      win.Position=UDim2.new(TRIP/3.0-tol/3.0,0,0,0)
    end,
    step=function(dt)
      if phase=="idle" then
        if takeTap(Enum.KeyCode.W) then
          phase="flight"; t=0; sweep.Visible=true
          status.TextColor3=CYAN; status.Text="Pulse away. 1.25 s out, 1.25 s back."
        end
        return
      end
      if phase=="flight" then
        t+=dt
        sweep.Position=UDim2.new(math.min(t/3.0,1),0,0,0)
        local tol=TOL[math.min(hits+1,3)]
        if takeTap(Enum.KeyCode.W) then
          local err=math.abs(t-TRIP)
          if err<=tol then
            hits+=1
            pulse.BackgroundTransparency=0
            task.delay(0.35,function() pulse.BackgroundTransparency=1 end)
            status.TextColor3=GRN
            status.Text=("RETURN DETECTED  ·  %.2f s  (off by %.0f ms)"):format(t,err*1000)
          else
            status.TextColor3=RED
            status.Text=(t<TRIP) and "Gate opened early — nothing there yet. Only noise."
              or "Gate opened late — the photons had already gone past."
          end
          shots+=1
          tally.Text=("RETURNS  %d / 3     pulses fired  %d"):format(hits,shots)
          phase="cool"; t=0
          if hits>=3 then
            running=false
            plot.Text="RANGE 384,400 km (mean)  ·  measured to a few centimetres.\n"..
              "Fifty-plus years of these returns show the Moon receding 3.8 cm a year — "..
              "and that is why this mirror is the only Apollo experiment still returning data."
            status.TextColor3=GRN
            status.Text="THREE CLEAN RETURNS. Observatories still do this several times a month."
            task.spawn(P.finish)
          end
          return
        end
        if t>3.0 then
          shots+=1
          tally.Text=("RETURNS  %d / 3     pulses fired  %d"):format(hits,shots)
          status.TextColor3=RED; status.Text="No gate. The return went unrecorded."
          phase="cool"; t=0
        end
        return
      end
      if phase=="cool" then
        t+=dt
        if t>0.9 then
          phase="idle"; t=0; sweep.Visible=false
          local tol=TOL[math.min(hits+1,3)]
          win.Size=UDim2.new(tol*2/3.0,0,1,0)
          win.Position=UDim2.new(TRIP/3.0-tol/3.0,0,0,0)
          if hits<3 then
            status.TextColor3=YEL; status.Text="Press W to fire again."
          end
        end
      end
    end,
  }
end

-- ============ 3. the rover's high-gain dish ============
do
  local f=panel()
  local sky=mk("Frame",{Size=UDim2.fromOffset(340,190),Position=UDim2.fromOffset(8,0),
    BackgroundColor3=Color3.fromRGB(6,6,9),BorderSizePixel=0,ClipsDescendants=true},f)
  mk("UICorner",{CornerRadius=UDim.new(0,6)},sky)
  mk("UIStroke",{Color=Color3.fromRGB(70,70,78),Thickness=1},sky)
  for i=1,40 do
    mk("Frame",{Size=UDim2.fromOffset(1,1),BackgroundColor3=Color3.fromRGB(180,180,190),
      Position=UDim2.fromScale((i*0.137)%1,(i*0.311)%1),BorderSizePixel=0},sky)
  end
  -- Earth: it does NOT move. The Moon keeps one face toward us, so from any one spot
  -- on the near side Earth hangs in the same patch of sky, permanently.
  local earth=mk("Frame",{Size=UDim2.fromOffset(16,16),AnchorPoint=Vector2.new(0.5,0.5),
    BackgroundColor3=Color3.fromRGB(90,150,225),BorderSizePixel=0,BackgroundTransparency=1},sky)
  mk("UICorner",{CornerRadius=UDim.new(1,0)},earth)
  local cross=mk("Frame",{Size=UDim2.fromOffset(34,34),AnchorPoint=Vector2.new(0.5,0.5),
    BackgroundTransparency=1,Position=UDim2.fromScale(0.5,0.5)},sky)
  mk("UIStroke",{Color=YEL,Thickness=1},cross)
  local sigBox=mk("Frame",{Size=UDim2.fromOffset(44,190),Position=UDim2.fromOffset(360,0),
    BackgroundColor3=Color3.fromRGB(20,20,24),BorderSizePixel=0},f)
  mk("UICorner",{CornerRadius=UDim.new(0,6)},sigBox)
  mk("UIStroke",{Color=Color3.fromRGB(70,70,78),Thickness=1},sigBox)
  local sig=mk("Frame",{Size=UDim2.new(1,0,0,0),Position=UDim2.new(0,0,1,0),
    AnchorPoint=Vector2.new(0,1),BackgroundColor3=GRN,BorderSizePixel=0},sigBox)
  local tv=mk("Frame",{Size=UDim2.fromOffset(160,120),Position=UDim2.fromOffset(416,34),
    BackgroundColor3=Color3.fromRGB(18,18,20),BorderSizePixel=0,ClipsDescendants=true},f)
  mk("UICorner",{CornerRadius=UDim.new(0,4)},tv)
  mk("UIStroke",{Color=Color3.fromRGB(70,70,78),Thickness=1},tv)
  local tvTxt=mk("TextLabel",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,
    Font=Enum.Font.GothamBold,TextSize=13,TextColor3=Color3.fromRGB(90,90,96),
    TextWrapped=true,Text="NO SIGNAL"},tv)
  mk("TextLabel",{Size=UDim2.fromOffset(160,16),Position=UDim2.fromOffset(416,160),
    BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=11,TextColor3=DIM,Text="TV DOWNLINK"},f)

  local ax,ay,held,ex,ey=0,0,0,0,0
  P.lrv={
    frame=f,
    title="LUNAR ROVING VEHICLE  ·  high-gain antenna",
    sub="Live TV needs the big dish aimed straight at Earth, and it will only hold its aim while the rover is stopped. There is no target marker — you have to know where Earth is.  W A S D to aim.",
    start=function()
      ax,ay,held=0,0,0
      -- Earth sits where it always sits: high and a little off to one side. Fixed.
      ex,ey=0.70,0.26
      earth.Position=UDim2.fromScale(ex,ey)
      earth.BackgroundTransparency=1
      tvTxt.Text="NO SIGNAL"; tvTxt.TextColor3=Color3.fromRGB(90,90,96)
      sig.Size=UDim2.new(1,0,0,0)
      status.TextColor3=RED; status.Text="SEARCHING — the dish is pointed at empty sky."
    end,
    step=function(dt)
      local sp=0.42*dt
      if down(Enum.KeyCode.A) then ax-=sp end
      if down(Enum.KeyCode.D) then ax+=sp end
      if down(Enum.KeyCode.W) then ay-=sp end
      if down(Enum.KeyCode.S) then ay+=sp end
      ax=math.clamp(ax,-0.5,0.5); ay=math.clamp(ay,-0.5,0.5)
      cross.Position=UDim2.fromScale(0.5+ax,0.5+ay)
      local d=math.sqrt((0.5+ax-ex)^2+(0.5+ay-ey)^2)
      local strength=math.clamp(1-d/0.42,0,1)
      sig.Size=UDim2.new(1,0,strength,0)
      sig.BackgroundColor3 = strength>0.8 and GRN or (strength>0.4 and YEL or RED)
      -- Earth only becomes visible on the panel once you are close: the sighting
      -- scope on the real dish worked the same way round.
      earth.BackgroundTransparency = strength>0.55 and 0 or 1
      if strength>0.88 then
        held+=dt
        status.TextColor3=YEL; status.Text=("LOCKED — holding %.1fs"):format(held)
        if held>1.2 then
          running=false
          tvTxt.Text="● LIVE FROM HADLEY"; tvTxt.TextColor3=GRN
          status.TextColor3=GRN
          status.Text="PICTURE RESTORED. Earth never moves in this sky — the Moon keeps one face turned to us, so the dish can be aimed once and left. That is how the world watched three days of driving at Hadley."
          task.spawn(P.finish)
        end
      else
        held=0
        status.TextColor3 = strength>0.4 and YEL or RED
        status.Text = strength>0.4 and "CARRIER — close, but not enough for pictures."
          or "SEARCHING — the dish is pointed at empty sky."
      end
    end,
  }
end

-- ============ 4. Opportunity's power budget ============
do
  local f=panel()
  local function meter(x,label,col)
    local holder=mk("Frame",{Size=UDim2.fromOffset(120,150),Position=UDim2.fromOffset(x,0),
      BackgroundTransparency=1},f)
    mk("TextLabel",{Size=UDim2.fromOffset(120,16),BackgroundTransparency=1,Font=Enum.Font.Gotham,
      TextSize=11,TextColor3=DIM,Text=label},holder)
    local b=mk("Frame",{Size=UDim2.fromOffset(120,120),Position=UDim2.fromOffset(0,22),
      BackgroundColor3=Color3.fromRGB(20,20,24),BorderSizePixel=0},holder)
    mk("UICorner",{CornerRadius=UDim.new(0,6)},b)
    mk("UIStroke",{Color=Color3.fromRGB(70,70,78),Thickness=1},b)
    local fillv=mk("Frame",{Size=UDim2.new(1,0,0,0),Position=UDim2.new(0,0,1,0),
      AnchorPoint=Vector2.new(0,1),BackgroundColor3=col,BorderSizePixel=0},b)
    local val=mk("TextLabel",{Size=UDim2.fromOffset(120,18),Position=UDim2.fromOffset(0,146),
      BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=12,TextColor3=col,Text=""},holder)
    return fillv,val
  end
  local sunFill,sunVal=meter(8,"PANEL ANGLE TO SUN",YEL)
  local dustFill,dustVal=meter(140,"DUST ON PANELS",Color3.fromRGB(200,140,80))
  local pwrFill,pwrVal=meter(272,"POWER",GRN)
  local tauFill,tauVal=meter(404,"DUST STORM (tau)",RED)
  local solLbl=mk("TextLabel",{Size=UDim2.fromOffset(560,30),Position=UDim2.fromOffset(8,170),
    BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=20,TextColor3=Color3.new(1,1,1),
    TextXAlignment=Enum.TextXAlignment.Left,Text=""},f)

  local tilt,dust,tau,power,sols,acc=0.2,0.35,1.0,1.0,5111,0
  P.oppy={
    frame=f,
    title="OPPORTUNITY  ·  power budget  ·  sol 5111",
    sub="This is what the team at JPL was trying to do in June 2018. Tilt the panels toward the Sun and brush the dust off. Do it as well as you can.  W / S tilt  ·  A / D brush.",
    start=function()
      tilt,dust,tau,power,sols,acc=0.2,0.35,1.0,1.0,5111,0
      status.TextColor3=YEL; status.Text="The sky is getting darker."
    end,
    step=function(dt)
      acc+=dt
      local sp=0.5*dt
      if down(Enum.KeyCode.W) then tilt=math.min(1,tilt+sp) end
      if down(Enum.KeyCode.S) then tilt=math.max(0,tilt-sp) end
      if down(Enum.KeyCode.A) or down(Enum.KeyCode.D) then dust=math.max(0,dust-sp*0.75) end
      -- the storm thickens no matter what the player does: tau 1 -> 10.8, the real peak
      tau=math.min(10.8,1.0+acc*0.42)
      dust=math.min(1,dust+dt*0.055*(tau/4))
      -- sunlight reaching the panels falls off exponentially with opacity
      local light=math.exp(-tau*0.235)
      power=math.clamp(light*(0.45+0.55*tilt)*(1-dust*0.7),0,1)
      sunFill.Size=UDim2.new(1,0,tilt,0);   sunVal.Text=("%d%%"):format(tilt*100)
      dustFill.Size=UDim2.new(1,0,dust,0);  dustVal.Text=("%d%%"):format(dust*100)
      pwrFill.Size=UDim2.new(1,0,power,0);  pwrVal.Text=("%d%%"):format(power*100)
      pwrFill.BackgroundColor3 = power>0.35 and GRN or (power>0.18 and YEL or RED)
      tauFill.Size=UDim2.new(1,0,tau/10.8,0); tauVal.Text=("%.1f"):format(tau)
      -- every good sol is a sol it really bought
      if power>0.17 then
        sols+=dt*7
        solLbl.Text=("SIM · SOL %d   ·   still alive"):format(sols)
        status.TextColor3 = power>0.35 and GRN or YEL
        status.Text = power>0.35 and "Holding. Keep the panels square to what light there is."
          or "Power low. The heaters are taking everything."
      else
        running=false
        solLbl.Text=("SIM ENDED · %d EXTRA SOLS"):format(sols-5111)
        status.TextColor3=Color3.fromRGB(200,200,210)
        status.Text="10 June 2018. The last signal.\n\n"..
          ("NASA's record: built for 90 sols, worked for more than 5,000, and drove 45.16 km. Your choices added %d simulated sols. "):format(sols-5111)..
          "Perseverance passed Opportunity's off-Earth driving-distance record on 11 October 2026, reaching 45.22 km. "..
          "More than a thousand commands were sent trying to wake it, because nobody wanted to stop trying.\n\n"..
          "Opportunity stopped. Mars exploration didn't: Curiosity is still driving, Perseverance is still collecting, and Ingenuity flew 72 times in air nobody thought could hold a helicopter."
        task.spawn(function() task.wait(0.5); P.finish(11) end)
      end
    end,
  }
end

-- ============ 5. the far-side relay ============
do
  local f=panel()
  local plot=mk("Frame",{Size=UDim2.fromOffset(580,190),Position=UDim2.fromOffset(0,0),
    BackgroundColor3=Color3.fromRGB(6,6,9),BorderSizePixel=0,ClipsDescendants=true},f)
  mk("UICorner",{CornerRadius=UDim.new(0,6)},plot)
  mk("UIStroke",{Color=Color3.fromRGB(70,70,78),Thickness=1},plot)
  -- a side view: Earth at the left, the Moon at the right, you behind it
  local earth=mk("Frame",{Size=UDim2.fromOffset(34,34),AnchorPoint=Vector2.new(0.5,0.5),
    Position=UDim2.fromScale(0.10,0.5),BackgroundColor3=Color3.fromRGB(90,150,225),
    BorderSizePixel=0},plot)
  mk("UICorner",{CornerRadius=UDim.new(1,0)},earth)
  mk("TextLabel",{Size=UDim2.fromOffset(60,14),Position=UDim2.new(0.10,-30,0.5,24),
    BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=11,
    TextColor3=Color3.fromRGB(150,205,255),Text="EARTH"},plot)
  local moon=mk("Frame",{Size=UDim2.fromOffset(44,44),AnchorPoint=Vector2.new(0.5,0.5),
    Position=UDim2.fromScale(0.62,0.5),BackgroundColor3=Color3.fromRGB(150,148,144),
    BorderSizePixel=0},plot)
  mk("UICorner",{CornerRadius=UDim.new(1,0)},moon)
  -- the half of the Moon that never sees Earth, and you standing on it
  local shade=mk("Frame",{Size=UDim2.fromOffset(22,44),AnchorPoint=Vector2.new(0,0.5),
    Position=UDim2.fromScale(0.62,0.5),BackgroundColor3=Color3.fromRGB(58,56,54),
    BorderSizePixel=0},plot)
  local you=mk("TextLabel",{Size=UDim2.fromOffset(70,14),Position=UDim2.new(0.655,0,0.5,-7),
    BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=11,TextColor3=YEL,
    TextXAlignment=Enum.TextXAlignment.Left,Text="◄ YOU"},plot)
  local relay=mk("Frame",{Size=UDim2.fromOffset(12,12),AnchorPoint=Vector2.new(0.5,0.5),
    BackgroundColor3=Color3.fromRGB(255,220,120),BorderSizePixel=0},plot)
  mk("UICorner",{CornerRadius=UDim.new(1,0)},relay)
  local beamA=mk("Frame",{Size=UDim2.fromOffset(0,2),AnchorPoint=Vector2.new(0,0.5),
    BackgroundColor3=Color3.fromRGB(120,230,150),BorderSizePixel=0,Visible=false,
    ZIndex=2},plot)
  local l2mark=mk("TextLabel",{Size=UDim2.fromOffset(120,14),Position=UDim2.new(0.80,-60,0.5,-40),
    BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=11,TextColor3=DIM,
    Text="L2"},plot)
  local readout=mk("TextLabel",{Size=UDim2.fromOffset(580,24),Position=UDim2.fromOffset(0,196),
    BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=14,TextColor3=YEL,
    TextXAlignment=Enum.TextXAlignment.Left,Text=""},f)

  -- x: how far along the Earth-Moon line. y: how far off that line (halo amplitude).
  local rx,ry,held=0.30,0.0,0
  local TARGET_X,TARGET_Y=0.80,0.17
  P.relay={
    frame=f,
    title="FAR-SIDE RELAY  ·  orbit plot",
    sub="There is no line of sight from here to Earth — the Moon itself is in the way. Put the relay somewhere that can see both at once.  A / D along the line  ·  W / S off it.",
    start=function()
      rx,ry,held=0.30,0.0,0
      beamA.Visible=false
      status.TextColor3=RED; status.Text="NO LINK. The relay cannot see Earth and the far side at the same time."
      readout.Text=""
    end,
    step=function(dt)
      local sp=0.30*dt
      if down(Enum.KeyCode.A) then rx-=sp end
      if down(Enum.KeyCode.D) then rx+=sp end
      if down(Enum.KeyCode.W) then ry-=sp end
      if down(Enum.KeyCode.S) then ry+=sp end
      rx=math.clamp(rx,0.14,0.95); ry=math.clamp(ry,-0.34,0.34)
      relay.Position=UDim2.fromScale(rx,0.5+ry)
      local dx,dy=rx-TARGET_X,math.abs(ry)-TARGET_Y
      local err=math.sqrt(dx*dx+dy*dy)
      -- behind the Moon but still off the line enough to see past it
      local blocked = rx>0.56 and rx<0.74 and math.abs(ry)<0.11
      if blocked then
        status.TextColor3=RED
        status.Text="BLOCKED. The relay is directly behind the Moon — from there it cannot see Earth either."
        readout.Text=("along %.2f   ·   off-line %.2f"):format(rx,math.abs(ry))
        beamA.Visible=false
        held=0
      elseif err<0.075 then
        held+=dt
        beamA.Visible=true
        -- draw it from Earth to the relay at the true angle: the whole point of this
        -- orbit is that the line to Earth CLEARS the Moon instead of running into it
        local ex,ey=0.10*580,0.5*190
        local px,py=rx*580,(0.5+ry)*190
        local bx,by=px-ex,py-ey
        beamA.Position=UDim2.fromOffset(ex,ey)
        beamA.Size=UDim2.fromOffset(math.sqrt(bx*bx+by*by),2)
        beamA.Rotation=math.deg(math.atan2(by,bx))
        status.TextColor3=YEL; status.Text=("ACQUIRING — holding %.1fs"):format(held)
        readout.Text="HALO ORBIT ABOUT EARTH–MOON L2  ·  sees Earth and the far side at once"
        if held>1.2 then
          running=false
          status.TextColor3=GRN
          status.Text="LINK ESTABLISHED. A relay in a halo orbit around the Earth–Moon L2 point, out past the Moon, can see Earth and the far side at the same time. China flew Queqiao there in 2018 so Chang'e 4 could land here and still talk to home.\n\nRanger 4 never had one. It arrived silent in 1962, and nobody heard a thing."
          task.spawn(function() P.finish(9) end)
        end
      else
        held=0; beamA.Visible=false
        status.TextColor3=RED
        status.Text = (rx<0.56) and "NO LINK. Too close to Earth — the far side is still hidden behind the Moon."
          or "NO LINK. Nearly. Hold it steady out past the Moon, a little off the line."
        readout.Text=("along %.2f   ·   off-line %.2f"):format(rx,math.abs(ry))
      end
    end,
  }
end

-- ============ 6. driving Sojourner ============
-- The real lesson: you cannot drive a rover on Mars. A command takes minutes to arrive,
-- so nobody ever steered it live. They planned a move, sent it, and waited to find out.
do
  local f=panel()
  local plot=mk("Frame",{Size=UDim2.fromOffset(400,190),Position=UDim2.fromOffset(0,0),
    BackgroundColor3=Color3.fromRGB(58,34,22),BorderSizePixel=0,ClipsDescendants=true},f)
  mk("UICorner",{CornerRadius=UDim.new(0,6)},plot)
  mk("UIStroke",{Color=Color3.fromRGB(70,70,78),Thickness=1},plot)
  local lander=mk("Frame",{Size=UDim2.fromOffset(18,18),AnchorPoint=Vector2.new(0.5,0.5),
    Position=UDim2.fromScale(0.10,0.5),BackgroundColor3=Color3.fromRGB(214,212,204),
    BorderSizePixel=0},plot)
  mk("TextLabel",{Size=UDim2.fromOffset(80,13),Position=UDim2.new(0.10,-40,0.5,14),
    BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=10,TextColor3=DIM,Text="LANDER"},plot)
  -- the rocks Sojourner actually went to look at
  local ROCKS={{0.44,0.30,"Barnacle Bill"},{0.52,0.70,"Scooby-Doo"}}
  for _,r in ipairs(ROCKS) do
    local b=mk("Frame",{Size=UDim2.fromOffset(26,22),AnchorPoint=Vector2.new(0.5,0.5),
      Position=UDim2.fromScale(r[1],r[2]),BackgroundColor3=Color3.fromRGB(104,62,42),
      BorderSizePixel=0},plot)
    mk("UICorner",{CornerRadius=UDim.new(0,5)},b)
    mk("TextLabel",{Size=UDim2.fromOffset(90,12),Position=UDim2.new(r[1],-45,r[2],16),
      BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=10,
      TextColor3=Color3.fromRGB(190,160,140),Text=r[3]},plot)
  end
  local TX,TY=0.80,0.46
  local target=mk("Frame",{Size=UDim2.fromOffset(30,26),AnchorPoint=Vector2.new(0.5,0.5),
    Position=UDim2.fromScale(TX,TY),BackgroundColor3=Color3.fromRGB(128,82,54),
    BorderSizePixel=0},plot)
  mk("UICorner",{CornerRadius=UDim.new(0,5)},target)
  mk("UIStroke",{Color=YEL,Thickness=1},target)
  mk("TextLabel",{Size=UDim2.fromOffset(90,12),Position=UDim2.new(TX,-45,TY,18),
    BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=10,TextColor3=YEL,
    Text="Yogi"},plot)
  local rover=mk("Frame",{Size=UDim2.fromOffset(11,11),AnchorPoint=Vector2.new(0.5,0.5),
    Position=UDim2.fromScale(0.16,0.5),BackgroundColor3=Color3.fromRGB(245,231,60),
    BorderSizePixel=0,ZIndex=3},plot)
  local aim=mk("Frame",{Size=UDim2.fromOffset(0,2),AnchorPoint=Vector2.new(0,0.5),
    BackgroundColor3=Color3.fromRGB(240,230,160),BackgroundTransparency=0.35,
    BorderSizePixel=0,ZIndex=2},plot)
  local info=mk("TextLabel",{Size=UDim2.fromOffset(168,190),Position=UDim2.fromOffset(412,0),
    BackgroundTransparency=1,Font=Enum.Font.GothamMedium,TextSize=13,TextColor3=Color3.fromRGB(210,210,215),
    TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,
    Text=""},f)

  local head,dist,sols,phase,t=0,0.30,0,"plan",0
  local rx,ry=0.16,0.5
  local sx,sy=0.16,0.5
  local function redraw()
    rover.Position=UDim2.fromScale(rx,ry)
    local ex=rx+math.cos(math.rad(head))*dist
    local ey=ry+math.sin(math.rad(head))*dist*0.5
    local ax,ay=rx*400,ry*190
    local bx,by=ex*400,ey*190
    aim.Position=UDim2.fromOffset(ax,ay)
    aim.Size=UDim2.fromOffset(math.sqrt((bx-ax)^2+(by-ay)^2),2)
    aim.Rotation=math.deg(math.atan2(by-ay,bx-ax))
    info.Text=("SOL %d\n\nHEADING  %+d deg\nDISTANCE %.2f\n\nW / S  heading\nA / D  distance\n[ + ]  send the command")
      :format(sols,head,dist)
  end
  P.sojourner={
    frame=f,
    title="SOJOURNER  ·  drive plan",
    sub="You cannot steer it. A command takes minutes to reach Mars, so plan the move, send it, and wait to find out what happened.  W / S heading · A / D distance · [ + ] send.",
    start=function()
      head,dist,sols,phase,t=0,0.30,0,"plan",0
      rx,ry=0.16,0.5
      aim.Visible=true
      redraw()
      status.TextColor3=YEL
      status.Text="Yogi is the big rock to the east. Plan a drive that gets there without running into anything."
    end,
    step=function(dt)
      if phase=="plan" then
        local sp=34*dt
        if down(Enum.KeyCode.W) then head=math.clamp(head-sp,-60,60) end
        if down(Enum.KeyCode.S) then head=math.clamp(head+sp,-60,60) end
        if down(Enum.KeyCode.D) then dist=math.clamp(dist+sp*0.012,0.05,0.75) end
        if down(Enum.KeyCode.A) then dist=math.clamp(dist-sp*0.012,0.05,0.75) end
        redraw()
        if takeTap(Enum.KeyCode.Up) then
          phase="uplink"; t=0; aim.Visible=false
          sx,sy=rx,ry
          status.TextColor3=CYAN
          status.Text="COMMAND SENT. Mars is about 11 light-minutes away today, so this takes 11 minutes to arrive — and 11 more before you hear what happened.  [ x compressed ]"
        end
        return
      end
      if phase=="uplink" then
        t+=dt
        if t>2.1 then phase="drive"; t=0 end
        return
      end
      if phase=="drive" then
        t+=dt
        local k=math.min(t/2.2,1)
        local ex=sx+math.cos(math.rad(head))*dist
        local ey=sy+math.sin(math.rad(head))*dist*0.5
        rx=sx+(ex-sx)*k; ry=sy+(ey-sy)*k
        rover.Position=UDim2.fromScale(rx,ry)
        -- did it hit one of the rocks on the way?
        for _,r in ipairs(ROCKS) do
          if math.abs(rx-r[1])<0.045 and math.abs(ry-r[2])<0.10 then
            phase="report"; t=0; sols+=1
            status.TextColor3=RED
            status.Text=("It stopped against %s. The hazard cameras saw the rock and the rover halted itself, exactly as it was told to. You find out a sol later."):format(r[3])
            info.Text=("SOL %d\n\nDRIVE HALTED\n\n[ + ] plan again"):format(sols)
            return
          end
        end
        if k>=1 then
          phase="report"; t=0; sols+=1
          if math.abs(rx-TX)<0.085 and math.abs(ry-TY)<0.13 then
            running=false
            status.TextColor3=GRN
            status.Text="AT YOGI. The spectrometer goes against the rock overnight.\n\nNobody ever drove this rover live. Every move was planned on Earth, sent, and the answer came back minutes later — which is why it covered about 100 metres in 83 sols, and why that was still extraordinary."
            info.Text=("SOL %d\n\nTARGET REACHED"):format(sols)
            task.spawn(function() P.finish(10) end)
          else
            status.TextColor3=YEL
            -- say which way it missed: planning the next move depends on knowing
            local past = rx>TX+0.085
            local offLine = math.abs(ry-TY)>=0.13
            status.Text = offLine and "It drove past to one side. The heading was off; the distance was about right. Plan the next one from where it actually stopped."
              or past and "It overshot and stopped beyond the rock. Too much distance in that command. Plan the next one."
              or "The drive finished short of the rock. No harm done — it simply stopped where the command ran out. Plan the next one."
            info.Text=("SOL %d\n\nDRIVE COMPLETE\n\n[ + ] plan again"):format(sols)
          end
        end
        return
      end
      if phase=="report" then
        t+=dt
        if t>0.6 and takeTap(Enum.KeyCode.Up) then
          phase="plan"; aim.Visible=true; redraw()
          status.TextColor3=YEL
          status.Text="Plan the next move from where it actually stopped."
        end
      end
    end,
  }
end

-- ---------- dispatch ----------
local cur=nil
function P.finish(wait_s)
  solved=true
  rem.SolvePuzzle:FireServer(openId,false)
  freeze(false)
  task.wait(wait_s or 5.5)
  gui.Enabled=false; running=false; openId=nil; solved=false
  if cur then cur.frame.Visible=false end
  cur=nil
end
local function close(abandon)
  if openId and abandon and not solved then rem.SolvePuzzle:FireServer(openId,true) end
  gui.Enabled=false; freeze(false); running=false; openId=nil; solved=false
  if cur then cur.frame.Visible=false end
  cur=nil
end

rem.OpenPuzzle.OnClientEvent:Connect(function(id)
  if running then return end
  local p=P[id]
  if not p then warn("Reactivate: no panel for "..tostring(id)) return end
  openId=id; running=true; solved=false
  if cur then cur.frame.Visible=false end
  cur=p
  title.Text=p.title; sub.Text=p.sub
  p.frame.Visible=true
  p.start()
  freeze(true)
  gui.Enabled=true
end)

rem:WaitForChild("LocalKey").Event:Connect(function(code,phase)
  if typeof(code)~="EnumItem" then return end
  if phase=="up" then keys[code]=nil else keys[code]=true; tapped[code]=true end
  if code==Enum.KeyCode.Q and phase~="up" and gui.Enabled then close(true) end
end)
UIS.InputBegan:Connect(function(i,gpe)
  if i.UserInputType==Enum.UserInputType.Keyboard then keys[i.KeyCode]=true; tapped[i.KeyCode]=true end
  if running and not gpe and i.KeyCode==Enum.KeyCode.Q then close(true) end
end)
UIS.InputEnded:Connect(function(i)
  if i.UserInputType==Enum.UserInputType.Keyboard then keys[i.KeyCode]=nil end
end)

xBtn.MouseButton1Click:Connect(function() if running then close(true) end end)

RS.RenderStepped:Connect(function(dt)
  if not running or solved or not cur then return end
  local ok,err=pcall(cur.step,math.min(dt,0.05))
  if not ok then warn("Reactivate step: "..tostring(err)) end
end)

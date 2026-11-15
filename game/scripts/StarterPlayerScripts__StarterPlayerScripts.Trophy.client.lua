-- LocalScript  StarterPlayerScripts/StarterPlayerScripts.Trophy
-- THE TROPHY ROOM. Opened from the settings button, any time, anywhere: everything the
-- crew has recovered, everything still out there as a silhouette, and how far along you are.
-- It replaced a physical replica hall that used to stand beside Eagle at Tranquility.
local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local TS=game:GetService("TweenService")
local RSrv=game:GetService("ReplicatedStorage")
local plr=Players.LocalPlayer
local pg=plr:WaitForChild("PlayerGui")
local rem=RSrv:WaitForChild("Remotes")
local IDX=require(RSrv:WaitForChild("ArtifactIndex"))

local YEL=Color3.fromRGB(245,231,60)
local CYAN=Color3.fromRGB(150,205,255)
local GRN=Color3.fromRGB(120,230,150)
local DIM=Color3.fromRGB(150,156,164)
local INK=Color3.fromRGB(8,8,10)
local function mk(c,p,par) local o=Instance.new(c)
  for k,v in pairs(p) do o[k]=v end
  -- A UIStroke on a text object outlines the letters, not the box. We always mean the box.
  if c=="UIStroke" and p.ApplyStrokeMode==nil and par
     and (par:IsA("TextButton") or par:IsA("TextLabel") or par:IsA("TextBox")) then
    o.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
  end
  o.Parent=par return o end

-- Spinning models cost a render pass each. Phones and tablets get still ones by default;
-- the settings menu can switch motion back on (or off on a desktop that struggles).
local STILL=UIS.TouchEnabled

local found={}        -- artifact id -> {by=...}
local online={}
local read={}         -- archive ids the player has read (the unreachable ones)

-- ---------- settings button + menu ----------
local gui=mk("ScreenGui",{Name="Settings",ResetOnSpawn=false,IgnoreGuiInset=true,
  DisplayOrder=7},pg)
local cog=mk("TextButton",{Name="Cog",Size=UDim2.fromOffset(44,44),Position=UDim2.new(1,-60,0,16),
  BackgroundColor3=Color3.fromRGB(14,15,18),BackgroundTransparency=0.12,AutoButtonColor=true,
  Font=Enum.Font.GothamBold,TextSize=20,TextColor3=YEL,Text="\u{2699}"},gui)
mk("UICorner",{CornerRadius=UDim.new(0,10)},cog)
mk("UIStroke",{Color=Color3.fromRGB(70,74,82),Thickness=1},cog)

local menu=mk("Frame",{Name="Menu",Size=UDim2.fromOffset(212,204),Position=UDim2.new(1,-228,0,68),
  BackgroundColor3=INK,BackgroundTransparency=0.06,BorderSizePixel=0,Visible=false},gui)
mk("UICorner",{CornerRadius=UDim.new(0,10)},menu)
mk("UIStroke",{Color=Color3.fromRGB(70,74,82),Thickness=1},menu)
mk("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},menu)
mk("UIPadding",{PaddingTop=UDim.new(0,10),PaddingLeft=UDim.new(0,10),
  PaddingRight=UDim.new(0,10)},menu)
local function menuItem(label,order)
  local b=mk("TextButton",{Size=UDim2.new(1,0,0,40),BackgroundColor3=Color3.fromRGB(28,30,35),
    AutoButtonColor=true,Font=Enum.Font.GothamBold,TextSize=14,TextColor3=Color3.new(1,1,1),
    Text=label,LayoutOrder=order},menu)
  mk("UICorner",{CornerRadius=UDim.new(0,7)},b)
  return b
end
local btnMap=menuItem("SURVEY MAP",0)
local btnTrophy=menuItem("TROPHY ROOM",1)
local btnControls=menuItem("CONTROLS",2)
local btnMotion=menuItem("",3)
local function motionLabel()
  btnMotion.Text=STILL and "MOTION: OFF" or "MOTION: ON"
end

-- ---------- the trophy room ----------
local room=mk("ScreenGui",{Name="TrophyRoom",ResetOnSpawn=false,IgnoreGuiInset=true,
  Enabled=false,DisplayOrder=13},pg)
mk("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(0,0,0),
  BackgroundTransparency=0.25,BorderSizePixel=0},room)
local panel=mk("Frame",{Size=UDim2.fromOffset(940,580),AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),
  BackgroundColor3=INK,BackgroundTransparency=0.04,BorderSizePixel=0},room)
mk("UICorner",{CornerRadius=UDim.new(0,12)},panel)
mk("UIStroke",{Color=Color3.fromRGB(60,64,72),Thickness=1},panel)
local sc=mk("UIScale",{},panel)
local function fit()
  local vp=workspace.CurrentCamera.ViewportSize
  sc.Scale=math.min(1,(vp.X-20)/940,(vp.Y-20)/580)
end
fit(); workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fit)

mk("TextLabel",{Size=UDim2.fromOffset(600,18),Position=UDim2.fromOffset(24,18),
  BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=13,TextColor3=CYAN,
  TextXAlignment=Enum.TextXAlignment.Left,Text="ASTROLOG  ·  RECOVERED BY THIS CREW"},panel)
mk("TextLabel",{Size=UDim2.fromOffset(600,34),Position=UDim2.fromOffset(24,38),
  BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=27,TextColor3=Color3.new(1,1,1),
  TextXAlignment=Enum.TextXAlignment.Left,Text="Trophy Room"},panel)
local close=mk("TextButton",{Size=UDim2.fromOffset(104,32),Position=UDim2.new(1,-128,0,22),
  BackgroundColor3=Color3.fromRGB(30,32,36),AutoButtonColor=true,Font=Enum.Font.GothamBold,
  TextSize=14,TextColor3=YEL,Text="[Q] close"},panel)
mk("UICorner",{CornerRadius=UDim.new(0,7)},close)

-- progress bar
local barBg=mk("Frame",{Size=UDim2.fromOffset(892,12),Position=UDim2.fromOffset(24,86),
  BackgroundColor3=Color3.fromRGB(28,30,35),BorderSizePixel=0},panel)
mk("UICorner",{CornerRadius=UDim.new(1,0)},barBg)
local barFill=mk("Frame",{Size=UDim2.fromScale(0,1),BackgroundColor3=YEL,BorderSizePixel=0},barBg)
mk("UICorner",{CornerRadius=UDim.new(1,0)},barFill)
local tally=mk("TextLabel",{Size=UDim2.fromOffset(892,20),Position=UDim2.fromOffset(24,104),
  BackgroundTransparency=1,Font=Enum.Font.GothamMedium,TextSize=13,TextColor3=YEL,
  TextXAlignment=Enum.TextXAlignment.Left,Text=""},panel)

local scroll=mk("ScrollingFrame",{Size=UDim2.fromOffset(892,424),Position=UDim2.fromOffset(24,132),
  BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=5,
  CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y},panel)
mk("UIListLayout",{Padding=UDim.new(0,10),SortOrder=Enum.SortOrder.LayoutOrder},scroll)

local MODELS=RSrv:WaitForChild("TrophyModels",20)
local rows={}

local function header(text,order)
  local f=mk("Frame",{Size=UDim2.new(1,-8,0,24),BackgroundTransparency=1,LayoutOrder=order},scroll)
  mk("TextLabel",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Font=Enum.Font.GothamBold,
    TextSize=12,TextColor3=CYAN,TextXAlignment=Enum.TextXAlignment.Left,
    TextYAlignment=Enum.TextYAlignment.Bottom,Text=string.upper(text)},f)
  table.insert(rows,f); return f
end

local function grid(order)
  local f=mk("Frame",{Size=UDim2.new(1,-8,0,0),AutomaticSize=Enum.AutomaticSize.Y,
    BackgroundTransparency=1,LayoutOrder=order},scroll)
  mk("UIGridLayout",{CellSize=UDim2.fromOffset(166,176),CellPadding=UDim2.fromOffset(10,10),
    SortOrder=Enum.SortOrder.LayoutOrder},f)
  table.insert(rows,f); return f
end

-- One tile. The model is not built until the tile is actually scrolled into view, and its
-- ViewportFrame is switched off the moment it leaves: each visible viewport is a separate
-- render pass, so what costs performance is how many are on screen, not how many triangles
-- they contain (the whole set is about 5,000 — nothing). This keeps ~8 live instead of 25.
local tiles={}        -- every tile, visible or not

local function mount(e)
  if e.mounted then return end
  e.mounted=true
  local src=MODELS and MODELS:FindFirstChild(e.id)
  if not src then
    mk("TextLabel",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Font=Enum.Font.GothamBold,
      TextSize=34,TextColor3=Color3.fromRGB(60,64,70),Text="?"},e.vp)
    return
  end
  local m=src:Clone()
  if not e.got then
    for _,d in ipairs(m:GetDescendants()) do
      if d:IsA("BasePart") then
        d.Color=Color3.fromRGB(6,7,9); d.Material=Enum.Material.SmoothPlastic
        d.Reflectance=0; d.Transparency=(d.Transparency>=1) and 1 or 0
      end
    end
  end
  m.Parent=e.vp
  local cam=Instance.new("Camera"); cam.Parent=e.vp; e.vp.CurrentCamera=cam
  local extent=src:GetAttribute("Extent") or 10
  e.cam=cam
  e.dist=math.max(2.5,extent*0.95)
  -- park it at a pleasant three-quarter angle for the still case
  e.cam.CFrame=CFrame.new(Vector3.new(math.sin(2.3)*e.dist,e.dist*0.45,math.cos(2.3)*e.dist),
    Vector3.new(0,0,0))
end

local function tile(parent,order,id,gotIt,title,sub,tagText)
  local card=mk("Frame",{Size=UDim2.fromOffset(166,176),LayoutOrder=order,
    BackgroundColor3=gotIt and Color3.fromRGB(24,27,31) or Color3.fromRGB(15,16,19),
    BorderSizePixel=0},parent)
  mk("UICorner",{CornerRadius=UDim.new(0,10)},card)
  mk("UIStroke",{Color=gotIt and Color3.fromRGB(70,86,72) or Color3.fromRGB(32,34,38),
    Thickness=1},card)
  local vp=mk("ViewportFrame",{Size=UDim2.fromOffset(150,112),Position=UDim2.fromOffset(8,8),
    BackgroundColor3=gotIt and Color3.fromRGB(12,14,18) or Color3.fromRGB(10,11,13),
    BorderSizePixel=0,Visible=false,
    Ambient=gotIt and Color3.fromRGB(150,150,160) or Color3.fromRGB(28,28,32),
    LightColor=gotIt and Color3.fromRGB(255,250,240) or Color3.fromRGB(40,40,46),
    LightDirection=Vector3.new(-0.4,-1,-0.6)},card)
  mk("UICorner",{CornerRadius=UDim.new(0,7)},vp)

  mk("TextLabel",{Size=UDim2.fromOffset(150,20),Position=UDim2.fromOffset(8,124),
    BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=14,
    TextColor3=gotIt and Color3.new(1,1,1) or Color3.fromRGB(96,100,108),
    TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,
    Text=gotIt and title or "? ? ? ?"},card)
  mk("TextLabel",{Size=UDim2.fromOffset(150,16),Position=UDim2.fromOffset(8,144),
    BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=11,
    TextColor3=gotIt and DIM or Color3.fromRGB(74,78,86),
    TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,
    Text=sub},card)
  if tagText and tagText~="" then
    mk("TextLabel",{Size=UDim2.fromOffset(150,14),Position=UDim2.fromOffset(8,159),
      BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=10,TextColor3=YEL,
      TextXAlignment=Enum.TextXAlignment.Left,Text=tagText},card)
  end
  local e={card=card,vp=vp,id=id,got=gotIt,mounted=false,cam=nil,dist=10,phase=(order%7)*0.9}
  table.insert(tiles,e)
  return card
end

-- which tiles overlap the scroll window right now
local function cull()
  if not room.Enabled then return end
  local top=scroll.AbsolutePosition.Y
  local bottom=top+scroll.AbsoluteSize.Y
  for _,e in ipairs(tiles) do
    local y=e.card.AbsolutePosition.Y
    local h=e.card.AbsoluteSize.Y
    local onScreen=(y+h>=top-60) and (y<=bottom+60)
    if onScreen and not e.mounted then mount(e) end
    if e.vp.Visible~=onScreen then e.vp.Visible=onScreen end
    e.onScreen=onScreen
  end
end
scroll:GetPropertyChangedSignal("CanvasPosition"):Connect(cull)

-- turn only what is on screen, and only 24 times a second rather than every frame
local acc=0
game:GetService("RunService").RenderStepped:Connect(function(dt)
  if not room.Enabled or STILL then return end
  acc+=dt
  if acc<1/24 then return end
  acc=0
  local t=tick()
  for _,e in ipairs(tiles) do
    if e.onScreen and e.cam then
      local a=t*0.55+e.phase
      e.cam.CFrame=CFrame.new(
        Vector3.new(math.sin(a)*e.dist,e.dist*0.45,math.cos(a)*e.dist),Vector3.new(0,0,0))
    end
  end
end)

local function clearRows()
  for _,r in ipairs(rows) do r:Destroy() end
  rows={}; tiles={}
end

local function render()
  clearRows()
  local n,order=0,0
  local lastSite,g=nil,nil
  for _,id in ipairs(IDX.ORDER) do
    local site=IDX.SITEOF[id]
    if site~=lastSite then
      lastSite=site; order+=1
      local world=IDX.WORLD[site] or ""
      header(site..(world~="" and ("   \u{00B7}   "..world) or ""),order)
      order+=1; g=grid(order)
    end
    local d=found[id]
    if d then n+=1 end
    local tag=(d and online[id]) and (IDX.ONLINE_LABEL[id] or "ONLINE") or ""
    tile(g,order,id,d~=nil,IDX.SHORT[id],
      d and ("found by "..(d.by or "?")) or "still out there", tag)
  end
  order+=1
  header("Too far to stand on   \u{00B7}   catalogued from the archive",order)
  order+=1
  local g2=grid(order)
  local m=0
  for _,u in ipairs(IDX.UNREACHABLE) do
    local got=read[u.id]==true
    if got then m+=1 end
    tile(g2,order,u.id,got,u.name,got and u.where or "read its card","")
  end
  local total=#IDX.ORDER
  barFill.Size=UDim2.fromScale(n/total,1)
  barFill.BackgroundColor3=(n==total) and GRN or YEL
  tally.Text=("%d of %d found   \u{00B7}   %d of %d catalogued from a distance")
    :format(n,total,m,#IDX.UNREACHABLE)
  task.defer(cull)   -- AbsolutePosition is only right once the layout has run
end

-- ---------- controls sheet ----------
local sheet=mk("ScreenGui",{Name="Controls",ResetOnSpawn=false,IgnoreGuiInset=true,
  Enabled=false,DisplayOrder=13},pg)
mk("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(0,0,0),
  BackgroundTransparency=0.3,BorderSizePixel=0},sheet)
local cpanel=mk("Frame",{Size=UDim2.fromOffset(460,330),AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),
  BackgroundColor3=INK,BackgroundTransparency=0.04,BorderSizePixel=0},sheet)
mk("UICorner",{CornerRadius=UDim.new(0,12)},cpanel)
local csc=mk("UIScale",{},cpanel)
local function cfit()
  local vp=workspace.CurrentCamera.ViewportSize
  csc.Scale=math.min(1,(vp.X-20)/460,(vp.Y-20)/330)
end
cfit(); workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(cfit)
mk("UIStroke",{Color=Color3.fromRGB(60,64,72),Thickness=1},cpanel)
mk("TextLabel",{Size=UDim2.fromOffset(400,30),Position=UDim2.fromOffset(24,18),
  BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=22,TextColor3=Color3.new(1,1,1),
  TextXAlignment=Enum.TextXAlignment.Left,Text="Controls"},cpanel)
mk("TextLabel",{Size=UDim2.fromOffset(412,230),Position=UDim2.fromOffset(24,58),
  BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=15,TextColor3=Color3.fromRGB(210,212,218),
  TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,TextWrapped=true,
  Text="E      scan whatever you are standing next to\nR      remember — watch it working\nF      reactivate, where there is something to work\nV      switch between first and third person\nM      the survey map\nL      the logbook (or tap it, top left)\nAlt    free the mouse pointer (Option on a Mac)\nQ      close a card or a panel\n\nOn a phone or tablet the same five appear as buttons.\n\nThe survey log is in the top left. This panel, the map\nand the trophy room are behind the gear, top right."},cpanel)
local cclose=mk("TextButton",{Size=UDim2.fromOffset(104,32),Position=UDim2.new(1,-128,1,-48),
  BackgroundColor3=Color3.fromRGB(30,32,36),AutoButtonColor=true,Font=Enum.Font.GothamBold,
  TextSize=14,TextColor3=YEL,Text="[Q] close"},cpanel)
mk("UICorner",{CornerRadius=UDim.new(0,7)},cclose)

-- ---------- open / close ----------
local function walk(on)
  local c=plr.Character; local h=c and c:FindFirstChildOfClass("Humanoid")
  if h then h.WalkSpeed=on and 11 or 0 end
end
local function closeAll()
  room.Enabled=false; sheet.Enabled=false; menu.Visible=false; walk(true)
end
local function openRoom()
  menu.Visible=false
  render()
  room.Enabled=true
  walk(false)
end
motionLabel()
cog.MouseButton1Click:Connect(function()
  if room.Enabled or sheet.Enabled then closeAll() return end
  menu.Visible=not menu.Visible
end)
btnTrophy.MouseButton1Click:Connect(openRoom)
btnMap.MouseButton1Click:Connect(function()
  menu.Visible=false
  rem:WaitForChild("OpenMap"):Fire()
end)
btnMotion.MouseButton1Click:Connect(function()
  STILL=not STILL
  motionLabel()
end)
btnControls.MouseButton1Click:Connect(function()
  menu.Visible=false; sheet.Enabled=true; walk(false)
end)
close.MouseButton1Click:Connect(closeAll)
cclose.MouseButton1Click:Connect(closeAll)

local function onKey(code)
  if code==Enum.KeyCode.Q and (room.Enabled or sheet.Enabled) then closeAll()
  elseif code==Enum.KeyCode.Tab then
    if room.Enabled then closeAll() else openRoom() end
  end
end
UIS.InputBegan:Connect(function(i,gpe)
  if gpe then return end
  onKey(i.KeyCode)
end)
rem:WaitForChild("LocalKey").Event:Connect(function(code,phase)
  if phase~="up" then onKey(code) end
end)

-- ---------- state ----------
rem:WaitForChild("LogUpdate").OnClientEvent:Connect(function(snap)
  found={}
  for k,v in pairs(snap or {}) do if v then found[k]=v end end
  if room.Enabled then render() end
end)
rem:WaitForChild("OnlineUpdate").OnClientEvent:Connect(function(snap)
  online=snap or {}
  if room.Enabled then render() end
end)
-- reading a card in the archive counts as cataloguing the ones nobody can reach
-- opening an entry at the NSSDCA terminal catalogues it
rem:WaitForChild("Catalogued").Event:Connect(function(id)
  if id then read[id]=true; if room.Enabled then render() end end
end)

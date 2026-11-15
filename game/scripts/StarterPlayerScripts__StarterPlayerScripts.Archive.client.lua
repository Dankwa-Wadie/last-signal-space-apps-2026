-- LocalScript  StarterPlayerScripts/StarterPlayerScripts.Archive
-- The NSSDCA terminal. Every piece of equipment named in the challenge, read from NASA's
-- catalogue. It used to be maps and paragraphs; it is now a grid of the actual machines,
-- because this is a game for people who would rather look than read.
local Players=game:GetService("Players")
local RSrv=game:GetService("ReplicatedStorage")
local UIS=game:GetService("UserInputService")
local RS=game:GetService("RunService")
local plr=Players.LocalPlayer
local pg=plr:WaitForChild("PlayerGui")
local CAT=require(RSrv:WaitForChild("ArchiveCatalog"))
local rem=RSrv:WaitForChild("Remotes")
local MODELS=RSrv:WaitForChild("TrophyModels",20)

local YEL=Color3.fromRGB(245,231,60); local CYAN=Color3.fromRGB(150,205,255)
local GRN=Color3.fromRGB(120,230,150)
local INK=Color3.fromRGB(8,8,10); local DIM=Color3.fromRGB(154,160,166)
local function mk(c,p,par) local o=Instance.new(c)
  for k,v in pairs(p) do o[k]=v end
  -- A UIStroke on a text object outlines the letters, not the box. We always mean the box.
  if c=="UIStroke" and p.ApplyStrokeMode==nil and par
     and (par:IsA("TextButton") or par:IsA("TextLabel") or par:IsA("TextBox")) then
    o.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
  end
  o.Parent=par return o end

-- catalogue id -> the model kept in ReplicatedStorage.TrophyModels
local MODEL_OF={apollo11_lm="lm",apollo12_alsep="a12alsep",apollo15_lrv="lrv",
  surveyor3="surv3",opportunity="oppy"}
-- short captions: the full NSSDCA names do not fit a tile, and children scan labels
local TILE_NAME={apollo11_lm="Apollo 11\nEagle",apollo12_alsep="Apollo 12\nALSEP",
  apollo15_lrv="Apollo 15\nRover",surveyor3="Surveyor 3",viking1="Viking 1",
  viking2="Viking 2",pathfinder="Pathfinder\n& Sojourner",spirit="Spirit",
  opportunity="Opportunity",phoenix="Phoenix",insight="InSight",ingenuity="Ingenuity",
  near="NEAR\nShoemaker",dawn="Dawn",kepler="Kepler",pioneer10="Pioneer 10",
  pioneer11="Pioneer 11",voyager1="Voyager 1"}
local function modelFor(id) return MODELS and MODELS:FindFirstChild(MODEL_OF[id] or id) end

-- which catalogue entries the crew has already recovered in the field
local FOUND_MAP={lm="apollo11_lm",seis="apollo11_lm",retro="apollo11_lm",
  surv3="surveyor3",a12alsep="apollo12_alsep",
  falcon="apollo15_lrv",lrv="apollo15_lrv",lrrr15="apollo15_lrv",
  oppy="opportunity",heatshield="opportunity",
  pathfinder="pathfinder",sojourner="pathfinder",
  viking1="viking1",viking2="viking2",spirit="spirit",phoenix="phoenix",
  insight="insight",ingenuity="ingenuity",near="near"}
local found={}
local refresh=nil
rem:WaitForChild("LogUpdate").OnClientEvent:Connect(function(snap)
  for k,v in pairs(snap or {}) do if v and FOUND_MAP[k] then found[FOUND_MAP[k]]=true end end
  if refresh then refresh() end
end)
local Catalogued=rem:WaitForChild("Catalogued")   -- BindableEvent: tells the trophy room

local gui=mk("ScreenGui",{Name="Archive",ResetOnSpawn=false,IgnoreGuiInset=true,
  Enabled=false,DisplayOrder=5},pg)
mk("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(0,0,0),
  BackgroundTransparency=0.35,BorderSizePixel=0},gui)
local panel=mk("Frame",{Size=UDim2.fromOffset(980,600),AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),
  BackgroundColor3=INK,BackgroundTransparency=0.04,BorderSizePixel=0},gui)
mk("UICorner",{CornerRadius=UDim.new(0,12)},panel)
mk("UIStroke",{Color=Color3.fromRGB(60,64,72),Thickness=1},panel)
local uiScale=mk("UIScale",{},panel)
local function fit()
  local vp=workspace.CurrentCamera.ViewportSize
  uiScale.Scale=math.min(1,(vp.X-20)/980,(vp.Y-20)/600)
end
fit(); workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fit)

mk("TextLabel",{Size=UDim2.fromOffset(640,18),Position=UDim2.fromOffset(24,18),
  BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=12,TextColor3=CYAN,
  TextXAlignment=Enum.TextXAlignment.Left,
  Text="NASA SPACE SCIENCE DATA COORDINATED ARCHIVE  ·  NSSDCA"},panel)
mk("TextLabel",{Size=UDim2.fromOffset(640,32),Position=UDim2.fromOffset(24,36),
  BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=26,TextColor3=Color3.new(1,1,1),
  TextXAlignment=Enum.TextXAlignment.Left,Text="Everything we left out there"},panel)
local close=mk("TextButton",{Size=UDim2.fromOffset(104,32),Position=UDim2.new(1,-128,0,22),
  BackgroundColor3=Color3.fromRGB(30,32,36),AutoButtonColor=true,Font=Enum.Font.GothamBold,
  TextSize=14,TextColor3=YEL,Text="[Q] close"},panel)
mk("UICorner",{CornerRadius=UDim.new(0,7)},close)

local tabs={"Moon","Mars","Beyond"}
local tabBtn={}
for i,name in ipairs(tabs) do
  local b=mk("TextButton",{Size=UDim2.fromOffset(112,32),Position=UDim2.fromOffset(24+(i-1)*120,78),
    BackgroundColor3=Color3.fromRGB(30,32,36),Font=Enum.Font.GothamBold,TextSize=15,
    TextColor3=Color3.new(1,1,1),Text=string.upper(name)},panel)
  mk("UICorner",{CornerRadius=UDim.new(0,7)},b)
  tabBtn[name]=b
end

-- left: the grid of machines.  right: the one you picked, big.
local scroll=mk("ScrollingFrame",{Size=UDim2.fromOffset(590,458),Position=UDim2.fromOffset(24,122),
  BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=5,
  CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y},panel)
mk("UIGridLayout",{CellSize=UDim2.fromOffset(136,150),CellPadding=UDim2.fromOffset(10,10),
  SortOrder=Enum.SortOrder.LayoutOrder},scroll)

local detail=mk("Frame",{Size=UDim2.fromOffset(322,458),Position=UDim2.fromOffset(634,122),
  BackgroundColor3=Color3.fromRGB(16,17,20),BorderSizePixel=0},panel)
mk("UICorner",{CornerRadius=UDim.new(0,10)},detail)
local bigVp=mk("ViewportFrame",{Size=UDim2.fromOffset(298,180),Position=UDim2.fromOffset(12,12),
  BackgroundColor3=Color3.fromRGB(11,13,17),BorderSizePixel=0,
  Ambient=Color3.fromRGB(150,150,160),LightColor=Color3.fromRGB(255,250,240),
  LightDirection=Vector3.new(-0.4,-1,-0.6)},detail)
mk("UICorner",{CornerRadius=UDim.new(0,8)},bigVp)
local dName=mk("TextLabel",{Size=UDim2.fromOffset(298,24),Position=UDim2.fromOffset(12,202),
  BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=17,TextColor3=Color3.new(1,1,1),
  TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,Text=""},detail)
local dWhere=mk("TextLabel",{Size=UDim2.fromOffset(298,34),Position=UDim2.fromOffset(12,228),
  BackgroundTransparency=1,Font=Enum.Font.GothamMedium,TextSize=12,TextColor3=CYAN,
  TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,
  TextYAlignment=Enum.TextYAlignment.Top,Text=""},detail)
local dEnd=mk("TextLabel",{Size=UDim2.fromOffset(298,30),Position=UDim2.fromOffset(12,264),
  BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=13,TextColor3=YEL,
  TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,
  TextYAlignment=Enum.TextYAlignment.Top,Text=""},detail)
local dStory=mk("TextLabel",{Size=UDim2.fromOffset(298,120),Position=UDim2.fromOffset(12,298),
  BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=13,TextColor3=Color3.fromRGB(205,207,213),
  TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,
  TextYAlignment=Enum.TextYAlignment.Top,Text=""},detail)
local dFound=mk("TextLabel",{Size=UDim2.fromOffset(298,18),Position=UDim2.fromOffset(12,422),
  BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=12,TextColor3=GRN,
  TextXAlignment=Enum.TextXAlignment.Left,Text=""},detail)
mk("TextLabel",{Size=UDim2.fromOffset(590,16),Position=UDim2.fromOffset(24,584),
  BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=11,TextColor3=DIM,
  TextXAlignment=Enum.TextXAlignment.Left,Text=CAT.source},panel)

-- every live viewport camera, turned by one loop
local spin={}
local bigSpin={cam=nil,dist=10}
local function mountModel(vp,id,dist_mult)
  for _,c in ipairs(vp:GetChildren()) do c:Destroy() end
  local src=modelFor(id)
  if not src then
    mk("TextLabel",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Font=Enum.Font.GothamBold,
      TextSize=30,TextColor3=Color3.fromRGB(60,64,70),Text="?"},vp)
    return nil
  end
  local m=src:Clone(); m.Parent=vp
  local cam=Instance.new("Camera"); cam.Parent=vp; vp.CurrentCamera=cam
  local extent=src:GetAttribute("Extent") or 10
  local d=math.max(2.5,extent*(dist_mult or 0.95))
  cam.CFrame=CFrame.new(Vector3.new(math.sin(2.3)*d,d*0.42,math.cos(2.3)*d),Vector3.new(0,0,0))
  return {cam=cam,dist=d}
end

local function show(it)
  dName.Text=it.name
  dWhere.Text=it.rest
  dEnd.Text=it.ended
  dStory.Text=it.story
  dFound.Text=found[it.id] and "✓ RECOVERED BY THIS CREW" or ""
  bigSpin=mountModel(bigVp,it.id,0.85) or {cam=nil,dist=10}
  -- opening an entry is how the unreachable ones get catalogued
  Catalogued:Fire(it.id)
end

local tiles={}
local function clearTiles()
  for _,t in ipairs(tiles) do t:Destroy() end
  tiles={}; spin={}
end

local function tile(it,order)
  local card=mk("TextButton",{Size=UDim2.fromOffset(136,150),LayoutOrder=order,AutoButtonColor=false,
    BackgroundColor3=Color3.fromRGB(22,24,28),BorderSizePixel=0,Text=""},scroll)
  mk("UICorner",{CornerRadius=UDim.new(0,9)},card)
  local stroke=mk("UIStroke",{Color=found[it.id] and Color3.fromRGB(70,86,72)
    or Color3.fromRGB(36,38,44),Thickness=1},card)
  local vp=mk("ViewportFrame",{Size=UDim2.fromOffset(120,94),Position=UDim2.fromOffset(8,8),
    BackgroundColor3=Color3.fromRGB(11,13,17),BorderSizePixel=0,
    Ambient=Color3.fromRGB(140,140,150),LightColor=Color3.fromRGB(255,250,240),
    LightDirection=Vector3.new(-0.4,-1,-0.6)},card)
  mk("UICorner",{CornerRadius=UDim.new(0,6)},vp)
  local s=mountModel(vp,it.id,1.0)
  if s then table.insert(spin,s) end
  local short=TILE_NAME[it.id] or ((it.name:match("^[^%(%+,]+") or it.name):gsub("%s+$",""))
  mk("TextLabel",{Size=UDim2.fromOffset(120,32),Position=UDim2.fromOffset(8,106),
    BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=13,TextColor3=Color3.new(1,1,1),
    TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,
    TextWrapped=true,Text=short},card)
  if found[it.id] then
    mk("TextLabel",{Size=UDim2.fromOffset(20,20),Position=UDim2.fromOffset(112,10),
      BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=15,TextColor3=GRN,
      Text="✓"},card)
  end
  card.MouseButton1Click:Connect(function() show(it) end)
  card.MouseEnter:Connect(function() stroke.Color=YEL end)
  card.MouseLeave:Connect(function()
    stroke.Color=found[it.id] and Color3.fromRGB(70,86,72) or Color3.fromRGB(36,38,44)
  end)
  table.insert(tiles,card)
  return card
end

local openName="Moon"
local function openTab(name)
  openName=name
  for n,b in pairs(tabBtn) do
    b.BackgroundColor3=(n==name) and Color3.fromRGB(70,64,20) or Color3.fromRGB(30,32,36)
    b.TextColor3=(n==name) and YEL or Color3.new(1,1,1)
  end
  clearTiles()
  local first,order=nil,0
  for _,it in ipairs(CAT.items) do
    if it.tab==name then
      order+=1
      tile(it,order)
      first=first or it
    end
  end
  if first then show(first) end
end
for _,n in ipairs(tabs) do tabBtn[n].MouseButton1Click:Connect(function() openTab(n) end) end
refresh=function() if gui.Enabled then openTab(openName) end end

-- Each small viewport is its own render pass, so the cost here is the number of live
-- viewports, not their triangle count (the whole set is about 5,000). A tab shows at most
-- eight. Turning them is throttled to 24 fps, and on a phone the tiles hold still -- only
-- the one you have picked keeps moving.
local STILL=UIS.TouchEnabled
local acc=0
RS.RenderStepped:Connect(function(dt)
  if not gui.Enabled then return end
  acc+=dt
  if acc<1/24 then return end
  acc=0
  local t=tick()
  if not STILL then
    for i,v in ipairs(spin) do
      local a=t*0.5+i*0.8
      v.cam.CFrame=CFrame.new(Vector3.new(math.sin(a)*v.dist,v.dist*0.42,math.cos(a)*v.dist),
        Vector3.new(0,0,0))
    end
  end
  if bigSpin and bigSpin.cam then
    local a=t*0.35
    bigSpin.cam.CFrame=CFrame.new(
      Vector3.new(math.sin(a)*bigSpin.dist,bigSpin.dist*0.38,math.cos(a)*bigSpin.dist),
      Vector3.new(0,0,0))
  end
end)

local function setOpen(on)
  gui.Enabled=on
  local c=plr.Character; local hum=c and c:FindFirstChildOfClass("Humanoid")
  if hum then hum.WalkSpeed=on and 0 or 11 end
  if on then openTab(openName) end
end
close.MouseButton1Click:Connect(function() setOpen(false) end)
UIS.InputBegan:Connect(function(i,gpe)
  if gpe then return end
  if i.KeyCode==Enum.KeyCode.Q and gui.Enabled then setOpen(false) end
end)
rem:WaitForChild("LocalKey").Event:Connect(function(code,phase)
  if code==Enum.KeyCode.Q and phase~="up" and gui.Enabled then setOpen(false) end
end)

rem:WaitForChild("OpenArchive").OnClientEvent:Connect(function(id)
  if not id then setOpen(true); return end
  for _,it in ipairs(CAT.items) do
    if it.id==id then setOpen(true); openTab(it.tab); show(it); return end
  end
end)

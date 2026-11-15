-- LocalScript  StarterPlayerScripts/StarterPlayerScripts.Map
-- THE SURVEY MAP. Orbit found it; the ground confirms it.
--
-- Nothing on the Moon or Mars is truly unmapped -- both are imaged globally from orbit. But
-- orbit only sees the hardware as a few pixels and a shadow: it can tell you SOMETHING is
-- there, not what it is or what state it is in. That takes someone standing next to it.
-- So the map has three tiers, and the player's job is to turn the middle one into the last:
--   ORBITAL SURVEY      the whole surface, from the start
--   SPOTTED FROM ORBIT  a site where something was seen -- unidentified
--   GROUND TRUTH        every object there confirmed in person
-- Drawn with plain frames, not a live camera: it costs nothing on a phone.
local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
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

-- which artifacts belong to which site, in log order
local SITE_ITEMS={}
for _,id in ipairs(IDX.ORDER) do
  local s=IDX.SITEOF[id]
  SITE_ITEMS[s]=SITE_ITEMS[s] or {}
  table.insert(SITE_ITEMS[s],id)
end

local found={}

-- ---------- frame ----------
local gui=mk("ScreenGui",{Name="SurveyMap",ResetOnSpawn=false,IgnoreGuiInset=true,
  Enabled=false,DisplayOrder=13},pg)
mk("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(0,0,0),
  BackgroundTransparency=0.25,BorderSizePixel=0},gui)
local panel=mk("Frame",{Size=UDim2.fromOffset(950,590),AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),
  BackgroundColor3=INK,BackgroundTransparency=0.04,BorderSizePixel=0},gui)
mk("UICorner",{CornerRadius=UDim.new(0,12)},panel)
mk("UIStroke",{Color=Color3.fromRGB(60,64,72),Thickness=1},panel)
local sc=mk("UIScale",{},panel)
local function fit()
  local vp=workspace.CurrentCamera.ViewportSize
  sc.Scale=math.min(1,(vp.X-20)/950,(vp.Y-20)/590)
end
fit(); workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fit)

mk("TextLabel",{Size=UDim2.fromOffset(700,18),Position=UDim2.fromOffset(24,18),
  BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=12,TextColor3=CYAN,
  TextXAlignment=Enum.TextXAlignment.Left,
  Text="SURVEY MAP  ·  ORBIT FOUND IT, THE GROUND CONFIRMS IT"},panel)
mk("TextLabel",{Size=UDim2.fromOffset(600,32),Position=UDim2.fromOffset(24,36),
  BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=26,TextColor3=Color3.new(1,1,1),
  TextXAlignment=Enum.TextXAlignment.Left,Text="Survey Map"},panel)
local close=mk("TextButton",{Size=UDim2.fromOffset(104,32),Position=UDim2.new(1,-128,0,22),
  BackgroundColor3=Color3.fromRGB(30,32,36),AutoButtonColor=true,Font=Enum.Font.GothamBold,
  TextSize=14,TextColor3=YEL,Text="[M] close"},panel)
mk("UICorner",{CornerRadius=UDim.new(0,7)},close)

local worlds={"Moon","Mars","Eros"}
local tabBtn={}
for i,w in ipairs(worlds) do
  local b=mk("TextButton",{Size=UDim2.fromOffset(112,32),Position=UDim2.fromOffset(24+(i-1)*120,78),
    BackgroundColor3=Color3.fromRGB(30,32,36),Font=Enum.Font.GothamBold,TextSize=15,
    TextColor3=Color3.new(1,1,1),Text=string.upper(w)},panel)
  mk("UICorner",{CornerRadius=UDim.new(0,7)},b)
  tabBtn[w]=b
end
local tally=mk("TextLabel",{Size=UDim2.fromOffset(560,32),Position=UDim2.fromOffset(370,78),
  BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=14,TextColor3=YEL,
  TextXAlignment=Enum.TextXAlignment.Right,Text=""},panel)

-- the map: longitude across, latitude up -- a flat projection of the whole globe
local MW,MH=600,300
local map=mk("Frame",{Size=UDim2.fromOffset(MW,MH),Position=UDim2.fromOffset(24,124),
  BorderSizePixel=0,ClipsDescendants=true},panel)
mk("UICorner",{CornerRadius=UDim.new(0,8)},map)

-- the detail panel for whichever site is picked
local detail=mk("Frame",{Size=UDim2.fromOffset(294,300),Position=UDim2.fromOffset(632,124),
  BackgroundColor3=Color3.fromRGB(16,17,20),BorderSizePixel=0},panel)
mk("UICorner",{CornerRadius=UDim.new(0,10)},detail)
local dpad=mk("Frame",{Size=UDim2.new(1,-28,1,-24),Position=UDim2.fromOffset(14,12),
  BackgroundTransparency=1},detail)
mk("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},dpad)
local function drow(order,font,size,col)
  return mk("TextLabel",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
    BackgroundTransparency=1,Font=font,TextSize=size,TextColor3=col,TextWrapped=true,
    TextXAlignment=Enum.TextXAlignment.Left,Text="",LayoutOrder=order},dpad)
end
local dName=drow(1,Enum.Font.GothamBold,19,Color3.new(1,1,1))
local dWhere=drow(2,Enum.Font.GothamMedium,12,CYAN)
local dTier=drow(3,Enum.Font.GothamBold,13,YEL)
local dItems=drow(4,Enum.Font.Gotham,14,Color3.fromRGB(210,212,218))
local dNote=drow(5,Enum.Font.Gotham,12,DIM)

-- the three-tier legend, drawn as pictures rather than explained in a paragraph
local legend=mk("Frame",{Size=UDim2.fromOffset(902,120),Position=UDim2.fromOffset(24,440),
  BackgroundTransparency=1},panel)
local function swatch(x,kind,title,line)
  local f=mk("Frame",{Size=UDim2.fromOffset(292,110),Position=UDim2.fromOffset(x,0),
    BackgroundColor3=Color3.fromRGB(16,17,20),BorderSizePixel=0},legend)
  mk("UICorner",{CornerRadius=UDim.new(0,9)},f)
  local s=mk("Frame",{Size=UDim2.fromOffset(26,26),Position=UDim2.fromOffset(14,16),
    BorderSizePixel=0},f)
  mk("UICorner",{CornerRadius=UDim.new(1,0)},s)
  if kind=="orbital" then
    s.BackgroundColor3=Color3.fromRGB(110,110,112)
    mk("UICorner",{CornerRadius=UDim.new(0,4)},s)
  elseif kind=="spotted" then
    s.BackgroundTransparency=1
    mk("UIStroke",{Color=CYAN,Thickness=3},s)
    mk("TextLabel",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Font=Enum.Font.GothamBold,
      TextSize=15,TextColor3=CYAN,Text="?"},s)
  else
    s.BackgroundColor3=GRN
    mk("TextLabel",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Font=Enum.Font.GothamBold,
      TextSize=15,TextColor3=INK,Text="✓"},s)
  end
  mk("TextLabel",{Size=UDim2.fromOffset(230,22),Position=UDim2.fromOffset(52,14),
    BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=14,TextColor3=Color3.new(1,1,1),
    TextXAlignment=Enum.TextXAlignment.Left,Text=title},f)
  mk("TextLabel",{Size=UDim2.fromOffset(266,60),Position=UDim2.fromOffset(14,48),
    BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=12,TextColor3=DIM,TextWrapped=true,
    TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,Text=line},f)
end
swatch(0,  "orbital","ORBITAL SURVEY","The whole surface, mapped from orbit long before you arrived.")
swatch(305,"spotted","SPOTTED FROM ORBIT","Something is there. From orbit it is a few pixels and a shadow — nobody can say what state it is in.")
swatch(610,"truth","GROUND TRUTH","You stood next to every object at the site and confirmed it. Only a surveyor can do this.")

-- ---------- state ----------
local function siteProgress(site)
  local items=SITE_ITEMS[site] or {}
  local n=0
  for _,id in ipairs(items) do if found[id] then n+=1 end end
  return n,#items
end

local function siteHere()
  local c=plr.Character
  local hrp=c and c:FindFirstChild("HumanoidRootPart")
  if not hrp then return nil end
  local p=Vector3.new(hrp.Position.X,0,hrp.Position.Z)
  local best,bd=nil,260
  for name,m in pairs(IDX.MAP) do
    local d=(p-m.pos).Magnitude
    if d<bd then best,bd=name,d end
  end
  return best
end

local function coordText(m)
  local la=("%.2f %s"):format(math.abs(m.lat),m.lat>=0 and "N" or "S")
  local lo=("%.2f %s"):format(math.abs(m.lon),m.lon>=0 and "E" or "W")
  return la..", "..lo..(m.estimated and "  ·  estimated" or "")
end

local function showSite(site)
  local m=IDX.MAP[site]; if not m then return end
  local n,total=siteProgress(site)
  dName.Text=site
  dWhere.Text=m.world.."  ·  "..coordText(m)
  if n==total then
    dTier.Text="GROUND TRUTH  ·  all confirmed"
    dTier.TextColor3=GRN
  elseif n>0 then
    dTier.Text=("PARTLY CONFIRMED  ·  %d of %d"):format(n,total)
    dTier.TextColor3=YEL
  else
    dTier.Text=m.estimated and "ESTIMATED FROM ITS PATH" or "SPOTTED FROM ORBIT"
    dTier.TextColor3=CYAN
  end
  local lines={}
  for _,id in ipairs(SITE_ITEMS[site] or {}) do
    if found[id] then
      table.insert(lines,"✓  "..IDX.SHORT[id])
    else
      table.insert(lines,"?  unidentified object")
    end
  end
  dItems.Text=table.concat(lines,"\n")
  if m.estimated then
    dNote.Text="This is the one place orbit never found. Its crater has never been identified in orbital images — the spot is worked out from where it was heading. Standing here is the only way to confirm it."
  elseif n==total then
    dNote.Text="Confirmed in person. The map now knows what orbit could not."
  else
    dNote.Text="Go there and scan each object to confirm it."
  end
end

-- ---------- drawing ----------
local layer=nil
local current="Moon"
local selected=nil

local function draw(world)
  current=world
  for w,b in pairs(tabBtn) do
    b.BackgroundColor3=(w==world) and Color3.fromRGB(70,64,20) or Color3.fromRGB(30,32,36)
    b.TextColor3=(w==world) and YEL or Color3.new(1,1,1)
  end
  if layer then layer:Destroy() end
  layer=mk("Frame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1},map)
  map.BackgroundColor3 = (world=="Moon") and Color3.fromRGB(96,96,98)
    or (world=="Eros") and Color3.fromRGB(104,94,82) or Color3.fromRGB(154,88,54)

  if world=="Moon" then
    -- the far side: never faces Earth. Drawn darker, because there is no Earth in its sky.
    for _,x in ipairs({0,0.75}) do
      mk("Frame",{Size=UDim2.fromScale(0.25,1),Position=UDim2.fromScale(x,0),
        BackgroundColor3=Color3.fromRGB(52,52,56),BackgroundTransparency=0.15,
        BorderSizePixel=0},layer)
    end
    mk("TextLabel",{Size=UDim2.fromOffset(140,14),Position=UDim2.fromOffset(8,6),
      BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=10,
      TextColor3=Color3.fromRGB(170,170,176),TextXAlignment=Enum.TextXAlignment.Left,
      Text="FAR SIDE · no Earth in the sky"},layer)
    mk("TextLabel",{Size=UDim2.fromOffset(150,14),Position=UDim2.new(0.5,-75,0,6),
      BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=10,
      TextColor3=Color3.fromRGB(210,210,214),Text="NEAR SIDE · faces Earth"},layer)
  end
  -- latitude and longitude every 30 degrees; the equator and prime meridian stronger
  for i=1,11 do
    mk("Frame",{Size=UDim2.new(0,1,1,0),Position=UDim2.fromScale(i/12,0),
      BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=(i==6) and 0.6 or 0.86,
      BorderSizePixel=0},layer)
  end
  for j=1,5 do
    mk("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.fromScale(0,j/6),
      BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=(j==3) and 0.6 or 0.86,
      BorderSizePixel=0},layer)
  end

  local here=siteHere()
  for site,m in pairs(IDX.MAP) do
    if m.world==world then
      -- keep pins off the very edge (Gusev sits at 175 E) so none is cut in half
      local x=math.clamp((m.lon+180)/360,0.035,0.965)
      local y=(90-m.lat)/180
      local n,total=siteProgress(site)
      local truth=(n==total)
      local b=mk("TextButton",{Size=UDim2.fromOffset(26,26),AnchorPoint=Vector2.new(0.5,0.5),
        Position=UDim2.fromScale(x,y),AutoButtonColor=false,Font=Enum.Font.GothamBold,
        TextSize=14,ZIndex=3},layer)
      mk("UICorner",{CornerRadius=UDim.new(1,0)},b)
      if truth then
        b.BackgroundColor3=GRN; b.TextColor3=INK; b.Text="✓"
      else
        b.BackgroundColor3=Color3.fromRGB(14,16,20); b.BackgroundTransparency=0.15
        b.TextColor3=CYAN; b.Text=(n>0) and tostring(n) or "?"
        mk("UIStroke",{Color=(n>0) and YEL or CYAN,Thickness=2.5,
          LineJoinMode=Enum.LineJoinMode.Round},b)
      end
      local lab=mk("TextLabel",{Size=UDim2.fromOffset(110,14),Position=UDim2.new(x,16,y,-7),
        BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=11,
        TextColor3=Color3.new(1,1,1),TextStrokeTransparency=0.45,ZIndex=3,
        TextXAlignment=Enum.TextXAlignment.Left,Text=m.short},layer)
      if x>0.8 or m.labelLeft then
        lab.Position=UDim2.new(x,-126,y,-7); lab.TextXAlignment=Enum.TextXAlignment.Right
      end
      if site==here then
        -- you are here: a yellow ring around the marker
        local r=mk("Frame",{Size=UDim2.fromOffset(40,40),AnchorPoint=Vector2.new(0.5,0.5),
          Position=UDim2.fromScale(x,y),BackgroundTransparency=1,ZIndex=2},layer)
        mk("UICorner",{CornerRadius=UDim.new(1,0)},r)
        mk("UIStroke",{Color=YEL,Thickness=2},r)
        mk("TextLabel",{Size=UDim2.fromOffset(90,12),Position=UDim2.new(x,-45,y,22),
          BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=10,TextColor3=YEL,
          ZIndex=3,Text="YOU ARE HERE"},layer)
      end
      b.MouseButton1Click:Connect(function() selected=site; showSite(site) end)
    end
  end

  -- whole-survey progress, across both worlds
  local sites,done,objs,got=0,0,0,0
  for site in pairs(IDX.MAP) do
    sites+=1
    local n,total=siteProgress(site)
    objs+=total; got+=n
    if n==total then done+=1 end
  end
  tally.Text=("GROUND TRUTH  %d of %d sites  ·  %d of %d objects"):format(done,sites,got,objs)

  -- pick something sensible for the side panel
  local pick=selected
  if not pick or not IDX.MAP[pick] or IDX.MAP[pick].world~=world then
    pick=(here and IDX.MAP[here] and IDX.MAP[here].world==world) and here or nil
  end
  if not pick then
    for site,m in pairs(IDX.MAP) do if m.world==world then pick=site break end end
  end
  if pick then showSite(pick) end
end
for _,w in ipairs(worlds) do tabBtn[w].MouseButton1Click:Connect(function() draw(w) end) end

-- ---------- open / close ----------
local function setOpen(on)
  gui.Enabled=on
  local c=plr.Character; local h=c and c:FindFirstChildOfClass("Humanoid")
  if h then h.WalkSpeed=on and 0 or 11 end
  if on then
    local here=siteHere()
    selected=here
    draw((here and IDX.MAP[here] and IDX.MAP[here].world) or "Moon")
  end
end
close.MouseButton1Click:Connect(function() setOpen(false) end)

local function onKey(code)
  if code==Enum.KeyCode.M then setOpen(not gui.Enabled)
  elseif code==Enum.KeyCode.Q and gui.Enabled then setOpen(false) end
end
UIS.InputBegan:Connect(function(i,gpe) if not gpe then onKey(i.KeyCode) end end)
rem:WaitForChild("LocalKey").Event:Connect(function(code,phase) if phase~="up" then onKey(code) end end)
rem:WaitForChild("OpenMap").Event:Connect(function() setOpen(true) end)

rem:WaitForChild("LogUpdate").OnClientEvent:Connect(function(snap)
  found={}
  for k,v in pairs(snap or {}) do if v then found[k]=v end end
  if gui.Enabled then draw(current) end
end)

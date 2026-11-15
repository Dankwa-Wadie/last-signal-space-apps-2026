-- LocalScript  StarterPlayerScripts/StarterPlayerScripts.Logbook
-- ASTROLOG, as a pill in the corner instead of a permanent list.
-- Collapsed by default: "ASTROLOG  3/20". Tap it (or press L) to open the card for the site
-- you are standing at. It also opens by itself for a few seconds when you find something or
-- arrive somewhere new, then tucks itself away again.
-- Built to the figma-to-roblox-ui rules through UIKit: Scale only, centred anchors unless a
-- reason is recorded, ScaledSize strokes, scaled corners and text. Design frame 1280x720.
local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local TS=game:GetService("TweenService")
local RSrv=game:GetService("ReplicatedStorage")
local plr=Players.LocalPlayer
local pg=plr:WaitForChild("PlayerGui")
local rem=RSrv:WaitForChild("Remotes")
local IDX=require(RSrv:WaitForChild("ArtifactIndex"))
local UI=require(RSrv:WaitForChild("UIKit"))

local SW,SH=1280,720
local YEL=Color3.fromRGB(245,231,60)
local CYAN=Color3.fromRGB(150,205,255)
local GRN=Color3.fromRGB(120,230,150)
local INK=Color3.fromRGB(10,11,14)
local EDGE=Color3.fromRGB(64,68,78)
local DIM=Color3.fromRGB(150,156,164)

local gui=UI.new("ScreenGui",{Name="Logbook",ResetOnSpawn=false,IgnoreGuiInset=false,
  ZIndexBehavior=Enum.ZIndexBehavior.Sibling,ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets,
  DisplayOrder=6},pg)

-- ---------- the pill ----------
local PW,PH=236,46
local pill=UI.new("TextButton",{Name="Pill",BackgroundColor3=INK,BackgroundTransparency=0.12,
  AutoButtonColor=false,Text="",TextScaled=true,BorderSizePixel=0},gui)
UI.place(pill,16,12,PW,PH,SW,SH,Vector2.new(0,0),"HUD pinned to the top-left corner")
UI.aspect(pill,PW,PH,Enum.DominantAxis.Height)
UI.corner(pill,PH/2,PW,PH)
UI.stroke(pill,1.5,PW,PH,EDGE)
local dot=UI.new("Frame",{Name="Dot",BackgroundColor3=YEL,BorderSizePixel=0},pill)
UI.place(dot,16,18,10,10,PW,PH); UI.corner(dot,5,10,10)
UI.label(pill,"Title","ASTROLOG",Enum.Font.GothamBold,YEL,12,32,13,112,20,PW,PH)
local count=UI.label(pill,"Count","0/20",Enum.Font.GothamBold,Color3.new(1,1,1),12,146,13,52,20,PW,PH,
  Enum.TextXAlignment.Right)
local chev=UI.label(pill,"Chevron","+",Enum.Font.GothamBold,DIM,12,204,13,22,20,PW,PH,
  Enum.TextXAlignment.Center)

-- ---------- the card ----------
local CW=300
local card=UI.new("Frame",{Name="Card",BackgroundColor3=INK,BackgroundTransparency=0.08,
  BorderSizePixel=0,Visible=false},gui)

local found,online={},{}
local open,pinned=false,false
local hideToken=0

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

local function renderCard()
  for _,ch in ipairs(card:GetChildren()) do ch:Destroy() end
  local here=siteHere()
  local rows={}
  if here then
    for _,id in ipairs(IDX.ORDER) do
      if IDX.SITEOF[id]==here then table.insert(rows,id) end
    end
  end
  local CH=44+math.max(1,#rows)*30+34
  UI.place(card,16,64,CW,CH,SW,SH,Vector2.new(0,0),"drops down from the pill, pinned top-left")
  UI.aspect(card,CW,CH,Enum.DominantAxis.Height)
  UI.corner(card,14,CW,CH)
  UI.stroke(card,1.5,CW,CH,EDGE)
  UI.label(card,"Site",here and string.upper(here) or "BETWEEN SITES",Enum.Font.GothamBold,CYAN,13,
    16,12,CW-32,22,CW,CH)
  if #rows==0 then
    UI.label(card,"Empty","Walk to a site to see what's there.",Enum.Font.Gotham,DIM,14,16,44,CW-32,24,CW,CH)
  end
  for i,id in ipairs(rows) do
    local y=44+(i-1)*30
    local got=found[id]~=nil
    local mark=UI.new("Frame",{Name="Mark"..i,BorderSizePixel=0,
      BackgroundColor3=got and GRN or Color3.fromRGB(26,28,34)},card)
    UI.place(mark,16,y+4,18,18,CW,CH); UI.corner(mark,9,18,18)
    if not got then UI.stroke(mark,1.5,18,18,CYAN) end
    UI.label(mark,"Glyph",got and "✓" or "?",Enum.Font.GothamBold,got and INK or CYAN,11,0,0,18,18,18,18,
      Enum.TextXAlignment.Center)
    local txt=got and IDX.SHORT[id] or "unidentified object"
    if got and online[id] then txt=txt.."  ·  "..(IDX.ONLINE_LABEL[id] or "ONLINE") end
    UI.label(card,"Row"..i,txt,got and Enum.Font.GothamMedium or Enum.Font.Gotham,
      got and Color3.new(1,1,1) or DIM,15,44,y,CW-60,26,CW,CH)
  end
  UI.label(card,"Footer",UIS.TouchEnabled and "Full list: ⚙ → Survey map" or "Full list:  M  survey map",
    Enum.Font.Gotham,DIM,12,16,CH-30,CW-32,20,CW,CH)
end

local function total()
  local n=0
  for _,id in ipairs(IDX.ORDER) do if found[id] then n+=1 end end
  return n
end
local function refreshPill()
  count.Text=("%d/%d"):format(total(),#IDX.ORDER)
  chev.Text=open and "–" or "+"
end

local function setOpen(on)
  open=on
  if on then renderCard() end
  card.Visible=on
  refreshPill()
end

-- open for a few seconds, then tuck away -- unless the player opened it on purpose
local function peek(seconds)
  if pinned then renderCard() return end
  hideToken+=1
  local my=hideToken
  setOpen(true)
  task.delay(seconds or 6,function()
    if hideToken==my and not pinned then setOpen(false) end
  end)
end

local function toggle()
  pinned=not open
  hideToken+=1
  setOpen(pinned)
end
pill.MouseButton1Click:Connect(toggle)
UIS.InputBegan:Connect(function(i,gpe)
  if not gpe and i.KeyCode==Enum.KeyCode.L then toggle() end
end)
rem:WaitForChild("LocalKey").Event:Connect(function(code,phase)
  if phase~="up" and code==Enum.KeyCode.L then toggle() end
end)

-- something found: say so
rem:WaitForChild("LogUpdate").OnClientEvent:Connect(function(snap)
  local before=total()
  found={}
  for k,v in pairs(snap or {}) do if v then found[k]=v end end
  refreshPill()
  if total()>before then peek(6) elseif open then renderCard() end
end)
rem:WaitForChild("OnlineUpdate").OnClientEvent:Connect(function(snap)
  online=snap or {}
  if open then renderCard() end
end)

-- arriving at a new site: show what's here
task.spawn(function()
  local last=siteHere()
  while true do
    task.wait(1)
    local h=siteHere()
    if h~=last then
      last=h
      if h then peek(6) elseif open then renderCard() end
    end
  end
end)

refreshPill()

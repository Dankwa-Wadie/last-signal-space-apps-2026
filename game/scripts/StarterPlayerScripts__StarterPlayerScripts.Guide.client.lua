-- THE GUIDE. A picture-first walk through the controls, pointing at the real buttons.
-- Starts after the opening scene; each step finishes itself when the player does the thing
-- (or taps NEXT / presses Enter). The "?" button top right replays it any time.
-- Built with UIKit (figma-to-roblox-ui rules).
local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local UIS=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local UI=require(RS:WaitForChild("UIKit"))
local rem=RS:WaitForChild("Remotes")
local me=Players.LocalPlayer
local pg=me:WaitForChild("PlayerGui")
local INK,Y,C,G=Color3.fromRGB(10,11,14),Color3.fromRGB(245,231,60),Color3.fromRGB(150,205,255),Color3.fromRGB(120,230,150)
local touch=UIS.TouchEnabled and not UIS.KeyboardEnabled

local W,H=1280,720
local gui=UI.new("ScreenGui",{Name="Guide",ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=12,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},pg)
local root=UI.new("Frame",{Name="Root",BackgroundTransparency=1},gui); UI.place(root,0,0,W,H,W,H)

-- "?" button, next to the gear
local help=UI.new("TextButton",{Name="Help",BackgroundColor3=INK,BackgroundTransparency=0.12,Text="?",Font=Enum.Font.GothamBold,TextColor3=Y,AutoButtonColor=true},root)
UI.place(help,1168,16,44,44,W,H,Vector2.new(1,0),"HUD pinned to the top-right corner, beside the gear"); UI.aspect(help,1,1)
UI.corner(help,10,44,44); UI.stroke(help,1.5,44,44,Color3.fromRGB(70,74,82)); UI.text(help,20)

-- the card
local CW,CH=560,170
local card=UI.new("Frame",{Name="Card",BackgroundColor3=INK,BackgroundTransparency=0.06,Visible=false},root)
UI.place(card,(W-CW)/2,500,CW,CH,W,H); UI.corner(card,22,CW,CH); UI.aspect(card,CW,CH)
UI.stroke(card,3,CW,CH,Y)
local stepLbl=UI.label(card,"Step","",Enum.Font.GothamBold,C,13,24,14,300,18,CW,CH)
local keys=UI.new("Frame",{Name="Keys",BackgroundTransparency=1},card); UI.place(keys,24,40,150,86,CW,CH)
local title=UI.label(card,"Title","",Enum.Font.GothamBold,Y,24,190,36,350,32,CW,CH)
local body=UI.label(card,"Body","",Enum.Font.GothamMedium,Color3.new(1,1,1),16,190,72,350,56,CW,CH)
body.TextYAlignment=Enum.TextYAlignment.Top
local nextB=UI.new("TextButton",{Name="Next",BackgroundColor3=Y,Text="NEXT",Font=Enum.Font.GothamBold,TextColor3=INK},card)
UI.place(nextB,420,128,116,30,CW,CH); UI.corner(nextB,15,116,30); UI.text(nextB,15)
local skipB=UI.new("TextButton",{Name="Skip",BackgroundTransparency=1,Text="SKIP GUIDE",Font=Enum.Font.Gotham,TextColor3=Color3.fromRGB(160,165,175)},card)
UI.place(skipB,292,128,128,30,CW,CH); UI.text(skipB,13)
local hint=UI.label(card,"Hint",touch and "" or "[Enter] next",Enum.Font.Gotham,Color3.fromRGB(130,135,145),12,24,134,200,20,CW,CH)

-- pointer: a ring around the real button and a bouncing arrow under it
local ring=UI.new("Frame",{Name="Ring",BackgroundTransparency=1,Visible=false},root); UI.place(ring,0,0,10,10,W,H)
local ringStroke=UI.new("UIStroke",{StrokeSizingMode=Enum.StrokeSizingMode.ScaledSize,Thickness=0.08,Color=Y,ApplyStrokeMode=Enum.ApplyStrokeMode.Border},ring)
UI.new("UICorner",{CornerRadius=UDim.new(0.3,0)},ring)
local arrow=UI.new("TextLabel",{Name="Arrow",BackgroundTransparency=1,Text="^",Font=Enum.Font.GothamBold,TextColor3=Y,Visible=false},root)
UI.place(arrow,0,0,40,40,W,H); UI.text(arrow,40)

local function keycap(i,n,label,wide)
  local kw=wide and 150 or 42
  local k=UI.new("Frame",{Name="Key"..i,BackgroundColor3=Color3.fromRGB(34,37,44)},keys)
  local col,row=(i-1)%3,math.floor((i-1)/3)
  UI.place(k,wide and 0 or col*50,row*46,kw,40,150,86); UI.corner(k,8,kw,40); UI.stroke(k,2,kw,40,Color3.fromRGB(90,95,105))
  UI.label(k,"L",label,Enum.Font.GothamBold,Color3.new(1,1,1),wide and 15 or 18,0,0,kw,40,kw,40,Enum.TextXAlignment.Center)
end
local function setKeys(list)
  for _,c in ipairs(keys:GetChildren()) do c:Destroy() end
  for i,k in ipairs(list) do keycap(i,#list,k,#list==1 and #k>2) end
end

local function hrp() local c=me.Character return c and c:FindFirstChild("HumanoidRootPart") end
local function find(path) local o=pg for _,n in ipairs(path) do o=o and o:FindFirstChild(n) end return o end
local scanned=false
rem:WaitForChild("LogUpdate").OnClientEvent:Connect(function(s) for _,v in pairs(s or {}) do if v then scanned=true end end end)

local start
local STEPS={
  {"MOVE AROUND", touch and "Drag the circle on the left of the screen to walk." or "Walk with these keys. Drag the mouse to look.",
    touch and {"STICK"} or {"","W","","A","S","D"}, nil,
    function(s) local r=hrp() s.p0=s.p0 or (r and r.Position) return r and s.p0 and (r.Position-s.p0).Magnitude>12 end},
  {"HOP!", "The Moon's gravity is weak, so you float. Try a jump.", touch and {"JUMP"} or {"SPACE"}, nil,
    function() local c=me.Character local h=c and c:FindFirstChildOfClass("Humanoid") return h and h:GetState()==Enum.HumanoidStateType.Freefall end},
  {"FIND THE LOST SIGNAL", "Apollo 11's signal is weak. Walk around: more bars means you are closer.", {"SIGNAL"}, {"Storm","Root","Signal"},
    function() local s=find({"Storm","Root","Signal"}) return s and not s.Visible end},
  {"SCAN IT", touch and "Stand next to an old machine and press SCAN." or "Stand next to an old machine and hold E.", touch and {"SCAN"} or {"E"}, nil,
    function() return scanned end},
  {"YOUR LOGBOOK", touch and "Tap the ASTROLOG pill to see what you found." or "Press L (or click the pill) to see what you found.", touch and {"TAP"} or {"L"}, {"Logbook","Pill"}, nil},
  {"THE MAP", touch and "Tap MAP to see every landing site." or "Press M to see every landing site.", touch and {"MAP"} or {"M"}, nil,
    function() local m=pg:FindFirstChild("SurveyMap") return m and m.Enabled end},
  {"MENU", "The gear opens your trophy room, the controls, and this guide.", {"GEAR"}, {"Settings","Cog"}, nil},
  {"DUST STORMS: ONLY ON MARS", "Mars has air and wind, so real dust storms happen there. Some cover the whole planet! Run inside a glass SHELTER dome.", {"MARS"}, nil, nil},
  {"SOLAR STORMS: MOON & EROS", "No air there, so no dust storms. But the Sun can blast out radiation. You can't see it, so watch your RADIATION meter and get to a SHELTER.", {"SUN"}, nil, nil},
  {"TRAVEL", "To fly to Mars or Eros, use the TRANSIT console at the station.", {"TRANSIT"}, nil, nil},
  {"CLICKING BUTTONS", touch and "Just tap any button." or "Pointer stuck? Press Alt to free it. On a Mac, that's the Option key.", touch and {"TAP"} or {"ALT","OPT"}, nil, nil},
}

local cur,token=0,0
local function finish() card.Visible=false ring.Visible=false arrow.Visible=false cur=0 end
local function show(i)
  token+=1
  local s=STEPS[i]; if not s then
    card.Visible=true; stepLbl.Text="ALL DONE"; title.Text="YOU'RE READY, ASTROLOG!"; body.Text="Find the old machines and bring their stories home."
    setKeys({"GO!"}); nextB.Text="CLOSE"; cur=#STEPS+1; ring.Visible=false; arrow.Visible=false return
  end
  cur=i; card.Visible=true; nextB.Text="NEXT"
  stepLbl.Text=("STEP %d OF %d"):format(i,#STEPS); title.Text=s[1]; body.Text=s[2]; setKeys(s[3])
  s.p0=nil
end
local function advance() if cur>#STEPS then finish() elseif cur>0 then show(cur+1) end end
start=function() show(1) end
local function skipGuide() finish() end
nextB.MouseButton1Click:Connect(advance)
skipB.MouseButton1Click:Connect(skipGuide)
help.MouseButton1Click:Connect(function() if card.Visible then finish() else start() end end)
UIS.InputBegan:Connect(function(i,gpe)
  if card.Visible and (i.KeyCode==Enum.KeyCode.Return or i.KeyCode==Enum.KeyCode.KeypadEnter) then advance() end
  if card.Visible and i.KeyCode==Enum.KeyCode.Escape then skipGuide() end
end)
-- the logbook and gear steps finish when those are used
task.spawn(function()
  local pill=pg:WaitForChild("Logbook",30) and pg.Logbook:FindFirstChild("Pill",true)
  if pill then pill.MouseButton1Click:Connect(function() if STEPS[cur] and STEPS[cur][1]=="YOUR LOGBOOK" then advance() end end) end
  UIS.InputBegan:Connect(function(i,gpe) if not gpe and i.KeyCode==Enum.KeyCode.L and STEPS[cur] and STEPS[cur][1]=="YOUR LOGBOOK" then advance() end end)
  local cog=pg:WaitForChild("Settings",30) and pg.Settings:FindFirstChild("Cog")
  if cog then cog.MouseButton1Click:Connect(function() if STEPS[cur] and STEPS[cur][1]=="MENU" then advance() end end) end
end)

local t0=os.clock()
RunService.RenderStepped:Connect(function()
  local s=STEPS[cur]
  if not (card.Visible and s) then ring.Visible=false arrow.Visible=false return end
  if s[5] then local ok,done=pcall(s[5],s); if ok and done then task.defer(advance) return end end
  local tgt=s[4] and find(s[4])
  if tgt and tgt:IsA("GuiObject") and tgt.Visible and tgt.AbsoluteSize.X>0 then
    local A=gui.AbsoluteSize; local p,z=tgt.AbsolutePosition+Vector2.new(0,gui.IgnoreGuiInset and 0 or 0),tgt.AbsoluteSize
    local inset=tgt:FindFirstAncestorOfClass("ScreenGui").IgnoreGuiInset and 0 or game:GetService("GuiService"):GetGuiInset().Y
    local cx,cy=(p.X+z.X/2)/A.X,(p.Y+z.Y/2+inset)/A.Y
    local pulse=1+0.08*math.sin((os.clock()-t0)*6)
    ring.Visible=true; ring.Position=UDim2.fromScale(UI.r4(cx),UI.r4(cy))
    ring.Size=UDim2.fromScale(UI.r4((z.X+16)*pulse/A.X),UI.r4((z.Y+16)*pulse/A.Y))
    arrow.Visible=true; arrow.Position=UDim2.fromScale(UI.r4(cx),UI.r4(cy+(z.Y/2+30+6*math.sin((os.clock()-t0)*5))/A.Y))
  else ring.Visible=false; arrow.Visible=false end
end)

-- begin after the opening scene (or straight away if it already played)
task.spawn(function()
  local t=os.clock()
  task.wait(2)
  while pg:FindFirstChild("Intro") and os.clock()-t<90 do task.wait(0.5) end
  task.wait(1.5)
  if cur==0 then start() end
end)

if RunService:IsStudio() then
  local f=Instance.new("BindableFunction"); f.Name="_GuideTest"; f.Parent=gui
  f.OnInvoke=function(cmd) if cmd=="next" then advance() end
    return {cur=cur,title=title.Text,ring=ring.Visible,bad=UI.validate(gui)} end
end

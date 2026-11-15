-- STORMS, SHELTERS AND THE LOST SIGNAL (client). Built with UIKit (figma-to-roblox-ui rules).
local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local TS=game:GetService("TweenService")
local RunService=game:GetService("RunService")
local L=game:GetService("Lighting")
local UI=require(RS:WaitForChild("UIKit"))
local rem=RS:WaitForChild("Remotes")
local me=Players.LocalPlayer
local game_=workspace:WaitForChild("Game")
local INK,Y,C,G,RED=Color3.fromRGB(10,11,14),Color3.fromRGB(245,231,60),Color3.fromRGB(150,205,255),Color3.fromRGB(120,230,150),Color3.fromRGB(255,120,90)

local WL=require(game:GetService("ReplicatedStorage"):WaitForChild("WorldLayout"))
local function worldAt(p) return WL.worldAt(p) end
local function hrp() local c=me.Character return c and c:FindFirstChild("HumanoidRootPart") end

-- ---------- GUI (design frame 1280x720) ----------
local W,H=1280,720
local gui=UI.new("ScreenGui",{Name="Storm",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,IgnoreGuiInset=false},me:WaitForChild("PlayerGui"))
local root=UI.new("Frame",{Name="Root",BackgroundTransparency=1},gui); UI.place(root,0,0,W,H,W,H)
local banner=UI.new("Frame",{Name="Banner",BackgroundColor3=INK,BackgroundTransparency=0.08,Visible=false},root)
UI.place(banner,340,96,600,86,W,H); UI.corner(banner,20,600,86); UI.aspect(banner,600,86)
local bStroke=UI.stroke(banner,3,600,86,Y)
local bTitle=UI.label(banner,"Title","",Enum.Font.GothamBold,Y,26,20,8,560,40,600,86,Enum.TextXAlignment.Center)
local bSub=UI.label(banner,"Sub","",Enum.Font.GothamMedium,Color3.new(1,1,1),17,20,48,560,30,600,86,Enum.TextXAlignment.Center)

local power=UI.new("Frame",{Name="Power",BackgroundColor3=INK,BackgroundTransparency=0.15,Visible=false},root)
UI.place(power,1040,24,216,40,W,H,Vector2.new(1,0),"HUD pinned to the top-right corner"); UI.corner(power,20,216,40); UI.aspect(power,216,40)
UI.stroke(power,2,216,40,C)
local pLbl=UI.label(power,"Lbl","SUIT",Enum.Font.GothamBold,C,14,12,8,52,24,216,40)
local track=UI.new("Frame",{Name="Track",BackgroundColor3=Color3.fromRGB(40,42,48)},power); UI.place(track,66,13,136,14,216,40); UI.corner(track,7,136,14)
local fill=UI.new("Frame",{Name="Fill",BackgroundColor3=G},track); UI.place(fill,0,0,136,14,136,14,Vector2.new(0,0.5),"fill bar grows from the left"); UI.corner(fill,7,136,14)

local sig=UI.new("Frame",{Name="Signal",BackgroundColor3=INK,BackgroundTransparency=0.15,Visible=false},root)
UI.place(sig,1040,72,216,40,W,H,Vector2.new(1,0),"HUD pinned to the top-right corner"); UI.corner(sig,20,216,40); UI.aspect(sig,216,40)
UI.stroke(sig,2,216,40,Y)
UI.label(sig,"Lbl","SIGNAL",Enum.Font.GothamBold,Y,14,12,8,70,24,216,40)
local bars={}
for i=1,5 do
  local b=UI.new("Frame",{Name="Bar"..i,BackgroundColor3=Color3.fromRGB(60,62,68)},sig)
  local h=6+i*4; UI.place(b,96+(i-1)*22,32-h,14,h,216,40); UI.corner(b,3,14,h); bars[i]=b
end

-- ---------- shelters ----------
local Shelters=game_:WaitForChild("Shelters",60)
local function nearestShelter(w,pos)
  local best,bd
  for _,s in ipairs(Shelters and Shelters:GetChildren() or {}) do
    local c=s:FindFirstChild("Centre")
    if s:GetAttribute("World")==w and c then local d=(c.Position-pos).Magnitude; if not bd or d<bd then best,bd=s,d end end
  end
  return best,bd
end
local function highlightShelters(w,on)
  for _,s in ipairs(Shelters and Shelters:GetChildren() or {}) do
    local tag=s:FindFirstChild("Centre") and s.Centre:FindFirstChild("Tag")
    if tag then tag.AlwaysOnTop=on and s:GetAttribute("World")==w; tag.MaxDistance=on and 2000 or 450 end
  end
end

-- ---------- storm visuals ----------
local cc=UI.new("ColorCorrectionEffect",{Name="StormTint",Enabled=false},L)
local storm={}   -- storm[w]={kind,phase,ends}
local function look(w,phase,kind)
  if w=="mars" then
    if phase=="active" then
      TS:Create(L,TweenInfo.new(6),{FogEnd=55,FogStart=0,FogColor=Color3.fromRGB(150,96,58)}):Play()
    elseif phase=="clear" then
      TS:Create(L,TweenInfo.new(8),{FogEnd=620,FogStart=90,FogColor=Color3.fromRGB(176,124,80)}):Play()
    end
  else
    cc.Enabled=false
  end
end
local TEXT={
  dust={warn={"MARTIAN DUST EVENT","Compressed for gameplay -- shelter is optional"},
        active={"DUST IN THE ATMOSPHERE","Opportunity's solar-array output falls as sunlight dims"},
        clear={"DUST EVENT PASSED","Wind sometimes clears solar panels; dust accumulation is gradual"}},
  solar={warn={"SOLAR STORM COMING!","The Sun just flared. Radiation is on its way -- get to a SHELTER"},
        active={"SOLAR STORM","Radiation is invisible -- the flashes and clicks show it. Stay sheltered"},clear={"STORM PASSED","Safe to explore again"}},
}
rem:WaitForChild("StormState").OnClientEvent:Connect(function(w,kind,phase,secs)
  storm[w]={kind=kind,phase=phase,ends=os.clock()+secs}
  if w=="mars" and kind=="dust" and phase=="active" then
    -- A Mars dust event gradually softens the player's local bootprints under
    -- settling dust. Lunar tracks do not weather away in the airless vacuum.
    local prints=workspace:FindFirstChild("LocalFootprints")
    if prints then
      for _,mark in ipairs(prints:GetChildren()) do
        if mark:GetAttribute("World")=="mars" and mark.Parent then
          TS:Create(mark,TweenInfo.new(math.min(24,secs),Enum.EasingStyle.Linear),{Transparency=1}):Play()
        end
      end
    end
  end
  local r=hrp(); local mine=r and worldAt(r.Position)==w
  highlightShelters(w,phase~="clear")
  if mine then
    look(w,phase,kind)
    rem.RadioBeep:Fire()
  end
end)

-- ---------- lost signal at Tranquility ----------
local locked=false
local lockShow=0
local tranq={}
task.spawn(function()
  local T=game_:WaitForChild("Tranquility")
  for _,n in ipairs({"LM_DescentStage","Seismometer","Retroreflector"}) do
    local m=T:WaitForChild(n,60); local a=m and m:WaitForChild("Anchor",30)
    local pp=a and a:WaitForChild("ProximityPrompt",30)
    if pp then table.insert(tranq,{a=a,pp=pp}); if not locked then pp.Enabled=false end end
  end
end)
local lastBeep=0
local function signalTick(r)
  if locked or #tranq==0 then sig.Visible=false return end
  local d=math.huge for _,t in ipairs(tranq) do d=math.min(d,(t.a.Position-r.Position).Magnitude) end
  sig.Visible=worldAt(r.Position)=="moon"
  local s=math.clamp(1-d/320,0,1)
  -- noisy: the signal is weak and drifts, so you have to sweep around
  s=math.clamp(s+(math.noise(os.clock()*0.7)*0.18),0,1)
  local n=math.floor(s*5+0.5)
  for i,b in ipairs(bars) do b.BackgroundColor3=i<=n and (n>=4 and G or Y) or Color3.fromRGB(60,62,68) end
  if d<22 then
    locked=true; for _,t in ipairs(tranq) do t.pp.Enabled=true end
    sig.Visible=false; rem.RadioBeep:Fire()
    banner.Visible=true; bStroke.Color=G; bTitle.TextColor3=G
    bTitle.Text="SIGNAL FOUND!"; bSub.Text="Tranquility Base -- Apollo 11, 1969. Scan what you find"
    lockShow=os.clock()+6
  end
end


-- ---------- what a solar storm looks and sounds like ----------
-- Radiation itself cannot be seen. What the game shows is real:
--  * the flare: the Sun brightens before the particles arrive (they travel slower than light)
--  * a radiation counter ticking, like a dosimeter, fast outside and slow in the shelter
--  * light flashes: Apollo 11's Armstrong and Aldrin (and later crews) saw brief flashes even
--    with their eyes shut -- cosmic-ray particles passing through the eye
local flashLayer=UI.new("Frame",{Name="Flashes",BackgroundTransparency=1},root); UI.place(flashLayer,0,0,W,H,W,H)
local tick=Instance.new("Sound"); tick.SoundId="rbxasset://sounds/clickfast.wav"; tick.Volume=0.35; tick.Parent=gui
local bloom=L:FindFirstChildOfClass("BloomEffect") or UI.new("BloomEffect",{Name="FlareBloom",Intensity=0,Size=24,Threshold=0.9},L)
local bloom0=bloom.Intensity
local sky=L:FindFirstChildOfClass("Sky"); local sun0=sky and sky.SunAngularSize
local function flareSun(on)
  TS:Create(bloom,TweenInfo.new(on and 3 or 6),{Intensity=on and 1.6 or bloom0}):Play()
  if sky then TS:Create(sky,TweenInfo.new(on and 3 or 6),{SunAngularSize=on and (sun0 or 11)*2.2 or sun0}):Play() end
end
local function streak()
  local x,y=math.random(80,W-80),math.random(60,H-60)
  local len=math.random(30,90)
  local f=UI.new("Frame",{Name="Flash",BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=0.1,BorderSizePixel=0,Rotation=math.random(0,180)},flashLayer)
  UI.place(f,x-len/2,y-1.5,len,3,W,H)
  TS:Create(f,TweenInfo.new(0.12),{BackgroundTransparency=1}):Play()
  task.delay(0.15,function() f:Destroy() end)
end
local solarOn=false
task.spawn(function()
  while true do
    local r=hrp(); local w=r and worldAt(r.Position); local st=w and storm[w]
    local active=st and st.kind=="solar" and st.phase=="active"
    if active then
      local s,d=nearestShelter(w,r.Position); local inside=s and d<=s:GetAttribute("Radius")+1
      tick.PlaybackSpeed=1.6+math.random()*0.6; tick:Play()
      if not inside and math.random()<0.18 then streak() end
      task.wait(inside and (0.8+math.random()*1.6) or (0.05+math.random()*0.15))
    else
      task.wait(0.3)
    end
    local want=st and st.kind=="solar" and st.phase~="clear" or false
    if want~=solarOn then solarOn=want; flareSun(want) end
  end
end)

-- ---------- per frame ----------
RunService.Heartbeat:Connect(function()
  local r=hrp(); if not r then return end
  local w=worldAt(r.Position)
  local st=storm[w]
  local pw=me:GetAttribute("SuitPower") or 100
  power.Visible=pw<99 or (st and st.phase~="clear")
  fill.Size=UDim2.fromScale(UI.r4(pw/100),1); fill.BackgroundColor3=pw<30 and RED or (pw<60 and Y or G)
  pLbl.Text=(st and st.kind=="solar" and st.phase~="clear") and "RAD" or "SUIT"
  if st and st.phase~="clear" then
    local t=TEXT[st.kind][st.phase]; local left=math.max(0,math.ceil(st.ends-os.clock()))
    local s,d=nearestShelter(w,r.Position)
    local inside=s and d<=s:GetAttribute("Radius")+1
    banner.Visible=true; bStroke.Color=st.phase=="active" and RED or Y; bTitle.TextColor3=bStroke.Color
    bTitle.Text=t[1].."  "..left.."s"
    bSub.Text=inside and "You're safe in the shelter" or (t[2]..(d and ("  ("..math.floor(d).." studs)") or ""))
  elseif os.clock()<lockShow then
    -- the SIGNAL FOUND banner owns it
  elseif st and st.phase=="clear" and os.clock()-st.ends<6 then
    local t=TEXT[st.kind].clear; banner.Visible=true; bStroke.Color=G; bTitle.TextColor3=G; bTitle.Text=t[1]; bSub.Text=t[2]
  else
    banner.Visible=false
  end
  signalTick(r)
end)

-- Studio-only test hook
if RunService:IsStudio() then
  local h=Instance.new("BindableFunction"); h.Name="_StormTest"; h.Parent=gui
  h.OnInvoke=function() return {banner=banner.Visible,title=bTitle.Text,power=power.Visible,signal=sig.Visible,locked=locked,
    bad=UI.validate(gui)} end
end

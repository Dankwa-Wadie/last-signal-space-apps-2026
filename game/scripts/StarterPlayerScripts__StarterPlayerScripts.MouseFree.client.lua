-- Client mouse and pause handling.
local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local RS=game:GetService("RunService")
local CAS=game:GetService("ContextActionService")
local RSrv=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")
local plr=Players.LocalPlayer
local pg=plr:WaitForChild("PlayerGui")
local rem=RSrv:WaitForChild("Remotes")
local MENUS={"Transit","Console","Panel","Archive","TrophyRoom","SurveyMap","Controls","Handover"}

local function menuOpen()
  for _,n in ipairs(MENUS) do local g=pg:FindFirstChild(n); if g and g.Enabled then return true end end
  local s=pg:FindFirstChild("Settings"); local m=s and s:FindFirstChild("Menu")
  return m and m.Visible or false
end

local gui=Instance.new("ScreenGui"); gui.Name="MouseFree"; gui.ResetOnSpawn=false; gui.DisplayOrder=1; gui.Parent=pg
local modal=Instance.new("TextButton"); modal.Name="Modal"; modal.Modal=true; modal.Text=""; modal.TextScaled=true
modal.BackgroundTransparency=1; modal.AnchorPoint=Vector2.new(0.5,0.5); modal.Position=UDim2.fromScale(0.5,0.5)
modal.Size=UDim2.fromScale(0.001,0.001); modal.Visible=false; modal.Parent=gui

local pauseGui=Instance.new("ScreenGui"); pauseGui.Name="Pause"; pauseGui.ResetOnSpawn=false
pauseGui.IgnoreGuiInset=true; pauseGui.DisplayOrder=40; pauseGui.Enabled=false; pauseGui.Parent=pg
local shade=Instance.new("Frame"); shade.Size=UDim2.fromScale(1,1); shade.BackgroundColor3=Color3.new(0,0,0)
shade.BackgroundTransparency=0.25; shade.BorderSizePixel=0; shade.Parent=pauseGui
local panel=Instance.new("Frame"); panel.Size=UDim2.fromOffset(360,230); panel.AnchorPoint=Vector2.new(0.5,0.5)
panel.Position=UDim2.fromScale(0.5,0.5); panel.BackgroundColor3=Color3.fromRGB(12,13,16); panel.Parent=pauseGui
local pc=Instance.new("UICorner"); pc.CornerRadius=UDim.new(0,12); pc.Parent=panel
local title=Instance.new("TextLabel"); title.Size=UDim2.new(1,-32,0,48); title.Position=UDim2.fromOffset(16,18)
title.BackgroundTransparency=1; title.Font=Enum.Font.GothamBold; title.TextSize=28; title.TextColor3=Color3.new(1,1,1)
title.Text="PAUSED"; title.Parent=panel
local resume=Instance.new("TextButton"); resume.Size=UDim2.new(1,-48,0,48); resume.Position=UDim2.fromOffset(24,92)
resume.BackgroundColor3=Color3.fromRGB(245,231,60); resume.TextColor3=Color3.fromRGB(10,11,14)
resume.Font=Enum.Font.GothamBold; resume.TextSize=18; resume.Text="RESUME"; resume.Parent=panel
local rc=Instance.new("UICorner"); rc.CornerRadius=UDim.new(0,8); rc.Parent=resume

local paused=false
local humanoid=nil
local saved={}
local function setPaused(on)
  if paused==on then return end
  paused=on; pauseGui.Enabled=on
  local c=plr.Character; local h=c and c:FindFirstChildOfClass("Humanoid")
  humanoid=h
  if on then
    if h then
      saved.walk=h.WalkSpeed; saved.jump=h.JumpPower; saved.height=h.JumpHeight
      saved.autoRotate=h.AutoRotate; saved.jumpEnabled=h:GetStateEnabled(Enum.HumanoidStateType.Jumping)
      h.WalkSpeed=0; h.JumpPower=0; h.JumpHeight=0; h.AutoRotate=false
      h:SetStateEnabled(Enum.HumanoidStateType.Jumping,false); h:Move(Vector3.zero,false)
    end
    for _,n in ipairs({"Suit","Outside"}) do local g=SoundService:FindFirstChild(n); if g then saved[n]=g.Volume; g.Volume=0 end end
  else
    if h and h.Parent then
      h.WalkSpeed=saved.walk or 11; h.JumpPower=saved.jump or 0; h.JumpHeight=saved.height or 0
      h.AutoRotate=saved.autoRotate~=false
      h:SetStateEnabled(Enum.HumanoidStateType.Jumping,saved.jumpEnabled~=false); h:Move(Vector3.zero,false)
    end
    for _,n in ipairs({"Suit","Outside"}) do local g=SoundService:FindFirstChild(n); if g and saved[n]~=nil then g.Volume=saved[n] end end
    table.clear(saved); humanoid=nil
  end
end
resume.MouseButton1Click:Connect(function() setPaused(false) end)
local function pauseAction(_,state)
  if state==Enum.UserInputState.Begin then
    if paused then setPaused(false) elseif not menuOpen() then setPaused(true) end
  end
  return Enum.ContextActionResult.Sink
end
CAS:BindActionAtPriority("LastSignalPause",pauseAction,false,Enum.ContextActionPriority.High.Value,Enum.KeyCode.Escape)
-- The Roblox menu may consume Escape before a bound action on some clients. Observe the
-- menu lifecycle as a fallback so pausing always freezes the local avatar and audio.
local GuiService=game:GetService("GuiService")
GuiService.MenuOpened:Connect(function()
  if not menuOpen() then setPaused(true) end
end)
GuiService.MenuClosed:Connect(function()
  if paused then setPaused(false) end
end)
UIS.InputBegan:Connect(function(input,gpe)
  if input.KeyCode==Enum.KeyCode.Escape and not gpe then
    if paused then setPaused(false) elseif not menuOpen() then setPaused(true) end
  end
end)
RS:BindToRenderStep("LastSignalPauseFreeze",Enum.RenderPriority.Last.Value,function()
  if not paused then return end
  local c=plr.Character; local h=c and c:FindFirstChildOfClass("Humanoid")
  if h then
    h.WalkSpeed=0; h.JumpPower=0; h.JumpHeight=0; h:Move(Vector3.zero,false)
    h:SetStateEnabled(Enum.HumanoidStateType.Jumping,false)
  end
  local root=c and c:FindFirstChild("HumanoidRootPart")
  if root then root.AssemblyLinearVelocity=Vector3.zero; root.AssemblyAngularVelocity=Vector3.zero end
end)

-- First-person camera locking prevents mouse use in full-screen panels.
local altFree=false
local acc,free=0,false
RS:BindToRenderStep("MouseFree",Enum.RenderPriority.Camera.Value+1,function(dt)
  acc+=dt
  if acc>=0.08 then
    acc=0; free=altFree or paused or menuOpen(); modal.Visible=free
  end
  if free then UIS.MouseBehavior=Enum.MouseBehavior.Default; UIS.MouseIconEnabled=true end
end)
local function toggleAlt() altFree=not altFree end
UIS.InputBegan:Connect(function(i)
  if i.KeyCode==Enum.KeyCode.LeftAlt or i.KeyCode==Enum.KeyCode.RightAlt then toggleAlt() end
end)
rem:WaitForChild("LocalKey").Event:Connect(function(code,phase)
  if code==Enum.KeyCode.LeftAlt and phase~="up" then toggleAlt() end
end)
UIS.InputBegan:Connect(function(i,gpe) if not gpe and i.KeyCode==Enum.KeyCode.Q then altFree=false end end)

-- LocalScript  StarterPlayerScripts/StarterPlayerScripts.Helmet
-- helmet rim vignette + first/third person toggle
local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local RS=game:GetService("RunService")
local plr=Players.LocalPlayer
local first=true
local pg=plr:WaitForChild("PlayerGui")

local gui=Instance.new("ScreenGui")
gui.Name="HelmetView"; gui.ResetOnSpawn=false; gui.IgnoreGuiInset=true
gui.DisplayOrder=-5; gui.Parent=pg

-- four soft edge bands suggest the inside of a helmet without hiding the view
local function band(size,pos,rot)
  local f=Instance.new("Frame")
  f.Size=size; f.Position=pos; f.BorderSizePixel=0
  f.BackgroundColor3=Color3.fromRGB(6,6,8)
  f.Parent=gui
  local g=Instance.new("UIGradient")
  g.Transparency=NumberSequence.new({
    NumberSequenceKeypoint.new(0,0.15),
    NumberSequenceKeypoint.new(0.55,0.75),
    NumberSequenceKeypoint.new(1,1)})
  g.Rotation=rot
  g.Parent=f
  return f
end
band(UDim2.new(1,0,0,150),UDim2.new(0,0,0,0),90)      -- top
band(UDim2.new(1,0,0,170),UDim2.new(0,0,1,-170),270)  -- bottom
band(UDim2.new(0,190,1,0),UDim2.new(0,0,0,0),0)       -- left
band(UDim2.new(0,190,1,0),UDim2.new(1,-190,0,0),180)  -- right

-- First-person visibility.
-- * Head, helmet and visor are hidden from our own camera in first person: the camera follows the
--   body, not the head, so a visible head shows its back whenever it bobs ahead (walking, jumping).
-- * A part hidden that way casts NO shadow (tested), which made the shadow headless. So a local-only
--   "shadow helmet" ball is kept exactly where the camera is: we are always at its centre, Roblox
--   draws no inside faces, and it still casts the round head shadow. Only this client has it.
-- * The camera itself is left alone (pinning it to the animated head made the view shake).
-- * The default camera also writes LocalTransparencyModifier every frame; running right after the
--   camera step means this script has the last word (no blinking).
local HIDE={Head=true,Helmet=true,Visor=true}
local tracked=nil
local function localize(char)
  task.wait(0.4)
  tracked=char
end
local shadowHelm=Instance.new("Part")
shadowHelm.Name="LocalShadowHelmet"; shadowHelm.Shape=Enum.PartType.Ball; shadowHelm.Size=Vector3.new(2,2,2)
shadowHelm.Material=Enum.Material.Glass; shadowHelm.Transparency=0.45; shadowHelm.Color=Color3.fromRGB(240,240,240)
shadowHelm.Anchored=true; shadowHelm.CanCollide=false; shadowHelm.CanQuery=false; shadowHelm.CanTouch=false
shadowHelm.CastShadow=true
RS:BindToRenderStep("HelmetVisibility", Enum.RenderPriority.Camera.Value + 1, function()
  if not tracked or not tracked.Parent then shadowHelm.Parent=nil; return end
  for _,d in ipairs(tracked:GetDescendants()) do
    if d:IsA("BasePart") then
      d.LocalTransparencyModifier = (first and HIDE[d.Name]) and 1 or 0
    elseif d:IsA("Decal") then
      d.LocalTransparencyModifier = first and 1 or 0
    end
  end
  -- keep the eye inside the helmet: the default first-person camera follows the body and lags the
  -- head by up to ~1.5 studs when jumping. Steer Humanoid.CameraOffset toward the helmet centre with a
  -- low-pass filter: slow movement (jumps) is followed, the fast walking bob is smoothed out.
  local hum=tracked:FindFirstChildOfClass("Humanoid"); local hrp=tracked:FindFirstChild("HumanoidRootPart")
  local helm=tracked:FindFirstChild("Helmet")
  if hum and hrp and helm then
    if first then
      local cam=workspace.CurrentCamera
      local err=hrp.CFrame:VectorToObjectSpace(helm.Position-cam.CFrame.Position)   -- where the eye should move
      local target=hum.CameraOffset+err
      if target.Magnitude>2.5 then target=target.Unit*2.5 end
      hum.CameraOffset=hum.CameraOffset:Lerp(target,0.35)
    elseif hum.CameraOffset.Magnitude>0 then
      hum.CameraOffset=Vector3.zero
    end
  end
  if first then
    shadowHelm.CFrame=CFrame.new(workspace.CurrentCamera.CFrame.Position)
    shadowHelm.Parent=workspace
  else
    shadowHelm.Parent=nil
  end
end)
if plr.Character then task.spawn(localize,plr.Character) end
plr.CharacterAdded:Connect(function(c) task.spawn(localize,c) end)

-- V (or the on-screen button) switches first / third person. First person is the default and is
-- re-applied on every spawn, so the player never drifts out of it by accident.
local viewGui=Instance.new("ScreenGui"); viewGui.Name="ViewToggle"; viewGui.ResetOnSpawn=false; viewGui.Parent=pg
local viewBtn=Instance.new("TextButton")
viewBtn.Size=UDim2.fromOffset(150,36); viewBtn.Position=UDim2.new(1,-170,1,-56)
viewBtn.BackgroundColor3=Color3.fromRGB(8,8,10); viewBtn.BackgroundTransparency=0.25
viewBtn.Font=Enum.Font.GothamBold; viewBtn.TextSize=14; viewBtn.TextColor3=Color3.fromRGB(245,231,60)
viewBtn.Parent=viewGui
Instance.new("UICorner",viewBtn).CornerRadius=UDim.new(0,8)
local function applyView()
  plr.CameraMode = first and Enum.CameraMode.LockFirstPerson or Enum.CameraMode.Classic
  if not first then plr.CameraMinZoomDistance=8; plr.CameraMaxZoomDistance=16 else plr.CameraMinZoomDistance=0.5 end
  for _,f in ipairs(gui:GetChildren()) do
    if f:IsA("Frame") then f.Visible=first end
  end
  viewBtn.Text = first and "[V] 3RD PERSON" or "[V] 1ST PERSON"
end
local function toggleView()
  first=not first
  applyView()
end
viewBtn.MouseButton1Click:Connect(toggleView)
plr.CharacterAdded:Connect(function() task.wait(0.1); applyView() end)
applyView()

-- touch buttons feed the same toggle through Remotes.LocalKey (see the Touch script)
local LocalKey=game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("LocalKey")
LocalKey.Event:Connect(function(code,phase)
  if code==Enum.KeyCode.V and phase~="up" then toggleView() end
end)

UIS.InputBegan:Connect(function(i,gpe)
  if gpe then return end
  if i.KeyCode==Enum.KeyCode.V then toggleView() end
end)

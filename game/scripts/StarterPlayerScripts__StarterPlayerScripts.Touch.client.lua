-- LocalScript  StarterPlayerScripts/StarterPlayerScripts.Touch
-- Touchscreen controls. Everything in LAST SIGNAL was keyboard-only (E/R/F/V/Q plus WASD and
-- the arrows inside the puzzle), which locked out every player on a phone or tablet -- a large
-- share of this game's audience. These buttons fire Remotes.LocalKey, a BindableEvent, so the
-- existing handlers see them exactly as they see a real key press. Nothing goes over the network.
local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local RSrv=game:GetService("ReplicatedStorage")
local plr=Players.LocalPlayer
local pg=plr:WaitForChild("PlayerGui")
local rem=RSrv:WaitForChild("Remotes")
local LocalKey=rem:WaitForChild("LocalKey")

-- Show on touch devices. Also show when Studio is emulating touch, so this is testable.
if not UIS.TouchEnabled then return end

local YEL=Color3.fromRGB(245,231,60)
local function mk(cls,props,parent)
  local o=Instance.new(cls); for k,v in pairs(props) do o[k]=v end
  -- A UIStroke on a text object outlines the letters, not the box. We always mean the box.
  if cls=="UIStroke" and props.ApplyStrokeMode==nil and parent
     and (parent:IsA("TextButton") or parent:IsA("TextLabel") or parent:IsA("TextBox")) then
    o.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
  end
  o.Parent=parent; return o
end

local gui=mk("ScreenGui",{Name="TouchControls",ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=8},pg)

-- ---------- the verb row (bottom right, above Roblox's own jump button) ----------
local bar=mk("Frame",{Size=UDim2.fromOffset(242,116),Position=UDim2.new(1,-258,1,-250),
  BackgroundTransparency=1},gui)
mk("UIGridLayout",{CellSize=UDim2.fromOffset(74,50),CellPadding=UDim2.fromOffset(8,8),
  FillDirectionMaxCells=3,SortOrder=Enum.SortOrder.LayoutOrder},bar)

local function verb(label,key,order,hint)
  local b=mk("TextButton",{Size=UDim2.fromOffset(74,50),BackgroundColor3=Color3.fromRGB(14,15,18),
    BackgroundTransparency=0.12,AutoButtonColor=true,Font=Enum.Font.GothamBold,TextSize=14,
    TextColor3=YEL,Text=label,LayoutOrder=order},bar)
  mk("UICorner",{CornerRadius=UDim.new(0,8)},b)
  mk("UIStroke",{Color=Color3.fromRGB(70,74,82),Thickness=1},b)
  b.MouseButton1Click:Connect(function() LocalKey:Fire(key,"down"); LocalKey:Fire(key,"up") end)
  b.Name=label
  return b
end

verb("REMEMBER",Enum.KeyCode.R,1)
verb("REACTIVATE",Enum.KeyCode.F,2)
verb("CLOSE",Enum.KeyCode.Q,3)
verb("VIEW",Enum.KeyCode.V,4)

-- ---------- the puzzle pad (level / aim controls, hold to move) ----------
-- Hidden until a puzzle opens. The seismometer puzzle reads held keys, so these press and
-- release rather than tapping.
local pad=mk("Frame",{Size=UDim2.fromOffset(196,196),Position=UDim2.new(0,24,1,-230),
  BackgroundTransparency=1,Visible=false},gui)

local function hold(label,key,pos)
  local b=mk("TextButton",{Size=UDim2.fromOffset(60,60),Position=pos,
    BackgroundColor3=Color3.fromRGB(14,15,18),BackgroundTransparency=0.12,AutoButtonColor=true,
    Font=Enum.Font.GothamBold,TextSize=20,TextColor3=Color3.new(1,1,1),Text=label},pad)
  mk("UICorner",{CornerRadius=UDim.new(0,8)},b)
  mk("UIStroke",{Color=Color3.fromRGB(70,74,82),Thickness=1},b)
  local down=false
  local function press() if down then return end; down=true; LocalKey:Fire(key,"down") end
  local function release() if not down then return end; down=false; LocalKey:Fire(key,"up") end
  b.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then press() end
  end)
  b.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then release() end
  end)
  -- a finger that slides off the button must not leave the key stuck down
  b.MouseLeave:Connect(release)
  return b
end

-- tilt cluster (WASD) on the left, gain (up/down) on the right
hold("W",Enum.KeyCode.W,UDim2.fromOffset(68,0))
hold("A",Enum.KeyCode.A,UDim2.fromOffset(0,68))
hold("S",Enum.KeyCode.S,UDim2.fromOffset(68,136))
hold("D",Enum.KeyCode.D,UDim2.fromOffset(136,68))
hold("+",Enum.KeyCode.Up,UDim2.fromOffset(136,0))
hold("-",Enum.KeyCode.Down,UDim2.fromOffset(136,136))
mk("TextLabel",{Size=UDim2.fromOffset(196,20),Position=UDim2.fromOffset(0,-24),
  BackgroundTransparency=1,Font=Enum.Font.GothamMedium,TextSize=12,TextColor3=Color3.fromRGB(180,186,194),
  Text="LEVEL  ·  + / -  GAIN"},pad)

-- the puzzle and archive screens tell us when they are open
local OpenPuzzle=rem:WaitForChild("OpenPuzzle")
OpenPuzzle.OnClientEvent:Connect(function() pad.Visible=true end)
-- The puzzle closes locally (solved, or Escape), and SolvePuzzle only travels client -> server,
-- so there is no event to listen for. Watch its ScreenGui instead; it is named "Panel".
task.spawn(function()
  while true do
    task.wait(0.35)
    if pad.Visible then
      local p=pg:FindFirstChild("Panel")
      if not p or not p.Enabled then pad.Visible=false end
    end
  end
end)

-- Roblox shows its own button for a ProximityPrompt on touch, so E needs nothing here.
print("Touch controls on")

-- Script  ServerScriptService/Suit
-- EVA suit: white pressure garment, PLSS backpack, helmet + gold visor
local Players=game:GetService("Players")

local WHITE=Color3.fromRGB(236,236,232)

local function part(name,size,color,mat,parent)
  local p=Instance.new("Part")
  p.Name=name; p.Size=size; p.Color=color; p.Material=mat
  p.CanCollide=false; p.Massless=true
  p.TopSurface=Enum.SurfaceType.Smooth; p.BottomSurface=Enum.SurfaceType.Smooth
  p.Parent=parent
  return p
end

local function weld(a,b,c0)
  local w=Instance.new("Weld")
  w.Part0=a; w.Part1=b; w.C0=c0 or CFrame.new()
  w.Parent=a
  return w
end

local function dress(char)
  local hum=char:WaitForChild("Humanoid",10); if not hum then return end
  local head=char:WaitForChild("Head",10); if not head then return end
  local torso=char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
  if not torso then return end

  -- strip hair and anything cosmetic
  for _,a in ipairs(char:GetChildren()) do
    if a:IsA("Accessory") or a:IsA("Shirt") or a:IsA("Pants") or a:IsA("ShirtGraphic") then
      a:Destroy()
    end
  end
  -- white pressure garment
  local bc=char:FindFirstChildOfClass("BodyColors")
  if not bc then bc=Instance.new("BodyColors"); bc.Parent=char end
  for _,prop in ipairs({"HeadColor3","TorsoColor3","LeftArmColor3","RightArmColor3",
                        "LeftLegColor3","RightLegColor3"}) do
    pcall(function() bc[prop]=WHITE end)
  end
  for _,d in ipairs(char:GetDescendants()) do
    if d:IsA("BasePart") and d.Name~="HumanoidRootPart" then
      d.Color=WHITE; d.Material=Enum.Material.SmoothPlastic
    end
  end

  -- PLSS backpack
  local pack=part("PLSS",Vector3.new(1.9,2.0,0.85),Color3.fromRGB(222,222,218),Enum.Material.SmoothPlastic,char)
  pack.CFrame=torso.CFrame*CFrame.new(0,0.1,0.78)
  weld(torso,pack,CFrame.new(0,0.1,0.78))

  -- dynamic heads bake the face into the head texture: blank it so the suit reads as suited
  if head:IsA("MeshPart") then pcall(function() head.TextureID="" end) end
  for _,d in ipairs(head:GetChildren()) do if d:IsA("Decal") then d:Destroy() end end

  -- helmet bubble
  local helm=part("Helmet",Vector3.new(2.0,2.0,2.0),Color3.fromRGB(240,240,240),Enum.Material.Glass,char)
  helm.Shape=Enum.PartType.Ball
  helm.Transparency=0.45; helm.Reflectance=0.18
  helm.CFrame=head.CFrame
  weld(head,helm,CFrame.new(0,0,0))

  -- gold visor
  local visor=part("Visor",Vector3.new(1.45,1.0,0.55),Color3.fromRGB(214,168,54),Enum.Material.Glass,char)
  visor.Reflectance=0.45; visor.Transparency=0.18
  visor.CFrame=head.CFrame*CFrame.new(0,0.02,-0.72)
  weld(head,visor,CFrame.new(0,0.02,-0.72))

  -- red commander stripe so the suit reads as Apollo
  local band=part("Band",Vector3.new(1.3,0.18,1.3),Color3.fromRGB(190,62,48),Enum.Material.SmoothPlastic,char)
  local arm=char:FindFirstChild("RightUpperArm") or char:FindFirstChild("Right Arm")
  if arm then
    band.Size=Vector3.new(arm.Size.X*1.06,0.18,arm.Size.Z*1.06)
    band.CFrame=arm.CFrame*CFrame.new(0,0.25,0)
    weld(arm,band,CFrame.new(0,0.25,0))
  else band:Destroy() end

  hum.WalkSpeed=11      -- a suited astronaut is not sprinting
  hum.JumpPower=32      -- but lunar gravity gives a good hop
  hum.UseJumpPower=true
end

Players.PlayerAdded:Connect(function(p)
  p.CharacterAppearanceLoaded:Connect(dress)
  if p.Character then dress(p.Character) end
end)
for _,p in ipairs(Players:GetPlayers()) do
  p.CharacterAppearanceLoaded:Connect(dress)
  if p.Character then dress(p.Character) end
end

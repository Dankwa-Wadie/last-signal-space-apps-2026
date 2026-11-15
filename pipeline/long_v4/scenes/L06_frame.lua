local TILT=35
-- the collector bends at the waist, closes the tongs on the rock, straightens and drops it in the bag.
-- R15 joints here are AnimationConstraints: pose them by rotating the rig attachment BEFORE the step.
local c=S:FindFirstChild("Armstrong")
local u=k/math.max(1,n-1)
local bend
if u<0.30 then bend=ease(u/0.30)
elseif u<0.45 then bend=1
elseif u<0.75 then bend=1-ease((u-0.45)/0.30)
else bend=0 end
local reach=(u<0.75) and (0.25+0.75*bend) or (0.25*(1-ease((u-0.75)/0.25)))
if c then
  local wa=c.UpperTorso:FindFirstChild("WaistRigAttachment")
  local sa=c.RightUpperArm:FindFirstChild("RightShoulderRigAttachment")
  if wa then
    if not wa:GetAttribute("C0") then wa:SetAttribute("C0",wa.CFrame) end
    wa.CFrame=wa:GetAttribute("C0")*CFrame.Angles(math.rad(17*bend),0,0)
  end
  if sa then
    if not sa:GetAttribute("C0") then sa:SetAttribute("C0",sa.CFrame) end
    sa.CFrame=sa:GetAttribute("C0")*CFrame.Angles(math.rad(-(40+8*bend)),0,0)
  end
end
stepAll(1/24)
if not c then return "nocol" end
local hand=c.RightHand; local root=c.HumanoidRootPart
local tong=c.Tongs; local jaw=c.Jaw; local bag=c.SampleBag; local rock=S.Sample
local tilt=CFrame.Angles(math.rad(TILT),0,0)
tong.CFrame=hand.CFrame*tilt*CFrame.new(0,-1.05,0)
jaw.CFrame=hand.CFrame*tilt*CFrame.new(0,-2.05,0)
bag.CFrame=c.LowerTorso.CFrame*CFrame.new(-1.15,-0.1,0.05)
if u<0.36 then rock.CFrame=rock:GetAttribute("C0")
elseif u<0.92 then rock.CFrame=jaw.CFrame*CFrame.new(0,-0.18,0)
else rock.CFrame=bag.CFrame*CFrame.new(0,0.2,0) end
if matte then for _,p in ipairs({tong,jaw,bag,rock}) do p.Material=Enum.Material.Neon; p.Color=Color3.new(1,1,1) end end
return "ok"

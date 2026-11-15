-- "They planted a flag, collected bags of moon rocks": one astronaut at the flag behind, the
-- other in front picking up a sample with the long-handled tongs and bagging it
-- (reference: AS16-106-17340, John Young collecting samples).
local s=wipe(); spaceSky(); moonLight(9.5,60)
ground(s,Color3.fromRGB(150,147,140),Enum.Material.Sand,1600)
rocks(s,40,Color3.fromRGB(112,108,103),14,140,33,1)
procLM(18,-14,-40)
flag(CFrame.new(0,0,0)*CFrame.Angles(0,math.rad(-15),0))
local a,an=astronaut("Aldrin",CFrame.new(3.4,2.9,-2.6)*CFrame.Angles(0,math.rad(-120),0),false)
play(an,"idle",1,0.4)
-- the collector, in the foreground, facing camera-left
local c,anc=astronaut("Armstrong",CFrame.new(-1.6,2.9,6.2)*CFrame.Angles(0,math.rad(-70),0),true)
play(anc,"idle",1,1.1)
-- sample bag on the left hip, tongs in the right hand, the rock on the ground ahead
local hand=c:FindFirstChild("RightHand")
local tong=Instance.new("Part"); tong.Name="Tongs"; tong.Size=Vector3.new(0.12,2.0,0.12)
tong.Material=Enum.Material.Metal; tong.Color=Color3.fromRGB(190,190,186); tong.Anchored=true; tong.CanCollide=false; tong.Parent=c
local jaw=Instance.new("Part"); jaw.Name="Jaw"; jaw.Size=Vector3.new(0.36,0.22,0.22)
jaw.Material=Enum.Material.Metal; jaw.Color=Color3.fromRGB(150,150,146); jaw.Anchored=true; jaw.CanCollide=false; jaw.Parent=c
local bag=Instance.new("Part"); bag.Name="SampleBag"; bag.Size=Vector3.new(0.7,0.8,0.5)
bag.Material=Enum.Material.Fabric; bag.Color=Color3.fromRGB(205,200,186); bag.Anchored=true; bag.CanCollide=false; bag.Parent=c
local rock=Instance.new("Part"); rock.Name="Sample"; rock.Size=Vector3.new(0.42,0.32,0.38)
rock.Material=Enum.Material.Basalt; rock.Color=Color3.fromRGB(92,88,84); rock.Anchored=true; rock.CanCollide=false; rock.Parent=s
local root=c.HumanoidRootPart
rock.CFrame=CFrame.new(0.07,0.16,6.99)*CFrame.Angles(0.4,0.7,0.2)   -- where the tong jaws reach at full bend (measured)
rock:SetAttribute("C0",rock.CFrame)
return "L06"

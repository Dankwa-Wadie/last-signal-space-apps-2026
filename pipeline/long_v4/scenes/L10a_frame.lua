-- climb from the bottom rung to the porch. The ladder leans ~40 deg from vertical, so the climber's
-- hips sit at the ladder point level with them (plus a body-depth offset) and the body leans into it.
local a=S:FindFirstChild("Armstrong"); if not a then return "noa" end
local b,t,out=S:GetAttribute("LB"),S:GetAttribute("LT"),S:GetAttribute("LO")
local u=math.clamp(k/math.max(1,n-1),0,1)
local foot=b:Lerp(t,0.05+0.8*u)
local dir=(t-b).Unit
local hipY=foot.Y+2.4
local q=b+dir*((hipY-b.Y)/dir.Y)              -- ladder point at hip height
local root=q+out*0.85+Vector3.new(0,0.35,0)
local face=Vector3.new(q.X,root.Y,q.Z)
a.HumanoidRootPart.CFrame=CFrame.lookAt(root,face)*CFrame.Angles(math.rad(-34),0,0)
stepAll(1/24)
return "ok"

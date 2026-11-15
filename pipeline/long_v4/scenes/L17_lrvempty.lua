local s=wipe(); spaceSky(); moonLight(9.5,60); rille(); rilleRocks(s,15)
procLRV(18,0,20)
for i=1,24 do
  local p=Instance.new("Part"); p.Size=Vector3.new(0.5,0.04,1.05)
  p.CFrame=CFrame.new(15-i*0.9+(i%2==0 and 0.5 or -0.5),2.03,-2-i*1.1)*CFrame.Angles(0,math.rad(40),0)
  p.Anchored=true; p.CanCollide=false; p.Material=Enum.Material.Sand; p.Color=Color3.fromRGB(122,119,113); p.Parent=s
end

do -- rocks scattered over the carved rille would float: keep only those with ground under them
  local rp=RaycastParams.new(); rp.FilterType=Enum.RaycastFilterType.Include; rp.FilterDescendantsInstances={workspace.Terrain}
  for _=1,40 do if workspace:Raycast(Vector3.new(30,200,0),Vector3.new(0,-400,0),rp) then break end task.wait(0.05) end
  for _,p in ipairs(s:GetChildren()) do
    if p:IsA("BasePart") and p.Material==Enum.Material.Rock then
      local hit=workspace:Raycast(Vector3.new(p.Position.X,60,p.Position.Z),Vector3.new(0,-300,0),rp)
      if not hit or hit.Position.Y < p.Position.Y-1.5-p.Size.Y then p:Destroy() end
    end
  end
end
return "L17"

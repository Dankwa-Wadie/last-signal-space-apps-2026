local s=wipe(); spaceSky(); moonLight(9.5,60); rille(); rilleRocks(s,15)
procLRV(18,0,20)
for i=1,30 do
  for _,off in ipairs({-1.5,1.5}) do
    local p=Instance.new("Part"); p.Size=Vector3.new(0.75,0.06,2.0)
    local bend=math.sin(i/9)*4
    p.CFrame=CFrame.new(18+off+bend,2.04,5+i*2.0)*CFrame.Angles(0,math.rad(bend*1.6),0)
    p.Anchored=true; p.CanCollide=false; p.Material=Enum.Material.Sand; p.Color=Color3.fromRGB(118,115,109); p.Parent=s
  end
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
return "L15"

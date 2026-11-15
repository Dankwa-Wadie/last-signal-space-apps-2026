-- v138: move every site folder from its old spot to its real lat/lon on its world's ring,
-- clear the old rims/walls/terrain, and set streaming for phones.
local WL=(function()
WORLD_LAYOUT
end)()
local game_=workspace:WaitForChild("Game")
local b=game_:FindFirstChild("Bounds"); if b then b:Destroy() end
workspace.Terrain:Clear()
local moved={}
for name,s in pairs(WL.SITES) do
  local f=game_:FindFirstChild(name)
  if f and not f:GetAttribute("Relocated") then
    local delta=WL.pos(s[1],s[2],s[3])-s[4]
    for _,c in ipairs(f:GetChildren()) do
      if c:IsA("Model") then c:PivotTo(c:GetPivot()+delta)
      elseif c:IsA("BasePart") then c.CFrame=c.CFrame+delta end
    end
    f:SetAttribute("Relocated",true); table.insert(moved,name)
  end
  -- the old site plates: the ground now comes from the client's ring tiles
  for _,n in ipairs({"Ground","Regolith"}) do
    local g=f and f:FindFirstChild(n)
    if g then g:SetAttribute("SitePlate",true) end
  end
end
pcall(function() workspace.StreamingTargetRadius=640; workspace.StreamingMinRadius=256 end)
return "relocated: "..(#moved>0 and table.concat(moved,",") or "none (already)")

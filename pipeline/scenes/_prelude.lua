local ws=workspace
local L=game:GetService("Lighting")
local Lib=ws:WaitForChild("Library")

local function wipe()
  for _,n in ipairs({"Scene","Preview","LunarTest"}) do
    local x=ws:FindFirstChild(n); if x then x:Destroy() end
  end
  -- Studio's default SpawnLocation is a white slab sitting at the origin
  for _,c in ipairs(ws:GetChildren()) do
    if c:IsA("SpawnLocation") or c.Name=="SpawnLocation" then c:Destroy() end
  end
  ws.Terrain:Clear()
  task.wait(0.8)  -- let Terrain:Clear() settle before the next scene builds (back-to-back shots leaked terrain)
  -- The playable game lives in workspace.Game and sits on the same ground at
  -- the origin, so it would appear in every film frame. Park it in
  -- ServerStorage for the duration of the render; render_film.py puts it back.
  local SS=game:GetService("ServerStorage")
  local g=ws:FindFirstChild("Game")
  if g then g.Parent=SS end
  local f=Instance.new("Folder"); f.Name="Scene"; f.Parent=ws
  return f
end

local function spawn(tag,x,z,height,yaw,sink)
  local src=Lib:FindFirstChild(tag); if not src then return nil end
  local m=src:Clone()
  local ext=m:GetExtentsSize()
  m:ScaleTo(height/ext.Y)
  sink = sink or 0
  -- generate_mesh bakes a display stand into the bottom of some meshes. The
  -- model carries a PlinthFraction attribute; bury that much of it below the
  -- ground. (Cutting the stand off with SubtractAsync does NOT survive a save.)
  sink = sink + height*(src:GetAttribute("PlinthFraction") or 0)
  m:PivotTo(CFrame.new(x, height/2 - sink, z)*CFrame.Angles(0,math.rad(yaw or 0),0))
  for _,d in ipairs(m:GetDescendants()) do if d:IsA("BasePart") then d.Anchored=true end end
  m.Parent=ws.Scene
  return m
end

local function ground(scene,color,material,size)
  local p=Instance.new("Part")
  p.Size=Vector3.new(size,2,size); p.CFrame=CFrame.new(0,-1,0)
  p.Anchored=true; p.Color=color; p.Material=material
  p.TopSurface=Enum.SurfaceType.Smooth; p.Parent=scene
  return p
end

local function rocks(scene,n,color,minR,maxR,seed,scale)
  local rng=Random.new(seed)
  for i=1,n do
    local p=Instance.new("Part")
    local s=rng:NextNumber(0.5,3.0)*(scale or 1)
    p.Size=Vector3.new(s,s*rng:NextNumber(0.35,0.8),s*rng:NextNumber(0.7,1.4))
    local a=rng:NextNumber(0,math.pi*2); local d=rng:NextNumber(minR,maxR)
    p.CFrame=CFrame.new(math.cos(a)*d,s/5,math.sin(a)*d)
      *CFrame.Angles(rng:NextNumber(0,3),rng:NextNumber(0,3),rng:NextNumber(0,3))
    p.Anchored=true; p.Material=Enum.Material.Rock; p.Color=color; p.Parent=scene
  end
end

local function clearAtmos()
  for _,c in ipairs(L:GetChildren()) do
    if c:IsA("Atmosphere") then c:Destroy() end
  end
end

local function moonLight(clock,lat)
  clearAtmos()
  -- airless Moon: white sunlight. (A stray orange ColorShift_Top tinted everything once.)
  L.ColorShift_Top=Color3.new(0,0,0); L.ColorShift_Bottom=Color3.new(0,0,0)
  L.ClockTime=clock or 16.5
  L.GeographicLatitude=lat or 20
  L.Brightness=4
  L.Ambient=Color3.fromRGB(13,13,17)
  L.OutdoorAmbient=Color3.fromRGB(13,13,17)
  L.EnvironmentDiffuseScale=0
  L.EnvironmentSpecularScale=0.15
  L.ExposureCompensation=0.15
  L.FogEnd=100000
end

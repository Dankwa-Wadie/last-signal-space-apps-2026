-- GROUND (v138): every world is a ring with no edge, drawn only around you.
--  * Tiles: an 18x18 grid of 64-stud tiles (576 studs each way) follows you. Within 150 studs
--    the ground is flat to walk on; beyond that each tile is lowered and tilted by the curve
--    of a ball of the ring's radius (drop = d^2 / 2R), so the horizon falls away and the end of
--    the drawn ground is always below it. Nothing else of the world is ever loaded.
--  * Rocks come from a fixed recipe per tile (a hash of the tile's wrapped index), so a place
--    looks the same every time you come back -- including after walking all the way round.
--  * Wrap: walk past the seam and you are moved to the matching spot on the far side.
--  * Horizon: anything beyond where the curve would hide it is not drawn; nor is anything on
--    another world. This is the "draw only what you can see" rule that keeps phones fast.
-- The curve is far stronger than the real Moon's (its horizon is ~2.4 km for a standing
-- astronaut) -- at true scale it could never be seen in a game this size. The signs say so.
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local WL=require(game:GetService("ReplicatedStorage"):WaitForChild("WorldLayout"))
local me=Players.LocalPlayer
local game_=workspace:WaitForChild("Game")

local TILE,N=64,18
local FLAT=150
-- Bounds of the imported Blender terrain around the relocated Apollo 15 site.
-- Cells inside this footprint must defer to the mesh, including where it dips below y=0.
local HADLEY_TERRAIN={minX=-664,maxX=-239,minZ=-741,maxZ=-418}
local folder=Instance.new("Folder"); folder.Name="LocalGround"; folder.Parent=workspace
local groundTiles={}
local footprints=Instance.new("Folder"); footprints.Name="LocalFootprints"; footprints.Parent=workspace
local footprintRecords={}
local MAX_FOOTPRINTS=120
local STEP_DISTANCE=2.35
local lastStep,lastFoot,stepIndex=nil,0,0
local rayParams=RaycastParams.new()
rayParams.FilterType=Enum.RaycastFilterType.Exclude
rayParams.RespectCanCollide=true
local slabs={}
for i=1,N*N do
  local p=Instance.new("Part"); p.Name="Tile"; p.Anchored=true; p.CastShadow=false
  p.Size=Vector3.new(TILE+2,4,TILE+2); p.TopSurface=Enum.SurfaceType.Smooth; p.Parent=folder
  slabs[i]=p
  groundTiles[p]=true
end
local ROCKS=180
local rocks={}
for i=1,ROCKS do
  local r=Instance.new("Part"); r.Name="Rock"; r.Anchored=true; r.CanCollide=false; r.CastShadow=true
  r.Material=Enum.Material.Slate; r.Transparency=1; r.Parent=folder; rocks[i]=r
end

local function hash(a,b,salt)
  local h=math.sin(a*12.9898+b*78.233+salt*37.719)*43758.5453
  return h-math.floor(h)
end

local function curve(cfg,cx,cz,px,pz,thick)
  local dx,dz=cx-px,cz-pz
  local d=math.sqrt(dx*dx+dz*dz)
  local e=math.max(0,d-FLAT)
  local drop=e*e/(2*cfg.R)
  local a=e/cfg.R
  local pos=Vector3.new(cx,-drop-thick/2,cz)
  if a<1e-4 or d<1 then return CFrame.new(pos),drop,d end
  local u=Vector3.new(dx/d,0,dz/d)
  local n=Vector3.new(0,math.cos(a),0)+u*math.sin(a)
  local r=n:Cross(u).Unit
  return CFrame.fromMatrix(pos,r,n),drop,d
end

local lastC,lastW=nil,nil
local function rebuild(world,px,pz)
  local cfg=WL.WORLDS[world]
  local bx,bz=math.floor(px/TILE),math.floor(pz/TILE)
  local k=0; local ri=0
  for i=0,N-1 do for j=0,N-1 do
    k+=1
    local ix,iz=bx+i-N/2,bz+j-N/2
    local cx,cz=ix*TILE+TILE/2,iz*TILE+TILE/2
    local s=slabs[k]
    local cf,drop,d=curve(cfg,cx,cz,px,pz,4)
    s.CFrame=cf; s.Color=cfg.colour; s.Material=cfg.material
    -- Let the imported Hadley mesh provide both the visible floor and collision surface.
    -- Hide only cells whose centres lie within its footprint; the mesh meets the normal
    -- curved tile ground at its perimeter.
    local underLunarTerrain=world=="moon" and cx>=HADLEY_TERRAIN.minX and cx<=HADLEY_TERRAIN.maxX
      and cz>=HADLEY_TERRAIN.minZ and cz<=HADLEY_TERRAIN.maxZ
    s.LocalTransparencyModifier=underLunarTerrain and 1 or 0
    s.CanCollide=d<FLAT+TILE*1.5 and not underLunarTerrain
    s.CanQuery=not underLunarTerrain
    -- rocks: recipe keyed on the WRAPPED tile index, so the far side matches on return
    if d<330 then
      local wx=math.floor(((cx-cfg.xmin)%cfg.W)/TILE); local wz=math.floor(((cz-cfg.zmin)%cfg.D)/TILE)
      local salt=(world=="moon" and 1) or (world=="mars" and 2) or 3
      local count=math.floor(hash(wx,wz,salt)*3)
      for q=1,count do
        ri+=1; if ri>ROCKS then break end
        local r=rocks[ri]
        local sz=0.6+hash(wx,wz,salt*10+q)*2.6
        local ox=(hash(wx,wz,salt*20+q)-0.5)*TILE; local oz=(hash(wx,wz,salt*30+q)-0.5)*TILE
        local rcf,rdrop=curve(cfg,cx+ox,cz+oz,px,pz,0)
        r.Size=Vector3.new(sz*1.3,sz*0.7,sz)
        r.CFrame=rcf*CFrame.new(0,sz*0.25,0)*CFrame.Angles(0,hash(wx,wz,q)*6.28,hash(wz,wx,q)*0.5)
        r.Color=cfg.rock; r.Transparency=0
      end
    end
  end end
  for q=ri+1,ROCKS do rocks[q].Transparency=1 end
end

-- ---------- what is drawn ----------
local HORIZON={}
for w,cfg in pairs(WL.WORLDS) do HORIZON[w]=FLAT+math.sqrt(8*cfg.R) end   -- where things would sink ~4 studs
local parts={}
local function track(d)
  if d:IsA("BasePart") then
    parts[d]=WL.worldAt(d.Position)
    if d:GetAttribute("SitePlate") then d.CanCollide=false; d.LocalTransparencyModifier=1 end
  end
end
for _,d in ipairs(game_:GetDescendants()) do track(d) end
game_.DescendantAdded:Connect(function(d) task.defer(track,d) end)
game_.DescendantRemoving:Connect(function(d) parts[d]=nil end)
-- site plates are flagged on the server; flags may arrive after the part
game_.DescendantAdded:Connect(function(d)
  if d:IsA("BasePart") then d:GetAttributeChangedSignal("SitePlate"):Connect(function() track(d) end) end
end)

local function cull(world,px,pz)
  local hz=HORIZON[world]
  for p,w in pairs(parts) do
    if p.Parent then
      if p:GetAttribute("SitePlate") then
        p.LocalTransparencyModifier=1
      else
        local pos=p.Position
        local dx,dz=pos.X-px,pos.Z-pz
        local big=math.max(p.Size.X,p.Size.Z)/2
        local show=(w==world) and (dx*dx+dz*dz)<(hz+big)^2
        p.LocalTransparencyModifier=show and 0 or 1
      end
    end
  end
end

local function leaveFootprint(character,hrp,world,position,forward)
  -- Prints represent lunar dust impressions only. All constructed surfaces,
  -- including the Tranquility Heritage station and its exterior pad, are excluded.
  if world~="moon" then return end
  local excluded={character,footprints}
  rayParams.FilterDescendantsInstances=excluded
  local hit=workspace:Raycast(position+Vector3.new(0,2,0),Vector3.new(0,-8,0),rayParams)
  -- The ray begins above the character. Ignore it once the floor is far enough
  -- below the boots that this would be an airborne print.
  if not hit or hit.Distance>5.5 then return end
  local hadleyTerrain=game_:FindFirstChild("HadleyApennineTerrain")
  if not groundTiles[hit.Instance] and not (hadleyTerrain and hit.Instance:IsDescendantOf(hadleyTerrain)) then return end
  local normal=hit.Normal
  local up=normal.Magnitude>0 and normal or Vector3.yAxis
  local facing=CFrame.lookAt(hit.Position,hit.Position+forward,up)
  stepIndex+=1
  local side=(stepIndex%2==0) and -0.31 or 0.31
  local print=Instance.new("Part")
  print.Name="Footprint"
  print.Size=Vector3.new(0.44,0.025,0.76)
  print.Anchored=true; print.CanCollide=false; print.CanTouch=false; print.CanQuery=false
  print.CastShadow=false; print.Material=Enum.Material.Sand
  print.Color=Color3.fromRGB(75,68,58)
  print.Transparency=0.06
  print.CFrame=facing*CFrame.new(side,0.018,0)
  print:SetAttribute("World",world)
  print.Parent=footprints
  table.insert(footprintRecords,{part=print,created=os.clock()})
  if #footprintRecords>MAX_FOOTPRINTS then
    local oldest=table.remove(footprintRecords,1)
    if oldest.part.Parent then oldest.part:Destroy() end
  end
end

local acc=0
local stepDistance=0
RunService.Heartbeat:Connect(function(dt)
  local c=me.Character; local hrp=c and c:FindFirstChild("HumanoidRootPart")
  if not hrp then return end
  local p=hrp.Position
  local world=WL.worldAt(p)
  -- wrap round the seam
  local wp=WL.wrap(world,p)
  if (wp-p).Magnitude>1 then c:PivotTo(c:GetPivot()+(wp-p)); p=wp; lastC=nil end
  -- safety net: never fall forever
  if p.Y<-40 then c:PivotTo(CFrame.new(p.X,8,p.Z)); p=Vector3.new(p.X,8,p.Z) end
  local humanoid=c:FindFirstChildOfClass("Humanoid")
  if world=="moon" and humanoid and humanoid.MoveDirection.Magnitude>0.08 then
    local horizontal=Vector3.new(p.X,0,p.Z)
    if lastStep then
      local delta=horizontal-lastStep
      local moved=delta.Magnitude
      if moved>0 and moved<12 then stepDistance+=moved end
      if stepDistance>=STEP_DISTANCE then
        local direction=Vector3.new(delta.X,0,delta.Z)
        if direction.Magnitude>0.01 then
          leaveFootprint(c,hrp,world,p,direction.Unit)
          stepDistance=0
        end
      end
    end
    lastStep=horizontal
  else
    lastStep=nil; stepDistance=0
  end
  for i=#footprintRecords,1,-1 do
    local record=footprintRecords[i]
    if not record.part.Parent then
      table.remove(footprintRecords,i)
    else
      local age=os.clock()-record.created
      if record.part:GetAttribute("World")=="moon" then
        if age>180 then record.part.Transparency=math.min(1,0.06+(age-180)/45) end
      elseif age>75 then
        record.part.Transparency=math.min(1,0.06+(age-75)/30)
      end
      if record.part.Transparency>=1 then record.part:Destroy(); table.remove(footprintRecords,i) end
    end
  end
  if lastW~=world or not lastC or (Vector3.new(p.X,0,p.Z)-lastC).Magnitude>16 then
    rebuild(world,p.X,p.Z); lastC=Vector3.new(p.X,0,p.Z); lastW=world
    cull(world,p.X,p.Z); acc=0
  end
  acc+=dt
  if acc>0.5 then acc=0; cull(world,p.X,p.Z) end
end)

if RunService:IsStudio() then
  local f=Instance.new("BindableFunction"); f.Name="_GroundTest"; f.Parent=script
  f.OnInvoke=function()
    local shown,hidden=0,0
    for q,_ in pairs(parts) do if q.LocalTransparencyModifier==0 then shown+=1 else hidden+=1 end end
    return {world=lastW,shown=shown,hidden=hidden,horizon=HORIZON[lastW or "moon"]}
  end
end

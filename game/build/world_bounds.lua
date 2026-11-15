-- ONE GROUND PER WORLD, RIMS AND WALLS.
-- The worlds were patchworks of site plates: where two overlapped at the same height they
-- z-fought (flickered), and where they stopped there was a visible edge. Now:
--  * one continuous base under each world, a hair below the site plates
--  * each site plate lifted by its own tiny step so no two surfaces are coplanar
--  * lunar highlands and a rille make the Moon's terrain legible at the scale of the game
--  * a ring of crater-rim hills hides the edge (the real lunar horizon is ~2.4 km away for a
--    standing astronaut, further than this map, so the edge must never show)
--  * invisible walls just outside the rims
local game_=workspace:WaitForChild("Game")
local old=game_:FindFirstChild("Bounds"); if old then old:Destroy() end
local F=Instance.new("Folder"); F.Name="Bounds"; F.Parent=game_
local reg=game_.Tranquility:FindFirstChild("Regolith")
local WORLDS={
  {name="Moon",x0=-1100,x1=660,z0=-840,z1=340,col=reg and reg.Color or Color3.fromRGB(128,126,122),mat=reg and reg.Material or Enum.Material.Sand,rim=Color3.fromRGB(105,103,100),tmat=Enum.Material.Sand},
  {name="Mars",x0=-640,x1=520,z0=1050,z1=2000,col=Color3.fromRGB(176,110,70),mat=Enum.Material.Sand,rim=Color3.fromRGB(140,80,50),tmat=Enum.Material.Sandstone},
  {name="Eros",x0=1370,x1=1630,z0=-630,z1=-370,col=Color3.fromRGB(150,135,110),mat=Enum.Material.Slate,rim=Color3.fromRGB(120,108,88),tmat=Enum.Material.Slate},
}
-- lift every site plate by its own step
local i=0
for _,site in ipairs(game_:GetChildren()) do
  for _,n in ipairs({"Ground","Regolith"}) do
    local g=site:FindFirstChild(n)
    if g and g:IsA("BasePart") then
      i+=1
      local top=g.Position.Y+g.Size.Y/2
      g.Position=g.Position+Vector3.new(0,(-top)+0.01*i,0)   -- top at 0.01*i
    end
  end
end
local rng=Random.new(42)
workspace.Terrain:Clear()
workspace.Terrain:SetMaterialColor(Enum.Material.Sand,Color3.fromRGB(150,148,142))
workspace.Terrain:SetMaterialColor(Enum.Material.Sandstone,Color3.fromRGB(160,96,60))
workspace.Terrain:SetMaterialColor(Enum.Material.Slate,Color3.fromRGB(128,114,92))
for _,w in ipairs(WORLDS) do
  local M=Instance.new("Model"); M.Name=w.name; M.Parent=F
  local cx,cz=(w.x0+w.x1)/2,(w.z0+w.z1)/2
  local base=Instance.new("Part"); base.Name="Base"; base.Anchored=true
  base.Size=Vector3.new(w.x1-w.x0+300,4,w.z1-w.z0+300); base.Position=Vector3.new(cx,-2.05,cz)
  base.Color=w.col; base.Material=w.mat; base.TopSurface=Enum.SurfaceType.Smooth; base.Parent=M
  -- rims: wedges sloping up toward the edge, then taller hills behind them
  local function edge(ax,az,bx,bz,nx,nz)
    local len=math.sqrt((bx-ax)^2+(bz-az)^2); local steps=math.ceil(len/36)
    for s=0,steps do
      local t=s/steps; local px,pz=ax+(bx-ax)*t,az+(bz-az)*t
      -- rounded terrain mounds: an inner low rim and a taller outer ridge
      local r1=rng:NextNumber(26,40)
      local r2=rng:NextNumber(40,62)
      if w.name=="Moon" then
        workspace.Terrain:FillBall(Vector3.new(px+nx*10,-r1*0.55,pz+nz*10),r1,w.tmat)
        workspace.Terrain:FillBall(Vector3.new(px+nx*45,-r2*0.35,pz+nz*45),r2,w.tmat)
      else
        -- Mars and Eros hills are parts, not terrain: terrain is drawn for every player, so
        -- Mars's red hills showed over the Moon's horizon. Parts can be hidden per player.
        for _,b in ipairs({{r1,0.55,10},{r2,0.35,45}}) do
          local h=Instance.new("Part"); h.Shape=Enum.PartType.Ball; h.Anchored=true
          h.Material=w.mat; h.Color=w.rim; h.Size=Vector3.new(b[1]*2,b[1]*2,b[1]*2)
          h.Position=Vector3.new(px+nx*b[3],-b[1]*b[2],pz+nz*b[3]); h.CastShadow=false; h.Parent=M
        end
      end
    end
    local wall=Instance.new("Part"); wall.Name="Wall"; wall.Anchored=true; wall.Transparency=1; wall.CanQuery=false
    wall.Size=Vector3.new(len+120,400,4); wall.CFrame=CFrame.lookAt(Vector3.new((ax+bx)/2+nx*60,200,(az+bz)/2+nz*60),Vector3.new((ax+bx)/2+nx*61,200,(az+bz)/2+nz*61))
    wall.Size=Vector3.new(len+160,400,4); wall.Parent=M
  end
  edge(w.x0,w.z0,w.x1,w.z0,0,-1); edge(w.x0,w.z1,w.x1,w.z1,0,1)
  edge(w.x0,w.z0,w.x0,w.z1,-1,0); edge(w.x1,w.z0,w.x1,w.z1,1,0)
end
-- Hadley–Apennine relief: the Apennines rise above the landing plain and Hadley Rille
-- cuts across the opposite side. Keep the central corridor around the Apollo 15 artifacts
-- open; the relief is deliberately exaggerated in height for Roblox's compressed world scale.
local moon=F:FindFirstChild("Moon")
local relief=Instance.new("Folder"); relief.Name="HadleyRelief"; relief.Parent=moon
local function ridge(name,center,axis,length,width,height,material,color)
  local count=math.ceil(length/58)
  for n=0,count do
    local t=n/count-0.5
    local taper=0.62+0.38*math.sin(math.pi*n/count)
    local offset=math.sin(n*1.7)*width*0.12
    local ball=Instance.new("Part"); ball.Name=name; ball.Shape=Enum.PartType.Ball
    ball.Anchored=true; ball.CanCollide=true; ball.Material=material; ball.Color=color
    ball.Size=Vector3.new(width*taper*2,height*taper*2,width*taper*2)
    ball.Position=center+axis*(t*length)+Vector3.new(0,height*taper*0.35,offset)
    ball.TopSurface=Enum.SurfaceType.Smooth; ball.BottomSurface=Enum.SurfaceType.Smooth
    ball.Parent=relief
  end
end
local highlandColor=Color3.fromRGB(132,130,126)
ridge("ApennineHighland",Vector3.new(430,0,-420),Vector3.new(1,0,0),650,78,56,Enum.Material.Slate,highlandColor)
-- Secondary, lower shoulders create rolling foothills without blocking the broad approach.
ridge("ApennineFoothill",Vector3.new(430,0,-320),Vector3.new(1,0,0),560,58,26,Enum.Material.Sand,Color3.fromRGB(119,117,113))
-- A dark, recessed valley with raised shoulders, oriented toward the Hadley landing region.
local rilleCenter=Vector3.new(475,0,-70)
for n=0,18 do
  local t=n/18-0.5
  local x=rilleCenter.X+t*390
  local z=rilleCenter.Z+math.sin(n*0.55)*16
  local basin=Instance.new("Part"); basin.Name="HadleyRille"; basin.Anchored=true
  basin.Size=Vector3.new(38,14,62); basin.Position=Vector3.new(x,-5.5,z)
  basin.Color=Color3.fromRGB(65,64,62); basin.Material=Enum.Material.Slate
  basin.CanCollide=false; basin.Parent=relief
  for side=-1,1,2 do
    local lip=Instance.new("Part"); lip.Name="RilleShoulder"; lip.Shape=Enum.PartType.Ball
    lip.Anchored=true; lip.Size=Vector3.new(54,30,56)
    lip.Position=Vector3.new(x,-7,z+side*38); lip.Material=Enum.Material.Slate
    lip.Color=Color3.fromRGB(104,102,98); lip.CanCollide=true; lip.Parent=relief
  end
end
return "bounds: "..i.." site plates stepped, 3 worlds ringed"

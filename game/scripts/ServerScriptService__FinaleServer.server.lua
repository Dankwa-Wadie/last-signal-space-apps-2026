-- Script  ServerScriptService/FinaleServer
-- THE HANDOVER. When the crew has found everything, each player may leave one marker of
-- their own beside Eagle -- joining the list of things humans left on purpose, to be found.
-- Also creates the two client-side plumbing objects the HUD needs (see LocalKey below).
local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local rem=RS:WaitForChild("Remotes")

local function ensure(cls,name)
  local o=rem:FindFirstChild(name)
  if o and o.ClassName~=cls then o:Destroy(); o=nil end
  if not o then o=Instance.new(cls); o.Name=name; o.Parent=rem end
  return o
end
-- LocalKey is a BindableEvent: a client fires it and only that client hears it. It lets the
-- touchscreen buttons feed the same handlers as a real key press, with no network round trip.
ensure("BindableEvent","LocalKey")
-- client-local: the archive terminal tells the trophy room what has been read
ensure("BindableEvent","Catalogued")
ensure("BindableEvent","OpenMap")
ensure("BindableEvent","RadioBeep")   -- any script -> Quindar tone before a radio line    -- settings menu -> survey map
local PlaceMarker=ensure("RemoteEvent","PlaceMarker")
local MarkerUpdate=ensure("RemoteEvent","MarkerUpdate")

local site=workspace:WaitForChild("Game"):WaitForChild("Tranquility")
local MARK_RADIUS=40          -- studs from Eagle: you leave it at the landing site, not anywhere
local placed={}               -- userId -> true, one marker each, this server

local folder=site:FindFirstChild("Markers")
if not folder then folder=Instance.new("Folder"); folder.Name="Markers"; folder.Parent=site end

local function count() return #folder:GetChildren() end

local function hrpOf(p)
  local c=p.Character
  return c and c:FindFirstChild("HumanoidRootPart")
end

-- markers stand in a slow spiral out from the Eagle, so a busy server still looks deliberate
local function slot(n)
  local ang=math.rad(26+n*47)
  local r=16+n*1.15
  return Vector3.new(math.sin(ang)*r, 0, 8+math.cos(ang)*r)
end

local function build(name,dateText,n)
  local lm=site:FindFirstChild("LM_DescentStage")
  local centre=(lm and lm:FindFirstChild("Anchor") and lm.Anchor.Position) or Vector3.new(0,2,8)
  local pos=slot(n)
  local rp=RaycastParams.new(); rp.FilterType=Enum.RaycastFilterType.Exclude
  rp.FilterDescendantsInstances={folder}
  local hit=workspace:Raycast(Vector3.new(pos.X,centre.Y+120,pos.Z),Vector3.new(0,-300,0),rp)
  local gy=(hit and hit.Position.Y) or 0

  local m=Instance.new("Model"); m.Name="Marker_"..name; m.Parent=folder
  local face=CFrame.lookAt(Vector3.new(pos.X,gy,pos.Z),Vector3.new(centre.X,gy,centre.Z))
  local function P(nm,sz,cf,col,mat)
    local p=Instance.new("Part"); p.Name=nm; p.Size=sz; p.CFrame=face*cf; p.Anchored=true
    p.Color=col; p.Material=mat or Enum.Material.Metal
    p.TopSurface=Enum.SurfaceType.Smooth; p.BottomSurface=Enum.SurfaceType.Smooth
    p.Parent=m; return p
  end
  P("Stake",Vector3.new(0.16,2.1,0.16),CFrame.new(0,1.05,0),Color3.fromRGB(190,190,186))
  local plate=P("Plate",Vector3.new(1.9,1.15,0.08),CFrame.new(0,2.3,0),Color3.fromRGB(226,226,220),
    Enum.Material.SmoothPlastic)
  local g=Instance.new("SurfaceGui"); g.Face=Enum.NormalId.Back; g.CanvasSize=Vector2.new(380,230)
  g.LightInfluence=0; g.Parent=plate
  local function t(txt,y,h,font,col,scaled)
    local l=Instance.new("TextLabel"); l.Size=UDim2.new(1,-20,0,h); l.Position=UDim2.fromOffset(10,y)
    l.BackgroundTransparency=1; l.Font=font; l.TextColor3=col; l.Text=txt
    l.TextScaled=scaled~=false; l.TextWrapped=true; l.Parent=g
  end
  t("LAST SIGNAL",14,30,Enum.Font.GothamBold,Color3.fromRGB(28,30,34))
  t("SURVEY COMPLETE",46,26,Enum.Font.GothamMedium,Color3.fromRGB(90,94,100))
  t(name,82,56,Enum.Font.GothamBold,Color3.fromRGB(18,20,24))
  t(dateText,144,28,Enum.Font.Gotham,Color3.fromRGB(90,94,100))
  t("LEFT HERE ON PURPOSE",178,28,Enum.Font.GothamBold,Color3.fromRGB(150,120,20))
  return m
end

PlaceMarker.OnServerEvent:Connect(function(player)
  if placed[player.UserId] then return end
  local hrp=hrpOf(player); if not hrp then return end
  local lm=site:FindFirstChild("LM_DescentStage")
  local a=lm and lm:FindFirstChild("Anchor")
  if a and (hrp.Position-a.Position).Magnitude>MARK_RADIUS then
    rem.Notice:FireClient(player,"Leave it beside the Eagle.",3)
    return
  end
  placed[player.UserId]=true
  local ok,err=pcall(build,player.DisplayName,os.date("!%d %b %Y"),count())
  if not ok then warn("FinaleServer: "..tostring(err)); placed[player.UserId]=nil; return end
  MarkerUpdate:FireAllClients(count(),player.DisplayName)
  for _,p in ipairs(Players:GetPlayers()) do
    if p~=player then
      rem.Notice:FireClient(p,player.DisplayName.." left a marker at Tranquility.",4)
    end
  end
end)

Players.PlayerAdded:Connect(function(p)
  task.wait(1.4)
  MarkerUpdate:FireClient(p,count(),nil)
end)
print("FinaleServer ready")

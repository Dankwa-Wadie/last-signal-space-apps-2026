-- Station furniture: the Deep Space Network console (Voyager / Pioneer) and the transit
-- modules that carry the surveyor between the Moon and Mars.
local game_=workspace:WaitForChild("Game")
local function clear(parent,name) local o=parent:FindFirstChild(name); if o then o:Destroy() end end

local function console(parent, pos, yaw, name, consoleId, screenTop, screenBot, tint)
  clear(parent,name)
  local m=Instance.new("Model"); m.Name=name; m.Parent=parent
  local rp=RaycastParams.new(); rp.FilterType=Enum.RaycastFilterType.Exclude
  rp.FilterDescendantsInstances={m}
  local hit=workspace:Raycast(Vector3.new(pos.X,pos.Y+200,pos.Z),Vector3.new(0,-500,0),rp)
  local gy=hit and hit.Position.Y or 0
  local base=CFrame.new(Vector3.new(pos.X,gy,pos.Z))*CFrame.Angles(0,math.rad(yaw),0)
  local function P(n,sz,cf,col,mat)
    local p=Instance.new("Part"); p.Name=n; p.Size=sz; p.CFrame=base*cf; p.Anchored=true
    p.Color=col; p.Material=mat or Enum.Material.Metal
    p.TopSurface=Enum.SurfaceType.Smooth; p.BottomSurface=Enum.SurfaceType.Smooth
    p.Parent=m; return p
  end
  P("Pedestal",Vector3.new(3.2,3.4,1.6),CFrame.new(0,1.7,0),Color3.fromRGB(70,72,76))
  P("Desk",Vector3.new(3.6,0.25,2.2),CFrame.new(0,3.45,-0.3)*CFrame.Angles(math.rad(-12),0,0),Color3.fromRGB(40,42,46))
  local scr=P("Screen",Vector3.new(3.0,1.9,0.12),CFrame.new(0,4.6,0.35)*CFrame.Angles(math.rad(-18),0,0),tint,Enum.Material.Neon)
  local sg=Instance.new("SurfaceGui"); sg.Face=Enum.NormalId.Front; sg.CanvasSize=Vector2.new(600,380)
  sg.LightInfluence=0; sg.Parent=scr
  local a=Instance.new("TextLabel"); a.Size=UDim2.new(1,-20,0.55,0); a.Position=UDim2.fromOffset(10,10)
  a.BackgroundTransparency=1; a.Font=Enum.Font.GothamBold; a.TextColor3=Color3.fromRGB(245,231,60)
  a.TextScaled=true; a.Text=screenTop; a.Parent=sg
  local b=Instance.new("TextLabel"); b.Size=UDim2.new(1,-20,0.3,0); b.Position=UDim2.new(0,10,0.62,0)
  b.BackgroundTransparency=1; b.Font=Enum.Font.GothamMedium; b.TextColor3=Color3.fromRGB(215,215,220)
  b.TextScaled=true; b.TextWrapped=true; b.Text=screenBot; b.Parent=sg
  local anc=Instance.new("Part"); anc.Name="Anchor"; anc.Size=Vector3.new(1,1,1)
  anc.Transparency=1; anc.CanCollide=false; anc.Anchored=true
  anc.CFrame=base*CFrame.new(0,3.5,-1.4); anc.Parent=m
  anc:SetAttribute("ConsoleId",consoleId)
  local pp=Instance.new("ProximityPrompt")
  pp.ActionText=(consoleId=="dsn") and "Open link" or "Board"
  pp.ObjectText=(consoleId=="dsn") and "Deep Space Network" or "Transit module"
  pp.KeyboardKeyCode=Enum.KeyCode.E; pp.HoldDuration=0.25
  pp.MaxActivationDistance=10; pp.RequiresLineOfSight=false; pp.Parent=anc
  return m
end

local T=game_:WaitForChild("Tranquility")
local MER=game_:FindFirstChild("Meridiani")

-- the DSN link: the only way to reach Voyager, because you cannot stand next to it
console(T, Vector3.new(-23,0,140), -112, "DSNConsole", "dsn",   -- at the station
  "DEEP SPACE\nNETWORK",
  "Voyager 1 · Pioneer 10 · Pioneer 11", Color3.fromRGB(30,70,120))

-- transit, Moon side
console(T, Vector3.new(21,0,160), 64, "TransitConsole", "transit",   -- at the station
  "TRANSIT",
  "Departures · Mars · Eros", Color3.fromRGB(80,64,24))

-- transit, Mars side
if MER then
  console(MER, Vector3.new(60+18,0,1500+40), 186, "TransitConsole", "transit",
    "TRANSIT",
    "Departures · Tranquility Base, Moon", Color3.fromRGB(80,64,24))
  -- the outpost itself: one habitat, deliberately nothing more
  local hab=Instance.new("Model"); hab.Name="Outpost"; hab.Parent=MER
  local hb=CFrame.new(Vector3.new(60+34,0,1500+52))*CFrame.Angles(0,math.rad(200),0)
  local function H(n,sz,cf,col,mat)
    local p=Instance.new("Part"); p.Name=n; p.Size=sz; p.CFrame=hb*cf; p.Anchored=true
    p.Color=col; p.Material=mat or Enum.Material.Metal
    p.TopSurface=Enum.SurfaceType.Smooth; p.BottomSurface=Enum.SurfaceType.Smooth
    p.Parent=hab; return p
  end
  local shell=H("Hull",Vector3.new(9,5,9),CFrame.new(0,3.2,0),Color3.fromRGB(226,226,220),Enum.Material.SmoothPlastic)
  shell.Shape=Enum.PartType.Cylinder
  shell.CFrame=hb*CFrame.new(0,3.2,0)*CFrame.Angles(0,0,math.rad(90))
  H("Skirt",Vector3.new(10,0.5,10),CFrame.new(0,0.5,0),Color3.fromRGB(150,150,148))
  for i=0,2 do
    local a=math.rad(i*120)
    H("Leg"..i,Vector3.new(0.4,3.0,0.4),CFrame.new(math.sin(a)*4.2,1.5,math.cos(a)*4.2),Color3.fromRGB(190,190,186))
  end
  H("Airlock",Vector3.new(2.2,3.0,0.4),CFrame.new(0,1.9,-4.5),Color3.fromRGB(60,62,68))
  local solar=H("Solar",Vector3.new(7,0.2,3.4),CFrame.new(0,6.4,0),Color3.fromRGB(34,46,92),Enum.Material.Glass)
  solar.Reflectance=0.2
end

return "consoles installed"

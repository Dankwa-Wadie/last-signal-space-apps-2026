-- Ares Vallis, Mars: Mars Pathfinder (renamed the Carl Sagan Memorial Station) and
-- Sojourner, the first rover to drive on another planet.
-- Landed 4 July 1997 at 19.33 N, 33.55 W. Last contact 27 September 1997, after 83 sols.
local game_=workspace:WaitForChild("Game")
local old=game_:FindFirstChild("AresVallis"); if old then old:Destroy() end
local F=Instance.new("Folder"); F.Name="AresVallis"; F.Parent=game_
local OX,OZ = -210, 1540          -- abuts the Meridiani pan, so Mars is one continuous surface
local M=2.4
F:SetAttribute("World","Mars")

local pan=Instance.new("Part")
pan.Name="Ground"; pan.Anchored=true; pan.Size=Vector3.new(300,4,300)
pan.Position=Vector3.new(OX,-2,OZ); pan.Color=Color3.fromRGB(148,92,60)
pan.Material=Enum.Material.Sand; pan.TopSurface=Enum.SurfaceType.Smooth; pan.Parent=F
-- Ares Vallis is an ancient flood plain, and one of the rockiest places on Mars:
-- that is exactly why it was chosen, and why Sojourner had so much to look at.
for i=1,70 do
  local r=Instance.new("Part")
  r.Name="Rock"; r.Anchored=true
  local s=0.8+((i*13)%34)/10
  r.Size=Vector3.new(s,s*0.66,s*0.85)
  r.Position=Vector3.new(OX-135+((i*47)%270),s*0.3,OZ-135+((i*71)%270))
  r.Orientation=Vector3.new(0,(i*29)%180,(i%7)*3)
  r.Color=Color3.fromRGB(120-((i%5)*8),72,48); r.Material=Enum.Material.Slate; r.Parent=F
end
-- the flood channels that give the valley its name
for i=1,8 do
  local c=Instance.new("Part")
  c.Name="Channel"; c.Anchored=true
  c.Size=Vector3.new(230,2.5,13+((i*5)%10))
  c.Position=Vector3.new(OX-10+((i*17)%40),-1.2,OZ-120+i*30)
  c.Orientation=Vector3.new(0,-8+((i*3)%14),0)
  c.Color=Color3.fromRGB(132,80,52); c.Material=Enum.Material.Sand; c.Parent=F
end

local function attrs(m,t) for k,v in pairs(t) do m:SetAttribute(k,v) end end
local function anchorFor(m,pos,action,object)
  local a=Instance.new("Part"); a.Name="Anchor"; a.Size=Vector3.new(1,1,1)
  a.Transparency=1; a.CanCollide=false; a.Anchored=true; a.CFrame=CFrame.new(pos); a.Parent=m
  local pp=Instance.new("ProximityPrompt")
  pp.ActionText=action; pp.ObjectText=object; pp.KeyboardKeyCode=Enum.KeyCode.E
  pp.HoldDuration=0.25; pp.MaxActivationDistance=12; pp.RequiresLineOfSight=false; pp.Parent=a
end
local function P(parent,base,n,sz,cf,col,mat)
  local p=Instance.new("Part"); p.Name=n; p.Anchored=true; p.CanCollide=false
  p.Size=sz*M; p.CFrame=base*CFrame.new(cf.Position*M)*(cf-cf.Position)
  p.Color=col; p.Material=mat or Enum.Material.SmoothPlastic
  p.TopSurface=Enum.SurfaceType.Smooth; p.BottomSurface=Enum.SurfaceType.Smooth
  p.Parent=parent; return p
end
local BODY=Color3.fromRGB(214,212,204)
local CELL=Color3.fromRGB(34,46,92)
local DARKC=Color3.fromRGB(52,52,56)

-- ---------- Mars Pathfinder / Carl Sagan Memorial Station ----------
-- The lander opened like a flower: a base and three triangular petals that flattened
-- the airbags and let the rover drive off.
local pf=Instance.new("Model"); pf.Name="Pathfinder"; pf.Parent=F
local pb=CFrame.new(Vector3.new(OX-12,0,OZ-8))*CFrame.Angles(0,math.rad(22),0)
P(pf,pb,"Base",Vector3.new(1.5,0.4,1.5),CFrame.new(0,0.4,0),BODY,Enum.Material.Metal)
for i=0,2 do
  local a=math.rad(i*120)
  local px,pz=math.sin(a)*1.5,math.cos(a)*1.5
  local petal=P(pf,pb,"Petal"..i,Vector3.new(1.8,0.1,1.6),
    CFrame.new(px,0.26,pz)*CFrame.Angles(0,-a,math.rad(4)),BODY,Enum.Material.Metal)
  P(pf,pb,"PetalCells"..i,Vector3.new(1.5,0.04,1.3),
    CFrame.new(px,0.33,pz)*CFrame.Angles(0,-a,math.rad(4)),CELL,Enum.Material.Glass)
  -- the deflated airbags, still bunched under the petals
  P(pf,pb,"Airbag"..i,Vector3.new(1.9,0.26,1.7),
    CFrame.new(px*1.25,0.14,pz*1.25)*CFrame.Angles(0,-a,0),Color3.fromRGB(206,200,188),Enum.Material.Fabric)
end
-- the camera mast that took the first colour panorama of Ares Vallis
P(pf,pb,"Mast",Vector3.new(0.1,1.0,0.1),CFrame.new(0,1.1,0),BODY,Enum.Material.Metal)
P(pf,pb,"IMP",Vector3.new(0.4,0.26,0.22),CFrame.new(0,1.68,0),DARKC,Enum.Material.Metal)
P(pf,pb,"LowGain",Vector3.new(0.05,0.8,0.05),CFrame.new(0.5,1.0,0.3),Color3.fromRGB(190,190,186),Enum.Material.Metal)
local hga=P(pf,pb,"HighGain",Vector3.new(0.05,0.55,0.55),CFrame.new(-0.5,0.95,0.3),BODY,Enum.Material.Foil)
hga.Shape=Enum.PartType.Cylinder
hga.CFrame=pb*CFrame.new(Vector3.new(-0.5,0.95,0.3)*M)*CFrame.Angles(0,math.rad(90),math.rad(66))
attrs(pf,{ArtifactId="pathfinder",Title="Mars Pathfinder — Carl Sagan Memorial Station",
  Year="Landed 4 July 1997 · last contact 27 September 1997",
  What="A lander that arrived wrapped in airbags, bounced across the plain at least fifteen times — the first rebounds about fifteen metres high — then rolled to a stop and opened three petals like a flower.",
  Why="To prove a cheap, fast way of landing on Mars: no retro-rockets all the way down, just a parachute, an airbag cocoon, and a bounce. And to deliver the first rover.",
  Science="It sent back the first colour panoramas of an Ares Vallis flood plain and measured the weather for 83 sols. The airbag method it proved was used again to put Spirit and Opportunity on Mars. It was renamed the Carl Sagan Memorial Station after it landed."})
anchorFor(pf,Vector3.new(OX-12,2.6,OZ-8),"Scan","Carl Sagan Memorial Station")

-- ---------- Sojourner ----------
local so=Instance.new("Model"); so.Name="Sojourner"; so.Parent=F
local sb=CFrame.new(Vector3.new(OX+9,0,OZ+6))*CFrame.Angles(0,math.rad(-48),0)
P(so,sb,"Deck",Vector3.new(0.65,0.08,0.48),CFrame.new(0,0.34,0),BODY,Enum.Material.Metal)
P(so,sb,"SolarPanel",Vector3.new(0.62,0.03,0.45),CFrame.new(0,0.40,0),CELL,Enum.Material.Glass)
P(so,sb,"WarmBox",Vector3.new(0.4,0.16,0.3),CFrame.new(0,0.24,0),Color3.fromRGB(196,194,188),Enum.Material.Metal)
-- six wheels on a rocker-bogie, the design every Mars rover since has used
for _,wz in ipairs({0.26,-0.26}) do
  for _,wx in ipairs({0.24,0,-0.24}) do
    local w=P(so,sb,"Wheel",Vector3.new(0.09,0.26,0.26),CFrame.new(wx,0.15,wz),DARKC,Enum.Material.Metal)
    w.Shape=Enum.PartType.Cylinder
    w.CFrame=sb*CFrame.new(Vector3.new(wx,0.15,wz)*M)*CFrame.Angles(math.rad(90),0,math.rad(90))
  end
  P(so,sb,"Rocker",Vector3.new(0.5,0.035,0.035),CFrame.new(0,0.26,wz),Color3.fromRGB(170,168,162),Enum.Material.Metal)
end
-- the APXS, which it pressed against rocks to read what they were made of
P(so,sb,"APXS",Vector3.new(0.12,0.12,0.16),CFrame.new(-0.34,0.2,0),Color3.fromRGB(180,178,170),Enum.Material.Metal)
P(so,sb,"Antenna",Vector3.new(0.03,0.3,0.03),CFrame.new(0.26,0.55,0.15),Color3.fromRGB(200,200,196),Enum.Material.Metal)
attrs(so,{ArtifactId="sojourner",Title="Sojourner",
  Year="First drove 5 July 1997 · 83 sols",
  What="A rover the size of a microwave oven: 10.6 kg, six wheels on a rocker-bogie suspension, one solar panel, and a spectrometer it pressed against rocks to read their chemistry.",
  Why="To prove that a wheeled robot could be driven on another planet at all. Nobody had done it before.",
  Science="It drove about 100 metres in 83 sols and never went more than a few metres from the lander — but it measured the rocks around it and showed they were varied, which meant Ares Vallis really was a flood plain. Its rocker-bogie suspension is still the design every Mars rover uses, Perseverance included."})
anchorFor(so,Vector3.new(OX+9,2.0,OZ+6),"Scan","Sojourner")

-- ---------- site sign ----------
local sign=Instance.new("Model"); sign.Name="SiteSign"; sign.Parent=F
local sgb=CFrame.lookAt(Vector3.new(OX,0,OZ+56),Vector3.new(OX,0,OZ))
local function SP(n,sz,cf,col)
  local p=Instance.new("Part"); p.Name=n; p.Anchored=true; p.Size=sz; p.CFrame=sgb*cf
  p.Color=col; p.Material=Enum.Material.Metal; p.Parent=sign; return p
end
SP("Post",Vector3.new(0.2,4.2,0.2),CFrame.new(-2.3,2.1,0),Color3.fromRGB(190,190,186))
SP("Post2",Vector3.new(0.2,4.2,0.2),CFrame.new(2.3,2.1,0),Color3.fromRGB(190,190,186))
local board=SP("Board",Vector3.new(5.2,2.3,0.12),CFrame.new(0,3.3,0),Color3.fromRGB(14,14,16))
board.Material=Enum.Material.SmoothPlastic
local bg=Instance.new("SurfaceGui"); bg.Face=Enum.NormalId.Back; bg.CanvasSize=Vector2.new(620,274)
bg.LightInfluence=0; bg.Parent=board
local function T(txt,y,h,font,col)
  local l=Instance.new("TextLabel"); l.Size=UDim2.new(1,-28,0,h); l.Position=UDim2.fromOffset(14,y)
  l.BackgroundTransparency=1; l.Font=font; l.TextColor3=col; l.Text=txt
  l.TextScaled=true; l.TextXAlignment=Enum.TextXAlignment.Left; l.Parent=bg
end
T("ARES VALLIS",12,44,Enum.Font.GothamBold,Color3.fromRGB(245,231,60))
T("19.33 N, 33.55 W  ·  Mars  ·  Pathfinder and Sojourner, 1997",62,30,Enum.Font.GothamMedium,Color3.fromRGB(215,215,220))
T("An ancient flood plain, and one of the rockiest places on Mars.",102,28,Enum.Font.Gotham,Color3.fromRGB(165,170,176))
T("That is why it was chosen: the flood brought the rocks here.",134,28,Enum.Font.Gotham,Color3.fromRGB(165,170,176))
T("HERITAGE SITE  ·  DO NOT DISTURB",176,34,Enum.Font.GothamBold,Color3.fromRGB(150,205,255))

return "Ares Vallis built at ("..OX..",0,"..OZ..")"

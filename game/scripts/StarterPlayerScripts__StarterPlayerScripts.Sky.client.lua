-- LocalScript  StarterPlayerScripts/StarterPlayerScripts.Sky
-- What is actually overhead.
--
--  * The lunar sky is black in full daylight. There is no air to scatter the sunlight.
--  * The Moon keeps one face to Earth, so from any given spot on the near side Earth hangs
--    in the SAME place in the sky, permanently. It does not rise and it does not set.
--    Where it sits tells you where on the Moon you are standing: directly overhead at the
--    sub-Earth point, lower the further you are from it, and below the horizon on the far
--    side, where it is never visible at all.
--  * Earth is about four times the width the Moon appears from Earth, and far brighter.
--  * With no atmosphere there is no twinkling. Planets are steady, sharp points, and they
--    are visible during the lunar day as well as the night.
--  * From Mars, Earth is a brilliant blue evening/morning star, with the Moon beside it as
--    a fainter point.
-- Everything here is built on the client, so it costs the server nothing and no other
-- player sees a duplicate.
local Players=game:GetService("Players")
local RS=game:GetService("RunService")
local plr=Players.LocalPlayer

local SKY=Instance.new("Folder")
SKY.Name="LocalSky"
SKY.Parent=workspace

local function part(name,size,colour,material,parent)
  local p=Instance.new("Part")
  p.Name=name; p.Size=size; p.Anchored=true; p.CanCollide=false
  p.CanQuery=false; p.CanTouch=false; p.CastShadow=false; p.Locked=true
  p.Color=colour; p.Material=material or Enum.Material.Neon
  p.Shape=Enum.PartType.Ball
  p.Parent=parent or SKY
  return p
end

-- ---------- where each site is on the Moon ----------
-- selenographic latitude / longitude, straight out of the NSSDCA catalogue
local SITES={
  Tranquility      ={pos=Vector3.new(0,0,0),      lat=0.674,  lon=23.473},
  Procellarum      ={pos=Vector3.new(-470,0,150), lat=-3.016, lon=-23.418},
  Hadley           ={pos=Vector3.new(430,0,-210), lat=26.132, lon=3.633},
  Farside          ={pos=Vector3.new(-900,0,-620),lat=0,      lon=180},   -- Earth never visible
}
local WL=require(game:GetService("ReplicatedStorage"):WaitForChild("WorldLayout"))

-- Earth sits above the sub-Earth point (0 N, 0 E). For a site, work out how far round the
-- sphere that is, and in which direction.
local function earthAltAz(lat,lon)
  local la,lo=math.rad(lat),math.rad(lon)
  -- angle between the site and the sub-Earth point
  local c=math.acos(math.clamp(math.cos(la)*math.cos(lo),-1,1))
  local alt=math.pi/2-c
  -- bearing from the site towards (0,0), measured from north
  local y=math.sin(-lo)*math.cos(0)
  local x=math.cos(la)*math.sin(0)-math.sin(la)*math.cos(0)*math.cos(-lo)
  local az=math.atan2(y,x)
  return alt,az
end

local function dirFrom(alt,az)
  -- -Z is north, +X is east, +Y is up
  local ca=math.cos(alt)
  return Vector3.new(math.sin(az)*ca, math.sin(alt), -math.cos(az)*ca).Unit
end

-- ---------- Earth ----------
-- TRUE SIZE: from the Moon, Earth is about 1.9 degrees across -- roughly four times the
-- width the Moon shows from Earth. At 1,800 studs that is a 60-stud sphere, which comes
-- out around 38 pixels on screen: correct, and far too small to read on a phone.
-- So it is drawn three times oversize, the same deliberate compression already used for
-- the spacing between landing sites. The true figure is on the sign at Tranquility.
-- TRUE_EARTH_SIZE=60 (1.9 deg)  ·  drawn at 180 (5.7 deg)
-- The sky rides with the camera, so its distance is arbitrary -- and it has to be close
-- enough for Roblox to actually draw it. At 1,800 studs nothing rendered at all; 420 is
-- comfortably inside the render range. The angular size is what matters, and it is kept
-- the same by scaling the sphere with the distance.
local EARTH_DIST=420
local EARTH_SIZE=42
local EARTH_TRUE_DEG=1.91
local earth=Instance.new("Model"); earth.Name="Earth"; earth.Parent=SKY
local ocean=part("Ocean",Vector3.new(EARTH_SIZE,EARTH_SIZE,EARTH_SIZE),
  Color3.fromRGB(58,124,226),Enum.Material.Neon,earth)
-- continents and weather, roughed in so it reads as Earth and not a blue dot
-- Continents and weather. Sizes are fractions of the globe, so they stay right whatever
-- EARTH_SIZE is set to; they sit just under the surface so none pokes past the limb.
local BLOBS={
  {Vector3.new(0.34,0.26,-0.88),  0.26, Color3.fromRGB(104,166,96)},
  {Vector3.new(-0.52,0.10,-0.82), 0.21, Color3.fromRGB(118,178,104)},
  {Vector3.new(-0.18,-0.46,-0.86),0.24, Color3.fromRGB(96,158,92)},
  {Vector3.new(0.72,0.44,-0.52),  0.19, Color3.fromRGB(248,252,255)},
  {Vector3.new(-0.66,0.52,-0.50), 0.22, Color3.fromRGB(250,253,255)},
  {Vector3.new(0.10,-0.78,-0.58), 0.27, Color3.fromRGB(252,254,255)},
}
local blobParts={}
for i,b in ipairs(BLOBS) do
  local d=EARTH_SIZE*b[2]
  local p=part("Blob"..i,Vector3.new(d,d,d),b[3],Enum.Material.Neon,earth)
  table.insert(blobParts,{p,b[1].Unit})
end
local glow=Instance.new("PointLight")
glow.Brightness=2; glow.Range=120; glow.Color=Color3.fromRGB(150,190,255); glow.Parent=ocean

-- the Moon, as seen from Mars, sitting just beside Earth
local moonDot=part("MoonFromMars",Vector3.new(3,3,3),Color3.fromRGB(205,205,200),
  Enum.Material.Neon,SKY)

-- ---------- planets: steady points, no twinkling ----------
-- altitude, azimuth, size, colour -- laid out to look like a plausible sky rather than
-- to claim a real ephemeris for any particular date.
local PLANETS={
  {0.62, 1.05, 3.4, Color3.fromRGB(255,246,222)},   -- Venus, brilliant
  {0.34, 2.60, 2.6, Color3.fromRGB(255,240,210)},   -- Jupiter
  {0.48,-1.70, 1.8, Color3.fromRGB(240,226,180)},   -- Saturn
  {0.20,-0.65, 2.1, Color3.fromRGB(255,150,105)},   -- Mars: a reddish star, never a disc (it is far too small to show one)
  {0.12, 2.05, 1.3, Color3.fromRGB(226,226,230)},   -- Mercury
}
local planetParts={}
for i,pl in ipairs(PLANETS) do
  local p=part("Planet"..i,Vector3.new(pl[3],pl[3],pl[3]),pl[4],Enum.Material.Neon,SKY)
  table.insert(planetParts,{p,dirFrom(pl[1],pl[2])})
end

-- ---------- stars ----------
-- Far enough away that walking around a site does not shift them, so they can sit still.
local STAR_DIST=760
local stars=Instance.new("Model"); stars.Name="Stars"; stars.Parent=SKY
for i=1,90 do
  local a=(i*2.399963)             -- golden angle, so they scatter evenly
  local y=1-(i/90)*0.92
  local r=math.sqrt(math.max(0,1-y*y))
  local d=Vector3.new(math.cos(a)*r,y*0.9+0.08,math.sin(a)*r).Unit
  local s=0.55+((i*7)%5)*0.16
  local st=part("Star"..i,Vector3.new(s,s,s),Color3.fromRGB(236,238,245),Enum.Material.Neon,stars)
  st.Position=d*STAR_DIST
end

-- ---------- which world and which site ----------
-- (v138) Earth's place in the sky follows your real latitude and longitude as you walk:
-- walk west round the ring and it sinks; past the limb it is gone (the far side).
local function currentSite()
  local c=plr.Character
  local hrp=c and c:FindFirstChild("HumanoidRootPart")
  if not hrp then return nil,nil end
  local w=WL.worldAt(hrp.Position)
  if w~="moon" then return w,nil end
  local lat,lon=WL.latlon("moon",hrp.Position)
  return "moon",{lat=lat,lon=lon}
end

local function setVisible(inst,on)
  for _,d in ipairs(inst:GetDescendants()) do
    if d:IsA("BasePart") then d.Transparency=on and 0 or 1 end
  end
  if inst:IsA("BasePart") then inst.Transparency=on and 0 or 1 end
end

local acc=0
RS.RenderStepped:Connect(function(dt)
  acc+=dt
  if acc<1/20 then return end     -- the sky does not need 60 updates a second
  acc=0
  local cam=workspace.CurrentCamera
  if not cam then return end
  local eye=cam.CFrame.Position
  local world,site=currentSite()
  if not world then return end

  -- stars ride with the player so they never slide past
  stars:PivotTo(CFrame.new(eye))

  if world=="mars" or world=="eros" then
    -- From Mars, and from an asteroid, Earth is a brilliant blue point with the Moon just
    -- beside it -- the way it looks from Mars at twilight.
    local d=(world=="mars") and dirFrom(math.rad(16),math.rad(284)) or dirFrom(math.rad(38),math.rad(120))
    setVisible(earth,true)
    ocean.Size=Vector3.new(5,5,5)
    ocean.Material=Enum.Material.Neon
    ocean.Color=Color3.fromRGB(150,195,255)
    ocean.Position=eye+d*EARTH_DIST
    for _,b in ipairs(blobParts) do b[1].Transparency=1 end
    glow.Brightness=0
    moonDot.Transparency=0
    moonDot.Size=Vector3.new(1.8,1.8,1.8)
    moonDot.Position=eye+(d*EARTH_DIST)+Vector3.new(0,22,0)+d:Cross(Vector3.new(0,1,0))*26
    for _,pp in ipairs(planetParts) do
      pp[1].Transparency=(world=="mars") and 0.35 or 0   -- Mars has air; Eros has none
      if pp[1].Name=="Planet4" and world=="mars" then pp[1].Transparency=1 end   -- no Mars in Mars's own sky
      pp[1].Position=eye+pp[2]*STAR_DIST
    end
    setVisible(stars,true)
    return
  end

  moonDot.Transparency=1
  -- the Moon: planets are sharp and steady, and visible in daylight
  for _,pp in ipairs(planetParts) do
    pp[1].Transparency=0
    pp[1].Position=eye+pp[2]*STAR_DIST
  end
  setVisible(stars,true)

  local s=site
  if not s then
    -- There is no Earth in this sky. That is the whole point of the far side.
    setVisible(earth,false)
    glow.Brightness=0
    return
  end
  local alt,az=earthAltAz(s.lat,s.lon)
  if alt<=0 then setVisible(earth,false); glow.Brightness=0; return end
  setVisible(earth,true)
  ocean.Size=Vector3.new(EARTH_SIZE,EARTH_SIZE,EARTH_SIZE)
  ocean.Material=Enum.Material.Neon
  ocean.Color=Color3.fromRGB(58,124,226)
  glow.Brightness=2
  local d=dirFrom(alt,az)
  local centre=eye+d*EARTH_DIST
  ocean.Position=centre
  -- keep the continents on the face turned towards us
  local look=CFrame.lookAt(centre,eye)
  for _,b in ipairs(blobParts) do
    b[1].Transparency=0
    b[1].Position=(look*CFrame.new(b[2]*(EARTH_SIZE*0.44))).Position
  end
end)

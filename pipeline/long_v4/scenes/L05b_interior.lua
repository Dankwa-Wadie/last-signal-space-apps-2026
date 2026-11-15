-- Inside the Eagle (Apollo 11 LM ascent stage), on the surface: "They stayed for 21 hours."
-- Reference layout: two triangular forward windows, Commander left / LM Pilot right, standing
-- (the LM had no seats, the crew stood in restraints), main panels between and below the windows,
-- FDAI "8-ball" attitude indicators, DSKY keypad on the centre console, circuit-breaker panels on
-- both side walls, overhead docking hatch, square forward hatch at floor level.
local s=wipe(); spaceSky(); moonLight(9.5,60)
ground(s,Color3.fromRGB(150,147,140),Enum.Material.Sand,1600)
rocks(s,60,Color3.fromRGB(112,108,103),18,160,21,1)
flag(CFrame.new(5,0,-34)*CFrame.Angles(0,math.rad(-20),0))

local F=12                                   -- cabin floor height (sits on top of the descent stage)
local cab=Instance.new("Model"); cab.Name="Cabin"; cab.Parent=s
local WALL=Color3.fromRGB(118,114,106)       -- Beta-cloth / painted structure
local PANEL=Color3.fromRGB(52,56,60)         -- instrument panel grey
local DARK=Color3.fromRGB(30,32,34)
local function P(n,sz,cf,col,mat,shape)
  local p=Instance.new("Part"); p.Name=n; p.Size=sz; p.CFrame=cf; p.Anchored=true; p.CanCollide=false
  p.Color=col; p.Material=mat or Enum.Material.SmoothPlastic; if shape then p.Shape=shape end
  p.TopSurface=Enum.SurfaceType.Smooth; p.BottomSurface=Enum.SurfaceType.Smooth; p.Parent=cab; return p
end
local function W(n,sz,cf,col)   -- wedge
  local p=Instance.new("WedgePart"); p.Name=n; p.Size=sz; p.CFrame=cf; p.Anchored=true; p.CanCollide=false
  p.Color=col; p.Material=Enum.Material.SmoothPlastic; p.Parent=cab; return p
end

-- shell: floor, ceiling, side walls, back wall
local ZF=-4.2                                -- front wall plane
P("Floor",Vector3.new(13,0.3,9),CFrame.new(0,F-0.15,0),Color3.fromRGB(70,72,74),Enum.Material.DiamondPlate)
P("Ceiling",Vector3.new(13,0.3,9),CFrame.new(0,F+9.15,0),WALL)
P("WallL",Vector3.new(0.3,9.3,9),CFrame.new(-6.5,F+4.5,0),WALL,Enum.Material.Fabric)
P("WallR",Vector3.new(0.3,9.3,9),CFrame.new(6.5,F+4.5,0),WALL,Enum.Material.Fabric)
P("WallBack",Vector3.new(13,9.3,0.3),CFrame.new(0,F+4.5,4.6),WALL,Enum.Material.Fabric)

-- front wall with two triangular windows (openings), built from bands + corner wedges
local WY0,WY1=F+5.0,F+8.0                    -- window bottom/top
P("FrontLow",Vector3.new(13,WY0-F,0.3),CFrame.new(0,F+(WY0-F)/2,ZF),PANEL)
P("FrontTop",Vector3.new(13,F+9-WY1,0.3),CFrame.new(0,WY1+(F+9-WY1)/2,ZF),WALL)
P("Pillar",Vector3.new(2.2,WY1-WY0,0.3),CFrame.new(0,(WY0+WY1)/2,ZF),PANEL)
P("JambL",Vector3.new(1.8,WY1-WY0,0.3),CFrame.new(-5.6,(WY0+WY1)/2,ZF),WALL)
P("JambR",Vector3.new(1.8,WY1-WY0,0.3),CFrame.new(5.6,(WY0+WY1)/2,ZF),WALL)
-- each window: triangle with its vertical edge at the pillar, sloping down-outward:
-- fill the lower-outer corner of the [0.8..4.7] x [WY0..WY1] opening with a wedge
for _,sx in ipairs({-1,1}) do
  local cx=sx*2.75
  local wdg=W("WinCorner",Vector3.new(0.3,WY1-WY0,3.9),
    CFrame.new(cx,(WY0+WY1)/2,ZF)*CFrame.Angles(0,sx*math.rad(90),0)*CFrame.Angles(0,0,0),WALL)
  -- wedge slopes from full height at the outer jamb to zero at the pillar, on the bottom side
  -- filled corner = lower-OUTER, so the opening narrows down toward the centre pillar like the real LM
  wdg.CFrame=CFrame.new(cx,(WY0+WY1)/2,ZF)*CFrame.Angles(0,math.rad(sx>0 and 90 or -90),0)
  -- frame trim around the opening
  P("WinTrimTop",Vector3.new(3.9,0.18,0.4),CFrame.new(cx,WY1,ZF+0.05),DARK,Enum.Material.Metal)
end

-- main instrument panels below the windows, tilted toward the crew
local panelCF=CFrame.new(0,F+3.9,ZF+0.45)*CFrame.Angles(math.rad(-12),0,0)
P("MainPanel",Vector3.new(11.6,3.0,0.4),panelCF,PANEL)
-- FDAI attitude balls, one per crew station
for _,sx in ipairs({-2.05,2.05}) do
  local bez=panelCF*CFrame.new(sx,0.35,0.25)
  P("FDAIBezel",Vector3.new(0.12,1.5,1.5),bez*CFrame.Angles(0,math.rad(90),0),DARK,Enum.Material.Metal,Enum.PartType.Cylinder)
  P("FDAI",Vector3.new(1.15,1.15,1.15),bez*CFrame.new(0,0,0.15),Color3.fromRGB(226,222,212),Enum.Material.SmoothPlastic,Enum.PartType.Ball)
  P("FDAIHorizon",Vector3.new(1.18,0.06,1.18),bez*CFrame.new(0,0,0.15),DARK)
  -- tape meters and gauges beside each ball
  for g=0,2 do
    P("Tape",Vector3.new(0.28,1.1,0.1),panelCF*CFrame.new(sx+sx/math.abs(sx)*(1.1+g*0.45),0.35,-0.25),Color3.fromRGB(230,226,210))
  end
end
-- switch rows: dozens of small toggles and indicator lights across the panel
local rng=Random.new(1969)
for row=0,3 do
  for col=0,27 do
    local x=-5.4+col*0.4
    if math.abs(x)>1.0 or row<2 then
      local cf=panelCF*CFrame.new(x,-1.15+row*0.28,0.24)
      local lit=rng:NextNumber()<0.12
      if lit then
        P("Lamp",Vector3.new(0.16,0.1,0.06),cf,Color3.fromRGB(255,190,80),Enum.Material.Neon)
      else
        P("Toggle",Vector3.new(0.07,0.07,0.16),cf,Color3.fromRGB(205,205,200),Enum.Material.Metal)
      end
    end
  end
end
-- the centre pillar between the windows carries more panels (engine, radar, comms)
for r=0,7 do for c=0,4 do
  local lit=rng:NextNumber()<0.15
  P(lit and "Lamp" or "Toggle",lit and Vector3.new(0.16,0.12,0.06) or Vector3.new(0.07,0.07,0.16),
    CFrame.new(-0.8+c*0.4,WY0+0.35+r*0.33,ZF+0.2),lit and Color3.fromRGB(255,190,80) or Color3.fromRGB(205,205,200),
    lit and Enum.Material.Neon or Enum.Material.Metal)
end end
for g=0,1 do
  P("Gauge",Vector3.new(0.12,0.62,0.62),CFrame.new(-0.45+g*0.9,WY1-0.35,ZF+0.22)*CFrame.Angles(0,math.rad(90),0),Color3.fromRGB(226,222,212),Enum.Material.SmoothPlastic,Enum.PartType.Cylinder)
end
-- centre console: the DSKY (computer keypad) with its green electroluminescent display
local con=CFrame.new(0,F+2.0,ZF+1.4)*CFrame.Angles(math.rad(-40),0,0)
P("Console",Vector3.new(2.6,2.4,0.5),con,PANEL)
P("DSKYDisplay",Vector3.new(1.5,0.75,0.08),con*CFrame.new(0,0.65,0.28),Color3.fromRGB(40,60,40))
for r=0,2 do P("DSKYDigits",Vector3.new(1.1,0.1,0.04),con*CFrame.new(0.1,0.88-r*0.22,0.33),Color3.fromRGB(110,255,130),Enum.Material.Neon) end
for r=0,2 do for c=0,6 do
  P("Key",Vector3.new(0.17,0.17,0.08),con*CFrame.new(-0.65+c*0.22,-0.15-r*0.24,0.29),Color3.fromRGB(214,214,208))
end end

-- circuit-breaker panels on both side walls: rows of round black knobs
for _,sx in ipairs({-1,1}) do
  local wx=sx*6.3
  P("CBPanel",Vector3.new(0.12,2.6,5.4),CFrame.new(wx,F+6.6,-0.6),PANEL)
  for r=0,5 do for c=0,13 do
    P("CB",Vector3.new(0.12,0.16,0.16),CFrame.new(wx-sx*0.1,F+5.55+r*0.42,-3.0+c*0.37)*CFrame.Angles(0,0,math.rad(90)),DARK,Enum.Material.SmoothPlastic,Enum.PartType.Cylinder)
  end end
  -- crew restraint (bungee) anchor + armrest at each station
  P("Armrest",Vector3.new(0.3,0.25,1.6),CFrame.new(sx*4.4,F+3.6,-1.4),DARK)
end

-- overhead docking hatch and the rendezvous window above the commander
P("DockRing",Vector3.new(0.4,4.0,4.0),CFrame.new(0,F+9.0,0.6)*CFrame.Angles(0,0,math.rad(90)),Color3.fromRGB(170,168,160),Enum.Material.Metal,Enum.PartType.Cylinder)
P("DockHatch",Vector3.new(0.3,3.3,3.3),CFrame.new(0,F+8.95,0.6)*CFrame.Angles(0,0,math.rad(90)),Color3.fromRGB(140,138,132),Enum.Material.Metal,Enum.PartType.Cylinder)
P("OverheadWin",Vector3.new(1.4,0.1,1.0),CFrame.new(-3.4,F+9.05,-2.6),Color3.fromRGB(20,24,30),Enum.Material.Glass)
-- forward hatch at floor level, between the crew
P("FwdHatch",Vector3.new(2.6,2.6,0.25),CFrame.new(0,F+1.3,ZF+0.05),Color3.fromRGB(150,148,140),Enum.Material.Metal)
P("HatchHandle",Vector3.new(1.0,0.12,0.12),CFrame.new(0,F+1.6,ZF+0.25),DARK,Enum.Material.Metal)

-- loose stowage: the lunar sample boxes and checklists the crew handled
P("SRC",Vector3.new(1.2,0.8,0.9),CFrame.new(4.8,F+0.4,2.2)*CFrame.Angles(0,math.rad(12),0),Color3.fromRGB(176,178,180),Enum.Material.Metal)
P("Checklist",Vector3.new(0.7,0.05,0.9),CFrame.new(-4.2,F+3.75,-1.2)*CFrame.Angles(math.rad(-20),0,0),Color3.fromRGB(236,232,220))

-- cabin floodlights (warm) — the crew lit the cabin with flood and panel lighting
for _,lp in ipairs({{-3.5,F+8.4,1.5},{3.5,F+8.4,1.5},{0,F+4,2.5},{3.4,F+6.4,2.4}}) do
  local a=P("Flood",Vector3.new(0.4,0.2,0.4),CFrame.new(lp[1],lp[2],lp[3]),Color3.fromRGB(240,236,220),Enum.Material.Neon)
  local l=Instance.new("PointLight"); l.Brightness=0.45; l.Range=13; l.Color=Color3.fromRGB(255,232,196); l.Parent=a
end

-- the crew, standing at their stations, looking out of the windows
local cdr,an1=astronaut("Armstrong",CFrame.new(-3.6,F+2.9,-1.0),true)
local lmp,an2=astronaut("Aldrin",CFrame.new(3.6,F+2.9,-1.0),false)
cdr.HumanoidRootPart.CFrame=CFrame.lookAt(Vector3.new(-3.6,F+2.9,-1.0),Vector3.new(-2.8,F+3.4,-10))
lmp.HumanoidRootPart.CFrame=CFrame.lookAt(Vector3.new(3.6,F+2.9,-1.0),Vector3.new(2.8,F+3.4,-10))
play(an1,"idle",1,0.1); play(an2,"idle",1,1.4)
return "L05b"

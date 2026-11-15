-- ModuleScript  ReplicatedStorage/ArtifactIndex
-- One list of everything, shared by the HUD log and the trophy room so they can never
-- drift apart. Order is the order the log and the trophy room show things in.
return {
  ORDER={"lm","seis","retro","surv3","a12alsep","falcon","lrv","lrrr15",
         "oppy","heatshield","pathfinder","sojourner",
         "viking1","viking2","spirit","phoenix","insight","ingenuity","ranger4","near"},
  SHORT={lm="Descent Stage",seis="Seismometer",retro="Retroreflector",
    surv3="Surveyor 3",a12alsep="Apollo 12 ALSEP",
    falcon="Falcon Descent Stage",lrv="Lunar Rover",lrrr15="Retroreflector (A15)",
    oppy="Opportunity",heatshield="Heat Shield",
    pathfinder="Pathfinder",sojourner="Sojourner",
    viking1="Viking 1",viking2="Viking 2",spirit="Spirit",phoenix="Phoenix",
    insight="InSight",ingenuity="Ingenuity",ranger4="Ranger 4",near="NEAR Shoemaker"},
  SITEOF={lm="Tranquility",seis="Tranquility",retro="Tranquility",
    surv3="Oceanus Procellarum",a12alsep="Oceanus Procellarum",
    falcon="Hadley-Apennine",lrv="Hadley-Apennine",lrrr15="Hadley-Apennine",
    oppy="Meridiani Planum, Mars",heatshield="Meridiani Planum, Mars",
    pathfinder="Ares Vallis, Mars",sojourner="Ares Vallis, Mars",
    viking1="Chryse Planitia, Mars",viking2="Utopia Planitia, Mars",
    spirit="Gusev Crater, Mars",phoenix="Northern Polar Plains, Mars",
    insight="Elysium Planitia, Mars",ingenuity="Jezero Crater, Mars",
    ranger4="The Far Side",near="Eros"},
  WORLD={Tranquility="Moon",["Oceanus Procellarum"]="Moon",["Hadley-Apennine"]="Moon",
    ["The Far Side"]="Moon",["Meridiani Planum, Mars"]="Mars",["Ares Vallis, Mars"]="Mars",
    ["Chryse Planitia, Mars"]="Mars",["Utopia Planitia, Mars"]="Mars",
    ["Gusev Crater, Mars"]="Mars",["Northern Polar Plains, Mars"]="Mars",
    ["Elysium Planitia, Mars"]="Mars",["Jezero Crater, Mars"]="Mars",
    ["Eros"]="Eros"},
  PUZZLE={seis=true,retro=true,lrv=true,oppy=true,sojourner=true},
  ONLINE_LABEL={seis="ONLINE",retro="ONLINE",lrv="ONLINE",oppy="LOGGED",
    relay="LINKED",sojourner="DRIVEN"},
  -- Where each site really is, for the survey map. Selenographic / areographic coordinates
  -- from NASA's NSSDCA records; pos is where the site sits in this place.
  MAP={
    ["Tranquility"]           ={world="Moon",lat=0.674, lon=23.473, pos=Vector3.new(0,0,0),
      short="Tranquility"},
    ["Oceanus Procellarum"]   ={world="Moon",lat=-3.016,lon=-23.418,pos=Vector3.new(-1067,0,84),
      short="Procellarum"},
    ["Hadley-Apennine"]       ={world="Moon",lat=26.132,lon=3.633,  pos=Vector3.new(-451,0,-579),
      short="Hadley"},
    -- NASA: 15.5 S, 229.3 E. The crater has never been identified from orbit, so this is
    -- an estimate from its trajectory -- the one site orbit could not find.
    ["The Far Side"]          ={world="Moon",lat=-15.5, lon=-130.7, pos=Vector3.new(-3508,0,368),
      short="Ranger 4",estimated=true},
    ["Meridiani Planum, Mars"]={world="Mars",lat=-1.95, lon=-5.53,  pos=Vector3.new(20000,0,0),
      short="Meridiani"},
    ["Ares Vallis, Mars"]     ={world="Mars",lat=19.33, lon=-33.55, pos=Vector3.new(19681,0,-242),
      short="Ares Vallis"},
    ["Chryse Planitia, Mars"] ={world="Mars",lat=22.27, lon=-47.95, pos=Vector3.new(19517,0,-276),
      short="Chryse",labelLeft=true},   -- 14 deg from Ares Vallis: label the other side
    ["Utopia Planitia, Mars"] ={world="Mars",lat=47.67, lon=134.28, pos=Vector3.new(17495,0,-565),
      short="Utopia"},
    ["Gusev Crater, Mars"]    ={world="Mars",lat=-14.57,lon=175.48, pos=Vector3.new(17963,0,144),
      short="Gusev"},
    ["Northern Polar Plains, Mars"]={world="Mars",lat=68.15,lon=-125.9,pos=Vector3.new(18630,0,-798),
      short="Polar plains"},
    ["Elysium Planitia, Mars"]={world="Mars",lat=4.5,   lon=135.62, pos=Vector3.new(17510,0,-73),
      short="Elysium"},
    ["Jezero Crater, Mars"]   ={world="Mars",lat=18.45, lon=77.45,  pos=Vector3.new(16848,0,-232),
      short="Jezero"},
    -- Updated NEAR landing solution: 41.626 S, 80.421 E, near the Himeros saddle
    ["Eros"]                  ={world="Eros",lat=-41.626, lon=80.421, pos=Vector3.new(40000,0,0),
      short="NEAR Shoemaker"},
  },
  -- catalogue entries nobody can ever walk up to: these are "found" by reading them
  UNREACHABLE={
    {id="dawn",   name="Dawn",           where="Orbiting Ceres, out of fuel"},
    {id="kepler", name="Kepler",         where="Orbiting the Sun, trailing Earth"},
    {id="pioneer10",name="Pioneer 10",   where="Leaving the solar system"},
    {id="pioneer11",name="Pioneer 11",   where="Leaving the solar system"},
    {id="voyager1",name="Voyager 1",     where="Interstellar space, still answering"},
  },
}

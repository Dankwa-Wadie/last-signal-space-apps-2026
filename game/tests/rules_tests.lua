-- Unit tests for SurveyRules, extended on 14 Nov for four sites and two worlds.
-- Run from an Edit-mode execute_luau:  require(ServerScriptService.SurveyRules) and this file.
-- NOTE: `require` caches a module for the whole Studio session. If you edit SurveyRules,
-- reopen the place or read .Source to confirm what is actually there.
local R=require(game:GetService("ServerScriptService"):WaitForChild("SurveyRules"))
local pass,fail=0,{}
local function ok(name,cond)
  if cond then pass+=1 else table.insert(fail,name) end
end
local function near(a,b,eps) return math.abs(a-b)<=(eps or 1e-4) end

-- real anchor positions, all four sites
local A={
  lm        =Vector3.new(0,4,8),
  seis      =Vector3.new(-33,2.4,19),
  retro     =Vector3.new(36,2.6,-26),
  surv3     =Vector3.new(-484,2.2,156),
  a12alsep  =Vector3.new(-454,2.0,140),
  falcon    =Vector3.new(400,4.2,-228),
  lrv       =Vector3.new(452,2.6,-200),
  lrrr15    =Vector3.new(426,1.8,-166),
  oppy      =Vector3.new(50,2.4,1494),
  heatshield=Vector3.new(94,2.0,1526),
}

-- ---- inRange ----
ok("inRange same point", R.inRange(A.lm,A.lm,1))
ok("inRange exact boundary", R.inRange(Vector3.new(0,0,0),Vector3.new(14,0,0),14))
ok("inRange just outside", not R.inRange(Vector3.new(0,0,0),Vector3.new(14.1,0,0),14))
ok("inRange rejects nil", not R.inRange(nil,A.lm,14))
ok("inRange rejects non-vector", not R.inRange("x",A.lm,14))

-- ---- sites must not bleed into each other ----
-- A vignette at one site must never be witnessed by someone at another.
local ids={}
for id in pairs(A) do table.insert(ids,id) end
table.sort(ids)
local minCross=math.huge
for i=1,#ids do for j=i+1,#ids do
  local a,b=A[ids[i]],A[ids[j]]
  local siteA = (ids[i]=="lm" or ids[i]=="seis" or ids[i]=="retro") and "T"
    or (ids[i]=="surv3" or ids[i]=="a12alsep") and "P"
    or (ids[i]=="oppy" or ids[i]=="heatshield") and "M" or "H"
  local siteB = (ids[j]=="lm" or ids[j]=="seis" or ids[j]=="retro") and "T"
    or (ids[j]=="surv3" or ids[j]=="a12alsep") and "P"
    or (ids[j]=="oppy" or ids[j]=="heatshield") and "M" or "H"
  if siteA~=siteB then minCross=math.min(minCross,(a-b).Magnitude) end
end end
ok("cross-site separation beats witness radius ("..math.floor(minCross).." studs)",
   minCross > R.WITNESS_RADIUS)

-- ---- witnesses ----
local crew={
  {key="A",pos=A.lm},                               -- on top of it
  {key="B",pos=A.lm+Vector3.new(20,0,0)},           -- inside 22
  {key="C",pos=A.lm+Vector3.new(40,0,0)},           -- outside
  {key="D",pos=nil},                                -- no character
  {key="E",pos=A.oppy},                             -- on Mars entirely
}
local w=R.selectWitnesses(crew,A.lm,R.WITNESS_RADIUS)
ok("witness count is 2",#w==2)
ok("witness A included",w[1]=="A")
ok("witness B included",w[2]=="B")
ok("witness excludes the far one",not table.find(w,"C"))
ok("witness excludes the bodiless",not table.find(w,"D"))
ok("witness excludes another planet",not table.find(w,"E"))
ok("empty crew is empty",#R.selectWitnesses({},A.lm,22)==0)
ok("nobody near Mars artifact from the Moon",
   #R.selectWitnesses({{key="A",pos=A.lm}},A.oppy,22)==0)

-- ---- canTrigger ----
ok("canTrigger at the anchor",(R.canTrigger(A.seis,A.seis,14)))
ok("canTrigger just inside",(R.canTrigger(A.seis+Vector3.new(13,0,0),A.seis,14)))
ok("canTrigger fails just outside",not (R.canTrigger(A.seis+Vector3.new(15,0,0),A.seis,14)))
ok("canTrigger fails with no character",not (R.canTrigger(nil,A.seis,14)))
local _,why=R.canTrigger(nil,A.seis,14)
ok("canTrigger explains itself",why=="no character")
ok("canTrigger cannot reach Mars from the Moon",
   not (R.canTrigger(A.lm,A.oppy,14)))

-- ---- locks: one player per instrument ----
local locks={}
ok("first lock granted",(R.acquireLock(locks,"seis",111)))
ok("same player re-locks",(R.acquireLock(locks,"seis",111)))
ok("second player refused",not (R.acquireLock(locks,"seis",222)))
ok("other instrument free",(R.acquireLock(locks,"retro",222)))
ok("wrong player cannot release",not R.releaseLock(locks,"seis",222))
ok("owner releases",R.releaseLock(locks,"seis",111))
ok("now free for the other",(R.acquireLock(locks,"seis",222)))
ok("all four puzzles lock independently",
   (R.acquireLock(locks,"lrv",333)) and (R.acquireLock(locks,"oppy",444)))

-- ---- cooldown ----
local cool={}
ok("no cooldown initially",not R.onCooldown(cool,"lm",100))
cool.lm=130
ok("cooldown holds",R.onCooldown(cool,"lm",129.9))
ok("cooldown expires on the tick",not R.onCooldown(cool,"lm",130))
ok("cooldown expired after",not R.onCooldown(cool,"lm",131))
ok("cooldown is per artifact",not R.onCooldown(cool,"seis",129))

-- ---- snapshot ----
local ORDER={"lm","seis","retro","surv3","a12alsep","falcon","lrv","lrrr15","oppy","heatshield"}
local disc={lm={title="Eagle",by="X"},oppy={title="Oppy",by="Y"}}
local s=R.snapshot(ORDER,disc)
local n=0; for _ in pairs(s) do n+=1 end
ok("snapshot covers all ten",n==10)
ok("snapshot keeps found entries",s.lm~=false and s.lm.by=="X")
ok("snapshot marks the rest false",s.seis==false and s.heatshield==false)
ok("snapshot spans worlds",s.oppy~=false and s.oppy.by=="Y")
ok("snapshot ignores unknown ids",R.snapshot({"nope"},disc).nope==false)

local msg=("SurveyRules: %d/%d passed"):format(pass,pass+#fail)
if #fail>0 then msg=msg.."\nFAILED:\n  "..table.concat(fail,"\n  ") end
return msg

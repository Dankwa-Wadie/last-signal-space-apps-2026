-- Consistency checks for ReplicatedStorage.ArtifactIndex: the HUD log, the trophy room and
-- the survey map all read it, so a gap here shows up as a blank tile or a missing map pin.
-- A fresh clone is required so Studio's module cache cannot hand back a stale copy.
local RS=game:GetService("ReplicatedStorage")
local src=RS:WaitForChild("ArtifactIndex")
local tmp=src:Clone(); tmp.Name="ArtifactIndex_test"; tmp.Parent=RS
local ok,IDX=pcall(require,tmp)
tmp:Destroy()
if not ok then return "ArtifactIndex failed to load: "..tostring(IDX) end

local pass,fail=0,{}
local function check(name,cond) if cond then pass+=1 else table.insert(fail,name) end end

local seen={}
for _,id in ipairs(IDX.ORDER) do
  check("no duplicate id "..id, not seen[id]); seen[id]=true
  check("short name for "..id, type(IDX.SHORT[id])=="string" and #IDX.SHORT[id]>0)
  local site=IDX.SITEOF[id]
  check("site for "..id, type(site)=="string")
  check("map pin for site of "..id, site~=nil and IDX.MAP[site]~=nil)
  check("world for site of "..id, site~=nil and IDX.WORLD[site]~=nil)
end
local used={}
for _,id in ipairs(IDX.ORDER) do used[IDX.SITEOF[id]]=true end
local nsites=0
for site,m in pairs(IDX.MAP) do
  nsites+=1
  check("map site has objects: "..site, used[site]==true)
  check("map world matches: "..site, m.world==IDX.WORLD[site])
  check("latitude in range: "..site, type(m.lat)=="number" and m.lat>=-90 and m.lat<=90)
  check("longitude in range: "..site, type(m.lon)=="number" and m.lon>=-180 and m.lon<=180)
  check("place position: "..site, typeof(m.pos)=="Vector3")
end
check("13 sites on the map", nsites==13)
check("20 artifacts in the log", #IDX.ORDER==20)
-- Ranger 4: NASA gives 15.5 S, 229.3 E (= 130.7 W), and flags it as an estimate
local fs=IDX.MAP["The Far Side"]
check("Ranger 4 at NASA's estimate", fs and fs.lat==-15.5 and fs.lon==-130.7 and fs.estimated==true)

-- NEAR: updated touchdown solution, 41.626 S, 80.421 E -- and it is no longer catalogue-only
local er=IDX.MAP["Eros"]
check("NEAR at the updated landing solution", er and er.lat==-41.626 and er.lon==80.421 and er.world=="Eros")
local stillUnreachable=false
for _,u in ipairs(IDX.UNREACHABLE) do if u.id=="near" then stillUnreachable=true end end
check("NEAR is no longer listed as unreachable", not stillUnreachable)

local msg=("ArtifactIndex: %d/%d passed"):format(pass,pass+#fail)
if #fail>0 then msg=msg.."\nFAILED:\n  "..table.concat(fail,"\n  ") end
return msg

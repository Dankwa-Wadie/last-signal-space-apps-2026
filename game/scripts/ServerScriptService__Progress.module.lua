-- ModuleScript  ServerScriptService/Progress
-- What the crew has actually found. The trophy hall reads this: an exhibit only exists
-- once the thing it is a model OF has been recovered in the field, or catalogued at the
-- NSSDCA terminal for the ones nobody can reach.
local M={}
M.revealed={}                       -- gallery exhibit id -> true
M.changed=Instance.new("BindableEvent")

-- world artifact (ASTROLOG id) -> the gallery exhibit it unlocks
M.FROM_ARTIFACT={
  surv3     ="surveyor3",
  pathfinder="pathfinder",
  sojourner ="pathfinder",
  viking1   ="viking1",
  viking2   ="viking1",   -- one exhibit stands for both Viking landers
  spirit    ="spirit",
  phoenix   ="phoenix",
  insight   ="insight",
  ingenuity ="ingenuity",
  near      ="near",
}
-- the unreachable ones unlock by being read at the Archive terminal instead:
-- you cannot stand on Ceres or catch a Pioneer, so cataloguing them is the find.
-- Only what genuinely cannot be stood on: Dawn never landed (it is in a parking orbit
-- around Ceres), the Pioneers are in deep space, Kepler orbits the Sun.
M.CATALOGUE_ONLY={
  dawn=true, kepler=true, pioneer10=true, pioneer11=true,
}

function M.reveal(exhibitId)
  if type(exhibitId)~="string" or exhibitId=="" then return false end
  if M.revealed[exhibitId] then return false end
  M.revealed[exhibitId]=true
  M.changed:Fire(exhibitId)
  return true
end

function M.fromArtifact(artifactId)
  local g=M.FROM_ARTIFACT[artifactId]
  if g then return M.reveal(g) end
  return false
end

function M.snapshot()
  local t={}
  for k,v in pairs(M.revealed) do t[k]=v end
  return t
end

return M

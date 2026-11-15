-- ModuleScript  ServerScriptService/SurveyRules
-- Pure rules used by the live servers. No Roblox services touched, so it can
-- be tested with synthetic crews instead of needing real second clients.
local M={}

M.WITNESS_RADIUS=22
M.TRIGGER_RADIUS=14

function M.inRange(a,b,r)
  if typeof(a)~="Vector3" or typeof(b)~="Vector3" then return false end
  return (a-b).Magnitude<=r
end

-- crew: array of {key=<any>, pos=Vector3 or nil}
-- returns array of keys close enough to witness a vignette at anchorPos
function M.selectWitnesses(crew,anchorPos,radius)
  radius=radius or M.WITNESS_RADIUS
  local out={}
  for _,c in ipairs(crew) do
    if c.pos and M.inRange(c.pos,anchorPos,radius) then
      table.insert(out,c.key)
    end
  end
  return out
end

function M.canTrigger(playerPos,anchorPos,radius)
  radius=radius or M.TRIGGER_RADIUS
  if not playerPos then return false,"no character" end
  if not M.inRange(playerPos,anchorPos,radius) then return false,"too far" end
  return true
end

-- locks: table id -> userId
function M.acquireLock(locks,id,userId)
  local holder=locks[id]
  if holder~=nil and holder~=userId then return false,"busy" end
  locks[id]=userId
  return true
end

function M.releaseLock(locks,id,userId)
  if locks[id]==userId then locks[id]=nil return true end
  return false
end

-- cooldown: table id -> expiry clock value
function M.onCooldown(cool,id,now)
  return cool[id]~=nil and now<cool[id]
end

function M.snapshot(order,discovered)
  local t={}
  for _,id in ipairs(order) do t[id]=discovered[id] or false end
  return t
end

return M

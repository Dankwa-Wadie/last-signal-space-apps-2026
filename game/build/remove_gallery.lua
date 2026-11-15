-- The replica hall stood on the regolith at Tranquility, a few dozen metres from Eagle,
-- under signs reading DO NOT DISTURB. Progress now lives in a screen you open from the
-- settings button instead, so the landing site goes back to being only the landing site.
local game_=workspace:WaitForChild("Game")
local removed={}
local T=game_:FindFirstChild("Tranquility")
if T then
  local g=T:FindFirstChild("Gallery")
  if g then g:Destroy(); table.insert(removed,"Tranquility.Gallery") end
end
local h=game_:FindFirstChild("ArchiveHall")
if h then h:Destroy(); table.insert(removed,"ArchiveHall") end
local SSS=game:GetService("ServerScriptService")
local gs=SSS:FindFirstChild("GalleryServer")
if gs then gs:Destroy(); table.insert(removed,"GalleryServer") end
return "removed: "..((#removed>0) and table.concat(removed,", ") or "nothing to remove")

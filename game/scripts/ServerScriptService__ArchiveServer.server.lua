-- Script  ServerScriptService/ArchiveServer
-- The NSSDCA terminal and the replica gallery: prompts fire on the server, which tells that
-- player's screen what to open (nil = the terminal's front page, or an ArchiveId for one card).
local RS=game:GetService("ReplicatedStorage")
local rem=RS:WaitForChild("Remotes")
local ev=rem:FindFirstChild("OpenArchive") or Instance.new("RemoteEvent")
ev.Name="OpenArchive"; ev.Parent=rem
local Progress=require(game:GetService("ServerScriptService"):WaitForChild("Progress"))
local site=workspace:WaitForChild("Game"):WaitForChild("Tranquility")
local hooked={}
local function hook(pp)
  if hooked[pp] or not pp:IsA("ProximityPrompt") then return end
  local isTerm=pp:FindFirstAncestor("ArchiveTerminal")~=nil
  local id=pp:GetAttribute("ArchiveId")
  if not isTerm and not id then return end
  hooked[pp]=true
  pp.Triggered:Connect(function(player)
    ev:FireClient(player,id)
    -- Ceres, Eros, the Pioneers: nobody can walk up to those, so reading the
    -- catalogue entry is how they are "found".
    if id and Progress.CATALOGUE_ONLY[id] then Progress.reveal(id) end
  end)
end
for _,d in ipairs(site:GetDescendants()) do hook(d) end
site.DescendantAdded:Connect(hook)

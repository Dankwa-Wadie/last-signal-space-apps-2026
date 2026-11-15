-- Puts every screen that was first written in pixels through UIKit.adopt, so they all follow
-- the figma-to-roblox-ui rules (Scale only, ScaledSize strokes, Scale corners, TextScaled).
local Players=game:GetService("Players")
local UI=require(game:GetService("ReplicatedStorage"):WaitForChild("UIKit"))
local pg=Players.LocalPlayer:WaitForChild("PlayerGui")
local TARGETS={Archive=true,Panel=true,SurveyMap=true,Settings=true,TrophyRoom=true,Controls=true,
  HUD=true,Handover=true,Console=true,Arrive=true,Intro=true,ViewToggle=true}
local done={}
local function try(g)
  if g:IsA("ScreenGui") and TARGETS[g.Name] and not done[g] then
    done[g]=true
    task.delay(1,function() local ok,e=pcall(UI.adopt,g); if not ok then warn("Restyle "..g.Name..": "..tostring(e)) end end)
  end
end
for _,g in ipairs(pg:GetChildren()) do try(g) end
pg.ChildAdded:Connect(try)
if game:GetService("RunService"):IsStudio() then
  local f=Instance.new("BindableFunction"); f.Name="_RestyleTest"; f.Parent=script
  f.OnInvoke=function() local r={} for g in pairs(done) do r[g.Name]=#UI.validate(g) end return r end
end

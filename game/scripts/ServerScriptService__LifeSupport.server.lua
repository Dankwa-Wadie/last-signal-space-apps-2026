-- Air runs down during an EVA. The named habitat kiosks refill oxygen and suit power;
-- standing inside a habitat also tops both up, so the recharge path is easy to discover.
local Players=game:GetService("Players")
local gameFolder=workspace:WaitForChild("Game")
local rem=game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
local Notice=rem:WaitForChild("Notice")
local MAX=100

local function init(pl)
  pl:SetAttribute("SuitOxygen",100)
  if pl:GetAttribute("SuitPower")==nil then pl:SetAttribute("SuitPower",100) end
end
for _,pl in ipairs(Players:GetPlayers()) do init(pl) end
Players.PlayerAdded:Connect(init)

local function service(prompt,baseName)
  prompt.Triggered:Connect(function(pl)
    local char=pl.Character
    local root=char and char:FindFirstChild("HumanoidRootPart")
    local part=prompt.Parent
    if not root or not part:IsA("BasePart") or (root.Position-part.Position).Magnitude>12 then return end
    pl:SetAttribute("SuitOxygen",MAX)
    pl:SetAttribute("SuitPower",MAX)
    Notice:FireClient(pl,baseName.." life support restored: oxygen and suit power full.",4)
  end)
end

local anchors={
  {gameFolder.Tranquility.Station.StationConsole,"Tranquility Heritage Station"},
  {gameFolder.Meridiani.Outpost.LifeSupportKiosk,"Meridiani Outpost"},
  {gameFolder.Eros.ErosHabitat.LifeSupportKiosk,"Eros Research Habitat"},
}
for _,entry in ipairs(anchors) do
  local part,name=entry[1],entry[2]
  local prompt=part:FindFirstChildWhichIsA("ProximityPrompt")
  if prompt then service(prompt,name) end
end

local function inHabitat(p)
  return (p.X<10000 and (p-Vector3.new(0,8,184)).Magnitude<34)
    or (p.X>10000 and p.X<30000 and (p-Vector3.new(20034,7,52)).Magnitude<22)
    or (p.X>30000 and (p-Vector3.new(40034,7,48)).Magnitude<22)
end

local function atLifeSupport(p)
  return (p.X<10000 and (p-Vector3.new(0,8,184)).Magnitude<16)
    or (p.X>10000 and p.X<30000 and (p-Vector3.new(20034,7,52)).Magnitude<12)
    or (p.X>30000 and (p-Vector3.new(40034,7,48)).Magnitude<12)
end

-- Suit oxygen is a gameplay abstraction, not a claim about actual station pressure.
task.spawn(function()
  while true do
    task.wait(4)
    for _,pl in ipairs(Players:GetPlayers()) do
      local char=pl.Character
      local root=char and char:FindFirstChild("HumanoidRootPart")
      if root then
        local p=root.Position
        if atLifeSupport(p) then
          pl:SetAttribute("SuitOxygen",MAX)
          pl:SetAttribute("SuitPower",MAX)
          pl:SetAttribute("AirEmptyNotice",false)
        elseif not inHabitat(p) then
          local air=math.max(0,(pl:GetAttribute("SuitOxygen") or MAX)-1)
          pl:SetAttribute("SuitOxygen",air)
          if air==25 then Notice:FireClient(pl,"Suit oxygen low. Return to a habitat life-support console.",5) end
          if air==0 and pl:GetAttribute("AirEmptyNotice")~=true then
            pl:SetAttribute("AirEmptyNotice",true)
            Notice:FireClient(pl,"Oxygen depleted. Return to a habitat and refill life support.",6)
          end
        else
          pl:SetAttribute("AirEmptyNotice",false)
        end
      end
    end
  end
end)

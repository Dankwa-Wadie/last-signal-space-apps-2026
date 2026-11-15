local s = wipe(); clearAtmos(); L.ClockTime = 0.0
L.Brightness = 0.0
L.OutdoorAmbient = Color3.fromRGB(15, 18, 28)
L.Ambient = Color3.fromRGB(12, 15, 24)

-- Starfield / Sky
local sky = Instance.new("Sky")
sky.SkyboxBk = "rbxassetid://101379085951893"
sky.SkyboxDn = "rbxassetid://101379085951893"
sky.SkyboxFt = "rbxassetid://101379085951893"
sky.SkyboxLf = "rbxassetid://101379085951893"
sky.SkyboxRt = "rbxassetid://101379085951893"
sky.SkyboxUp = "rbxassetid://101379085951893"
sky.Parent = L

-- Key directional light representing the distant Sun (faint pinprick light in interstellar space)
local sunLight = Instance.new("Part")
sunLight.Size = Vector3.new(1, 1, 1); sunLight.CFrame = CFrame.new(60, 45, 60)
sunLight.Anchored = true; sunLight.Transparency = 1; sunLight.CanCollide = false
sunLight.Parent = s

local sunPoint = Instance.new("PointLight")
sunPoint.Brightness = 4.5
sunPoint.Range = 120
sunPoint.Color = Color3.fromRGB(240, 245, 255)
sunPoint.Parent = sunLight

-- Voyager model spawned at origin
local voy = spawn("VOYAGER", 0, 0, 7.5, 0, 0)
if voy then
  voy.Name = "VoyagerSpacecraft"
  voy:PivotTo(CFrame.new(0, 6, 0) * CFrame.Angles(math.rad(12), math.rad(-25), math.rad(8)))
end

return "long_s07_voyager"


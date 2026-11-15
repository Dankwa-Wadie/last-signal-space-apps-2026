local s = wipe(); clearAtmos(); L.ClockTime = 14.0
L.Brightness = 0.75
L.OutdoorAmbient = Color3.fromRGB(160, 80, 40)
L.Ambient = Color3.fromRGB(130, 68, 35)
L.ColorShift_Top = Color3.fromRGB(235, 130, 70)

local at = Instance.new("Atmosphere")
at.Density = 0.65; at.Offset = 0.28; at.Color = Color3.fromRGB(195, 95, 48)
at.Decay = Color3.fromRGB(145, 58, 22); at.Glare = 0.45; at.Haze = 3.2; at.Parent = L

ground(s, Color3.fromRGB(175, 82, 44), Enum.Material.Sand, 1600)
rocks(s, 90, Color3.fromRGB(130, 58, 30), 10, 160, 29, 1.1)

-- Opportunity Rover
local rover = spawn("ROVER", 0, 0, 3.6, -18, 0.05)

-- Martian dust cloud emitter attached to an anchor part
local dustPart = Instance.new("Part")
dustPart.Name = "DustAnchor"
dustPart.Size = Vector3.new(1, 1, 1)
dustPart.CFrame = CFrame.new(0, 1.5, 0)
dustPart.Anchored = true; dustPart.Transparency = 1; dustPart.CanCollide = false
dustPart.Parent = s

local emitter = Instance.new("ParticleEmitter")
emitter.Name = "MartianDust"
emitter.Rate = 45
emitter.Lifetime = NumberRange.new(3.0, 5.0)
emitter.Speed = NumberRange.new(6.0, 14.0)
emitter.SpreadAngle = Vector2.new(15, 15)
emitter.EmissionDirection = Enum.NormalId.Right
emitter.Color = ColorSequence.new(Color3.fromRGB(190, 95, 50))
emitter.Transparency = NumberSequence.new(0.65, 0.95)
emitter.Size = NumberSequence.new(2.5, 7.0)
emitter.Parent = dustPart

return "long_s06_mars"


local ws = workspace
local old = ws:FindFirstChild("LunarTest")
if old then old:Destroy() end
local root = Instance.new("Model"); root.Name = "LunarTest"; root.Parent = ws

local function part(name, size, cf, color, mat, parent)
  local p = Instance.new("Part")
  p.Name=name; p.Size=size; p.CFrame=cf; p.Anchored=true
  p.Color=color; p.Material=mat; p.TopSurface=Enum.SurfaceType.Smooth
  p.BottomSurface=Enum.SurfaceType.Smooth
  p.Parent=parent or root
  return p
end

-- regolith plate
part("Regolith", Vector3.new(220,2,220), CFrame.new(0,-1,0),
     Color3.fromRGB(128,124,118), Enum.Material.Sand)

-- lander descent stage
local body = part("DescentStage", Vector3.new(14,5,14), CFrame.new(0,4,0),
     Color3.fromRGB(212,175,55), Enum.Material.Foil)
for i,off in ipairs({Vector3.new(9,0,9),Vector3.new(-9,0,9),Vector3.new(9,0,-9),Vector3.new(-9,0,-9)}) do
  part("Leg"..i, Vector3.new(1,8,1), CFrame.new(off.X,2,off.Z), Color3.fromRGB(190,190,190), Enum.Material.Metal)
  part("Pad"..i, Vector3.new(4,0.6,4), CFrame.new(off.X,0.3,off.Z), Color3.fromRGB(160,160,160), Enum.Material.Metal)
end
part("Nozzle", Vector3.new(4,4,4), CFrame.new(0,0.5,0), Color3.fromRGB(60,60,60), Enum.Material.Metal)
part("Antenna", Vector3.new(0.5,7,0.5), CFrame.new(5,10,0), Color3.fromRGB(200,200,200), Enum.Material.Metal)

-- harsh low sun, black sky
local L = game:GetService("Lighting")
L.ClockTime = 6.3
L.Brightness = 3
L.Ambient = Color3.fromRGB(12,12,16)
L.OutdoorAmbient = Color3.fromRGB(16,16,22)
L.GlobalShadows = true
L.FogEnd = 100000

local cam = ws.CurrentCamera
cam.CFrame = CFrame.lookAt(Vector3.new(34,10,38), Vector3.new(0,5,0))

return "built "..#root:GetChildren().." parts"

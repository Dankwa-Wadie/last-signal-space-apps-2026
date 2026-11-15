-- A note at Tranquility about what is overhead, and about the one thing we exaggerate.
local game_=workspace:WaitForChild("Game")
local T=game_:WaitForChild("Tranquility")
local old=T:FindFirstChild("SkySign"); if old then old:Destroy() end
local sign=Instance.new("Model"); sign.Name="SkySign"; sign.Parent=T
-- at the station, readable from the spawn pad (SurfaceGui is on the +Z face)
local pos=Vector3.new(15,0,138)
local base=CFrame.lookAt(pos,pos+(pos-Vector3.new(0,0,150)))
local function SP(n,sz,cf,col)
  local p=Instance.new("Part"); p.Name=n; p.Anchored=true; p.Size=sz; p.CFrame=base*cf
  p.Color=col; p.Material=Enum.Material.Metal; p.Parent=sign; return p
end
SP("Post",Vector3.new(0.2,4.2,0.2),CFrame.new(-2.3,2.1,0),Color3.fromRGB(190,190,186))
SP("Post2",Vector3.new(0.2,4.2,0.2),CFrame.new(2.3,2.1,0),Color3.fromRGB(190,190,186))
local board=SP("Board",Vector3.new(5.2,2.6,0.12),CFrame.new(0,3.4,0),Color3.fromRGB(14,14,16))
board.Material=Enum.Material.SmoothPlastic
local g=Instance.new("SurfaceGui"); g.Face=Enum.NormalId.Back; g.CanvasSize=Vector2.new(620,310)
g.LightInfluence=0; g.Parent=board
local function T2(txt,y,h,font,col)
  local l=Instance.new("TextLabel"); l.Size=UDim2.new(1,-28,0,h); l.Position=UDim2.fromOffset(14,y)
  l.BackgroundTransparency=1; l.Font=font; l.TextColor3=col; l.Text=txt
  l.TextScaled=true; l.TextXAlignment=Enum.TextXAlignment.Left; l.Parent=g
end
T2("LOOK UP",10,42,Enum.Font.GothamBold,Color3.fromRGB(245,231,60))
T2("Earth never moves in this sky. The Moon keeps one face",58,26,Enum.Font.Gotham,Color3.fromRGB(215,215,220))
T2("turned to us, so from here Earth sits in the same spot",86,26,Enum.Font.Gotham,Color3.fromRGB(215,215,220))
T2("for ever. It never rises and it never sets.",114,26,Enum.Font.Gotham,Color3.fromRGB(215,215,220))
T2("The sky is black in full daylight: no air to scatter the",150,26,Enum.Font.Gotham,Color3.fromRGB(165,170,176))
T2("sunlight, and the stars do not twinkle.",178,26,Enum.Font.Gotham,Color3.fromRGB(165,170,176))
T2("Earth really looks about 4x as wide as the Moon does",216,24,Enum.Font.GothamMedium,Color3.fromRGB(150,205,255))
T2("from Earth. We draw it 3x bigger so you can see it.",242,24,Enum.Font.GothamMedium,Color3.fromRGB(150,205,255))
T2("Everything else here is to scale.",270,24,Enum.Font.GothamMedium,Color3.fromRGB(150,205,255))
return "sky sign installed"

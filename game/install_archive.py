"""Install the NSSDCA Archive terminal into the open LAST SIGNAL place (Edit mode).
   python3 install_archive.py <studio_id>   (idempotent: replaces any previous install)"""
import json, subprocess, threading, time, sys, os
HERE = os.path.dirname(os.path.abspath(__file__)); SID = sys.argv[1]
mod = open(os.path.join(HERE, "scripts", "ReplicatedStorage__ArchiveCatalog.module.lua")).read()
cli = open(os.path.join(HERE, "scripts", "StarterPlayerScripts__StarterPlayerScripts.Archive.client.lua")).read()
srv = open(os.path.join(HERE, "scripts", "ServerScriptService__ArchiveServer.server.lua")).read()
code = r'''
local RS=game:GetService("ReplicatedStorage")
local SPS=game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")
local site=workspace.Game.Tranquility
local SSS=game:GetService("ServerScriptService")
for _,o in ipairs({RS:FindFirstChild("ArchiveCatalog"),SPS:FindFirstChild("Archive"),site:FindFirstChild("ArchiveTerminal"),SSS:FindFirstChild("ArchiveServer")}) do if o then o:Destroy() end end
local sv=Instance.new("Script"); sv.Name="ArchiveServer"; sv.Source=[==[SRVSRC]==]; sv.Parent=SSS
local m=Instance.new("ModuleScript"); m.Name="ArchiveCatalog"; m.Source=[==[MODSRC]==]; m.Parent=RS
local l=Instance.new("LocalScript"); l.Name="Archive"; l.Source=[==[CLISRC]==]; l.Parent=SPS
-- the terminal: a ground-station style console, facing the spawn
local X,Z=-11,27
local rp=RaycastParams.new(); rp.FilterType=Enum.RaycastFilterType.Exclude
local hit=workspace:Raycast(Vector3.new(X,200,Z),Vector3.new(0,-400,0),rp)
local gy=hit and hit.Position.Y or 0
local base=CFrame.lookAt(Vector3.new(X,gy,Z),Vector3.new(0,gy,34))
local t=Instance.new("Model"); t.Name="ArchiveTerminal"; t.Parent=site
local function P(n,sz,cf,col,mat)
  local p=Instance.new("Part"); p.Name=n; p.Size=sz; p.CFrame=base*cf; p.Anchored=true; p.Color=col
  p.Material=mat or Enum.Material.Metal; p.TopSurface=Enum.SurfaceType.Smooth; p.BottomSurface=Enum.SurfaceType.Smooth; p.Parent=t; return p
end
P("Pedestal",Vector3.new(3.2,3.4,1.6),CFrame.new(0,1.7,0),Color3.fromRGB(70,72,76))
P("Desk",Vector3.new(3.6,0.25,2.2),CFrame.new(0,3.45,-0.3)*CFrame.Angles(math.rad(-12),0,0),Color3.fromRGB(40,42,46))
local scr=P("Screen",Vector3.new(3.0,1.9,0.12),CFrame.new(0,4.6,0.35)*CFrame.Angles(math.rad(-18),0,0),Color3.fromRGB(40,90,130),Enum.Material.Neon)
local sg=Instance.new("SurfaceGui"); sg.Face=Enum.NormalId.Front; sg.CanvasSize=Vector2.new(600,380); sg.LightInfluence=0; sg.Parent=scr
local tl=Instance.new("TextLabel"); tl.Size=UDim2.fromScale(1,1); tl.BackgroundTransparency=1; tl.Font=Enum.Font.GothamBold
tl.TextColor3=Color3.fromRGB(245,231,60); tl.TextScaled=true; tl.Text="NSSDCA\nARCHIVE"; tl.Parent=sg
P("Mast",Vector3.new(0.18,3.2,0.18),CFrame.new(1.4,5.0,0.6),Color3.fromRGB(190,190,186))
local dish=P("Dish",Vector3.new(0.15,1.3,1.3),CFrame.new(1.4,6.7,0.6)*CFrame.Angles(0,math.rad(90),math.rad(55)),Color3.fromRGB(220,220,216),Enum.Material.SmoothPlastic)
dish.Shape=Enum.PartType.Cylinder
local a=Instance.new("Part"); a.Name="Anchor"; a.Size=Vector3.new(1,1,1); a.Transparency=1; a.CanCollide=false; a.Anchored=true
a.CFrame=base*CFrame.new(0,3.5,-1.4); a.Parent=t
local pp=Instance.new("ProximityPrompt"); pp.ActionText="Open archive"; pp.ObjectText="NSSDCA terminal"
pp.KeyboardKeyCode=Enum.KeyCode.E; pp.HoldDuration=0.25; pp.MaxActivationDistance=10; pp.RequiresLineOfSight=false; pp.Parent=a
return "archive installed at ("..X..","..string.format("%.1f",gy)..","..Z..")"
'''.replace("MODSRC", mod).replace("CLISRC", cli).replace("SRVSRC", srv)
p = subprocess.Popen(["/Applications/RobloxStudio.app/Contents/MacOS/StudioMCP"], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True, bufsize=1)
resp = {}
def rd():
    for line in p.stdout:
        try: d = json.loads(line)
        except Exception: continue
        if "id" in d: resp[d["id"]] = d
threading.Thread(target=rd, daemon=True).start()
def send(o): p.stdin.write(json.dumps(o) + "\n"); p.stdin.flush()
send({"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {"protocolVersion": "2024-11-05", "capabilities": {}, "clientInfo": {"name": "arch", "version": "1"}}})
time.sleep(2); send({"jsonrpc": "2.0", "method": "notifications/initialized"})
send({"jsonrpc": "2.0", "id": 5, "method": "tools/call", "params": {"name": "execute_luau", "arguments": {"studio_id": SID, "datamodel_type": "Edit", "code": code}}})
t0 = time.time()
while 5 not in resp and time.time() - t0 < 120: time.sleep(0.1)
r = resp.get(5); print(" ".join(c.get("text", "") for c in r["result"]["content"]) if r else "NO RESPONSE")
p.kill()

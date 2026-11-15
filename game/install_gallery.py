"""Build the replica gallery (every challenge-listed item) behind the spawn at Tranquility.
   python3 install_gallery.py <studio_id> [--test]   idempotent; --test builds it at y+0 without saving"""
import json, subprocess, threading, time, sys, os
HERE = os.path.dirname(os.path.abspath(__file__)); SID = sys.argv[1]
models = open(os.path.join(HERE, "build", "equipment_models.lua")).read()
code = "local B=(function()\n" + models + "\nend)()\n" + r'''
local site=workspace.Game.Tranquility
local old=site:FindFirstChild("Gallery"); if old then old:Destroy() end
local G=Instance.new("Folder"); G.Name="Gallery"; G.Parent=site
local rp=RaycastParams.new(); rp.FilterType=Enum.RaycastFilterType.Exclude; rp.FilterDescendantsInstances={G}
local function ground(x,z) local h=workspace:Raycast(Vector3.new(x,300,z),Vector3.new(0,-600,0),rp); return h and h.Position.Y or 0 end
local FACE=Vector3.new(0,0,34)        -- every exhibit faces the spawn point
local function sign(parent,cf,title,line)
  local s=Instance.new("Part"); s.Name="Label"; s.Anchored=true; s.CanCollide=true; s.Size=Vector3.new(6,1.6,0.2)
  s.CFrame=cf; s.Color=Color3.fromRGB(14,14,16); s.Material=Enum.Material.SmoothPlastic; s.Parent=parent
  local g=Instance.new("SurfaceGui"); g.Face=Enum.NormalId.Front; g.CanvasSize=Vector2.new(600,160); g.LightInfluence=0; g.Parent=s
  local function t(txt,y,h,font,col) local l=Instance.new("TextLabel"); l.Size=UDim2.new(1,-24,0,h); l.Position=UDim2.fromOffset(12,y)
    l.BackgroundTransparency=1; l.Font=font; l.TextScaled=true; l.TextColor3=col; l.TextXAlignment=Enum.TextXAlignment.Left; l.Text=txt; l.Parent=g end
  t(title,10,54,Enum.Font.GothamBold,Color3.fromRGB(245,231,60))
  t(line,74,40,Enum.Font.Gotham,Color3.fromRGB(215,215,220))
  t("REPLICA, true scale · press E to read its NSSDCA card",120,30,Enum.Font.GothamMedium,Color3.fromRGB(150,205,255))
end
local EX={
  {"surveyor3","Surveyor 3",       -62,58, 12,12, "Real one: Oceanus Procellarum, Moon"},
  {"viking1",  "Viking 1 & 2 Landers",-38,58, 10,10, "Real ones: Chryse and Utopia Planitia, Mars"},
  {"pathfinder","Pathfinder + Sojourner",-12,58, 13,13, "Real one: Ares Vallis, Mars"},
  {"spirit",   "Spirit (twin of Opportunity)",14,58, 10,10, "Real one: Gusev Crater, Mars"},
  {"phoenix",  "Phoenix",          40,58, 15,9,  "Real one: northern polar plains, Mars"},
  {"insight",  "InSight",          68,58, 17,11, "Real one: Elysium Planitia, Mars"},
  {"ingenuity","Ingenuity",         90,58, 5,5,  "Real one: Jezero Crater, Mars"},
  {"near",     "NEAR Shoemaker",   -38,86, 10,9,  "Real one: on asteroid 433 Eros"},
  {"kepler",   "Kepler",           -12,86, 9,9,   "Real one: orbiting the Sun, trailing Earth"},
  {"pioneer10","Pioneer 10 & 11",   14,86, 10,10, "Real ones: leaving the solar system"},
}
local BUILD={surveyor3=B.surveyor3,viking1=B.viking,pathfinder=B.pathfinder,phoenix=B.phoenix,insight=B.insight,
  ingenuity=B.ingenuity,near=B.near,kepler=B.kepler,pioneer10=B.pioneer}
local n=0
for _,e in ipairs(EX) do
  local id,title,x,z,w,d,line=e[1],e[2],e[3],e[4],e[5],e[6],e[7]
  local gy=ground(x,z)
  local h=(id=="ingenuity") and 2.6 or 0.8
  local face=CFrame.lookAt(Vector3.new(x,gy,z),Vector3.new(FACE.X,gy,FACE.Z))
  local ex=Instance.new("Model"); ex.Name="Exhibit_"..id; ex.Parent=G
  local pl=Instance.new("Part"); pl.Name="Plinth"; pl.Anchored=true; pl.Size=Vector3.new(w,h,d); pl.CFrame=face*CFrame.new(0,h/2,0)
  pl.Color=Color3.fromRGB(46,46,50); pl.Material=Enum.Material.Concrete; pl.Parent=ex
  local top=face*CFrame.new(0,h,0)
  if id=="spirit" then
    local src=workspace:FindFirstChild("Library") and workspace.Library:FindFirstChild("ROVER")
    if src then local r=src:Clone(); r.Name="Spirit"; r.Parent=ex
      r:PivotTo(top*CFrame.Angles(0,math.rad(180),0))
      local cf,sz=r:GetBoundingBox()
      r:PivotTo(r:GetPivot()+Vector3.new(top.Position.X-cf.Position.X, top.Position.Y-(cf.Position.Y-sz.Y/2), top.Position.Z-cf.Position.Z))
      for _,d in ipairs(r:GetDescendants()) do if d:IsA("BasePart") then d.Anchored=true; d.CanCollide=true end end end
  else
    local mdl=BUILD[id](top,ex)
  end
  sign(ex,face*CFrame.new(0,1.0,-(d/2+1.2))*CFrame.Angles(math.rad(-15),0,0),title,line)
  local a=Instance.new("Part"); a.Name="Anchor"; a.Anchored=true; a.CanCollide=false; a.Transparency=1; a.Size=Vector3.new(1,1,1)
  a.CFrame=face*CFrame.new(0,2.5,-(d/2+0.6)); a.Parent=ex
  local pp=Instance.new("ProximityPrompt"); pp.ActionText="Read card"; pp.ObjectText=title; pp.HoldDuration=0.25; pp.MaxActivationDistance=12
  pp.RequiresLineOfSight=false; pp:SetAttribute("ArchiveId",id); pp.Parent=a
  n+=1
end
-- Dawn hangs over the gallery on cables
local dz,dx=72,0; local gy=ground(dx,dz)
local hang=CFrame.new(dx,gy+20,dz)*CFrame.Angles(0,math.rad(8),math.rad(-6))
local dawn=B.dawn(hang,G); dawn.Name="Exhibit_dawn"
for _,sx in ipairs({-9,9}) do
  local c=Instance.new("Part"); c.Name="Cable"; c.Anchored=true; c.CanCollide=false; c.Size=Vector3.new(0.12,40,0.12)
  c.CFrame=CFrame.new(dx+sx,gy+40,dz); c.Color=Color3.fromRGB(160,160,160); c.Material=Enum.Material.Metal; c.Parent=dawn
end
local da=Instance.new("Part"); da.Name="Anchor"; da.Anchored=true; da.CanCollide=false; da.Transparency=1; da.Size=Vector3.new(1,1,1)
da.CFrame=CFrame.new(dx,gy+2.5,dz); da.Parent=dawn
local dp=Instance.new("ProximityPrompt"); dp.ActionText="Read card"; dp.ObjectText="Dawn (overhead)"; dp.HoldDuration=0.25; dp.MaxActivationDistance=14
dp.RequiresLineOfSight=false; dp:SetAttribute("ArchiveId","dawn"); dp.Parent=da
local cnt=0; for _,d in ipairs(G:GetDescendants()) do if d:IsA("BasePart") then cnt+=1 end end
return "gallery: "..(n+1).." exhibits, "..cnt.." parts"
'''
p = subprocess.Popen(["/Applications/RobloxStudio.app/Contents/MacOS/StudioMCP"], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True, bufsize=1)
resp = {}
def rd():
    for line in p.stdout:
        try: d = json.loads(line)
        except Exception: continue
        if "id" in d: resp[d["id"]] = d
threading.Thread(target=rd, daemon=True).start()
def send(o): p.stdin.write(json.dumps(o) + "\n"); p.stdin.flush()
send({"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {"protocolVersion": "2024-11-05", "capabilities": {}, "clientInfo": {"name": "gal", "version": "1"}}})
time.sleep(2); send({"jsonrpc": "2.0", "method": "notifications/initialized"})
send({"jsonrpc": "2.0", "id": 5, "method": "tools/call", "params": {"name": "execute_luau", "arguments": {"studio_id": SID, "datamodel_type": "Edit", "code": code}}})
t0 = time.time()
while 5 not in resp and time.time() - t0 < 180: time.sleep(0.1)
r = resp.get(5); print(" ".join(c.get("text", "") for c in r["result"]["content"]) if r else "NO RESPONSE")
p.kill()

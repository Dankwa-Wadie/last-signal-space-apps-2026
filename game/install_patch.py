"""Install the gap-closing patch into the open LAST SIGNAL place (Edit mode).
   python3 install_patch.py <studio_id> [--site-only|--scripts-only]
   Idempotent. Covers: touch controls, LocalKey plumbing, the Handover finale,
   the Procellarum site (Surveyor 3 + Apollo 12 ALSEP), Archive silhouettes."""
import json, subprocess, threading, time, sys, os
HERE = os.path.dirname(os.path.abspath(__file__))
SID = sys.argv[1]
ONLY = sys.argv[2] if len(sys.argv) > 2 else ""

def S(name): return open(os.path.join(HERE, "scripts", name)).read()

SCRIPTS = [
    ("ModuleScript","ServerScriptService",  "Progress",      S("ServerScriptService__Progress.module.lua")),
    ("Script",      "ServerScriptService",  "ArchiveServer", S("ServerScriptService__ArchiveServer.server.lua")),
    ("Script",      "ServerScriptService",  "FinaleServer",  S("ServerScriptService__FinaleServer.server.lua")),
    ("Script",      "ServerScriptService",  "ConsoleServer", S("ServerScriptService__ConsoleServer.server.lua")),
    ("Script",      "ServerScriptService",  "SurveyServer",  S("ServerScriptService__SurveyServer.server.lua")),
    ("Script",      "ServerScriptService",  "ReactivateServer", S("ServerScriptService__ReactivateServer.server.lua")),
    ("LocalScript", "StarterPlayerScripts", "Touch",         S("StarterPlayerScripts__StarterPlayerScripts.Touch.client.lua")),
    ("LocalScript", "StarterPlayerScripts", "Worlds",        S("StarterPlayerScripts__StarterPlayerScripts.Worlds.client.lua")),
    ("LocalScript", "StarterPlayerScripts", "Sky",           S("StarterPlayerScripts__StarterPlayerScripts.Sky.client.lua")),
    ("LocalScript", "StarterPlayerScripts", "Map",           S("StarterPlayerScripts__StarterPlayerScripts.Map.client.lua")),
    ("LocalScript", "StarterPlayerScripts", "Intro",         S("StarterPlayerScripts__StarterPlayerScripts.Intro.client.lua")),
    ("LocalScript", "StarterPlayerScripts", "Survey",        S("StarterPlayerScripts__StarterPlayerScripts.Survey.client.lua")),
    ("LocalScript", "StarterPlayerScripts", "Helmet",        S("StarterPlayerScripts__StarterPlayerScripts.Helmet.client.lua")),
    ("LocalScript", "StarterPlayerScripts", "Reactivate",    S("StarterPlayerScripts__StarterPlayerScripts.Reactivate.client.lua")),
    ("LocalScript", "StarterPlayerScripts", "Archive",       S("StarterPlayerScripts__StarterPlayerScripts.Archive.client.lua")),
    ("ModuleScript","ReplicatedStorage",     "ArchiveCatalog",S("ReplicatedStorage__ArchiveCatalog.module.lua")),
    ("ModuleScript","ReplicatedStorage",     "ArtifactIndex", S("ReplicatedStorage__ArtifactIndex.module.lua")),
    ("ModuleScript","ReplicatedStorage",     "WorldLayout",   S("ReplicatedStorage__WorldLayout.module.lua")),
    ("ModuleScript","ReplicatedStorage",     "UIKit",         S("ReplicatedStorage__UIKit.module.lua")),
    ("LocalScript", "StarterPlayerScripts",  "MouseFree",     S("StarterPlayerScripts__StarterPlayerScripts.MouseFree.client.lua")),
    ("LocalScript", "StarterPlayerScripts",  "Sound",         S("StarterPlayerScripts__StarterPlayerScripts.Sound.client.lua")),
    ("LocalScript", "StarterPlayerScripts",  "RbxCharacterSounds", S("StarterPlayerScripts__StarterPlayerScripts.RbxCharacterSounds.client.lua")),
    ("LocalScript", "StarterPlayerScripts",  "Logbook",       S("StarterPlayerScripts__StarterPlayerScripts.Logbook.client.lua")),
    ("Script",      "ServerScriptService",  "StormServer",   S("ServerScriptService__StormServer.server.lua")),
    ("LocalScript", "StarterPlayerScripts",  "Storm",         S("StarterPlayerScripts__StarterPlayerScripts.Storm.client.lua")),
    ("LocalScript", "StarterPlayerScripts",  "Restyle",       S("StarterPlayerScripts__StarterPlayerScripts.Restyle.client.lua")),
    ("LocalScript", "StarterPlayerScripts",  "Guide",         S("StarterPlayerScripts__StarterPlayerScripts.Guide.client.lua")),
    ("LocalScript", "StarterPlayerScripts",  "Ground",        S("StarterPlayerScripts__StarterPlayerScripts.Ground.client.lua")),
    ("LocalScript", "StarterPlayerScripts",  "Trophy",        S("StarterPlayerScripts__StarterPlayerScripts.Trophy.client.lua")),
]

parts = []
# Remotes.LocalKey must exist before any client WaitForChild's it, so make it here too.
parts.append(r'''
local out={}
local RS=game:GetService("ReplicatedStorage")
local rem=RS:FindFirstChild("Remotes") or Instance.new("Folder")
rem.Name="Remotes"; rem.Parent=RS
local function ensure(cls,name)
  local o=rem:FindFirstChild(name)
  if o and o.ClassName~=cls then o:Destroy(); o=nil end
  if not o then o=Instance.new(cls); o.Name=name; o.Parent=rem end
end
ensure("BindableEvent","LocalKey")
ensure("RemoteEvent","PlaceMarker")
ensure("RemoteEvent","MarkerUpdate")
ensure("RemoteEvent","OpenConsole")
ensure("RemoteEvent","RequestTransit")
ensure("RemoteEvent","ArrivedAt")
ensure("RemoteEvent","Unclip")
ensure("BindableEvent","Catalogued")
ensure("BindableEvent","OpenMap")
ensure("BindableEvent","RadioBeep")
ensure("RemoteEvent","StormState")
table.insert(out,"remotes ok")
''')

if ONLY != "--site-only":
    for cls, where, name, src in SCRIPTS:
        host = ('game:GetService("ServerScriptService")' if where == "ServerScriptService"
                else 'game:GetService("ReplicatedStorage")' if where == "ReplicatedStorage"
                else 'game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")')
        parts.append(
            'do\n'
            f'  local host={host}\n'
            f'  local old=host:FindFirstChild("{name}"); if old then old:Destroy() end\n'
            f'  local s=Instance.new("{cls}"); s.Name="{name}"\n'
            '  s.Source=[=====[' + src + ']=====]\n'
            '  s.Parent=host\n'
            f'  table.insert(out,"script {name}")\n'
            'end\n')

if ONLY != "--scripts-only":
    for fn in ("procellarum.lua", "hadley.lua", "meridiani.lua", "aresvallis.lua", "mars_sites.lua", "farside.lua", "eros.lua", "station.lua", "remove_gallery.lua", "earth_sign.lua", "trophy_models.lua", "consoles.lua", "relocate.lua", "shelters.lua"):
        site = open(os.path.join(HERE, "build", fn)).read()
        site = site.replace("WORLD_LAYOUT", S("ReplicatedStorage__WorldLayout.module.lua"))
        site = site.replace("EQUIPMENT_MODELS", open(os.path.join(HERE, "build", "equipment_models.lua")).read())
        # each site file ends in `return "..."`; wrap it so its message joins the output
        parts.append("table.insert(out,(function()\n" + site + "\nend)())\n")

code = "\n".join(parts) + '\nreturn table.concat(out,"  |  ")\n'

p = subprocess.Popen(["/Applications/RobloxStudio.app/Contents/MacOS/StudioMCP"],
                     stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                     stderr=subprocess.DEVNULL, text=True, bufsize=1)
resp = {}
def rd():
    for line in p.stdout:
        try: d = json.loads(line)
        except Exception: continue
        if "id" in d: resp[d["id"]] = d
threading.Thread(target=rd, daemon=True).start()
def send(o): p.stdin.write(json.dumps(o) + "\n"); p.stdin.flush()
send({"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"patch","version":"1"}}})
time.sleep(2); send({"jsonrpc":"2.0","method":"notifications/initialized"})
send({"jsonrpc":"2.0","id":5,"method":"tools/call","params":{"name":"execute_luau","arguments":{"studio_id":SID,"datamodel_type":"Edit","code":code}}})
t0 = time.time()
while 5 not in resp and time.time()-t0 < 180: time.sleep(0.1)
r = resp.get(5)
print(" ".join(c.get("text","") for c in r["result"]["content"]) if r else "NO RESPONSE")
p.kill()

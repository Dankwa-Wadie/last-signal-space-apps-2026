"""Render the Roblox shots of the long film (beauty + matte where the sky is replaced).

  python3 render_long.py <studio_id>                 all roblox shots (skips finished ones)
  python3 render_long.py <studio_id> S05 S10         only these
  python3 render_long.py <studio_id> --test          2 beauty frames per shot -> test/

Run ONE copy at a time: two renderers share one Studio and wreck each other's scenes.
"""
import json, subprocess, threading, time, base64, os, sys
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from shots_long import SHOTS

SID = sys.argv[1]
TEST = "--test" in sys.argv
ONLY = [a for a in sys.argv[2:] if not a.startswith("--")] or None
OLD = os.path.join(HERE, "..", "scenes")
PRE = (open(os.path.join(OLD, "_prelude.lua")).read() + "\n" +
       open(os.path.join(HERE, "scenes", "_prelude_long.lua")).read())
FPRE = open(os.path.join(HERE, "scenes", "_frame_prelude.lua")).read()

MATTE = r'''
local s=workspace:FindFirstChild("Scene")
s:SetAttribute("Matte", true)
local L=game:GetService("Lighting")
for _,c in ipairs(L:GetChildren()) do
  if c:IsA("Atmosphere") then c.Density=0; c.Haze=0; c.Glare=0
  elseif c:IsA("PostEffect") then c.Enabled=false end
end
local cl=workspace.Terrain:FindFirstChildOfClass("Clouds"); if cl then cl.Enabled=false end
for _,d in ipairs(s:GetDescendants()) do
  if d:IsA("SurfaceAppearance") or d:IsA("Decal") or d:IsA("Texture") then d:Destroy()
  elseif d:IsA("BasePart") then
    d.Material=Enum.Material.Neon; d.Color=Color3.new(1,1,1); d.Reflectance=0
    if d:IsA("MeshPart") then pcall(function() d.TextureID="" end) end
  elseif d:IsA("Light") then d.Enabled=false end
end
-- terrain counts as "set" too: paint it white neon-ish by recolouring its materials
local T=workspace.Terrain
for _,m in ipairs({Enum.Material.Grass,Enum.Material.Ground,Enum.Material.Rock,Enum.Material.Sand}) do
  T:SetMaterialColor(m, Color3.new(1,1,1))
end
L.Brightness=10; L.Ambient=Color3.new(1,1,1); L.OutdoorAmbient=Color3.new(1,1,1)
return "matte on"
'''

RESTORE = r'''
local SS=game:GetService("ServerStorage"); local RS=game:GetService("ReplicatedStorage")
local L=game:GetService("Lighting")
local g=SS:FindFirstChild("Game"); if g then g.Parent=workspace end
local s=workspace:FindFirstChild("Scene"); if s then s:Destroy() end
workspace.Terrain:Clear()
local cl=workspace.Terrain:FindFirstChildOfClass("Clouds"); if cl then cl.Enabled=false end
for _,c in ipairs(L:GetChildren()) do if c:IsA("Atmosphere") then c:Destroy() end end
if not L:FindFirstChildOfClass("Sky") then
  local mw=RS:FindFirstChild("SkyLibrary") and RS.SkyLibrary:FindFirstChild("MilkyWay")
  if mw then mw:Clone().Parent=L end
end
for _,c in ipairs(L:GetChildren()) do if c:IsA("PostEffect") and c.Name~="DepthOfField" then c.Enabled=true end end
L.ColorShift_Top=Color3.new(0,0,0); L.ColorShift_Bottom=Color3.new(0,0,0)
L.ClockTime=16.5; L.GeographicLatitude=20; L.Brightness=4; L.ExposureCompensation=0.15
L.Ambient=Color3.fromRGB(16,16,20); L.OutdoorAmbient=Color3.fromRGB(16,16,20)
workspace.CurrentCamera.FieldOfView=50
return "game + sky restored"
'''

p = subprocess.Popen(["/Applications/RobloxStudio.app/Contents/MacOS/StudioMCP"],
                     stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, bufsize=1)
resp = {}
def reader():
    for line in p.stdout:
        try: d = json.loads(line)
        except Exception: continue
        if "id" in d: resp[d["id"]] = d
threading.Thread(target=reader, daemon=True).start()
def send(o): p.stdin.write(json.dumps(o) + "\n"); p.stdin.flush()
_id = [10]
def call(name, args, timeout=180):
    _id[0] += 1; mid = _id[0]
    send({"jsonrpc": "2.0", "id": mid, "method": "tools/call", "params": {"name": name, "arguments": args}})
    t0 = time.time()
    while mid not in resp:
        if time.time() - t0 > timeout: return None
        time.sleep(0.08)
    return resp.pop(mid)
def text(r):
    if not r or "result" not in r: return "NO-RESPONSE"
    return " ".join(c.get("text", "") for c in r["result"]["content"] if c.get("type") == "text")
def luau(code): return call("execute_luau", {"studio_id": SID, "datamodel_type": "Edit", "code": code})
def capture(tag, pos, tgt):
    res = call("screen_capture", {"studio_id": SID, "datamodel_type": "Edit", "capture_id": tag,
                                  "camera_position": pos, "look_at_position": tgt})
    if res and "result" in res:
        for c in res["result"]["content"]:
            if c.get("type") == "image": return base64.b64decode(c["data"])
    return None

send({"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {"protocolVersion": "2024-11-05",
      "capabilities": {}, "clientInfo": {"name": "long", "version": "1"}}})
time.sleep(2); send({"jsonrpc": "2.0", "method": "notifications/initialized"})

t_start = time.time()
os.makedirs(os.path.join(HERE, "test"), exist_ok=True)
try:
    for sh in SHOTS:
        if sh["kind"] != "roblox": continue
        if ONLY and sh["id"] not in ONLY: continue
        n = sh["n"]
        base = os.path.join(HERE, "roblox", sh["id"])
        passes = ["beauty"] + (["matte"] if sh.get("sky") in ("space", "night", "mars") else [])
        if not TEST and all(os.path.isdir(os.path.join(base, ps)) and len(os.listdir(os.path.join(base, ps))) >= n for ps in passes):
            print(f"[{sh['id']}] already complete, skipping", flush=True); continue
        cams = [dict(zip(("pos", "tgt"), sh["path"](i, n))) for i in range(n)]
        if not TEST:
            for ps in passes: os.makedirs(os.path.join(base, ps), exist_ok=True)
            json.dump({"fov": sh.get("fov", 50), "frames": cams}, open(os.path.join(base, "camera.json"), "w"))
        fcode = open(os.path.join(HERE, "scenes", sh["frame"] + ".lua")).read() if sh.get("frame") else None
        frames = [0, n // 2] if TEST else range(n)
        for ps in (["beauty"] if TEST else passes):
            r = luau(PRE + "\n" + open(os.path.join(HERE, "scenes", sh["scene"] + ".lua")).read())
            print(f"[{sh['id']}/{ps}] {sh['scene']} -> {text(r)[:120]}", flush=True)
            luau(f"workspace.CurrentCamera.FieldOfView={sh.get('fov', 50)}")
            if ps == "matte": print("  " + text(luau(MATTE)), flush=True)
            time.sleep(0.4); capture("warm", cams[0]["pos"], cams[0]["tgt"])
            last = -1
            for i in frames:
                if fcode:
                    # frame scripts are cumulative (tracks, animation): step through skipped frames
                    for j in range(last + 1, i + 1):
                        out = text(luau(f"local k={j}\nlocal n={n}\n" + FPRE + "\n" + fcode))
                        if out != "ok" and j == i: print(f"  frame script {j}: {out[:160]}", flush=True)
                last = i
                img = capture(f"{sh['id']}_{ps}_{i}", cams[i]["pos"], cams[i]["tgt"])
                if not img:
                    print(f"  !! {sh['id']}/{ps} frame {i} missing", flush=True); continue
                path = (os.path.join(HERE, "test", f"{sh['id']}_{i:04d}.jpg") if TEST
                        else os.path.join(base, ps, f"f{i:04d}.jpg"))
                open(path, "wb").write(img)
            print(f"  {sh['id']}/{ps}: done ({time.time()-t_start:.0f}s)", flush=True)
finally:
    print("restore:", text(luau(RESTORE)), flush=True)
    p.kill()
print("DONE", flush=True)

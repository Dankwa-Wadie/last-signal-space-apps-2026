"""Render the three Roblox shots for the v3 cut: a beauty pass and a matte pass each.

Writes roblox/<shot>/beauty/f0000.jpg, roblox/<shot>/matte/f0000.jpg and
roblox/<shot>/camera.json (position + look-at per frame, for sky ray-tracing).
Run ONE copy at a time: two renderers share one Studio and wreck each other's scenes.
"""
import json, subprocess, threading, time, base64, os, sys, math

HERE = os.path.dirname(os.path.abspath(__file__))
SCN = os.path.join(HERE, "..", "scenes")
SID = sys.argv[1]
ONLY = sys.argv[2:] or None
PRELUDE = open(os.path.join(SCN, "_prelude.lua")).read()

def _ease(t): return t * t * t * (t * (t * 6 - 15) + 10)

def path_mars(i, n):
    # low tracking shot beside Opportunity as it drives and stops
    STOP, DIST = 34, 6.0
    u = min(1.0, i / STOP); d = DIST * (1 - (1 - u) ** 2.2)
    fwd = (math.sin(math.radians(25)), 0.0, -math.cos(math.radians(25)))
    rover = [fwd[0] * d, 0.0, fwd[2] * d]
    e = _ease(i / (n - 1))
    off = [(-14.0) + (-1.5) * e, 2.6 + 0.9 * e, 11.5 + (-7.5) * e]
    return [rover[0] + off[0], off[1], rover[2] + off[2]], [rover[0], 2.9, rover[2]]

def path_retro(i, n):
    # slow orbit round the laser array, tilting up to the sky as the pulse returns
    e = _ease(i / (n - 1))
    ang = math.radians(-58 - 44 * e)          # orbit away from the sun line: stay on the lit side
    rad = 13.2 - 2.6 * e
    pos = [math.sin(ang) * rad, 4.8 - 1.2 * e, math.cos(ang) * rad]
    tilt = max(0.0, min(1.0, (i - 70) / 30.0))
    return pos, [0.0, 3.0 + 1.3 * _ease(tilt), 0.0]

def path_lander(i, n):
    # crane: start low along the bootprints, rise and tilt up to the descent stage
    e = _ease(i / (n - 1))
    pos = [2.4 - 1.0 * e, 1.4 + 3.8 * e, 46.0 - 10.0 * e]   # ends ~36 studs out: the whole 13-stud lander fits the 16:9 crop
    tgt = [0.4 - 0.4 * e, 1.6 + 4.9 * e, 26.0 - 26.0 * e]
    return pos, tgt

SHOTS = [
    {"name": "mars",   "scene": "s4_mars.lua",  "frames": 53,  "frame_code": "mars_frame.lua",  "path": path_mars},
    {"name": "retro",  "scene": "s6_retro_v3.lua", "frames": 125, "frame_code": "retro_frame.lua", "path": path_retro},
    {"name": "lander", "scene": "s2_boot_v3.lua",  "frames": 55,  "path": path_lander},
]

MATTE = r'''
-- matte pass: everything in the set is white Neon, sky dark, no effects
local s=workspace:FindFirstChild("Scene")
s:SetAttribute("Matte", true)          -- per-frame scripts check this
local L=game:GetService("Lighting")
for _,c in ipairs(L:GetChildren()) do
  if c:IsA("Atmosphere") then c.Density=0; c.Haze=0; c.Glare=0
  elseif c:IsA("PostEffect") then c.Enabled=false end
end
for _,d in ipairs(s:GetDescendants()) do
  if d:IsA("SurfaceAppearance") or d:IsA("Decal") or d:IsA("Texture") then d:Destroy()
  elseif d:IsA("BasePart") then
    d.Material=Enum.Material.Neon; d.Color=Color3.new(1,1,1); d.Reflectance=0
    if d:IsA("MeshPart") then pcall(function() d.TextureID="" end) end
    if d.Name=="Beam" then d.Color=Color3.new(1,1,1) end
  elseif d:IsA("Light") then d.Enabled=false end
end
return "matte on"
'''

RESTORE = r'''
local SS=game:GetService("ServerStorage")
local g=SS:FindFirstChild("Game"); if g then g.Parent=workspace end
local s=workspace:FindFirstChild("Scene"); if s then s:Destroy() end
return "game restored"
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
def call(name, args, timeout=120):
    _id[0] += 1; mid = _id[0]
    send({"jsonrpc": "2.0", "id": mid, "method": "tools/call", "params": {"name": name, "arguments": args}})
    t0 = time.time()
    while mid not in resp:
        if time.time() - t0 > timeout: return None
        time.sleep(0.1)
    return resp.pop(mid)
def text(r):
    if not r or "result" not in r: return "NO-RESPONSE"
    return " ".join(c.get("text", "") for c in r["result"]["content"] if c.get("type") == "text")
def luau(code): return call("execute_luau", {"studio_id": SID, "datamodel_type": "Edit", "code": code})

send({"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {"protocolVersion": "2024-11-05",
      "capabilities": {}, "clientInfo": {"name": "v3", "version": "1"}}})
time.sleep(2); send({"jsonrpc": "2.0", "method": "notifications/initialized"})

def ease(t): return t * t * t * (t * (t * 6 - 15) + 10)
def lerp(a, b, u): return [a[i] + (b[i] - a[i]) * u for i in range(3)]

fov = text(luau("return tostring(workspace.CurrentCamera.FieldOfView)"))
print("camera FOV", fov, flush=True)
t_start = time.time()
try:
    for sh in SHOTS:
        if ONLY and sh["name"] not in ONLY: continue
        base = os.path.join(HERE, "roblox", sh["name"])
        for sub in ("beauty", "matte"): os.makedirs(os.path.join(base, sub), exist_ok=True)
        fc = open(os.path.join(HERE, sh["frame_code"])).read() if sh.get("frame_code") else None
        n = sh["frames"]
        cams = []
        for i in range(n):
            pos, tgt = sh["path"](i, n)
            cams.append({"pos": pos, "tgt": tgt})
        json.dump({"fov": float(fov), "frames": cams}, open(os.path.join(base, "camera.json"), "w"))
        for pas in ("beauty", "matte"):
            r = luau(PRELUDE + "\n" + open(os.path.join(SCN, sh["scene"])).read())
            print(f"[{sh['name']}/{pas}] setup -> {text(r)}", flush=True)
            if pas == "matte":
                print(f"  {text(luau(MATTE))}", flush=True)
            # warm-up capture: Studio applies material/texture changes a frame late,
            # so the first real frame would otherwise still show textures in the matte
            time.sleep(0.4)
            call("screen_capture", {"studio_id": SID, "datamodel_type": "Edit", "capture_id": f"warm_{sh['name']}_{pas}",
                 "camera_position": cams[0]["pos"], "look_at_position": cams[0]["tgt"]})
            for i, c in enumerate(cams):
                if fc: luau(f"local k={i}\n" + fc)
                res = call("screen_capture", {"studio_id": SID, "datamodel_type": "Edit",
                           "capture_id": f"{sh['name']}_{pas}_{i:04d}",
                           "camera_position": c["pos"], "look_at_position": c["tgt"]})
                img = None
                if res and "result" in res:
                    for cc in res["result"]["content"]:
                        if cc.get("type") == "image": img = cc["data"]
                if img:
                    open(os.path.join(base, pas, f"f{i:04d}.jpg"), "wb").write(base64.b64decode(img))
                else:
                    print(f"  !! {sh['name']}/{pas} frame {i} missing", flush=True)
            print(f"  {sh['name']}/{pas}: {n} frames  ({time.time()-t_start:.0f}s)", flush=True)
finally:
    print("restore:", text(luau(RESTORE)), flush=True)
    p.kill()
print("DONE", flush=True)

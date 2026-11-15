"""Render the end-card key art (one beauty + one matte frame) to roblox/K33/.
   python3 keyart.py <studio_id>"""
import json, subprocess, threading, time, base64, os, sys
HERE = os.path.dirname(os.path.abspath(__file__))
SID = sys.argv[1]
OUT = sys.argv[2] if len(sys.argv) > 2 else "K33"
VIEWS = {   # camera pulled back and pitched up so the horizon sits low and the sky holds the words
  "K33":  ({"pos": [22, 2.3, 36], "tgt": [-4, 9.8, -8]}, 70),     # 16:9: horizon ~72% down
  "K33v": ({"pos": [24, 2.3, 38], "tgt": [-3, 27.0, -8]}, 70),    # 4:5:  horizon ~86% down
}
PRE = (open(os.path.join(HERE, "..", "scenes", "_prelude.lua")).read() + "\n" +
       open(os.path.join(HERE, "scenes", "_prelude_long.lua")).read())
src = open(os.path.join(HERE, "render_long.py")).read()
MATTE = src.split("MATTE = r'''")[1].split("'''")[0]
RESTORE = src.split("RESTORE = r'''")[1].split("'''")[0]
CAM, FOV = VIEWS[OUT]
p = subprocess.Popen(["/Applications/RobloxStudio.app/Contents/MacOS/StudioMCP"], stdin=subprocess.PIPE,
                     stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True, bufsize=1)
resp = {}
def rd():
    for line in p.stdout:
        try: d = json.loads(line)
        except Exception: continue
        if "id" in d: resp[d["id"]] = d
threading.Thread(target=rd, daemon=True).start()
def send(o): p.stdin.write(json.dumps(o) + "\n"); p.stdin.flush()
_id = [10]
def call(name, args, timeout=180):
    _id[0] += 1; mid = _id[0]
    send({"jsonrpc": "2.0", "id": mid, "method": "tools/call", "params": {"name": name, "arguments": args}})
    t0 = time.time()
    while mid not in resp and time.time() - t0 < timeout: time.sleep(0.08)
    return resp.pop(mid, None)
def luau(c): return call("execute_luau", {"studio_id": SID, "datamodel_type": "Edit", "code": c})
def cap(tag):
    r = call("screen_capture", {"studio_id": SID, "datamodel_type": "Edit", "capture_id": tag,
                                "camera_position": CAM["pos"], "look_at_position": CAM["tgt"]})
    for c in (r or {}).get("result", {}).get("content", []):
        if c.get("type") == "image": return base64.b64decode(c["data"])
send({"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {"protocolVersion": "2024-11-05", "capabilities": {}, "clientInfo": {"name": "k", "version": "1"}}})
time.sleep(2); send({"jsonrpc": "2.0", "method": "notifications/initialized"})
base = os.path.join(HERE, "roblox", OUT)
for ps in ("beauty", "matte"): os.makedirs(os.path.join(base, ps), exist_ok=True)
json.dump({"fov": FOV, "frames": [CAM]}, open(os.path.join(base, "camera.json"), "w"))
try:
    for ps in ("beauty", "matte"):
        luau(PRE + "\n" + open(os.path.join(HERE, "scenes", "L33_keyart.lua")).read())
        luau(f"workspace.CurrentCamera.FieldOfView={FOV}")
        if ps == "matte": luau(MATTE)
        time.sleep(0.5); cap("warm")
        img = cap("k_" + ps)
        open(os.path.join(base, ps, "f0000.jpg"), "wb").write(img)
        print(ps, "ok", len(img))
finally:
    luau(RESTORE); p.kill()

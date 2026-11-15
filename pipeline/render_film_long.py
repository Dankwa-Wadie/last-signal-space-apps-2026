import json, subprocess, threading, time, base64, os, math, sys

ROOT = "/Users/dankwawadie/projects/NASA_hack/pipeline"
os.chdir(ROOT)

SC = "scenes_long"
OUT = os.environ.get("OUT", "frames_long_roblox")
os.makedirs(OUT, exist_ok=True)
PRELUDE = open(os.path.join(SC, "_prelude.lua")).read()

p = subprocess.Popen(
    ["/Applications/RobloxStudio.app/Contents/MacOS/StudioMCP"],
    stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, bufsize=1
)

resp = {}
def reader():
    for line in p.stdout:
        try:
            d = json.loads(line)
        except:
            continue
        if "id" in d:
            resp[d["id"]] = d

threading.Thread(target=reader, daemon=True).start()

def send(o):
    p.stdin.write(json.dumps(o) + "\n")
    p.stdin.flush()

_id = [10]
def call(name, args, timeout=120):
    _id[0] += 1
    mid = _id[0]
    send({"jsonrpc": "2.0", "id": mid, "method": "tools/call", "params": {"name": name, "arguments": args}})
    t0 = time.time()
    while mid not in resp:
        if time.time() - t0 > timeout:
            return None
        time.sleep(0.12)
    return resp.pop(mid)

# Initialize MCP
send({"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {"protocolVersion": "2024-11-05", "capabilities": {}, "clientInfo": {"name": "render_long", "version": "1"}}})
time.sleep(1.5)
send({"jsonrpc": "2.0", "method": "notifications/initialized"})

# Dynamically discover active studio_id
res_studios = call("list_roblox_studios", {})
SID = None
if res_studios and "result" in res_studios:
    try:
        raw_text = res_studios["result"]["content"][0]["text"]
        s_data = json.loads(raw_text)
        if s_data.get("studios"):
            SID = s_data["studios"][0]["id"]
            print(f"Connected to Studio ID: {SID} ({s_data['studios'][0].get('name')})")
    except Exception as e:
        print("Error parsing studio ID:", e)

if not SID:
    SID = "09a55dbd-afe4-48d4-a8d0-0dbbfe281f3f"
    print(f"Fallback to Studio ID: {SID}")

def luau(code):
    return call("execute_luau", {"studio_id": SID, "datamodel_type": "Edit", "code": code})

def text_of(r):
    if not r or "result" not in r:
        return "NO-RESPONSE"
    return " ".join(c.get("text", "") for c in r["result"]["content"] if c.get("type") == "text")

def ease(t):
    return t * t * t * (t * (t * 6 - 15) + 10)

def lerp3(a, b, u):
    return [a[k] + (b[k] - a[k]) * u for k in range(3)]

shots = json.load(open(os.environ.get("SHOTS", "shots_long.json")))
only = sys.argv[1:] or None

gidx = 0
t0 = time.time()

for sh in shots:
    n = sh["frames"]
    if only and sh["name"] not in only:
        gidx += n
        continue

    setup = PRELUDE + "\n" + open(os.path.join(SC, sh["setup"])).read()
    r = luau(setup)
    print(f"[{sh['name']}] setup -> {text_of(r)}", flush=True)

    fc = None
    if sh.get("frame_code"):
        fc = open(os.path.join(SC, sh["frame_code"])).read()

    for i in range(n):
        u = ease(i / (n - 1)) if n > 1 else 0.0
        if sh["mode"] == "orbit":
            a = math.radians(sh["a0"] + (sh["a1"] - sh["a0"]) * u)
            cam = [math.sin(a) * sh["radius"], sh["height"], math.cos(a) * sh["radius"]]
            tgt = sh["tgt"]
        else:
            cam = lerp3(sh["camA"], sh["camB"], u)
            tgt = lerp3(sh["tgtA"], sh["tgtB"], u)

        if fc:
            luau(f"local u = {i / (n - 1) if n > 1 else 0.0}\n" + fc)

        res = call(
            "screen_capture",
            {
                "studio_id": SID,
                "datamodel_type": "Edit",
                "capture_id": f"{sh['name']}_{i:04d}",
                "camera_position": cam,
                "look_at_position": tgt,
            },
        )
        img = None
        if res and "result" in res:
            for c in res["result"]["content"]:
                if c.get("type") == "image":
                    img = c["data"]

        if img:
            open(os.path.join(OUT, f"{sh['name']}_{i:04d}.jpg"), "wb").write(base64.b64decode(img))
        else:
            print(f"  !! {sh['name']} frame {i} missing", flush=True)

        gidx += 1
        if i % 50 == 0:
            print(f"  {sh['name']} {i}/{n} (total frames rendered: {gidx}) [{time.time()-t0:.0f}s]", flush=True)

# Restore game back to workspace
restore = luau(
    'local SS=game:GetService("ServerStorage")\n'
    'local g=SS:FindFirstChild("Game")\n'
    "if g then g.Parent=workspace return 'game restored' end\n"
    "return 'nothing to restore'"
)
print("restore:", text_of(restore), flush=True)
print(f"DONE {gidx} frames rendered in {time.time()-t0:.0f}s", flush=True)
p.kill()


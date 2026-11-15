import json,subprocess,threading,time,base64,os,math,sys,atexit

SID="962a7448-1ed9-487d-b0d1-3d668585373f"
SC="scenes"; OUT=os.environ.get("OUT","film_frames")
os.makedirs(OUT,exist_ok=True)
PRELUDE=open(os.path.join(SC,"_prelude.lua")).read()

p=subprocess.Popen(["/Applications/RobloxStudio.app/Contents/MacOS/StudioMCP"],
    stdin=subprocess.PIPE,stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True,bufsize=1)
resp={}
def reader():
    for line in p.stdout:
        try: d=json.loads(line)
        except: continue
        if "id" in d: resp[d["id"]]=d
threading.Thread(target=reader,daemon=True).start()
def send(o): p.stdin.write(json.dumps(o)+"\n"); p.stdin.flush()
_id=[10]
def call(name,args,timeout=120):
    _id[0]+=1; mid=_id[0]
    send({"jsonrpc":"2.0","id":mid,"method":"tools/call","params":{"name":name,"arguments":args}})
    t0=time.time()
    while mid not in resp:
        if time.time()-t0>timeout: return None
        time.sleep(0.12)
    return resp.pop(mid)
def luau(code):
    return call("execute_luau",{"studio_id":SID,"datamodel_type":"Edit","code":code})
def text_of(r):
    if not r or "result" not in r: return "NO-RESPONSE"
    return " ".join(c.get("text","") for c in r["result"]["content"] if c.get("type")=="text")

send({"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05",
     "capabilities":{},"clientInfo":{"name":"film","version":"1"}}})
time.sleep(2); send({"jsonrpc":"2.0","method":"notifications/initialized"})

def restore_game():
    try:
        r=luau("local SS=game:GetService(\"ServerStorage\")\n"
                "local g=SS:FindFirstChild(\"Game\")\n"
                "if g then g.Parent=workspace return \"game restored\" end\n"
                "return \"nothing to restore\"")
        print("restore:",text_of(r),flush=True)
    except Exception as e:
        print("restore failed:",e,file=sys.stderr,flush=True)


def close_bridge():
    if p.poll() is None:
        p.kill()

atexit.register(close_bridge)
atexit.register(restore_game)

def ease(t): return t*t*t*(t*(t*6-15)+10)
def lerp3(a,b,u): return [a[k]+(b[k]-a[k])*u for k in range(3)]

shots=json.load(open(os.environ.get("SHOTS","shots.json")))
only=sys.argv[1:] or None
gidx=0; t0=time.time()
for sh in shots:
    n=sh["frames"]
    if only and sh["name"] not in only:
        gidx+=n; continue
    setup=PRELUDE+"\n"+open(os.path.join(SC,sh["setup"])).read()
    r=luau(setup)
    print(f"[{sh['name']}] setup -> {text_of(r)}",flush=True)
    fc=None
    if sh.get("frame_code"):
        fc=open(os.path.join(SC,sh["frame_code"])).read()
    for i in range(n):
        u=ease(i/(n-1)) if n>1 else 0.0
        if sh["mode"]=="orbit":
            a=math.radians(sh["a0"]+(sh["a1"]-sh["a0"])*u)
            cam=[math.sin(a)*sh["radius"],sh["height"],math.cos(a)*sh["radius"]]
            tgt=sh["tgt"]
        else:
            cam=lerp3(sh["camA"],sh["camB"],u)
            tgt=lerp3(sh["tgtA"],sh["tgtB"],u)
        if fc:
            luau(f"local u={i/(n-1) if n>1 else 0.0}\n"+fc)
        res=call("screen_capture",{"studio_id":SID,"datamodel_type":"Edit",
            "capture_id":f"{sh['name']}_{i:04d}","camera_position":cam,"look_at_position":tgt})
        img=None
        if res and "result" in res:
            for c in res["result"]["content"]:
                if c.get("type")=="image": img=c["data"]
        if img:
            open(os.path.join(OUT,f"g{gidx:05d}.jpg"),"wb").write(base64.b64decode(img))
        else:
            print(f"  !! {sh['name']} frame {i} missing",flush=True)
        gidx+=1
        if i%40==0: print(f"  {sh['name']} {i}/{n}  total {gidx}  {time.time()-t0:.0f}s",flush=True)
print(f"DONE {gidx} frames in {time.time()-t0:.0f}s",flush=True)
p.kill()

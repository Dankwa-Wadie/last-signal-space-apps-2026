import json,subprocess,threading,time,base64,os,math,sys

SID="962a7448-1ed9-487d-b0d1-3d668585373f"
N=int(sys.argv[1]) if len(sys.argv)>1 else 72
OUT="frames"

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
def call(mid,name,args,timeout=60):
    send({"jsonrpc":"2.0","id":mid,"method":"tools/call","params":{"name":name,"arguments":args}})
    t0=time.time()
    while mid not in resp:
        if time.time()-t0>timeout: return None
        time.sleep(0.15)
    return resp.pop(mid)

send({"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"render","version":"1"}}})
time.sleep(2); send({"jsonrpc":"2.0","method":"notifications/initialized"})

def ease(t):  # smootherstep
    return t*t*t*(t*(t*6-15)+10)

# slow push-in + slight orbit
A=(-42.0,11.0,48.0); B=(-19.0,6.2,23.0)
TA=(0.0,5.0,0.0);    TB=(0.0,5.6,0.0)

t0=time.time(); ok=0
for i in range(N):
    u=ease(i/(N-1))
    cam=[A[k]+(B[k]-A[k])*u for k in range(3)]
    # add gentle arc
    ang=math.radians(10*u)
    x,z=cam[0],cam[2]
    cam[0]=x*math.cos(ang)-z*math.sin(ang)
    cam[2]=x*math.sin(ang)+z*math.cos(ang)
    tgt=[TA[k]+(TB[k]-TA[k])*u for k in range(3)]
    r=call(100+i,"screen_capture",{"studio_id":SID,"datamodel_type":"Edit",
        "capture_id":f"f{i:04d}","camera_position":cam,"look_at_position":tgt},timeout=90)
    if not r or r.get("result",{}).get("isError"):
        print(f"frame {i} FAILED", flush=True); continue
    img=None
    for c in r["result"]["content"]:
        if c.get("type")=="image": img=c["data"]
    if not img:
        print(f"frame {i} no image", flush=True); continue
    open(os.path.join(OUT,f"f{i:04d}.jpg"),"wb").write(base64.b64decode(img))
    ok+=1
    if i%10==0: print(f"{i}/{N}  {time.time()-t0:.0f}s", flush=True)
print(f"DONE {ok}/{N} frames in {time.time()-t0:.0f}s", flush=True)
p.kill()

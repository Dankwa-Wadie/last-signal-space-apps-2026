"""Run a Lua test file inside the open place.  python3 run_tests.py <studio_id> [file] [Edit|Server]"""
import json, subprocess, threading, time, sys, os
HERE=os.path.dirname(os.path.abspath(__file__)); SID=sys.argv[1]
f=sys.argv[2] if len(sys.argv)>2 else os.path.join(HERE,"tests","rules_tests.lua")
dm=sys.argv[3] if len(sys.argv)>3 else "Server"
code=open(f).read()
p=subprocess.Popen(["/Applications/RobloxStudio.app/Contents/MacOS/StudioMCP"],stdin=subprocess.PIPE,
    stdout=subprocess.PIPE,stderr=subprocess.DEVNULL,text=True,bufsize=1)
resp={}
def rd():
    for line in p.stdout:
        try: d=json.loads(line)
        except Exception: continue
        if "id" in d: resp[d["id"]]=d
threading.Thread(target=rd,daemon=True).start()
def send(o): p.stdin.write(json.dumps(o)+"\n"); p.stdin.flush()
send({"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"t","version":"1"}}})
time.sleep(2); send({"jsonrpc":"2.0","method":"notifications/initialized"})
send({"jsonrpc":"2.0","id":5,"method":"tools/call","params":{"name":"execute_luau","arguments":{"studio_id":SID,"datamodel_type":dm,"code":code}}})
t0=time.time()
while 5 not in resp and time.time()-t0<180: time.sleep(0.1)
r=resp.get(5)
print(" ".join(c.get("text","") for c in r["result"]["content"]) if r else "NO RESPONSE")
p.kill()

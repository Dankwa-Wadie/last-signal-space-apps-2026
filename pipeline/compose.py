import json,subprocess,os,sys
lines=json.load(open("script.json"))
N=len(lines)
inputs=["-framerate","24","-i","film_frames/g%05d.jpg"]
for i in range(N):
    inputs += ["-i", f"caps/c{i:02d}.png"]

# base: fill-crop 1242x1080 -> 1080x1920, mild grade, slow fade in/out
fc = ("[0:v]scale=2209:1920:flags=lanczos,crop=1080:1920:(in_w-1080)/2:0,"
      "eq=contrast=1.07:saturation=1.04:gamma=1.02,"
      "fade=t=in:st=0:d=1.0,fade=t=out:st=59.0:d=1.0[b];")
cur="b"
for i,(s,e,txt) in enumerate(lines):
    nxt=f"v{i}"
    # NOTE: a still PNG has a single frame at t=0, so fade=...:alpha cannot be
    # keyed to the master clock - it just leaves the plate fully transparent.
    # Hard cuts are what the reference format uses anyway.
    fc += f"[{i+1}:v]format=rgba[c{i}];"
    fc += f"[{cur}][c{i}]overlay=0:0:enable='between(t,{s},{e})'[{nxt}];"
    cur=nxt
fc += f"[{cur}]format=yuv420p[out]"

cmd=["ffmpeg","-y"]+inputs+["-filter_complex",fc,"-map","[out]",
     "-c:v","libx264","-crf","18","-preset","slow","-r","24",
     "-movflags","+faststart","abandoned_but_not_forgotten.mp4"]
print("running ffmpeg with",N,"caption plates",flush=True)
r=subprocess.run(cmd,capture_output=True,text=True)
if r.returncode!=0:
    print(r.stderr[-2500:]); sys.exit(1)
print("OK")

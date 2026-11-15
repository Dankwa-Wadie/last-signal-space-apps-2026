import json, subprocess, os, sys

HERE = os.path.dirname(os.path.abspath(__file__))
os.chdir(HERE)

lines = json.load(open("script_30s.json"))
N = len(lines)

def build_composite(is_tall=False):
    out_name = "last_signal_submission_4x5.mp4" if is_tall else "last_signal_submission_16x9.mp4"
    caps_dir = "caps_30s_4x5" if is_tall else "caps_30s_16x9"

    inputs = [
        "-framerate", "24",
        "-i", "master_frames_16x9/frame_%05d.jpg",
        "-i", "voiceover_trimmed.mp3"
    ]
    for i in range(N):
        inputs += ["-i", f"{caps_dir}/c{i:02d}.png"]

    # Filter complex
    if not is_tall:
        # 16:9 (1920x1080)
        fc = (
            "[0:v]scale=1920:1080:flags=lanczos,"
            "eq=contrast=1.05:saturation=1.05:gamma=1.01,"
            "fade=t=in:st=0:d=0.5,fade=t=out:st=22.2:d=0.8[b];"
        )
    else:
        # 4:5 (1080x1350)
        # Center-crop 1920x1080 to 864x1080 and scale to 1080x1350 (or pad with dark blur)
        fc = (
            "[0:v]scale=2400:1350:flags=lanczos,crop=1080:1350:(in_w-1080)/2:0,"
            "eq=contrast=1.05:saturation=1.05:gamma=1.01,"
            "fade=t=in:st=0:d=0.5,fade=t=out:st=22.2:d=0.8[b];"
        )

    cur = "b"
    # Audio input is index 1, caption plates start at index 2
    for i, (s, e, txt) in enumerate(lines):
        nxt = f"v{i}"
        cap_idx = 2 + i
        fc += f"[{cap_idx}:v]format=rgba[c{i}];"
        fc += f"[{cur}][c{i}]overlay=0:0:enable='between(t,{s},{e})'[{nxt}];"
        cur = nxt

    fc += f"[{cur}]format=yuv420p[v_out];"
    # Audio with mild fade out at end
    fc += "[1:a]afade=t=in:st=0:d=0.3,afade=t=out:st=21.0:d=1.5[a_out]"

    cmd = [
        "ffmpeg", "-y",
        *inputs,
        "-filter_complex", fc,
        "-map", "[v_out]",
        "-map", "[a_out]",
        "-c:v", "libx264", "-crf", "18", "-preset", "medium", "-r", "24",
        "-c:a", "aac", "-b:a", "192k",
        "-t", "23.0",
        "-movflags", "+faststart",
        out_name
    ]

    print(f"Building {out_name} with {N} caption plates...")
    r = subprocess.run(cmd, capture_output=True, text=True)
    if r.returncode != 0:
        print("ERROR:", r.stderr[-2000:])
        return False
    print(f"SUCCESS: {out_name} created!")
    return True

# Build both versions and fail the command if either encode fails.
ok_wide=build_composite(is_tall=False)
ok_tall=build_composite(is_tall=True)
if not (ok_wide and ok_tall):
    sys.exit(1)


import json, subprocess, os, sys

ROOT = "/Users/dankwawadie/projects/NASA_hack/pipeline"
os.chdir(ROOT)

lines = json.load(open("script_long.json"))
N = len(lines)
TOTAL_DURATION = 184.9

def build_composite(is_tall=False):
    out_name = "last_signal_film_long_4x5.mp4" if is_tall else "last_signal_film_long_16x9.mp4"
    caps_dir = "caps_long_4x5" if is_tall else "caps_long_16x9"

    inputs = [
        "-framerate", "24",
        "-i", "master_frames_long/frame_%05d.jpg",
        "-i", "voiceover_long.mp3"
    ]
    for i in range(N):
        inputs += ["-i", f"{caps_dir}/c{i:03d}.png"]

    # Filter complex base
    if not is_tall:
        # 16:9 Landscape (1920x1080)
        fc = (
            "[0:v]scale=1920:1080:flags=lanczos,"
            "eq=contrast=1.05:saturation=1.05:gamma=1.01,"
            f"fade=t=in:st=0:d=0.8,fade=t=out:st={TOTAL_DURATION-1.2}:d=1.0[b];"
        )
    else:
        # 4:5 Portrait (1080x1350)
        fc = (
            "[0:v]scale=2400:1350:flags=lanczos,crop=1080:1350:(in_w-1080)/2:0,"
            "eq=contrast=1.05:saturation=1.05:gamma=1.01,"
            f"fade=t=in:st=0:d=0.8,fade=t=out:st={TOTAL_DURATION-1.2}:d=1.0[b];"
        )

    cur = "b"
    # Audio is input index 1, subtitle plates start at index 2
    for i, (s, e, txt) in enumerate(lines):
        nxt = f"v{i}"
        cap_idx = 2 + i
        fc += f"[{cap_idx}:v]format=rgba[c{i}];"
        fc += f"[{cur}][c{i}]overlay=0:0:enable='between(t,{s},{e})'[{nxt}];"
        cur = nxt

    fc += f"[{cur}]format=yuv420p[v_out];"
    # Audio with fade in and fade out
    fc += f"[1:a]afade=t=in:st=0:d=0.5,afade=t=out:st={TOTAL_DURATION-2.0}:d=1.8[a_out]"

    cmd = [
        "ffmpeg", "-y",
        *inputs,
        "-filter_complex", fc,
        "-map", "[v_out]",
        "-map", "[a_out]",
        "-c:v", "libx264", "-crf", "18", "-preset", "medium", "-r", "24",
        "-c:a", "aac", "-b:a", "192k",
        "-t", str(TOTAL_DURATION),
        "-movflags", "+faststart",
        out_name
    ]

    print(f"Building {out_name} with {N} caption plates (duration: {TOTAL_DURATION}s)...")
    r = subprocess.run(cmd, capture_output=True, text=True)
    if r.returncode != 0:
        print("ERROR:", r.stderr[-2500:])
        return False
    print(f"SUCCESS: {out_name} created cleanly!")
    return True

if __name__ == "__main__":
    only_mode = sys.argv[1] if len(sys.argv) > 1 else None
    if only_mode == "16x9":
        build_composite(is_tall=False)
    elif only_mode == "4x5":
        build_composite(is_tall=True)
    else:
        build_composite(is_tall=False)
        build_composite(is_tall=True)


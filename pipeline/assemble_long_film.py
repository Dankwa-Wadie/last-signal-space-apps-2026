import os, sys, shutil, json, glob

ROOT = "/Users/dankwawadie/projects/NASA_hack/pipeline"
os.chdir(ROOT)

MASTER_DIR = "master_frames_long"
os.makedirs(MASTER_DIR, exist_ok=True)

# List of shots in exact visual order with their expected frame counts
SHOT_ORDER = [
    ("long_b01", "frames_long_blender/long_b01_%04d.jpg", 232),
    ("long_s01_flag", "frames_long_roblox/long_s01_flag_%04d.jpg", 314),
    ("long_s02_liftoff", "frames_long_roblox/long_s02_liftoff_%04d.jpg", 212),
    ("long_s03_lm", "frames_long_roblox/long_s03_lm_%04d.jpg", 195),
    ("long_s04_seis", "frames_long_roblox/long_s04_seis_%04d.jpg", 556),
    ("long_s05_lrv", "frames_long_roblox/long_s05_lrv_%04d.jpg", 371),
    ("long_s06_mars", "frames_long_roblox/long_s06_mars_%04d.jpg", 675),
    ("long_s07_voyager", "frames_long_roblox/long_s07_voyager_%04d.jpg", 596),
    ("long_s08_retro", "frames_long_roblox/long_s08_retro_%04d.jpg", 965),
    ("long_s09_astronaut", "frames_long_roblox/long_s09_astronaut_%04d.jpg", 222),
    ("long_cta", "frames_long_cta_16x9/cta_%04d.jpg", 101),
]

def assemble():
    print("Assembling master sequence for long film...")
    master_idx = 0
    missing = []

    for shot_name, pattern, count in SHOT_ORDER:
        copied = 0
        for i in range(count):
            src = pattern % i
            if os.path.exists(src):
                dst = os.path.join(MASTER_DIR, f"frame_{master_idx:05d}.jpg")
                shutil.copyfile(src, dst)
                copied += 1
                master_idx += 1
            else:
                missing.append(src)
                master_idx += 1
        print(f"[{shot_name}] {copied}/{count} frames copied (total: {master_idx})")

    if missing:
        print(f"WARNING: {len(missing)} frames were missing (e.g. {missing[:3]})")
    else:
        print(f"SUCCESS: All {master_idx} frames assembled cleanly! Duration: {master_idx/24.0:.2f}s")

if __name__ == "__main__":
    assemble()


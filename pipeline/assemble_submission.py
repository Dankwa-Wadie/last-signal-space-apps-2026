import os, sys, shutil, json, subprocess, glob

ROOT = "/Users/dankwawadie/projects/NASA_hack/pipeline"
os.chdir(ROOT)

MASTER_16x9 = "master_frames_16x9"
MASTER_4x5  = "master_frames_4x5"
os.makedirs(MASTER_16x9, exist_ok=True)
os.makedirs(MASTER_4x5, exist_ok=True)

# 1. Collect all frames in order
print("Assembling frames into master sequences...")

idx = 0

# Shot 1: Blender Earth (77 frames)
s1_files = sorted(glob.glob("frames_30s_blender_16x9/s1_*.jpg"))
for p in s1_files:
    shutil.copy(p, os.path.join(MASTER_16x9, f"frame_{idx:05d}.jpg"))
    idx += 1
print(f"Shot 1: {len(s1_files)} frames -> total {idx}")

# Shot 2: Blender Vanguard 1 (91 frames)
s2_files = sorted(glob.glob("frames_30s_blender_16x9/s2_*.jpg"))
for p in s2_files:
    shutil.copy(p, os.path.join(MASTER_16x9, f"frame_{idx:05d}.jpg"))
    idx += 1
print(f"Shot 2: {len(s2_files)} frames -> total {idx}")

# Shot 3: Mars Opportunity (82 frames, g00000..g00081)
for i in range(82):
    p = f"frames_30s_roblox/g{i:05d}.jpg"
    if os.path.exists(p):
        shutil.copy(p, os.path.join(MASTER_16x9, f"frame_{idx:05d}.jpg"))
    idx += 1
print(f"Shot 3: 82 frames -> total {idx}")

# Shot 4: Apollo Retroreflector (98 frames, g00082..g00179)
for i in range(82, 82 + 98):
    p = f"frames_30s_roblox/g{i:05d}.jpg"
    if os.path.exists(p):
        shutil.copy(p, os.path.join(MASTER_16x9, f"frame_{idx:05d}.jpg"))
    idx += 1
print(f"Shot 4: 98 frames -> total {idx}")

# Shot 5: Moon Bootprints (60 frames, g00180..g00239)
for i in range(82 + 98, 82 + 98 + 60):
    p = f"frames_30s_roblox/g{i:05d}.jpg"
    if os.path.exists(p):
        shutil.copy(p, os.path.join(MASTER_16x9, f"frame_{idx:05d}.jpg"))
    idx += 1
print(f"Shot 5: 60 frames -> total {idx}")

# Shot 6: CTA End Screen (144 frames)
cta_files = sorted(glob.glob("frames_30s_cta_16x9/cta_*.jpg"))
for p in cta_files:
    shutil.copy(p, os.path.join(MASTER_16x9, f"frame_{idx:05d}.jpg"))
    idx += 1
print(f"Shot 6: {len(cta_files)} frames -> total {idx}")

total_frames = idx
print(f"TOTAL MASTER FRAMES: {total_frames} ({total_frames/24.0:.2f}s)")


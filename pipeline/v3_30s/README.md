# v3 30-second cut: "Last Signal"

Replaces Gemini's `last_signal_submission_*.mp4` (kept for comparison).

**Outputs:** `last_signal_v3_16x9.mp4` (1920x1080) and `last_signal_v3_4x5.mp4`
(1080x1350). Each is 24.0 s, 576 frames at 24 fps, with the voiceover.

## Shots (timed to the voiceover phrases, measured with ffmpeg silencedetect)

| Time | Shot | Source |
|---|---|---|
| 0.0–3.2 s | Earth, AutoCam push-in | Blender: BlenderKit "Planet Earth" on a smooth subdivided UV sphere |
| 3.2–7.0 s | Vanguard 1 on its real orbit, comet trail, live data panel, ×2,400 badge | Blender + compose |
| 7.0–9.2 s | Opportunity drives, slows, stops as a dust storm dims the light | Roblox + Martian sky |
| 9.2–14.4 s | Laser retroreflector: green beam out, 2.50 s real-time timer, return pulse | Roblox + starfield |
| 14.4–16.7 s | Crane from bootprints to the Apollo descent stage | Roblox + starfield |
| 16.7–24.0 s | Astrolog presents LAST SIGNAL, QR to the Roblox game | graphics |

## Re-run

```
python3 starfield.py                                   # sky_equirect.png, ~7 s
Blender -b blender/earth_v3.blend -S V3_30s_Earth --python blender_render.py -- 16x9
Blender -b blender/earth_v3.blend -S V3_30s_Earth --python blender_render.py -- 4x5
python3 render_roblox_v3.py <studio_id>                # ONE at a time; ~6 min
python3 compose.py 16x9 && python3 compose.py 4x5      # ~2 min each
python3 compose.py 16x9 250                            # single-frame preview
```

The Studio ID changes every time Studio reopens. Get it with `list_roblox_studios`.

## How the sky works
- `starfield.py` makes one 8192×4096 all-sky image (58,710 stars plus a Milky Way with dust lanes).
- Blender uses it as the world background.
- Every Roblox shot is rendered twice: once normally, and once as a **matte**, with every part
  turned white Neon against a dark sky. `compose.py` uses the matte as an alpha mask.
- Behind that mask it ray-traces the starfield from each frame's logged camera (Moon shots),
  or draws a Martian daytime sky graded by each pixel's elevation (Mars). The Mars sky dims as the storm builds.
- Per-frame Lua checks `Scene:GetAttribute("Matte")`. Anything that shows up later in the shot,
  like tracks or haze, would otherwise break the matte.

## Facts on screen (all checked)
- **Vanguard 1:** perigee 654 km, apogee 3,969 km. The period works out to 134.2 min, which
  matches the published figure. Speed runs from 8.22 km/s at perigee to 5.58 km/s at apogee.
  Silent since 1964. On screen it's a ×2,400 time-lapse, and the badge says so.
- **Opportunity:** last signal 10 June 2018, lost to a global dust storm that starved its solar panels.
- **Laser:** the Earth–Moon–Earth light time is about 2.5 s, and it runs at real speed on screen.
  The beam is green because the APOLLO observatory fires a 532 nm laser.

**Dramatised, so say so in the submission:**
- Opportunity's driving speed. The real rover topped out at about 5 cm/s.
- The visible laser beam. In vacuum a beam can't be seen from the side.
- The stars in the sky. Photos taken on the sunlit Moon show a black sky.

## AI tools used (Space Apps requires this disclosure)
- **Claude (Anthropic):** pipeline code, compositing, research and fact-checking.
- **Roblox `generate_mesh`:** the lander body, Opportunity, the lunar rover and Voyager models.
- **Voiceover:** an AI text-to-speech narration produced in an earlier session. Name the actual
  service used before you submit.

## Not AI-generated
The rest are assets, add-ons and code:
- BlenderKit "Planet Earth" material. The add-on's metadata says it's built from NASA imagery.
- The AutoCam Free add-on.
- The starfield, made procedurally in `starfield.py`.

## Gotchas found here
- `bmesh.ops.create_uvsphere(calc_uvs=True)` writes no UVs unless a UV layer exists first,
  and textures then sample a single pixel.
- Blender 5 removed `Action.fcurves`. These are slotted actions now.
- An orbit curve with zero emission still renders as a dark ring. Hide it instead.
- The AutoCam rig renames your path curve. Free mode only supports MANUAL aim (no lock-to-target),
  and its Inherit Timing step needs the source camera to be active.
- `SubtractAsync` geometry is **not saved** with the place. Use the hosted mesh and set `PlinthFraction`.
- Avenir has no `→` glyph; it renders as a box.

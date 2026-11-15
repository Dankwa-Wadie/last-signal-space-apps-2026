# Long cut (v4): "Last Signal"

This replaces Gemini's `last_signal_film_long_*.mp4`, which is kept for comparison.

**Outputs**
- `last_signal_long_v4_16x9.mp4`: 1920×1080
- `last_signal_long_v4_4x5.mp4`: 1080×1350

Both run 188.0 s at 24 fps: a 3 s music-only intro (`intro_pad.wav`, procedural) then `../voiceover_long.mp3`,
with burned-in English subtitles. Table times below are narration times; add 3 s for film time.
Every shot is cut to the narrator's word timings. Shot times are in `shots_long.py`, which
reads them from `../transcription_long.json`.

## What's on screen, line by line

| Time | Narration | Shot |
|---|---|---|
| −3–0 | (music only) | the solar system, sweeping in to Earth; planets labelled, "not to scale" (Blender) |
| 0–2.6 | "never been good at staying still" | Earth from space (Blender, BlenderKit Earth) |
| 2.6–6.2 | "sailed every ocean, walked every desert" | a crewed brig under sail (sailors on deck, at the wheel, in the crow's nest); explorers crossing dunes |
| 6.2–9.6 | "nowhere left… we looked up at the stars" | a person at the Giza pyramids at night, camera tilts up to the sky |
| 9.6–13.1 | Apollo 11 lands | the landing |
| 13.1–14.6 | "They stayed for 21 hours" | inside the Eagle: both crew standing at the triangular windows (the LM had no seats) |
| 14.6–17 | "planted a flag, collected bags of moon rocks" | flag behind; in front an astronaut picks up a rock with the sample tongs and bags it |
| 17–19.6 | "footprints in the dust" | close-up of a bootprint in lunar dust (procedural height field) |
| 19.6–28.2 | "couldn't take everything" | astronauts leave; the descent stage |
| 28.2–29.7 | "When it was time to leave" | the commander climbs the ladder to the hatch |
| 29.7–35.9 | "only the top cabin blasted into space" | liftoff as in the real films: foil burst, faint nozzle glow, a slow climb, base left behind |
| 35.9–39.6 | "Tranquility Base today" | the descent stage alone, flag knocked over |
| 39.6–62.8 | seismometer, the crash, "rang like a bell" | seismometer deployed; live trace spikes at impact; Earth vs Moon seismogram |
| 62.8–69.4 | Hadley Rille | crane down a V-shaped rille with talus boulders, modelled on AS15-85-11425 |
| 69.4–72.3 | "electric space buggy… wire mesh tires" | the rover driving in 1971: crew seated, wheels turning, dust in parabolas |
| 72.3–78.3 | "not moved an inch… just stepped away" | parked today, years counting 1971→2026; empty seat |
| 78.3–79.9 | "On Mars, the story is different" | NASA's Viking global photo of Mars, pushing in to a pin on Meridiani Planum |
| 79.9–106.4 | Mars has weather, Opportunity, the storm | dramatized dust devils over rippled plains with dunes; the drive (wheels turning) with a sol counter; the historical 2018 storm; last signal; commands with no reply |
| 106.4–131.2 | Voyager 1, one light-day, 2 of 10 instruments | Voyager fly-by; light-day clock; instrument panel |
| 131.2–171.4 | the mirrors, laser ranging, 3.8 cm a year | retroreflector; corner-cube diagram; laser to the Moon; 2.5 s round trip; drift |
| 171.4–175.3 | "abandoned, but not forgotten" | back at Giza, now with a child; the sky turns as the years count from 1969 to 2026 |
| 175.3–185 | the game pitch | LAST SIGNAL gameplay, then the end card: Tranquility Base today, Earth overhead, QR |

## Facts on screen (checked)
- **Apollo 11.** On the surface about 21 h 36 min. The descent stage stayed behind, and
  Aldrin saw the flag blown over at liftoff.
- **Seismometer.** The impact the narration describes was **Apollo 12's** ascent stage on
  20 Nov 1969, about 73 km away. Apollo 11's seismometer had stopped working in August 1969,
  and the on-screen tag says so. On Earth a quake like that dies away in minutes; on the
  Moon it kept ringing for close to an hour, because the dry, fractured crust has no water
  to damp it.
- **Hadley Rille (Apollo 15, 1971).** About 1.5 km wide and up to about 400 m deep. It is
  **965 km from Tranquility Base**: we computed the great-circle distance from the two
  landing coordinates and it matches. The narration calls it a "crater", but a rille is a
  channel. The subtitles follow the audio.
- **Opportunity.** Planned for 90 sols, it lasted 5,111. The last signal came on
  10 June 2018; NASA sent over 1,000 commands and none were answered.
- **Voyager 1.** Launched 5 Sep 1977. It reaches one light-day (25.9 billion km) in
  November 2026. Two of its 10 instruments are still on (MAG and PWS, per NASA status).
- **Laser ranging.** 384,400 km is about 9.6 times Earth's circumference. The round trip
  takes about 2.5 s and is shown in real time. The Moon drifts away about 3.8 cm a year,
  which is 2.2 m since 1969.

## Dramatised, so say so in the submission
- The visible laser beam. In vacuum you can't see a beam from the side.
- Stars over the sunlit Moon. Real photos show a black sky.
- Rover drive speed, dust-devil motion and the game's compressed storm timing. The ground shake in the impact shot
  stands in for what the instrument felt; the crash itself was beyond the horizon, and the
  shot shows nothing there.
- The rover parked at the rim of the rille. Apollo 15's lander touched down about 1.6–2 km
  east of the rim.
- The Giza pyramids are stepped silhouettes to scale (1 stud = 2.5 m, Khafre keeps its casing cap); the bookend says what the film means: we build things that outlast us, on Earth and off it.
- The final sky rotation is a time-lapse. The Moon disc is drawn about 4× its real size so
  it reads on a phone.


## Models built in code (this round)
- **Inside the Eagle (`L05b_interior.lua`).** Laid out from the real Apollo LM cabin:
  - the two triangular forward windows, with the commander on the left and the LM pilot on the right
  - no seats, because the crew stood in restraints
  - an FDAI attitude ball and tape meters at each station, and switch rows across the main panels
  - the DSKY computer keypad with its green display on the centre console
  - circuit-breaker panels on both side walls
  - the overhead docking hatch and the square forward hatch at the floor
- **The Eagle, outside (`procLM`).** Rebuilt from parts to the real layout:
  - **Descent stage:** an octagonal body in amber Kapton foil, with black thermal blankets on the
    diagonal bays and a dark heat shield, plus the descent engine bell underneath.
  - **Legs:** on the four main axes, each with a primary strut, two secondaries and a 0.94 m footpad.
    Contact probes are bent back under three pads. The ladder is on the forward leg, under the porch.
  - **Ascent stage:** the crew compartment with an aluminium front, two triangular windows, a black
    frame and the forward hatch. The midsection carries the propellant-tank bulges, and the black aft
    equipment bay sits behind.
  - **On top:** the docking tunnel, the rendezvous radar, the S-band steerable dish, two VHF antennas
    and four RCS thruster quads.
  - **Scale:** about 7 m tall at 2.4 studs/m, so roughly 3.3× an astronaut. The real ratio is
    about 3.9×, close enough for the existing staging.
  - **The game:** the same descent stage now stands at Tranquility Base in LAST SIGNAL (Team Create
    v88). It is solid, and the scan prompt and its NASA facts are kept.
- **Lunar Roving Vehicle (`procLRV`).** It replaces the hosted mesh, whose wheels didn't show:
  - four wire-mesh wheels under orange fenders
  - two seats and the T-handle controller
  - the umbrella high-gain antenna, the TV camera, and the battery and comms boxes under gold foil
  - snapped to the terrain with a raycast
- **Opportunity's wheels (`oppWheels`).** The hosted rover mesh has its wheels baked in. Four clean
  wheels now enclose them, at positions measured by raycasting the mesh, and they turn as it drives:
  angle = distance ÷ wheel radius.
- **End-card key art (`L33_keyart.lua` + `keyart.py`).**
  - The scene is the descent stage, the flag and one astronaut. The Earth comes from the Blender opening.
  - There's a separate camera per format, so the words sit in empty sky.
  - The same art is exported for the game page as `game_art/thumbnail_1920x1080.jpg` and `game_art/icon_512.png`.
- **Earth in the end card is dramatised.** From Tranquility Base the Earth actually hangs about 67°
  up in the sky, far higher than this low camera could show.


## Real NASA photographs used (all public domain; credit "NASA")
Downloaded from the NASA Image and Video Library (images.nasa.gov) into `refs/`. They served as
modelling references, and six appear on screen as small "NASA PHOTO" cards next to the recreation:
AS15-85-11425 and AS15-89-12100 (Hadley Rille), AS15-88-11901 and AS15-86-11603 (the rover),
AS16-106-17340 (sample collection), AS11-40-5868 (Aldrin on the ladder), S72-55421 (Apollo 17
liftoff on TV), PIA05847 (Meridiani ripples), PIA06754 (Endurance dunes), PIA00407 (Viking global
view of Mars, used for the zoom to Meridiani). Some show identifiable astronauts; fine for an
educational, non-commercial submission.

## Accuracy notes for this round
- **Liftoff:** the ascent engine (15.6 kN on ~4.9 t) gives ~1.6 m/s² net in lunar gravity, so the
  cabin creeps up; the hypergolic flame is nearly invisible, so the drama is the foil burst.
- **Rover:** top speed about 13 km/h; fenders are grey fiberglass; dust flies in clean parabolas.
- **Meridiani:** nearly rock-free, rippled plains; the dunes are the kind Opportunity saw in Endurance.
- **Solar system:** compressed distances and enlarged planets, labelled "not to scale".

## Re-run
```
python3 build_captions.py                                  # captions.json from the transcript
Blender -b ../v3_30s/blender/earth_v3.blend --python solar_render.py -- 16x9   # S00 (and -- 4x5)
python3 make_intro_pad.py                                  # intro_pad.wav
python3 render_long.py <studio_id>                          # Roblox beauty + matte passes, ONE at a time
python3 compose_long.py 16x9 && python3 compose_long.py 4x5 # composite + encode
python3 compose_long.py 16x9 --at 12.0 60.0                 # preview stills at given seconds
```
Before compositing S32, put the gameplay stills in `game_caps/`.

## Gotchas found here
- A Roblox model's default pivot is its **first part**. `PivotTo` on a model whose first
  part is rotated tips the whole thing over, which is why Voyager first rendered on its side.
  Set `WorldPivot` first.
- A terrain Air carve has no floor. Gaps below the horizon are filled as shadow in compose.
- Translucent parts go solid in the matte pass, so dust devils and haze are drawn in compose.
- `Lighting.ColorShift_Top` had been left orange, which tinted the Moon. `moonLight()` now
  resets it.
- A background `nohup` process ignores SIGINT, so stop the renderer with SIGTERM. Never kill
  the `StudioMCP` processes by name: that also drops the main MCP link.

## AI tools used (Space Apps requires this disclosure)
- **Claude (Anthropic).** Pipeline code, compositing, motion graphics, fact-checking.
- **Roblox `generate_mesh`.** The lander body, Opportunity and the lunar rover models.
- **Voiceover.** AI text-to-speech from an earlier session. Name the service before you submit.
- **Not AI-generated:** BlenderKit's Earth material (built from NASA imagery), the AutoCam
  add-on, the procedural starfield and bootprint, and the Voyager model, built from parts
  in code.

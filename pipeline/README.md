# Abandoned but not Forgotten — Roblox render pipeline

A 60-second vertical (1080x1920) animated short for the NASA Space Apps 2026
challenge *"Abandoned but not Forgotten: Storytelling about NASA's Discarded
Equipment on the Moon and Mars."*

Everything is driven headlessly from Roblox Studio over the official
`StudioMCP` bridge. No manual Studio work.

## Requirements

- Roblox Studio open with a place (Edit mode)
- `StudioMCP` registered:
  `claude mcp add roblox-studio --scope local -- /Applications/RobloxStudio.app/Contents/MacOS/StudioMCP`
- `ffmpeg` (this machine's build has **no** `drawtext`, hence PNG caption plates)
- Python 3 with Pillow

## Layout

| file | role |
|---|---|
| `scenes/_prelude.lua` | shared helpers: `wipe`, `spawn`, `ground`, `rocks`, `moonLight` |
| `scenes/s*.lua` | one setup script per shot |
| `scenes/s5_frame.lua`, `s6_frame.lua` | per-frame animation (Voyager spin, laser pulse) |
| `shots.json` | shot list: setup, frame count, camera path |
| `render_film.py` | drives StudioMCP over stdio, writes `film_frames/gNNNNN.jpg` |
| `script.json` | caption text with in/out times |
| `captions.py` | renders caption plates to `caps/` |
| `compose.py` | ffmpeg composite -> `abandoned_but_not_forgotten.mp4` |

## Run

```
python3 captions.py
python3 render_film.py          # ~15 min for 1440 frames
python3 compose.py
```

Render a single shot: `python3 render_film.py s4`
Smoke test (3 frames/shot): `SHOTS=shots_smoke.json OUT=smoke python3 render_film.py`

## Why frames go through the stdio bridge

Calling `screen_capture` as a normal MCP tool returns every frame as an image
into the agent's context. At 1440 frames that is unusable. `render_film.py`
speaks JSON-RPC to StudioMCP directly and writes frames to disk instead.

## Gotchas found the hard way

- `execute_luau` takes `code`, not `command`, and requires `datamodel_type: "Edit"`.
- `screen_capture` requires a `capture_id`.
- Setting `Sky.SkyboxUp=""` does **not** give black space — it silently falls back
  to the default day sky. Insert a real skybox asset (here `101379085951893`).
- Studio's default **SpawnLocation** is a white 12x1x12 slab at the origin and
  shows up under every subject. `wipe()` deletes it.
- `generate_mesh` bakes a display plinth into the mesh. `GeometryService:SubtractAsync`
  with a thin box at the base removes it; keep only the largest returned fragment.
- `segment_mesh` groups legs/wheels with the base, so it can't isolate a plinth.

## Factual basis

- Apollo 11 LM descent stage left at Tranquility Base, July 1969.
- No atmosphere on the Moon: no wind or rain to erase surface traces.
- Apollo 15 left the first Lunar Roving Vehicle at Hadley-Apennine, 1971.
- Opportunity fell silent during a global Martian dust storm; last signal 10 June 2018.
- Voyager 1 launched 5 September 1977, now in interstellar space, still returning data.
- Apollo 11/14/15 laser retroreflector arrays are still used for lunar laser ranging today.

## The film and the game share one Roblox place

Both live in the same Studio place, and both build at the origin.

- The film scenes (`scenes/*.lua`) never reference the game. They clone from
  `workspace.Library` and build their own set inside `workspace.Scene`, so
  moving anything in the game does **not** affect `shots.json` framing.
- The reverse was a real problem: the playable site sits in `workspace.Game`
  on the same ground at the origin, so it appeared in film frames (a bootprint
  trail cut straight across shot 1).
- `wipe()` now parks `workspace.Game` in `ServerStorage` for the duration of a
  render, and `render_film.py` restores it when the run finishes.

**If a render crashes part-way through**, the game will still be sitting in
ServerStorage. Put it back with:

```lua
local SS=game:GetService("ServerStorage")
local g=SS:FindFirstChild("Game")
if g then g.Parent=workspace end
```

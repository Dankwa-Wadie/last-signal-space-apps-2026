# Last Signal

**A Roblox exploration game about the spacecraft and instruments humanity left behind.**

Made by **Astrolog** for NASA Space Apps Challenge 2026, challenge [Abandoned but not Forgotten: Storytelling about NASA's Discarded Equipment on the Moon and Mars](https://www.spaceappschallenge.org/2026/challenges/nasas-discarded-equipment-storytelling/?tab=details).

Players explore the Moon, Mars, and 433 Eros, find historical spacecraft and instruments, scan them, and learn what they were designed to do and what their missions taught us. The experience includes a guided opening, an artifact log, environmental suit gauges, transit between bodies, archive puzzles, and clearly marked fictional heritage stations used to support exploration.

## Live gameplay videos

### Combined demo · 26 seconds

https://github.com/user-attachments/assets/5a5b403f-88c3-4c91-a7e8-494c66ca8a1d

<sub>If the player above does not load, open the clip directly: [`competition-demo-live-gameplay.mp4`](https://github.com/Dankwa-Wadie/last-signal-space-apps-2026/blob/main/game/videos/competition-demo-live-gameplay.mp4)</sub>

### Moon · Apollo 11 artifact scan

https://github.com/user-attachments/assets/647b436b-9217-49f9-8a40-588c612a1db0

<sub>If the player above does not load, open the clip directly: [`moon-live-gameplay.mp4`](https://github.com/Dankwa-Wadie/last-signal-space-apps-2026/blob/main/game/videos/moon-live-gameplay.mp4)</sub>

### Mars · transit and Opportunity

https://github.com/user-attachments/assets/e0249a10-30ce-4fd0-b899-73c474396500

<sub>If the player above does not load, open the clip directly: [`mars-live-gameplay.mp4`](https://github.com/Dankwa-Wadie/last-signal-space-apps-2026/blob/main/game/videos/mars-live-gameplay.mp4)</sub>

These are direct recordings from Roblox Studio's live Play session. The same MP4 files are committed to [`game/videos/`](game/videos), so they remain available even if an embedded player fails. A [dedicated demo page](https://github.com/Dankwa-Wadie/last-signal-space-apps-2026/issues/1) collects all three clips in one place.

## Scene previews

| Moon · Apollo 11 site | Transit · Moon to Mars | Mars · Opportunity |
|:---:|:---:|:---:|
| ![Astronaut exploring the Apollo 11 lunar module](game/videos/moon-artifact-scan.gif) | ![Transit console showing Moon, Mars, and Eros destinations](game/videos/mars-transit.gif) | ![Astronaut exploring near the Opportunity rover on Mars](game/videos/mars-opportunity.gif) |

## Project contents

- `game/scripts/` — exported Roblox scripts (recovery copy)
- `game/build/` — Luau builders and patches used during development
- `game/archive_catalog.json` — artifact facts, attribution references, and identifiers
- `game/manifest.json` — exported world/model manifest
- `game/tests/` — existing checks
- `game/videos/` — live gameplay evidence
- `pipeline/` — source scripts, scene descriptions, and configuration for the separate cinematic render workflow
- `SUBMISSION.md` — paste-ready project-page draft and disclosure notes
- `REFERENCES.md` — source and material attribution register
- `AI_DISCLOSURE.md` — tools used in creating the project

## Roblox experience

The playable source of truth is the live Roblox place, not the exported files in this repository. The repository contains the script and world-manifest export as a recovery backup; it does not contain a complete `.rbxl` place file, and some models are referenced by Roblox asset IDs. The experience link is https://www.roblox.com/games/104157966303180; confirm that it opens for logged-out visitors before relying on it for judging.

## Rebuilding and development

See [`game/README.md`](game/README.md) for the Roblox export/recovery notes and [`pipeline/README.md`](pipeline/README.md) for the film pipeline. Roblox Studio and the project’s Studio MCP integration are needed to apply or run the exported scripts. Render caches, intermediate frames, and prior cinematic exports are excluded; the live gameplay MP4 files are retained.

## Accuracy and fiction

Historical mission and artifact details are intended to follow the cited NASA/NSSDC sources. Distances, time compression, playable layouts, and future heritage bases are simplified for gameplay. In-game labels identify fictional stations and other additions so they are not mistaken for real mission hardware.

## License

Original code in this repository is licensed under the MIT License; see [`LICENSE`](LICENSE). Original project text and graphics are licensed under CC BY 4.0; see [`LICENSE-MEDIA.md`](LICENSE-MEDIA.md). Third-party Roblox assets, NASA material, and other credited material remain under their own terms; consult [`REFERENCES.md`](REFERENCES.md) before reuse. This repository license does not relicense third-party material.

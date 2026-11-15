# Space Apps 2026 project page draft

Target team page: https://www.spaceappschallenge.org/2026/find-a-team/astrolog/?tab=project

Challenge: [Abandoned but not Forgotten: Storytelling about NASA's Discarded Equipment on the Moon and Mars](https://www.spaceappschallenge.org/2026/challenges/nasas-discarded-equipment-storytelling/?tab=details)

## Project title

Last Signal

## One-line summary

A Roblox exploration game that turns the spacecraft and instruments left on the Moon, Mars, and beyond into an interactive story about what they were built to do and the science they still teach us.

## Project description

Last Signal is an educational exploration game created by Astrolog for NASA Space Apps Challenge 2026. Players arrive as suited explorers, travel between the Moon, Mars, and 433 Eros, locate real mission hardware, scan artifacts, and add discoveries to the ASTROLOG archive. The experience connects objects to their purpose and scientific legacy through short in-game explanations and interactive puzzles.

The game features Apollo-era equipment and lunar experiments, Mars rovers and landers, and deep-space missions including Voyager. Players can also use the transit console, track suit and air status, and explore fictional heritage stations that are clearly marked as game-created locations. The stations and travel times support gameplay and are not claims about current real-world bases or direct travel durations.

The project uses storytelling and exploration to make discarded equipment feel present and understandable: a silent object is a clue to the mission that left it there, the engineering that kept it working, and the measurements it returned.

## Demo / gameplay links

- Moon live gameplay: [moon-live-gameplay.mp4](https://github.com/Dankwa-Wadie/last-signal-space-apps-2026/blob/main/game/videos/moon-live-gameplay.mp4)
- Mars live gameplay: [mars-live-gameplay.mp4](https://github.com/Dankwa-Wadie/last-signal-space-apps-2026/blob/main/game/videos/mars-live-gameplay.mp4)
- Combined 26-second gameplay demo: [competition-demo-live-gameplay.mp4](https://github.com/Dankwa-Wadie/last-signal-space-apps-2026/blob/main/game/videos/competition-demo-live-gameplay.mp4)
- Repository and project files: https://github.com/Dankwa-Wadie/last-signal-space-apps-2026
- Roblox experience: https://www.roblox.com/games/104157966303180 — confirm public access from a logged-out browser before submitting.

These clips were captured from a running Roblox Studio Play session. The Moon clip shows the lunar site and an artifact scan. The Mars clip shows the transit interface, arrival on Mars, and exploration near the Opportunity rover.

## How we built it

The interactive experience was built in Roblox Studio using Luau scripts and 3D models. The game uses client/server scripts for scanning and archive progress, suit and environmental indicators, transit between world regions, and mission interactions. The repository contains an exported script and manifest recovery backup; the live Roblox place is the authoritative build. A separate Blender/FFmpeg pipeline was used for cinematic renders and is documented in `pipeline/`.

## NASA data and other sources

Mission facts and item-specific citations are documented in `game/archive_catalog.json` and `REFERENCES.md`. The submission is based on NASA and NSSDC mission records and mission-history resources. Review those links against every in-game fact and any embedded media before submitting.

## AI / SI tools

OpenAI Codex / ChatGPT assisted with research summaries, code review, debugging, and documentation. Roblox Studio MCP was used to inspect and operate the live Studio project and capture gameplay. See `AI_DISCLOSURE.md`; the team should add any other tools used by contributors.

## License and acknowledgements

Original code is MIT-licensed and original project text/graphics are CC BY 4.0, as documented in this repository. Third-party Roblox assets and NASA/partner materials retain their own terms and are listed in `REFERENCES.md`. The project must not be submitted until the team has verified rights and attribution for all asset IDs and media actually included in the published experience.

## Items to confirm in the official form

- Confirm the exact required fields and maximum lengths in the 2026 Project tab.
- Confirm the Roblox experience link opens for judges without sign-in or group access.
- Confirm the experience and its third-party assets are public and reusable under the competition terms.
- Check the team’s complete AI/SI-tool use and citations.
- Confirm all team contributors and any additional media/data sources.

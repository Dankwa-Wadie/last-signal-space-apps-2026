# Space Apps 2026 project page draft

Target team page: https://www.spaceappschallenge.org/2026/find-a-team/astrolog/?tab=project

Challenge: [Abandoned but not Forgotten: Storytelling about NASA's Discarded Equipment on the Moon and Mars](https://www.spaceappschallenge.org/2026/challenges/nasas-discarded-equipment-storytelling/?tab=details)

## Project title

Last Signal

## One-line summary

A public, browser-playable field guide that turns spacecraft and instruments left on the Moon, Mars and asteroid 433 Eros into interactive stories about what they were built to do and the science they made possible.

## Project description

Last Signal is a public educational website created by Astrolog for NASA Space Apps Challenge 2026. It opens without a password, account or registration. The public link opens directly into the playable expedition at Tranquility Heritage Station. The website reproduces the Roblox opening, habitats, transit choices, Survey Map and Trophy Room; a project overview provides the catalog, source links and gameplay evidence.

The expedition features Apollo-era equipment and lunar experiments, Mars rovers and landers, and a catalog of additional deep-space missions. Players travel among 13 regions on the Moon, Mars and Eros, scan field objects, solve six instrument challenges, track suit oxygen and power, seek shelter from hazards, and read an 18-record NASA archive. Browser progress is saved locally. Procedural terrain and mission-scale distances are simplified for interactive storytelling. Any fictional heritage station is identified as game-created, not a current or historical NASA facility.

The project uses storytelling and exploration to make discarded equipment feel present and understandable: a silent object is a clue to the mission that left it there, the engineering that kept it working, and the measurements it returned.

## Demo / gameplay links

- **Public project website:** https://dankwa-wadie.github.io/last-signal-space-apps-2026/ — opens directly into the playable expedition, with a Tranquility arrival, station, destinations, Survey Map and Trophy Room.
- **Official 30-second cinematic film & trailer (live gameplay ending):** [Play on GitHub](https://github.com/user-attachments/assets/d6698b05-cb32-403b-96d0-03fb360a34e2) · [Direct repository MP4](https://github.com/Dankwa-Wadie/last-signal-space-apps-2026/blob/main/pipeline/v4_30s/last_signal_30s_v4_16x9.mp4) · [Social 4:5 Cut](https://github.com/user-attachments/assets/279e0bbc-7d95-4d40-a51e-91364791cf3c)
- Project overview, catalog, references and disclosures: https://dankwa-wadie.github.io/last-signal-space-apps-2026/project.html
- Direct playable expedition: https://dankwa-wadie.github.io/last-signal-space-apps-2026/field.html
- Supplementary Moon live gameplay: [moon-live-gameplay.mp4](https://github.com/Dankwa-Wadie/last-signal-space-apps-2026/blob/main/game/videos/moon-live-gameplay.mp4)
- Supplementary Mars live gameplay: [mars-live-gameplay.mp4](https://github.com/Dankwa-Wadie/last-signal-space-apps-2026/blob/main/game/videos/mars-live-gameplay.mp4)
- Combined 26-second gameplay demo: [competition-demo-live-gameplay.mp4](https://github.com/Dankwa-Wadie/last-signal-space-apps-2026/blob/main/game/videos/competition-demo-live-gameplay.mp4)
- Repository and project files: https://github.com/Dankwa-Wadie/last-signal-space-apps-2026

These supplementary clips were captured from a running Studio development build. The submitted project itself is the browser-accessible website and expedition linked above; visitors do not need Studio or Roblox to access it.

## How we built it

The project website and playable field guide use HTML, CSS, JavaScript, Three.js and WebGL. Mission records are served as project data, while browser storage keeps each visitor’s expedition progress on their device. The team also prototyped the experience in Roblox Studio; those development recordings are included as supplementary media. A separate Blender/FFmpeg pipeline is documented in `pipeline/`.

## NASA data and other sources

Mission facts and item-specific citations are documented in `game/archive_catalog.json` and `REFERENCES.md`. The submission is based on NASA and NSSDC mission records and mission-history resources. Review those links against every in-game fact and any embedded media before submitting.

## AI / SI tools

OpenAI Codex / ChatGPT assisted with research summaries, code review, debugging, and documentation. Roblox Studio MCP was used to inspect and operate the live Studio project and capture gameplay. See `AI_DISCLOSURE.md`; the team should add any other tools used by contributors.

## License and acknowledgements

Original code is MIT-licensed and original project text/graphics are CC BY 4.0, as documented in this repository. Third-party Roblox assets and NASA/partner materials retain their own terms and are listed in `REFERENCES.md`. The project must not be submitted until the team has verified rights and attribution for all asset IDs and media actually included in the published experience.

## Team and contributors

- **Nana Dankwa Oduro-Wadie** — Team Lead (Film pipeline, game code and research)
- **Nicholas Dock Tindan** — Assistant Lead (Scene build, play-testing and fact-checking)

## Items to confirm in the official form

- Confirm the exact required fields and maximum lengths in the 2026 Project tab.
- Confirm the public GitHub Pages link and embedded expedition load from a logged-out browser, including video and source links.
- Confirm permissions and credits for third-party assets, images, audio and other media actually included on the public website.
- Check the team’s complete AI/SI-tool use and citations.
- Confirm all team contributors and any additional media/data sources.

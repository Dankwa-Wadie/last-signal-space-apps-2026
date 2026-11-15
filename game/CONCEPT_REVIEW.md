# Concept review — "Relic Hunter" / "Futuristic" drafts vs what's built

Written 14 Nov 2026. Reviews the two concept documents against the game that
actually exists, and sets the hopeful ending the user asked for.

**Headline:** the two drafts are about 70% compatible and the incompatible 30%
is concentrated in a few places that would cost us the challenge's one hard
constraint — *"Accuracy is important throughout!"* The log-book ideas are good
and mostly already built. The alien storyline has to go. The futuristic framing
is the best idea in either document and it is what makes a happy ending
possible without lying.

---

## 1. The equipment question, settled

The drafts propose 16 artifacts. **All 16 are already in the game**, as of the
work done this morning. There is nothing to add to the roster.

| Draft's name for it | Where it already is | Note |
|---|---|---|
| Apollo Lunar Modules | **Mission 0**, scannable (Eagle descent stage) | Full card + REMEMBER flashback |
| ALSEP packages | **Mission 0**, scannable (seismometer + retroreflector) | Has the REACTIVATE puzzle |
| Lunar Roving Vehicles | **Mission 1** (planned, Hadley) | Apollo 15 LRV |
| Surveyor landers | **Replica gallery**, Surveyor 3 | Promote to a scan object — see §4 |
| Sojourner / Pathfinder | Replica gallery + Archive card | |
| Spirit | Replica gallery + Archive card | |
| Opportunity | **Mission 2** (planned, Meridiani) | |
| Viking 1 & 2 | Replica gallery + Archive card | One exhibit for both |
| Phoenix | Replica gallery + Archive card | |
| InSight | Replica gallery + Archive card | |
| Ingenuity | Replica gallery + Archive card | |
| Dawn | Archive card | No replica yet |
| NEAR Shoemaker | Replica gallery + Archive card | |
| Pioneer 10 & 11 | Replica gallery + Archive card | One exhibit for both |
| Kepler | Replica gallery + Archive card | |
| Voyager 1 | **Mission 3** (planned, DSN console) | |

Three places the drafts describe equipment wrongly. These are already right in
`archive_catalog.json`; fix them in the drafts so nobody re-introduces them.

1. **"Kepler: exoplanet-hunting telescope drifting in Earth's orbit."** Kepler
   is not in Earth orbit. It is in an Earth-*trailing* orbit around the Sun,
   slowly falling further behind us. Our card already says "orbiting the Sun,
   trailing Earth."
2. **"Asteroid Belts" as a map with NEAR Shoemaker in it.** NEAR landed on
   **433 Eros, a near-Earth asteroid**, not a belt object. Dawn's targets
   (Vesta and Ceres) *are* in the belt. A single "Asteroid Belt" zone would
   misplace NEAR. The Archive terminal's **Beyond** tab handles both without
   making a claim about where they are.
3. **"The moon buggy takes off into flight"** (LRV jingle). It stayed on the
   ground. It did get brief air over bumps at about 10 km/h, which is a better
   and still true line.

---

## 2. Keep / adapt / drop

### Keep — adopt these as written
- **Silhouetted unfound targets.** Strong instinct: it makes the unknown
  inviting instead of empty. The Archive terminal already ticks scanned items;
  make unscanned ones silhouettes.
- **3D rotatable models in the log book.** We went one better by accident — the
  replica gallery is this, at true scale, walkable. Keep the gallery as the
  primary version and add in-log rotation only if time is left.
- **2–3 bullet lore cards.** Already the card format (what / why / science).
- **DataStore persistence.** Already specified in `MISSIONS.md` §3.3.
- **Mobile and tablet readability.** Genuinely important and not yet in the
  plan — a large share of young Roblox players are on touchscreens, and our
  interaction is keyboard-only (E / R / F / V / Q). **Add on-screen buttons for
  all five verbs.** This is a real gap; it goes in the build order.
- **Holographic helmet HUD** — curved visor overlay, edge lighting, a
  distance readout. We already darken the helmet edges in `Helmet.client`;
  this is a styling pass on something that exists.
- **Audio over paragraphs** for this age group. Right in principle. See §3 on
  why it can't ship this event.

### Adapt — good idea, wrong mechanism
- **"Cosmic Catalog" → keep the name ASTROLOG.** It is the team's name inside
  the game and that is a deliberate decision in `HANDOFF.md` §1.1.
- **Collection sets unlocking suits and trails.** Keep the *sets* (completing
  "every Mars lander" is a real, satisfying goal across the Archive). Make the
  reward a **mission patch on your suit sleeve**, which is what actually
  happens to astronauts, rather than trail effects.
- **Micro-minigames, 3–5 seconds.** Our puzzles run 60–90 s, which is right for
  the set-piece objects. But the drafts are correct that 16 artifacts cannot
  each carry a 90-second puzzle. **Resolution: two tiers.** Set-piece objects
  (Eagle, seismometer, retroreflector, LRV, Opportunity, Voyager) keep the full
  REMEMBER → REACTIVATE treatment. Archive objects get a 3–5 s scan flourish
  only. That is roughly what is built; it just needed naming.
  - *Wipe dust off Spirit/Opportunity* — keep as a brief panel-maintenance interaction.
    Dust accumulation and wind cleaning both matter: Opportunity's final silence followed
    a global storm that starved its solar arrays, while occasional wind events cleaned
    Spirit and Opportunity panels. Do not make every storm bury a rover.
  - *Rotate an antenna for Pioneer* — keep, and it's the same mechanic as the
    LRV dish and the far-side relays. Build it once, reuse three times.
  - *Ice-digging rhythm game for Phoenix* — keep the digging, drop the rhythm.
    Phoenix's real drama was that the icy soil **stuck to the scoop** and took
    days to shake loose. "Keep trying, it's stubborn" is truer and just as
    tappable.
- **Moon rock power-ups.** The geology is real and worth teaching — anorthosite
  highlands, mare basalt, Apollo 17's orange volcanic glass, regolith holding
  trapped solar-wind gas. But one effect contradicts our own film:
  **"gravity boots prevent players from being blown away by lunar dust
  storms."** There is no wind on the Moon. Film v1's whole second shot is "No
  wind. No rain." — we cannot ship a game that contradicts our own film in the
  same submission. **Adapt:** rocks become *samples you collect and your suit
  analyses*, each unlocking its real science line, and the only upgrade they
  grant is **scanner range**, which is a tool getting better rather than
  physics changing.
- **"Far Side: Earth comms are cut off, deploy 3 relay beacons."** This is the
  best gameplay idea in either draft and it is **scientifically correct** — the
  far side never faces Earth, which is why China flew the Queqiao relay
  satellites to talk to its far-side landers. Keep the puzzle exactly as
  described and drop the aliens from it. It also pairs perfectly with Hadley,
  where the lesson is that **Earth hangs motionless in the sky and never
  moves**; on the far side it is never there at all. Two missions, one physical
  fact, taught from opposite directions.
- **Futuristic 22nd-century framing.** Adopt. See §4 — it is load-bearing for
  the ending.

### Drop
- **Cosmic Sprites, the alien stealth patrol, the neon monuments and the
  rhythm boss.** Reasons, in order of seriousness:
  1. The premise is that aliens **took** the artifacts. The true story is the
     opposite and it is the entire point of the challenge: nothing took them.
     They are exactly where we left them, which is why LRO can still
     photograph them and why lasers still come back off the reflectors.
  2. "Accuracy is important throughout!" is the brief's one hard constraint.
     A judge reading "aliens stole Surveyor 3" has to discount the whole entry,
     including the parts we sourced carefully to NSSDCA.
  3. It costs the most build time of anything in either draft (stealth AI,
     searchlights, a boss sequence) and we have roughly 36 hours.
  The *appetite* behind it is real, though — kids want something at stake.
  §4 replaces it with stakes that are true.
- **Star ratings on scan accuracy, coins, badge pop-ups on every catalogue.**
  `HANDOFF.md` §3.3 settled this: no points counter, no quiz. Scoring a child
  on how well they looked at a historical object is the wrong lesson. Keep the
  progress bar and the log filling up — that is gratification enough, and it's
  the sticker-album feeling the draft is actually after.
- **Monetization and cosmetic sales.** Out of scope, and a paid storefront on a
  NASA-challenge entry reads badly to judges. Patches and visor tints should
  all be earned.
- **Jetpacks and customizable rovers.** Conflicts with the first-person suit
  build and with lunar-surface reality. Revisit after the event.
- **The 8-week, 4-phase schedule.** We have about 36 hours and film v2 is due
  in parallel. `MISSIONS.md` §10 is the real schedule.

---

## 3. The audio idea — right instinct, no budget

The drafts are correct that this audience will not read paragraphs, and the
jingles are genuinely charming. Two blockers, both in `HANDOFF.md` §3.1:
Magnific is on the free plan with **0 credits**, and the TikTok-style narrator
voice only exists inside CapCut.

What we can do for free: the **real archival audio is public domain.** Apollo
air-to-ground, the Eagle landing callouts, the seismometer's data as sound.
A five-second burst of real mission audio when you scan Eagle beats a
synth-pop jingle on authenticity, costs nothing, and still means no reading.

Verdict: build the audio *hooks* now (one sound per artifact, played on scan),
leave the files as a to-do, and fill them with archival clips if time allows.
Jingles stay in the backlog as a post-event idea.

---

## 4. Hope, and the happy ending

The user's directive: *"this game should give Hope to the future generation and
have a Happy ending."* This is the right call and it exposes a real flaw in the
current plan — `MISSIONS.md` §6.4 ends the Mars mission with a puzzle the
player is **designed to lose**. That is honest but it is not hopeful, and it is
the last thing a player would feel.

Here is the fix, which costs almost nothing to build because it is mostly
framing.

### 4.1 Adopt the future framing — it does the work for us

**You are an explorer in the next century, and humans are back.** The sites you
visit are *protected heritage sites*; your job is to survey them and keep the
record. Nothing about the hardware's history changes, so every fact stays
true — but the player's present tense is one where we returned and stayed.

This single change makes hope structural instead of a speech at the end. It
also explains, in-world, why you have a scanner, why there's a Deep Space
Network console on the Moon, and why anyone is cataloguing this at all.

It must be *labelled* as a frame, in one line on the title screen: *"A century
from now, someone comes back to check on everything we left."* Then the
history is history and the framing is clearly the fiction. That is the same
honesty rule film v2 uses for its sped-up orbit.

### 4.2 Fix the Mars ending without faking it

Opportunity cannot be saved. Letting the player rescue it would be a lie about
a real event, and the real event is not actually sad — a rover built for 90
sols worked for more than 5,000 and drove 45.16 km.

So keep the puzzle, change what it is *for*. Three edits:

1. **Reframe the task.** The panel no longer asks you to save it. It asks you
   to do what the team at JPL did: keep it alive as long as you can. Sols
   survived counts up and responds to good play.
2. **End on the number, not the silence.** When the radio goes quiet, the
   screen fills in the real totals: *90 sols designed · more than 5,000 sols
   worked · 45.16 km driven · more than 1,000 recovery commands sent, because nobody
   wanted to stop trying.* That last clause is the hopeful fact and it's true.
3. **Then pull out to now.** The dust clears and the HUD shows what is on Mars
   **today**: Curiosity still driving, Perseverance still collecting, Ingenuity
   having flown 72 times in air nobody thought could hold a helicopter. Closing
   line: **"Opportunity stopped. Mars exploration didn't."**

Nobody loses. The mission's truth line changes from *"it was built for 90
days"* to **"It was built for 90 sols. It worked for more than 5,000 — and we
never stopped going back."**

### 4.3 The finale: "The Handover"

When every mission is closed and the Archive is full, the DSN console receives
one more thing, and it is not from the past.

1. ASTROLOG completes and tallies the whole catalogue: 18 objects found.
2. Below it, a second number: **"Still answering: 4."** The Apollo
   retroreflectors, Voyager 1's two live instruments, and the rovers working
   right now. This number is literally true and it is the hopeful one.
3. The console asks you to do the thing every mission in the game is about:
   **leave something behind on purpose.** You place a small marker at
   Tranquility with your name and the date, next to Eagle. It joins the list of
   things humans left deliberately — and like the retroreflector, it is left
   *to be found*.
4. Final card: Artemis is taking humans back to the Moon. The reflectors Apollo
   left will still be there when they arrive, still working, because they need
   no power and have no moving parts. Someone in the next crew will range on
   the same mirrors Armstrong and Aldrin set down.
5. Closing truth, and the game's last line:
   **"Nothing out here is lost. It's waiting."**

That is a happy ending that does not require a single invented fact, and it
turns the whole game's premise — *abandoned* — inside out, which is exactly
what the challenge title asks for: **abandoned, but not forgotten.**

### 4.4 Rewritten mission spine

| Mission | The truth you leave with |
|---|---|
| 0 Tranquility | We left something here on purpose, and it still answers. |
| 1 Hadley | We drove on another world, and pointed a dish at home so you could watch. |
| 2 Meridiani | Built for 90 sols. It worked for more than 5,000 — and we never stopped going back. |
| 3 Interstellar | Nothing is broken. It is just very far away, and still talking. |
| 4 Far side *(replaces Vanguard)* | We can reach the one place that can't see us. |
| Finale | Nothing out here is lost. It's waiting. |

Mission 4 changes from the Vanguard 1 console to the **far-side relay puzzle**
from the second draft. It is a better mission, it is a real engineering
problem, and it is hopeful rather than melancholy — Vanguard's beat was
"silent since 1964", which is the wrong note to end near. Vanguard keeps its
Archive card.

---

## 5. What this adds to the build order

**Status 14 Nov: the first six are built, installed and play-tested.** See §7.

| Work | Est. | Why it's worth it | Status |
|---|---|---|---|
| Mars ending reframe (§4.2) — text and one HUD panel | 40 min | Removes the only unhappy ending; near-zero code | **built** |
| The Handover finale (§4.3) | 1.5 h | The game currently has no ending at all | **built** |
| Touchscreen buttons for E / R / F / V / Q | 1 h | Without it, most young players cannot play | **built** |
| Surveyor 3 promoted to a scannable object | 45 min | "The one we came back for" is the best card we have | **built** |
| Silhouettes for unfound Archive items | 30 min | Cheap; turns a list into a collection | **built** |
| Future framing line + title screen | 20 min | Makes the hope structural | **built** |
| Far-side relay mission, replacing Vanguard console | 2.5 h | Only if Missions 1 and 2 are both done | **built** — around Ranger 4 |
| Rock samples with real science lines | 1 h | Stretch | not started |
| Archival audio on scan | 1 h | Stretch, and needs clip sourcing | not started |

## 6. Fact-checks — cleared 14 Nov 2026

All seven open items were checked. Four were confirmed, three changed the text.

**Confirmed, now on screen**
- **Ingenuity:** 72 flights, ended 18 Jan 2024 when a rotor blade was damaged on landing
  (about 25% of one blade lost). Planned for five flights.
  ([Live Science](https://www.livescience.com/space/mars/nasas-historic-ingenuity-helicopter-ends-its-3-year-mars-mission-suffering-rotor-damage-on-72nd-flight))
- **Phoenix:** the icy soil really did stick in the inverted scoop; on sol 60 too little
  reached the TEGA oven for its doors to close, and the team resorted to vibrating the scoop
  and switching to drier soil. The digging minigame has its basis.
  ([JPL](https://www.jpl.nasa.gov/news/nasas-phoenix-mars-lander-working-with-sticky-soil/))
- **Queqiao:** the far side cannot talk to Earth directly because the Moon itself is in the
  way, so China flew a relay into a halo orbit around Earth–Moon L2, which can see both at
  once. The far-side mission's premise holds.
  ([Planetary Society](https://www.planetary.org/articles/0519-change-4-relay-satellite))
- **Apollo 15 retroreflector:** 300 corner cubes against 100 each for Apollo 11 and 14; it is
  the largest Apollo array.
  ([UCSD / Apollo LLR](https://tmurphy.physics.ucsd.edu/apollo/lrrr.html))
- **Opportunity:** final odometer 45.16 km, 90-sol design life, tau 10.8 recorded 11 June
  2018 — the highest ever measured on the Martian surface.
  ([Planetary Society](https://www.planetary.org/articles/08-mer-update-opportunity-sleeps))
- **Curiosity and Perseverance** both still operating as of early Nov 2026 (Curiosity passed
  5,000 sols in September 2026). Secondary sources only — **re-check on a JPL mission page
  before release**, because the "still answering" tally on the ending screen depends on it.
  ([Perseverance status](https://en.wikipedia.org/wiki/Perseverance_(rover)))

**Three corrections**

1. **The LRV dish puzzle had the mechanism slightly wrong.** The high-gain antenna was used
   *only while the rover was stopped*, and the low-gain antenna was the one hand-aimed during
   drives. Apollo 15 proved the high-gain could not be held on target while moving — TV was
   tried in motion once, on EVA-3, and almost nothing got through. The puzzle is still right,
   but its line must be "you have to stop to send pictures," not "aim it at every stop."
   I found no source saying the low-gain carried voice, so **drop that claim**.
   ([NASA LRV Operations Handbook](https://www.nasa.gov/wp-content/uploads/static/history/alsj/LRV_OpsNAS8-25145Pt7.pdf))
2. **Apollo 15's liftoff *was* televised — it was the tilt that failed.** The camera was on
   and pointed at the LM; the tilt mechanism malfunctioned, so it never followed the ascent
   stage up and the LM climbed out of frame. Apollo 16 lost it too (rover parked too close).
   Apollo 17 is the one that worked, and Ed Fendell had to send the pan command about 1.3 s
   early to beat the Earth–Moon signal delay. Don't write "the liftoff was not televised".
   ([Smithsonian](https://www.airandspace.si.edu/multimedia-gallery/apollo-17-liftoff-moon-december-14-1972), [NASA](https://www.nasa.gov/feature/50-years-ago-apollo-17-heads-home-to-earth))
3. **Opportunity's sol count is ambiguous — don't put 5,111 on screen as a bare number.**
   5,111 is operational sols; 5,352 is sols from landing to end of mission. Sources differ
   and neither is wrong. Use **"built for 90 sols, worked for more than 5,000"**, which is
   true under either count. Use the safer phrasing in both the archive and ending screen.

**Also checked, for the rock samples (stretch)**
- Highlands are anorthositic and cover ~83% of the surface; maria are basaltic, ~17%, mostly
  on the near side. Apollo 17's orange soil is ~99% tiny titanium-rich volcanic glass
  spheres from a lava fountain, found by Schmitt at the rim of Shorty crater. Note that
  "fire fountain" is not the term the sources use — say "lava fountain".
  ([LROC](https://www.lroc.asu.edu/images/417), [OpenLearn](https://www.open.edu/openlearn/science-maths-technology/the-moon/content-section-4.6))
- **Still unverified:** the height of the Apennines above the Hadley plain. The ~3.5 km
  figure in `MISSIONS.md` §5.1 has no source behind it yet; it needs a LOLA or site-specific
  reference, or the number should come off the sign.

---

## 7. What was built, 14 Nov

Installed into the open place with `game/install_patch.py` and play-tested. No console errors;
all five artifacts hook on startup.

- **`Remotes.LocalKey`** — a BindableEvent. Touch buttons fire it and the existing keyboard
  handlers answer, so there is one code path for both. Nothing crosses the network.
- **`Touch` LocalScript** — REMEMBER / REACTIVATE / CLOSE / VIEW buttons, plus a press-and-hold
  pad (WASD + / -) for the seismometer puzzle, shown only on touch devices. E needs nothing:
  Roblox draws its own button for a ProximityPrompt.
- **Procellarum site** — Surveyor 3 and the Apollo 12 ALSEP (central station, SNAP-27 RTG
  standing off on its cable, PSE), on their own regolith pan inside a low crater rim, with a
  sign giving the real coordinates and saying plainly that the short walk from Tranquility is
  ours, not NASA's. Both are scannable, both have REMEMBER vignettes.
- **ASTROLOG** now groups by site and counts 5.
- **The Handover** — fires when the log hits 5/5: the "still answering" tally, the Artemis
  line, and a button that plants a named marker beside the Eagle. Server-authoritative, one
  per player, broadcast to the crew.
- **Archive silhouettes** — unfound items show as hollow dots and "? ? ? ?" and redraw the
  moment you scan them.
- **Opening line** — "Tranquility Base, a century from now. Everything here is exactly where
  we left it."
- **`SurveyServer` / `ReactivateServer`** generalised: artifacts resolve as {site folder,
  model} instead of one hardcoded folder, which is what Hadley and Mars will need.

### Known bug, pre-existing and not fixed

**The sky is Roblox's default daytime blue, with clouds, on the Moon.** It is not caused by
this patch — it was already so before any change, and it contradicts the film. The `Sky`
object is present and correct, but neither skybox asset renders: not `11889993473`
(the `MilkyWay` that was set), and not `101379085951893` (the black sky recorded in
`manifest.json`). A no-asset workaround — a black unlit sphere around the sites — does not
work either, because Roblox backface-culls a ball part from the inside.

Most likely the assets are not loading for this account or have been moderated. Next step is
to upload a black 1×1 texture to this account and point all six faces at it, which depends on
nothing external.

**One thing to be aware of:** while diagnosing, I replaced the `Sky` object before recording
all six of its face textures. It has been put back as `MilkyWay` with the one id I did
record (`11889993473`) on all six faces. If the original used a different texture per face,
those ids are gone and need re-applying. Nothing is visibly lost today, because the skybox
does not render either way.

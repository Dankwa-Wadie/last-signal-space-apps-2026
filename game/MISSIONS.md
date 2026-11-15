# MISSIONS — "Last Signal"

The full mission plan for the game. Written 13 Nov 2026, to be built during
the hackathon (14–15 Nov). Companion to `HANDOFF.md`; read §0 of that file
first — the pre-event rule means this document is a *plan*, and the missions
in it get built during the event, not before.

Mission 0 (Tranquility) already exists and is play-tested. Missions 1–4 are
specified here to be buildable without further design work.

---

## 1. What a "mission" is

One mission = **one place you stand in, two or three objects, one truth.**

The loop, unchanged from Mission 0:

```
ARRIVE → FIND → SCAN (E) → REMEMBER (R) → REACTIVATE (F) → LOG
```

The rule that makes it a game rather than a museum: **the REMEMBER flashback
teaches you how to solve the REACTIVATE puzzle.** If a player can solve a
puzzle without having watched the flashback, the puzzle is wrong.

Each mission must answer three questions on screen, in the artifact cards:
what the object is, why it was sent, and what science it produced. That is the
challenge brief's requirement, and it is also the card layout already built.

Each mission ends on **one sentence of truth** — the line the player leaves
with. Those five lines are the spine of the whole game:

| Mission | The truth you leave with |
|---|---|
| 0 Tranquility | We left something here on purpose, and it still answers. |
| 1 Hadley | We drove on another world, and pointed a dish at home so you could watch. |
| 2 Meridiani | Built for 90 days. It worked for more than 5,000 sols — and we never stopped going back. |
| 3 Interstellar | Nothing is broken. It is just very far away, and still talking. |
| 4 Far side | We can reach the one place that can't see us. |
| **Finale** | **Nothing out here is lost. It's waiting.** |

Revised 14 Nov after the concept review. The game is set **a century from
now, when humans are back** and these are protected heritage sites you survey.
The hardware's history is unchanged and still true; the player's present tense
is one where we returned and stayed, which is what makes the ending hopeful
without inventing anything. See `CONCEPT_REVIEW.md` §4.

---

## 2. Scope decision, up front

There is roughly 36 hours of event, and film v2 is also due. Building five
full walkable regions is not realistic. The plan splits the missions by how
expensive they are to build:

| Mission | Form | Cost | Verdict |
|---|---|---|---|
| 0 Tranquility Base | Walkable region | built | **Done** — needs 2 small fixes (§4) |
| 1 Hadley–Apennine | Walkable region, same place, same gravity | ~4–5 h | **Must have** |
| 2 Meridiani Planum (Mars) | Walkable region, second place | ~5–6 h | **Must have** — it's the emotional climax |
| 3 Interstellar (Voyager 1) | **Console scene, not a region** | ~2 h | **Should have** — cheap, and better as a console |
| 4 Low Earth orbit (Vanguard 1) | Console scene | ~1.5 h | **Stretch only** |

**The Voyager decision.** The first instinct is a zero-gravity region you fly
around. Don't build it: freefall movement is a new control scheme, a new suit
state and a new set of bugs, and it fights the point. Voyager is 25.9 billion
km away — you *cannot* stand next to it. Making the player sit at a Deep Space
Network console and wait for a round trip is cheaper **and** truer. Same for
Vanguard 1.

So: **two walkable worlds (Moon, Mars) and one console that reaches the other
two.** The console lives at Tranquility and is unlocked once Mission 0 is
complete.

### BUILT — status 14 Nov, end of day

The whole game is in the place and play-tested. Place saved as **version 104**.

| Mission | Site | Artifacts | Puzzle | State |
|---|---|---|---|---|
| 0 | Tranquility Base | Eagle, seismometer, retroreflector | `seis` level · `retro` ranging | built |
| 0b | Oceanus Procellarum | Surveyor 3, Apollo 12 ALSEP | — | built |
| 1 | Hadley–Apennine | Falcon, LRV, Apollo 15 LRRR | `lrv` dish aiming | built |
| 2 | Meridiani Planum (Mars) | Opportunity, heat shield | `oppy` power budget | built |
| 3 | Deep Space Network console | Voyager 1, Pioneer 10/11 | ping + light-day countdown | built |
| 4 | The Far Side | **Ranger 4** | `relay` L2 halo orbit | built |
| — | The Handover | the ending, 11/11 | marker beside the Eagle | built |

**11 artifacts · 5 sites · 2 worlds · 5 puzzles.**

Tests: `python3 run_tests.py <studio_id>` runs `tests/rules_tests.lua` — **38/38 pass**.
A scan regression over all 11 artifacts at all 5 sites passes 11/11.

**Deviation from §3.3, deliberate.** Travel is *not* TeleportService between two
places. Mars is a region in the same place at z≈1500, and the transit console
moves the character. The reason is testability: teleports and DataStores do not
work in Studio solo play, so the separate-places design could not have been
tested or demonstrated during the event. Gravity is corrected per player with a
VectorForce on the HumanoidRootPart (Moon 16.2, Mars 37 — the real 2.3x ratio),
and the Mars sky, fog and light are restyled client-side so only that player
sees them. The separate-places version in §3.3 remains the upgrade once the
game is published and a real multi-server test is possible.


### Update 15 Nov — Eros, the station, the opening (place v127)

- **20 artifacts on 13 sites.** NEAR Shoemaker now lies at the updated landing solution on 433 Eros
  (41.626 S, 80.421 E, near the Himeros saddle), reached by a third transit leg.
- **Eros gravity** is 1.8 studs/s^2 against a true-to-ratio 0.06 — deliberately raised so a
  hop doesn't leave the map, and said so on the site sign. Real figure: ~0.0059 m/s^2, under
  a thousandth of Earth's; escape speed 3.1–17.2 m/s across the surface. A **tether**
  (client-side RopeConstraint, 72 studs) clips every visitor to a stake; tested holding at
  71.6 studs after a 70 studs/s throw. The server unclips before any transit move.
- **Tranquility Heritage Station.** Spawn, archive, DSN radio and transit moved off the
  heritage site to a station 140 studs out, behind a marked boundary arc (NASA's 2011
  recommendation is 75 m; shortened here, and the sign says by how much).
- **Opening scene** (Intro.client): on your back on the pad looking up at Earth, the
  station on the radio, then you stand facing the Eagle. Once per visit, any input skips
  it (0.07 s to control), client-only so it never holds up a co-op partner.
- **Corner log** now shows only the site you're at plus one progress line; the map and
  trophy room carry the full list.
- Tests: index 170/170, rules 38/38, layout 43/43, full scan regression 20/20.

### Minimum shippable cut### Minimum shippable cut
If time collapses: Mission 0 + Mission 1 + the Voyager console. That is a
complete game with the Moon, a rover, a drive, and an ending. Mars is the
first thing to cut and the last thing you want to cut — protect it by starting
it early (§8).

---

## 3. Shared architecture — do this before Mission 1

Mission 0's code hardcodes one site in five places. Every new mission
multiplies that. Spend the first 90 minutes making it data-driven; everything
after is additive.

### 3.1 New ModuleScript: `ServerScriptService/MissionData`

One table, required by both server and client (put a copy or a mirror in
`ReplicatedStorage` so the client can read it too). Replaces the `ORDER`,
`MODEL`, `SHORT`, `PUZZLE` and `HAS_PUZZLE` tables now scattered across four
scripts.

```lua
return {
  { id="tranquility", title="Tranquility Base", folder="Tranquility",
    subtitle="Apollo 11 · 20 July 1969",
    artifacts={
      { id="lm",    model="LM_DescentStage", short="Descent Stage" },
      { id="seis",  model="Seismometer",     short="Seismometer",   puzzle="seis_level" },
      { id="retro", model="Retroreflector",  short="Retroreflector", puzzle="retro_ranging" },
    } },
  { id="hadley", title="Hadley–Apennine", folder="Hadley", ... },
  ...
}
```

The artifact *card text* stays where it is now — as attributes on the model in
the world (`Title`, `Year`, `What`, `Why`, `Science`, `ArtifactId`). That is
already working, it keeps the words next to the thing, and the manifest
already round-trips it. Don't move it into the module.

### 3.2 Script changes

| Script | Change |
|---|---|
| `SurveyServer` | Replace `local site = workspace.Game.Tranquility` with a loop over `MissionData`. Hook prompts for every artifact in every mission. `discovered` stays one flat table keyed by artifact id — artifact ids are globally unique. |
| `SurveyRules` | `snapshot()` takes the full mission list and returns per-mission groups. Still pure. Extend the test crew to cover two missions and cross-mission range checks (a player at Hadley must not witness a Tranquility vignette). |
| `ReactivateServer` | `HAS_PUZZLE` comes from `MissionData` (`artifact.puzzle ~= nil`). `online` and the lock table are already keyed by artifact id, so they need no change. |
| `Survey` (client) | ASTROLOG renders **grouped by mission**, collapsed to the current mission plus a one-line count for the others. `V` (vignettes) becomes a folder of per-mission modules — the file is already 213 lines and will triple otherwise. |
| `Reactivate` (client) | Split into `PuzzleUI` (shared chrome: panel, title, instructions, close, `WalkSpeed=0` handling) plus one module per puzzle returning `solved: boolean`. The existing seismometer puzzle becomes `seis_level`, unchanged. |
| `Suit` | No change. Same suit on Mars. It's a deliberate conceit — you are the same visitor throughout. |

### 3.3 Travel between worlds

**Moon → Mars crosses a gravity boundary, and `workspace.Gravity` is global
per server.** Per-player gravity hacks (VectorForce on the HRP) are possible
but fight the existing lunar movement that is already tuned and tested.

Use **TeleportService between two places in one universe**:

- Place A `Luna` — Tranquility + Hadley, `Gravity = 16.2`, black sky.
- Place B `Meridiani` — Mars, `Gravity = 37`, dusty butterscotch sky.

Gravity note: Roblox default is 196.2 for 9.81 m/s². True-ratio values would
be 32.4 (Moon) and 74.4 (Mars). Mission 0 ships the stylised half-scale 16.2,
which is play-tested and feels good — so keep it, and use **37** for Mars. The
*ratio* between the two (2.3×) is then correct, which is the thing a player
actually feels.

ASTROLOG has to survive the teleport. Two pieces:

1. `TeleportService:SetTeleportData` carries the player's own found-list
   across, for an instant log on arrival.
2. A `DataStoreService` store keyed by `UserId` is the source of truth, written
   on discovery and on `PlayerRemoving`. This also gives you progress across
   sessions, which the game currently has none of.

**Enable Studio access to API services** before any of this works
(Game Settings → Security). Test teleports need the game published; teleports
do not work in Studio's solo play — budget for that and test it in a real
server early, not at hour 30.

### 3.3b Bases, and how you cross between worlds *(decided 14 Nov)*

**Yes to a base on each world, but deliberately lopsided**, and neither one sits
on top of the hardware.

**Why the base is not at the landing site.** NASA's 2011 recommendations to
space-faring entities set a **75 m ground-travel buffer around the Apollo 11
site**, measured from the descent stage, and 225 m for Apollo 17. It is
guidance, not law, but it is real, and it is a gift to this game: it is the
true reason a heritage surveyor parks away and **walks in**. Put a boundary
marker on the ground where the buffer starts, and the framing earns itself.
(One outlet reports a 2 km figure; that is an outlier — use the 75/225 m
numbers from NASA's own PDF, `617743main_NASA-USG_LUNAR_HISTORIC_SITES_RevA-508.pdf`.)

One caveat to be honest about: at the game's 2.4 studs/m scale, 75 m is 180
studs, which is far wider than the 34–82 studs the artifacts are currently
spaced apart. Do **not** enforce it literally; it would wreck a layout that is
already tuned and play-tested. Put the station outside a *scaled* buffer, mark
the boundary, and disclose the compression in the submission alongside the
existing note about artifact spacing (`HANDOFF.md` §6.1, item 3).

| | Moon — **Tranquility Heritage Station** | Mars — **Meridiani Outpost** |
|---|---|---|
| Role | The hub. Everything that is not a mission lives here. | A doorstep, and nothing more. |
| Already built | Spawn, NSSDCA Archive terminal, replica gallery | nothing |
| To add | DSN console (Voyager/Pioneer), transit board, buffer marker | One habitat, a return console, a log repeater |
| Cost | ~1 h on top of what exists | ~1 h |

**Keep Mars sparse on purpose.** The temptation is to mirror the Moon base.
Don't: a second Archive and a second gallery would make Meridiani feel like a
reskin and cost two hours the schedule has not got. More importantly, Mission 2
is the emotional climax and its focus is Opportunity. Furniture competes with
it. The Archive is a *network* — it is reachable from both worlds, which is
also why coming back to the Moon still has a point.

**Crossing: TeleportService, with the transfer window as the story.**

Real orbital mechanics do not care what century it is. Earth–Mars launch
windows open roughly every 26 months and the crossing takes months, not
minutes. So the transit board at each base shows the next window and the cruise
time, and the journey itself is the loading screen: a progress bar carrying the
real duration and distance, ticking fast, **labelled as compressed** — the same
honesty rule film v2 uses for its sped-up orbit. The player learns the most
surprising true thing about going to Mars (you cannot leave whenever you like)
without being made to wait.

```
walk into the transit module  →  E  →  departure board
   DESTINATION  Meridiani Planum
   NEXT WINDOW  opens every ~26 months
   CRUISE       ~7 months        [ ×compressed ]
→  confirm  →  journey bar  →  ARRIVE at Meridiani
```

The same console sits in the Mars outpost for the trip back.

**Two traps this sets, both avoidable:**

1. **A plain teleport splits the crew.** Two friends playing together will land
   in two different Mars servers. Travel the party together with one
   `TeleportAsync` call taking the list of players in the module, or reserve a
   server. This is the single most likely thing to go wrong.
2. **ASTROLOG must survive the hop**, so the DataStore in §3.3 stops being
   optional the moment Mars exists. Teleports and DataStores also do not work
   in Studio solo play, which is why step 6 of the build order has to happen
   before Mars, not after.

**The alternative, for the record:** one place, both worlds far apart, per-player
gravity faked with a VectorForce on the HumanoidRootPart. It dodges teleports
and publishing entirely. It is rejected because the gravity hack fights the
lunar movement that is already tuned and tested, and because both worlds then
load for every player all the time. Revisit only if teleports prove impossible
to test in time.

### 3.4 ARRIVE beats

Every mission opens with the same three-second move: black, one line of white
text (site name, mission, date), fade up on the horizon with the objects
already visible in the distance. Write it once as `ArriveSequence(missionId)`
in the client and call it on spawn and on teleport arrival. Costs 20 minutes
and makes five missions feel like one game.

---

## 4. Mission 0 — Tranquility Base *(built; two fixes)*

Apollo 11 · 20 July 1969 · Mare Tranquillitatis
Artifacts: LM descent stage *Eagle*, Passive Seismic Experiment, Laser Ranging
Retroreflector. Scan, remember and the seismometer levelling puzzle all work.

Both accuracy corrections from `HANDOFF.md` §6.1 are **already applied** in the
backed-up scripts — the seismometer vignette credits the 55-minute ringing to
Apollo 12's deliberate *Intrepid* impact 73 km away, and the retroreflector
says "several times a month". Verified in
`scripts/StarterPlayerScripts__StarterPlayerScripts.Survey.client.lua:150` and
`:165`. Nothing to redo; confirm it's the same in the live place.

Two things left:

**4.1 The retroreflector has no REACTIVATE puzzle** — `retro` is in `MODEL`
but not `HAS_PUZZLE`, so F does nothing there. This is the game's title object
and its closing truth; it should carry the best puzzle.

> **Puzzle `retro_ranging` — "Catch the return."**
> The panel is an observatory ranging screen. You fire, and a counter runs.
> Light takes 1.25 s each way, so you must press RETURN GATE in the window
> 2.5 s after firing — open the gate early or late and you collect noise
> instead of photons. Three successful returns and the screen plots the
> distance: 384,400 km, and a second plot showing it growing 3.8 cm a year.
> Why it's honest: real lunar laser ranging gates the detector to a narrow
> time window for exactly this reason, and out of ~10^17 photons sent, about
> one comes back per pulse. The third return should be visibly *hard*.
> Build cost: ~75 min. Reuses the `seis_level` panel chrome.

**4.2 Add the mission-complete beat.** When all three Tranquility artifacts
are in ASTROLOG, the log stamps the mission closed and the Deep Space Network
console (§7) lights up. Without this there is no reason to walk anywhere new.

---

## 5. Mission 1 — Hadley–Apennine

**Apollo 15 · 30 July – 2 Aug 1971 · Hadley Rille, at the foot of the
Apennine mountains.**

Why this mission: it is the one with the **rover**, and driving — or even just
walking up to a parked car on the Moon — is the single most memorable image
available. It is also same-gravity, same-place, so it costs a region and not a
world.

### 5.1 The place
Mountains on one horizon (the Apennines rise ~3.5 km above the plain) and the
cut of Hadley Rille on the other. Build the ridge as simple anchored terrain
wedges with a flat shader — the game's visual language is already low-detail,
don't fight it. Rover wheel tracks as a decal path from the LM to the rover's
final parking spot, because the tracks are the thing LRO can still photograph.

### 5.2 Artifacts (3)

| Object | Card: what / why / science |
|---|---|
| **Lunar Roving Vehicle (LRV-1)** | A battery-electric car folded against the side of the LM. / So the crew could reach the rille and the mountain front instead of walking. / It extended the crew's range enormously, and it carried the TV camera that let the world watch. |
| **Falcon descent stage** | The lower half of the lander, left standing. / Same job as *Eagle*: a launch platform that was never coming back. / Still there, photographed from orbit; it and the retroreflector anchor the site's coordinates. |
| **Laser Ranging Retroreflector (Apollo 15)** | A much larger array than Apollo 11's. / A bigger target returns more photons, so observatories can range on it in worse conditions. / **It is still returning data today** — the deliberate callback to Mission 0. |

The Apollo 15 retroreflector appearing *again*, 400 km and two years away from
the first one, is the best storytelling beat in the game. Give its scan card a
line that explicitly ties back: *"You have seen one of these before."*

### 5.3 REMEMBER — the drive
The flashback is first-person from the rover seat, moving: camera follows a
pre-baked path away from the LM toward the mountains, bouncy, dust kicking up,
the real voice-cadence of a traverse in captions. End parked, facing back at
the LM, which is now a speck. Caption: *"The first car on the Moon drove about
28 km in three days, and never came home."*

### 5.4 REACTIVATE — `lrv_dish`, "Point it at Earth"

The puzzle. The LRV's umbrella-shaped **high-gain antenna had to be aimed at
Earth by hand at every single stop** — the crew sighted it using an optical
guide — because the high-gain dish and TV camera operated only while stopped.
The low-gain antenna was oriented during traverses. Miss the aim and the
picture doesn't come.

> Two-axis aiming on the panel, with a signal-strength bar. The target is
> **Earth, which does not move in the lunar sky** — the Moon keeps the same
> face toward us, so from Hadley, Earth hangs in the same spot, permanently.
> The flashback says this out loud; the puzzle requires you to have heard it,
> because the panel shows no target marker, just the sky and the bar. Lock on
> and the rover's TV picture resolves on the panel.
>
> **Co-op variant:** with two players in range, one aims and the other reads
> the bar out loud — the bar is only visible on the second player's screen.
> Solo falls back to both on one screen. This is the mission that justifies
> multiplayer; use it.

**Accuracy trap — do not claim Apollo 15's liftoff TV worked.** Ground
controller Ed Fendell remotely panned the rover camera to film the ascent
stage lifting off; **on Apollo 15 that attempt failed** (the camera's tilt did
not respond). It worked on Apollo 17. If you want the liftoff pan in the game,
either put it in Mission 1 **as the attempt that failed** and name Apollo 17 as
the one that succeeded, or leave it out. Getting this wrong is exactly the
kind of error the "accuracy is important throughout!" line in the brief is
aimed at. → fact-check list, §9.

---

## 6. Mission 2 — Meridiani Planum

**Opportunity (MER-B) · landed 25 Jan 2004 · last signal 10 June 2018 ·
mission declared over 13 Feb 2019.**

This is the climax. Everything before it is about things that outlasted their
makers. This one is about a thing that stopped, and it is the mission that
earns "Most Inspirational".

### 6.1 The place
Second Roblox place (§3.3). Butterscotch sky, low sun, dust haze that
**gets thicker over the course of the mission** — drive the fog density from
the puzzle state so the world itself closes in while you work. Gravity 37.
Keep the same suit.

### 6.2 Artifacts (2, deliberately fewer)

| Object | Card |
|---|---|
| **Opportunity** | A six-wheeled, solar-powered geologist the size of a golf cart. / Sent to look for evidence that Mars once had liquid water. / In its first weeks it found layered rocks and hematite spherules that supported a watery past. Built for 90 sols, it worked for more than 5,000 and drove 45.16 km. It held the off-Earth driving-distance record until Perseverance passed it on 11 October 2026. |
| **Heat shield / backshell debris** | The discarded parts of its own arrival. / Jettisoned during descent. / Opportunity later **drove back to photograph its own heat shield** — and found a meteorite lying next to it. |

The heat shield is the mission's "discarded equipment" in the most literal
sense the challenge asks for: hardware thrown away *by* the hardware we're
visiting. Don't skip it to save time; it is cheap (two bent panels) and it is
on-brief.

### 6.3 REMEMBER — the storm
Flashback: the sky browns out over a compressed timeline, a tau (opacity)
figure climbs on a HUD, the rover's power bar falls. Ends on the real last
contact date. Caption: *"10 June 2018. The last signal."*

### 6.4 REACTIVATE — `oppy_power`

> **Superseded 14 Nov.** This section originally ended the mission with a
> puzzle the player was designed to lose. That is honest but it is the wrong
> last feeling, and the user has asked for a hopeful ending. The puzzle below
> still stands — Opportunity cannot be saved, and faking that would be a lie
> about a real event — but its *framing and ending* are replaced by
> `CONCEPT_REVIEW.md` §4.2: the task becomes keeping it alive as long as JPL
> did, it ends on the real totals rather than the silence, and it pulls out to
> what is working on Mars today. Read that before building this.

> You get three controls: tilt the solar panels toward the sun, brush dust off
> them, and choose what to power (heaters, radio, or the drive). You have a
> power budget that is **smaller than the sum of what you need**. Play
> optimally and you buy a few more sols. Then the opacity rises again, the
> budget shrinks again, and whatever you do, the radio goes quiet.
>
> The panel does not say FAILED. It fades, and the log writes:
> **"Built for 90 sols. Worked for more than 5,000. Drove 45.16 km. Mission complete."**

**This must be built carefully or it will read as a bug.** Three guardrails:

1. Tell the player before they start. The flashback already shows the storm
   winning; add one line on the panel: *"This is what the team at JPL was
   trying to do. Do it as well as you can."*
2. Make optimal play *visibly* better — a counter of sols survived that
   responds to good decisions. The player must feel they mattered.
3. Afterwards, everything stays scannable and ASTROLOG marks the mission
   complete like any other. No retry prompt. Letting the player retry would
   undo the whole point.

**Accuracy trap — "My battery is low and it's getting dark" is not a real
quote.** It is a journalist's paraphrase of the final telemetry (low power,
low sunlight). Do not put it on screen as Opportunity's words. The honest
version is the telemetry itself, which is what the puzzle shows anyway.

---

## 7. Mission 3 — Interstellar

**Voyager 1 · launched 5 Sep 1977 · in interstellar space since Aug 2012.**

Not a region. A **Deep Space Network console** that stands at Tranquility and
unlocks when Mission 0 is closed. Walk up, press E, and the screen opens.

### 7.1 Why a console is the right answer
You cannot visit Voyager. Distance *is* the subject. A console makes the
player experience the one thing a walkable region would destroy: that every
question takes the better part of two days to answer.

### 7.2 The scan card
Voyager 1: a nuclear-powered probe carrying a gold-plated record of sounds and
images from Earth. Sent to fly past Jupiter and Saturn — it did that by 1980,
and has been leaving ever since. It crossed the heliopause into interstellar
space in August 2012, the first human-made object to do so. **Two of its ten
instruments are still on** (magnetometer and plasma wave). Its generator loses
about 4 W a year, so instruments are switched off one at a time to keep the
rest alive.

### 7.3 The sequence — "Nothing is broken"
Not a puzzle. A ritual, about 90 seconds:

1. The console shows the current distance, counting up in real time.
2. You compose a command. There is exactly one: **PING**.
3. You send it. A line of light leaves Earth on a map.
4. The screen says **round-trip light time: about 46 hours**, and starts a
   counter. It is not compressed; the *clock* is compressed and labelled as
   such (`×20,000`, shown on screen — the same honesty rule film v2 uses for
   the orbit sequence).
5. The reply comes. It is faint, and it is there.
6. Caption: **"Nothing is broken. It is just very far away."**

### 7.4 The topical beat — build this if nothing else
**On 18 Nov 2026 at 2:16 a.m. PST, Voyager 1 passes one light-day from Earth**
— 16.094 billion miles — the first human-made object ever that far. That is
**three days after the hackathon ends.** The console should show a live
countdown to it.

Nothing else in this project is that current. A judge watching the submission
in the week it happens sees a game counting down to a real milestone. Put the
same countdown on the end card of film v2.

---

## 8. Mission 4 — Low Earth orbit *(replaced)*

> **Replaced 14 Nov.** Mission 4 is now the **far-side relay mission**
> (`CONCEPT_REVIEW.md` §4.4): the far side of the Moon never faces Earth, so
> you deploy three relay beacons on high ground to restore the comms link. It
> is a real engineering problem — it is why China flew the Queqiao relay
> satellites — and it reuses the dish-aiming mechanic from Mission 1. Vanguard
> 1's beat was "silent since 1964", which is the wrong note to end near; it
> keeps its Archive card. The Vanguard spec is kept below for reference.

### 8.1 Reference — the original Vanguard console *(not being built)*

**Vanguard 1 · launched 17 Mar 1958 · silent since 1964.** The oldest
human-made object still in orbit. ~654 × 3,969 km, about 134 minutes a lap,
expected to stay up until roughly 2198.

Second console channel, built on the same chrome as Mission 3: an orbit plot,
a pass prediction, and a receiver that stays silent. The whole mission is a
single beat — you tune in, it comes over the horizon exactly on schedule, and
there is nothing to hear. It closes the arc: Tranquility still answers,
Voyager still answers, Opportunity stopped, and this one has been going round
in silence since before Apollo was funded.

**Naming care, from `HANDOFF.md` §6.2:** the US Naval Research Laboratory
launched it, in March 1958, **before NASA existed** (October 1958). Do not call
it "NASA's satellite." Use "the oldest satellite still in orbit" or "America's
first solar-powered satellite".

---

## 8b. The Archive — every piece of equipment on the challenge's list *(added 14 Nov)*

The challenge's Resources tab points at NASA's **NSSDCA** catalog and names
16 pieces of equipment. The film and the missions above cover 4 of them. The
rest go into one cheap, high-value object: an **NSSDCA Archive terminal** at
Tranquility, next to the DSN console (§7), built on the same panel chrome.

Data: `game/archive_catalog.json`, 18 records read from NSSDCA on 14 Nov 2026.
Each record has its COSPAR ID, launch date, resting place with coordinates,
how it ended, and a one-line story. Copy it into a ModuleScript; the card text
is already written.

**What the terminal does**
- Three tabs: **Moon · Mars · Beyond**. Each shows a simple map with a dot for
  every resting place, using the coordinates in the catalog.
- Select a dot to open a card: name, NSSDCA ID, launched, where it rests,
  last signal, and the story.
- Items the player has already scanned in the world are ticked, which ties the
  terminal to ASTROLOG.
- Footer on every card: *"Source: NASA NSSDCA, nssdc.gsfc.nasa.gov"*. This
  shows judges the recommended data source in use.

Build cost: about 1.5 h, mostly the three maps.

| Equipment (challenge list) | NSSDCA ID | In the film | In the game |
|---|---|---|---|
| Apollo LMs (Eagle) | 1969-059C | yes | Mission 0 |
| LRVs (Apollo 15) | 1971-063C | yes | Mission 1 |
| ALSEP (seismometer, retroreflector) | 1969-099C | yes | Mission 0 |
| Surveyor landers (Surveyor 3) | 1967-035A | no | Archive; **best candidate for a scan object** (below) |
| Sojourner / Pathfinder | 1996-068A | no | Archive |
| Spirit & Opportunity | 2003-027A, 2003-032A | Opportunity | Mission 2 (Opportunity); Spirit in Archive |
| Viking 1 & 2 landers | 1975-075C, 1975-083C | no | Archive |
| Phoenix & InSight | 2007-034A, 2018-042A | no | Archive |
| Ingenuity | 2020-052A | no | Archive |
| Dawn | 2007-043A | no | Archive |
| NEAR Shoemaker | 1996-008A | no | Archive |
| Pioneer 10 & 11 | 1972-012A, 1973-019A | no | Archive, and a second line on the DSN console (silent since 2003 and 1995) |
| Kepler | 2009-011A | no | Archive |

**Surveyor 3 deserves a physical spot.** It is the only discarded spacecraft
anyone ever went back to visit. Apollo 12 landed within about 180 m of it in
November 1969, and Conrad and Bean walked over and removed about 10 kg of
parts, including its TV camera, which is now in the Smithsonian (NSSDCA
1967-035A). As a scannable object in a small Apollo 12 corner of the Moon map,
its card writes itself: *"The one we came back for."*

---

## 9. Fact-check list — **cleared 14 Nov 2026**

All of these were checked; sources and the three corrections they forced are in
`CONCEPT_REVIEW.md` §6. Summary:

- [x] Apollo 15 liftoff TV — **corrected.** The liftoff *was* televised; the camera's
      *tilt* failed, so it never followed the ascent stage up. Apollo 16 also lost it
      (parked too close). Apollo 17 is the one that worked.
- [x] LRV high-gain antenna — **corrected.** It was used only while stopped; the
      *low-gain* was the one hand-aimed during drives. Drop the "low-gain carried voice"
      claim, which no source supports.
- [x] Apollo 15 LRRR: 300 corner cubes vs 100 for Apollo 11 and 14; the largest Apollo array.
- [x] Opportunity: 45.16 km confirmed. **Sol count is ambiguous** — 5,111 operational vs
      5,352 from landing. Use "more than 5,000", true under either.
- [x] Opportunity's heat shield: the meteorite found beside it is **"Heat Shield Rock"**,
      found during the first 90 sols. Not Block Island, which is a different find.
- [x] Peak dust-storm opacity: **tau 10.8**, recorded 11 June 2018, highest ever measured
      on the Martian surface.
- [x] Voyager 1 heliopause crossing: August 2012 (already sourced in `HANDOFF.md` §6.2).
- [x] Vanguard 1 — already sourced in `HANDOFF.md` §6.2. Mission 4 no longer uses it.
- [ ] **LRV-1 total distance (~27.8 km) and 3 EVAs — still unchecked.**
- [ ] **Apennine height above the Hadley plain (~3.5 km) — still unchecked**, and the
      figure in §5.1 has no source. Get a LOLA or site-specific reference, or drop the
      number from the sign.
- [ ] **Voyager 1 round-trip light time (~46 h) — still unchecked** for Nov 2026.
- [ ] **Curiosity and Perseverance operational status** — confirmed early Nov 2026, but
      from secondary sources. This is a live number feeding the ending screen's tally;
      re-check on a JPL mission page before release.

## 10. Build order

Sequenced so that the most valuable thing is finished first and Mars is
protected from the end-of-event crunch.

| # | Work | Est. | Blocks |
|---|---|---|---|
| 1 | §3 refactor: `MissionData`, split vignettes and puzzles, regroup ASTROLOG | 1.5 h | everything |
| 2 | Mission 0 close-out: `retro_ranging` puzzle + mission-complete beat | 2 h | the DSN console |
| 3 | Mission 3 console + Voyager sequence + light-day countdown | 2 h | — |
| 4 | Mission 1 Hadley: terrain, rover placement, 3 cards | 2 h | — |
| 5 | Mission 1: drive flashback + `lrv_dish` puzzle + co-op variant | 2.5 h | #4 |
| 6 | Publish, enable API services, **two-player test in a real server** | 1 h | #1 |
| 7 | Mission 2 Mars: second place, teleport, DataStore log, terrain | 3 h | #6 |
| 8 | Mission 2: storm flashback + `oppy_power` + the ending | 2.5 h | #7 |
| 9 | Mission 4 Vanguard console | 1.5 h | #3 |
| 10 | Pass over all card text against §9; capture footage for film v2 | 1.5 h | all |

Step 6 is not optional and not postponable. Teleports and DataStores do not
work in Studio solo play, so the first time they run in a real server must not
be at hour 32.

Rough total to the must-have cut (steps 1–8): **~17 h**. With everything,
~20 h. That is deliverable in the event if the film is running in parallel,
and it is the honest number — it is not deliverable by one person doing both.

---

## 11. Open questions for the user

1. **Does the rover drive, or is it a flashback only?** Spec above is flashback
   only, because a drivable VehicleSeat on a mesh with no real wheels is a
   half-day of physics tuning and a long tail of bugs. If driving matters more
   than Mars, say so and the order changes.
2. **Does ASTROLOG persist between sessions?** The DataStore in §3.3 gives you
   that for free once Mars exists. Worth confirming you want progress saved —
   it changes whether a judge opening the game sees it fresh or half-finished.
3. **Mission 4 at all?** It's the weakest beat and the one most likely to eat
   the fact-check budget.
4. **The pre-event rule.** This document is a plan, not built content, but
   `HANDOFF.md` §0.1 is unresolved. Still worth the Local Lead's answer before
   the event opens.

## v131 — storms, shelters, lost signal
- Shelter domes on every world (build/shelters.lua): 6 Moon (station counts), 6 Mars, 1 Eros.
- StormServer: Mars dust events reduce sunlight and suit solar power; Moon/Eros solar particle
  events are a separate gameplay abstraction. Event intervals/durations are compressed for play.
  Zero power routes the player to a shelter without death. InSight and Opportunity are shown with
  present-day panel dust; a separate prompt represents panel cleaning without disabling artifact scans.
  Occasional Mars wind events can clean arrays; gradual buildup and clearing are compressed.
- Storm client: banner, SUIT bar, SIGNAL bars. Tranquility starts as lost signal: its Scan prompts
  stay off until you sweep in on the noisy signal (<22 studs). Validator clean.
- Historical test note: warn banner, starting panel-dust visuals, signal lock, drain to 0 + autopilot.

## 2026-11-15 — hazard and jump accuracy pass
- Mars dust accumulation is no longer an automatic consequence of every storm. Separate panel-dust
  visuals preserve artifact scanning; occasional wind events may clear arrays, matching observed
  Spirit/Opportunity cleaning events. Gameplay timing remains explicitly compressed.
- Moon jump target is grounded in Apollo 16's observed 2.7 ft (about 0.82 m) high jump by Charlie
  Duke, with the backward fall noted. Mars jump remains labelled as an unverified gameplay estimate.
- Roblox gravity and stud scaling remain stylized; this is not presented as a validated suit biomechanics model.

"""Captions from the word-level transcript of voiceover_long.mp3.
Splits each spoken line into chunks of at most ~42 characters, timed from word
timestamps, fixes the transcription errors, and marks key words for highlight."""
import json, re
segs = json.load(open("../transcription_long.json"))

# transcription errors -> what the narrator actually says
FIX = {"Hadley Reel": "Hadley Rille", "if you shown": "if you shone",
       "further out, passed all": "further out, past all",
       "Opportunity solar panels": "Opportunity's solar panels",
       "moon quakes": "moonquakes", "Astrolog log book": "Astrolog logbook",
       "last signal on Roblox": "LAST SIGNAL on Roblox", "400 ,000": "400,000", "of the eagle": "of the Eagle"}
HI = ["1969", "21 hours", "flag", "footprints", "Eagle", "descent stage", "top cabin",
      "Tranquility Base", "seismometer", "moonquakes", "70 kilometers", "nearly an hour",
      "Hadley Rille", "Apollo 15", "1971", "50 years", "Mars", "weather", "Opportunity",
      "90 days", "5,000 days", "2018", "June 10th", "1,000 commands", "Voyager 1", "1977",
      "26 billion kilometers", "24 whole hours", "Two of its 10", "corner cube reflectors",
      "green laser", "400,000 kilometers", "10 times", "two and a half seconds",
      "four centimeters", "fingernails", "abandoned", "not forgotten", "space suit",
      "Astrolog", "LAST SIGNAL", "Moon", "moon"]
MAXC = 42

caps = []
for s in segs:
    words = []
    for w in s["words"]:
        tx = w["word"].strip()
        if not tx: continue
        if words and tx[0] in ",.;:!?":      # "400" ",000" -> "400,000"
            p0 = words[-1]; words[-1] = (p0[0] + tx, p0[1], w["end"]); continue
        words.append((tx, w["start"], w["end"]))
    # balanced split: k chunks of roughly equal length, so no orphan single words
    total = len(" ".join(x[0] for x in words))
    k = max(1, -(-total // MAXC)); target = total / k
    chunks, cur = [], []
    for j, w in enumerate(words):
        trial = " ".join(x[0] for x in cur + [w])
        if cur and len(chunks) < k - 1 and (len(trial) > target + 4 or len(trial) > MAXC + 6):
            chunks.append(cur); cur = []
        cur.append(w)
    if cur: chunks.append(cur)
    for c in chunks:
        caps.append([round(c[0][1], 2), round(c[-1][2], 2), " ".join(x[0] for x in c)])

text_all = "\n".join(c[2] for c in caps)
for i, c in enumerate(caps):
    t = c[2]
    for a, b in FIX.items():
        t = re.sub(re.escape(a), b, t, flags=re.I)
    # highlight: wrap known phrases in *...*, longest first, never double-wrap
    for k in sorted(HI, key=len, reverse=True):
        t = re.sub(r"(?<![\w*])(" + re.escape(k) + r")(?![\w*])", r"*\1*", t, count=1)
    c[2] = t
# a fix can straddle two chunks ("Hadley" | "Reel"): patch neighbours too
for i in range(len(caps) - 1):
    if caps[i][2].endswith("Hadley") and caps[i + 1][2].startswith("Reel"):
        caps[i + 1][2] = "Rille" + caps[i + 1][2][4:]
    if caps[i][2].endswith("if you") and caps[i + 1][2].startswith("shown"):
        caps[i + 1][2] = "shone" + caps[i + 1][2][5:]
# hold each caption until the next starts (no flicker in short gaps), cap 0.6 s overhang
for i in range(len(caps) - 1):
    gap = caps[i + 1][0] - caps[i][1]
    if 0 < gap < 0.6: caps[i][1] = caps[i + 1][0]
json.dump(caps, open("captions.json", "w"), indent=0)
print(len(caps), "captions")
for c in caps[:6] + caps[40:46] + caps[-4:]:
    print(f"{c[0]:7.2f}-{c[1]:7.2f}  {c[2]}")
bad = [c for c in caps if re.search(r"Reel|shown|passed all", c[2])]
print("uncorrected errors left:", bad)

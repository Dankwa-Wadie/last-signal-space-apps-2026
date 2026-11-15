import json

with open("pipeline/transcription_long.json") as f:
    segments = json.load(f)

raw_cards = []

for seg in segments:
    words = seg.get("words", [])
    if not words:
        raw_cards.append({"start": seg["start"], "end": seg["end"], "text": seg["text"]})
        continue

    cur_words = []
    card_start = words[0]["start"]

    for w in words:
        word_txt = w["word"].strip()
        if not word_txt:
            continue
        cur_words.append(word_txt)
        cur_phrase = " ".join(cur_words)

        # Break conditions
        ends_punct = word_txt[-1] in ".!?,;:"
        time_span = w["end"] - card_start

        # Break if long enough, or ends with punct and has >= 3 words, or time > 2.2s
        if len(cur_phrase) >= 28 or (ends_punct and len(cur_words) >= 3) or time_span >= 2.2:
            raw_cards.append({
                "start": round(card_start, 2),
                "end": round(w["end"], 2),
                "text": cur_phrase
            })
            cur_words = []
            card_start = w["end"]

    if cur_words:
        raw_cards.append({
            "start": round(card_start, 2),
            "end": round(words[-1]["end"], 2),
            "text": " ".join(cur_words)
        })

# Post-processing: Merge very short trailing fragments (< 2 words or < 0.6s) into previous card
merged = []
for c in raw_cards:
    txt = c["text"].strip()
    words = txt.split()
    duration = c["end"] - c["start"]
    if len(words) <= 2 and duration < 0.8 and merged:
        # Merge with previous
        merged[-1]["text"] += " " + txt
        merged[-1]["end"] = c["end"]
    else:
        merged.append(c)

# Ensure strictly non-overlapping intervals and min duration
final_cards = []
for i, c in enumerate(merged):
    s = c["start"]
    e = c["end"]
    # Ensure minimum visible duration of 0.8s
    if e - s < 0.8:
        e = s + 0.8
    # Ensure no overlap with next card
    if i < len(merged) - 1:
        next_s = merged[i+1]["start"]
        if e > next_s:
            e = max(s + 0.4, next_s - 0.05)
    final_cards.append([round(s, 2), round(e, 2), c["text"]])

print(f"Refined {len(final_cards)} subtitle cards.")

with open("pipeline/script_long.json", "w") as f:
    json.dump(final_cards, f, indent=2)

print("Saved to pipeline/script_long.json!")

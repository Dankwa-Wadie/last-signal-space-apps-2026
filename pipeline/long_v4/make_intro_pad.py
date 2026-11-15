"""Intro music for the 3 s solar-system opening: a slow-swelling A-minor(add9) synth pad with a
shimmer, rising under the sweep and fading as the narrator begins. Procedural (no samples).
Writes intro_pad.wav (48 kHz stereo, 5 s: it tails under the first words)."""
import numpy as np, wave
SR = 48000; DUR = 5.0
t = np.arange(int(SR * DUR)) / SR
notes = [110.0, 164.81, 220.0, 261.63, 329.63, 493.88]
amps  = [0.30, 0.22, 0.20, 0.14, 0.12, 0.07]
sig = np.zeros((len(t), 2))
rng = np.random.default_rng(7)
for f, a in zip(notes, amps):
    for ch, det in ((0, -0.18), (1, 0.21)):            # slight detune per side for width
        ph = rng.uniform(0, 2 * np.pi)
        x = np.sin(2 * np.pi * (f + det) * t + ph) + 0.35 * np.sin(2 * np.pi * 2 * (f + det) * t + ph)
        sig[:, ch] += a * x
# shimmer: high partials fading in with the zoom
for f in (987.77, 1318.5):
    sig[:, 0] += 0.025 * np.sin(2 * np.pi * f * t) * np.clip(t / 2.5, 0, 1)
    sig[:, 1] += 0.025 * np.sin(2 * np.pi * (f * 1.003) * t) * np.clip(t / 2.5, 0, 1)
env = np.clip(t / 2.6, 0, 1) ** 1.6                       # swell over the sweep
env *= np.where(t < 2.9, 1.0, np.clip(1 - (t - 2.9) / 2.1, 0, 1) ** 1.3)   # then tuck under the voice
sig *= env[:, None]
# simple reverb: convolve with a decaying noise tail
ir = rng.standard_normal(int(SR * 1.6)) * np.exp(-np.arange(int(SR * 1.6)) / (SR * 0.45))
for ch in range(2):
    wet = np.convolve(sig[:, ch], ir)[: len(t)] * 0.012
    sig[:, ch] = sig[:, ch] * 0.75 + wet
sig /= np.max(np.abs(sig)) / 0.5
pcm = (sig * 32767).astype(np.int16)
with wave.open("intro_pad.wav", "wb") as w:
    w.setnchannels(2); w.setsampwidth(2); w.setframerate(SR); w.writeframes(pcm.tobytes())
print("intro_pad.wav", DUR, "s")

Scene notes for render_roblox_v3.py (reference only, not executed)

- mars   : ../scenes/s4_mars.lua   + Opportunity restored from asset 140476596063186
- retro  : ../scenes/s6_retro.lua  + retro_frame.lua (outgoing pulse local frame 29, return 89)
- lander : ../scenes/s2_boot.lua

Every shot renders twice:
  beauty/   normal Roblox frame
  matte/    every part in workspace.Scene forced to white Neon, effects off, sky dark
compose.py uses matte luma as alpha and fills the sky with the shared starfield
(Moon) or a Martian daytime gradient (Mars), ray-traced from the logged camera.

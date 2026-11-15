# STILL WORKING — game source backup

Exported from the live Studio place so the build survives a Studio crash.
**This is a backup, not the source of truth** — the place itself is.

- `scripts/` — every script, verbatim (Script / LocalScript / ModuleScript)
- `manifest.json` — artifact positions + attributes, library mesh IDs,
  world settings, and a `recovery` block for rebuilding lost meshes

Re-export any time after changes: run `export_game.lua` through the StudioMCP
bridge (see `../pipeline/render_film.py` for the bridge pattern).

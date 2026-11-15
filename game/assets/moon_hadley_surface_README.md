# Hadley–Apennine lunar terrain

The surface is modeled in Blender as a continuous mare plain with an irregular Apennine mountain front, the sinuous Hadley Rille, low shoulders, and four subdued crater bowls. The ridge and rille are based on the Apollo 15 Hadley–Apennine landing region. Vertical relief is compressed for the game's scale, while the shape keeps the major geological features visible.

## Files

- `moon_hadley_surface.blend` — native Blender source (2,500 × 1,900 m terrain grid).
- `moon_hadley_surface_roblox.fbx` — game-scale export, split into 10 sealed mesh strips.

Each exported mesh has 18,312 triangles, below Roblox's 20,000-triangle individual mesh limit. The assembled target footprint is about 425 × 323 studs, with about 14 studs of visible relief. The FBX has no image textures; it uses a matte regolith material and geometry for its landforms.

The imported model is installed at `Workspace.Game.HadleyApennineTerrain`, centered on the relocated Apollo 15 site at `(-451.47, -579.31)` in the game's X/Z plane. The Blender FBX arrived 4.82× too large, so Studio applied a `0.2075195` scale factor. The ten MeshParts are anchored, use Sand color/material, and use precise convex decomposition for collision. The older 81-part prototype relief was removed; the Hadley ground slab is retained as an invisible, non-colliding reference.

The endless-ground LocalScript hides and disables its flat tiles under this terrain footprint and allows lunar footprints on the imported mesh. A live Play check confirmed the character lands on Sand on the plain, Apennine ridge, and in the rille.

Imported Roblox mesh IDs:

| FBX strip | Mesh asset ID |
| --- | --- |
| 01 | `114198683297178` |
| 02 | `95584739913328` |
| 03 | `96946761738133` |
| 04 | `113819226272043` |
| 05 | `138016789395742` |
| 06 | `107782772568347` |
| 07 | `138995235264676` |
| 08 | `106568057696464` |
| 09 | `70839564839370` |
| 10 | `128005005888512` |

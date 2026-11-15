# Hadley–Apennine lunar terrain

The surface is modeled in Blender as a continuous mare plain with an irregular Apennine mountain front, the sinuous Hadley Rille, low shoulders, and four subdued crater bowls. The ridge and rille are based on the Apollo 15 Hadley–Apennine landing region. Vertical relief is compressed for the game's scale, while the shape keeps the major geological features visible.

## Files

- `moon_hadley_surface.blend` — native Blender source (2,500 × 1,900 m terrain grid).
- `moon_hadley_surface_roblox.fbx` — game-scale export, split into 10 sealed mesh strips.

Each exported mesh has 18,312 triangles, below Roblox's 20,000-triangle individual mesh limit. The assembled target footprint is about 425 × 323 studs, with about 14 studs of visible relief. The FBX has no image textures; it uses a matte regolith material and geometry for its landforms.

The game layout target is centered near the Apollo 15 region around `(430, 0, -210)`. Verify imported axis orientation, scale, terrain seams, ground contact, and clearance from artifact models before replacing the current rough relief in the live place.

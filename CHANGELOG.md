# Changelog

## 1.0.2

- Added `creativePickItem` support for plant blocks.
- Added GUI `onTick` support using Fabric `ServerTickEvents`.

## 1.0.1

- Fixed `NullPointerException` when saving elements in workspaces that contain
  tag elements (missing `tags` specification in the generator).
- Tab search is still not available on Minecraft 1.20.1; the field remains
  intentionally disabled.

## 1.0.0

- Initial public release of **TFabric-Generator-1.20.1**.
- Fabric 1.20.1 generator for MCreator 2024.4.
- OBJ block models selected in the block editor, with automatic manifest,
  texture lookup, rotations and item model support.
- Fixed `BlockModel parent has to be a block model` crash.
- Fixed blocks being registered in every custom creative tab.
- Block and plant loot tables.
- Block tags: tool levels, stairs, slabs, fences, walls, leaves, replaceable.
- Tool item tags: pickaxes, axes, swords, shovels, hoes.
- Sapling support with generated `TreeGrower`.
- Plant tags: saplings, replaceable.
- Tooltip localization for blocks, plants and tools.
- Item music disc tag.
- Fuel and compost support through Fabric API.
- Bundled BSL shader edits for the Whiteout tree models (leaves/plants wind).

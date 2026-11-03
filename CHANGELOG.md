# Changelog / История изменений

## 1.0.2

### English
- Added `creativePickItem` support for plant blocks.
- Added GUI `onTick` support using Fabric `ServerTickEvents`.

### Русский
- Добавлена поддержка `creativePickItem` для растений.
- Добавлена поддержка `onTick` для GUI через Fabric `ServerTickEvents`.

## 1.0.1

### English
- Fixed `NullPointerException` when saving elements in workspaces that contain
  tag elements (missing `tags` specification in the generator).
- Tab search is still not available on Minecraft 1.20.1; the field remains
  intentionally disabled.

### Русский
- Исправлен `NullPointerException` при сохранении элементов в воркспейсах,
  где есть элементы-теги (в генераторе не хватало `tags`-спецификации).
- Поиск по вкладке в Minecraft 1.20.1 по-прежнему недоступен; поле отключено
  намеренно.

## 1.0.0

### English
- Initial public release of **TFabric-Generator-1.20.1**.
- Fabric 1.20.1 generator for MCreator 2024.4.
- OBJ block models selected in the block editor, with automatic manifest,
  texture lookup, rotations and block item model support.
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

### Русский
- Первый публичный релиз **TFabric-Generator-1.20.1**.
- Генератор Fabric 1.20.1 для MCreator 2024.4.
- OBJ-модели блоков, выбираемые в редакторе блока: автоматический манифест,
  поиск текстуры, повороты и поддержка item-модели блока.
- Исправлен краш `BlockModel parent has to be a block model`.
- Исправлена регистрация блоков во всех кастомных креативных вкладках.
- Loot-таблицы блоков и растений.
- Теги блоков: уровни инструментов, `stairs`, `slabs`, `fences`, `walls`,
  `leaves`, `replaceable`.
- Теги инструментов: `pickaxes`, `axes`, `swords`, `shovels`, `hoes`.
- Поддержка саженцев со сгенерированным `TreeGrower`.
- Теги растений: `saplings`, `replaceable`.
- Локализация тултипов блоков, растений и инструментов.
- Тег `music_discs` для предметов.
- Поддержка топлива и компоста через Fabric API.

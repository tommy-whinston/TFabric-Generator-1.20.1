# Changelog / История изменений

## 1.1.0

### English
- OBJ models for **items, tools and armor pieces** (helmet, chestplate,
  leggings, boots), generated through `obj_items_generated.json`.
- Multiple textures per OBJ model through materials (`usemtl`) and MCreator's
  `*.obj.textures` sidecar.
- Dedicated item, tool and block transforms (first person, third person,
  GUI, ground, head, fixed).
- Rotation support for multipart blockstates that reference the OBJ model.
- Added `display` to the manifest format and item lighting for OBJ items.
- Face culling for block OBJ models is now **opt-in** (`"culling": true`).
  It is disabled by default because complex models can lose faces or render
  incorrectly with some Sodium/Iris shader setups.
- Added the `tint_index` manifest option for tinted block models.
- OBJ quads are now **double-sided by default** (`double_sided`): single-sided
  models no longer show see-through gaps in the trunk and canopy.
- README rewritten from scratch, new banner and artwork, `CONTRIBUTING.md`,
  issue templates and GitHub Actions for validation and releases.

### Русский
- OBJ-модели для **предметов, инструментов и брони** (шлем, нагрудник,
  штаны, ботинки) через `obj_items_generated.json`.
- Несколько текстур на OBJ-модель через материалы (`usemtl`) и sidecar
  `*.obj.textures` от MCreator.
- Отдельные трансформы для предметов, инструментов и блоков (рука, GUI,
  земля, голова, рамка).
- Culling граней у блочных OBJ-моделей теперь **опциональный**
  (`"culling": true`) и по умолчанию выключен: сложные модели могут терять
  грани или рендериться некорректно с некоторыми сборками Sodium/Iris.
- Поддержка поворотов multipart-blockstate, если часть ссылается на
  OBJ-модель.
- В формат манифеста добавлено поле `display`; для OBJ-предметов
  используется item-освещение.
- Добавлена опция манифеста `tint_index` для тонированных блочных моделей.
- Квады OBJ теперь **двусторонние по умолчанию** (`double_sided`):
  односторонние модели больше не дают просветов в стволе и кроне.
- README переписан с нуля (RU/EN), новый баннер и иллюстрации,
  `CONTRIBUTING.md`, issue-шаблоны и GitHub Actions для проверки и релизов.

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

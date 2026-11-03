# Promotion kit / Пакет для продвижения

Готовые тексты и чек-лист для запуска **TFabric-Generator-1.20.1**.
Скопируй нужный блок и опубликуй от своего имени. Без спама: сначала
польза, потом ссылка.

> **Ссылки для вставки**
> - Репозиторий: https://github.com/tommy-whinston/TFabric-Generator-1.20.1
> - Релиз: https://github.com/tommy-whinston/TFabric-Generator-1.20.1/releases/tag/v1.1.0
> - Скачать: https://github.com/tommy-whinston/TFabric-Generator-1.20.1/releases/latest

---

## 1. Страница на mcreator.net

### Русский

**Название:** TFabric-Generator-1.20.1

**Короткое описание:**
Доработанный Fabric-генератор для MCreator 2024.4: исправления, теги,
деревья, инструменты, лут-таблицы и OBJ-модели.

**Полное описание:**

**TFabric-Generator-1.20.1** — доработанная сборка Fabric-генератора для
MCreator 2024.4. Это не генератор с нуля: за основу взят популярный
Fabric-генератор, поверх добавлены исправления и новые возможности.

**Что внутри:**

- Исправлен `NullPointerException` при сохранении элементов-тегов.
- Исправлен краш `BlockModel parent has to be a block model`.
- Блоки регистрируются только в выбранных креативных вкладках.
- Loot-таблицы блоков и растений.
- Теги блоков: уровни инструментов, `stairs`, `slabs`, `fences`, `walls`,
  `leaves`, `replaceable`.
- Саженцы с автоматическим `TreeGrower`.
- Теги растений: `saplings`, `replaceable`.
- `creativePickItem` для растений и GUI `onTick`.
- Теги инструментов: `pickaxes`, `axes`, `swords`, `shovels`, `hoes`.
- Топливо, компост, музыкальные пластинки и тултипы.
- OBJ-модели блоков, предметов, инструментов и брони: авто-манифесты,
  несколько текстур, трансформы, двусторонние грани.
- Стабильный рендер с Sodium/Iris: сложные модели не просвечивают.

**Установка:**

1. Скачай `TFabric-Generator-1.20.1.zip` из раздела Releases.
2. Открой **MCreator → Preferences → Manage plugins → Install plugin from file**.
3. Перезапусти MCreator и создай воркспейс с генератором
   **TFabric-Generator-1.20.1 for 1.20.1 - 0.90.7**.

**Совместимость:** MCreator 2024.4, Minecraft 1.20.1, Fabric API 0.90.7+1.20.1.

**Лицензия:** LGPL-3.0.

### English

**Name:** TFabric-Generator-1.20.1

**Short description:**
An improved Fabric generator for MCreator 2024.4: fixes, tags, trees, tools,
loot tables and OBJ models.

**Full description:**

**TFabric-Generator-1.20.1** is an improved build of the Fabric generator for
MCreator 2024.4. It is not a generator written from scratch: the popular
Fabric generator is used as the base, with fixes and new features added on top.

**What's inside:**

- Fixed the `NullPointerException` when saving tag elements.
- Fixed the `BlockModel parent has to be a block model` crash.
- Blocks are registered only in their selected creative tabs.
- Block and plant loot tables.
- Block tags: tool levels, `stairs`, `slabs`, `fences`, `walls`, `leaves`,
  `replaceable`.
- Saplings with an automatic `TreeGrower`.
- Plant tags: `saplings`, `replaceable`.
- `creativePickItem` for plants and GUI `onTick`.
- Tool tags: `pickaxes`, `axes`, `swords`, `shovels`, `hoes`.
- Fuel, compost, music discs and tooltips.
- OBJ models for blocks, items, tools and armor: automatic manifests, multiple
  textures, transforms and double-sided faces.
- Stable Sodium/Iris rendering: complex models no longer show gaps.

**Installation:**

1. Download `TFabric-Generator-1.20.1.zip` from Releases.
2. Open **MCreator → Preferences → Manage plugins → Install plugin from file**.
3. Restart MCreator and create a workspace with the
   **TFabric-Generator-1.20.1 for 1.20.1 - 0.90.7** generator.

**Compatibility:** MCreator 2024.4, Minecraft 1.20.1, Fabric API 0.90.7+1.20.1.

**License:** LGPL-3.0.

---

## 2. Посты для запуска

### MCreator Forum / Discord (RU)

> **TFabric-Generator — доработка Fabric-генератора для MCreator 2024.4**
>
> Сделал сборку Fabric-генератора, в которой исправлены краши с тегами и
> `BlockModel parent`, добавлены лут-таблицы, теги инструментов, деревья с
> `TreeGrower`, `creativePickItem`, GUI `onTick`, тултипы, топливо/компост
> и OBJ-модели для блоков, предметов и брони.
>
> Плагин самодостаточный: обычный Fabric-генератор отдельно ставить не нужно.
>
> Установка: MCreator → Preferences → Manage plugins → Install from file.
> Скачать: <release link>
>
> Буду рад фидбеку и багам — особенно по рендеру с Sodium/Iris.

### MCreator Forum / Discord (EN)

> **TFabric-Generator — an improved Fabric generator for MCreator 2024.4**
>
> I built an improved version of the Fabric generator with fixes for the tag
> NPE and `BlockModel parent` crash, plus loot tables, tool tags, saplings with
> `TreeGrower`, `creativePickItem`, GUI `onTick`, tooltips, fuel/compost and
> OBJ models for blocks, items and armor.
>
> The add-on is standalone: you do not need to install the regular Fabric
> generator separately.
>
> Install: MCreator → Preferences → Manage plugins → Install from file.
> Download: <release link>
>
> Feedback and bug reports are welcome — especially Sodium/Iris rendering.

### Reddit / r/MCreator (EN)

**Title:** I improved the Fabric generator for MCreator 2024.4 — fixes, tags, trees, tools and OBJ models

**Body:**

> MCreator's Fabric generator is great, but a few things kept breaking for me:
> tag elements caused an NPE on save, blocks were added to every creative tab,
> and some model setups crashed with `BlockModel parent has to be a block model`.
>
> So I made an improved build that keeps the base generator and adds:
>
> - fixes for the tag NPE, creative tabs and model parent crash;
> - block/plant loot tables and tool-level tags;
> - saplings with generated `TreeGrower`;
> - `creativePickItem` and GUI `onTick`;
> - tool tags, fuel/compost, tooltips and music discs;
> - OBJ models for blocks, items, tools and armor;
> - Sodium/Iris-safe rendering for complex models.
>
> It is a generator add-on, not a runtime mod. Install it through
> **Preferences → Manage plugins**, then create a workspace with the
> `TFabric-Generator-1.20.1` generator.
>
> Download / source: <repo link>
>
> Happy to hear feedback, especially from people using Sodium/Iris or custom
> OBJ trees.

### Telegram / VK (RU)

> **TFabric-Generator-1.20.1 — доработка Fabric-генератора для MCreator 2024.4**
>
> Что нового:
> — исправлены NPE с тегами и краш `BlockModel parent`;
> — блоки больше не попадают во все креативные вкладки;
> — лут-таблицы, теги инструментов и блоков;
> — саженцы с автоматическим `TreeGrower`;
> — `creativePickItem`, GUI `onTick`, тултипы, топливо/компост;
> — OBJ-модели блоков, предметов и брони;
> — стабильный рендер с Sodium/Iris.
>
> Плагин самодостаточный, обычный Fabric-генератор не нужен.
> Скачать: <release link>
> Исходники: <repo link>

### YouTube / Shorts — описание (RU)

> **TFabric-Generator-1.20.1 — Fabric-генератор для MCreator 2024.4**
>
> В этом видео: установка плагина, исправление крашей с тегами, создание
> блока с тегами и лут-таблицей, саженец с `TreeGrower`, инструмент с тегом
> и OBJ-модель дерева.
>
> Скачать: <release link>
> Исходники: <repo link>
>
> #MCreator #Fabric #Minecraft #Modding #MCreatorPlugin

---

## 3. Сценарий видео на 60 секунд

| Время | Сцена | Текст на экране / голос |
| --- | --- | --- |
| 0–5 с | MCreator, открытый воркспейс | «MCreator + Fabric: убираем краши и добавляем деревья, теги и модели» |
| 5–15 с | Preferences → Manage plugins → Install from file, выбор zip | «Устанавливаем TFabric-Generator-1.20.1» |
| 15–25 с | Создание блока, вкладка тегов и лут-таблицы | «Теги, лут-таблицы и креативные вкладки работают без NPE» |
| 25–35 с | Создание саженца, выбор дерева, генерация | «Саженец сам получает TreeGrower» |
| 35–45 с | Создание инструмента, тег pickaxe | «Инструменты сразу попадают в нужные теги» |
| 45–55 с | Блок с OBJ-моделью, запуск мира | «OBJ-модели блоков, предметов и брони» |
| 55–60 с | Плашка с ссылкой на релиз | «Скачать: github.com/tommy-whinston/TFabric-Generator-1.20.1» |

**Совет:** запиши два варианта — вертикальный (Shorts/TikTok) и
горизонтальный (YouTube). Вертикальный даёт больше охвата.

---

## 4. Демо-воркспейс

Сделай отдельный воркспейс `TFabric Demo` на этом генераторе. Минимальный
набор для скриншотов и видео:

- [ ] Блок `demo_block`: теги `needs_stone_tool`, `stairs`/`slabs`, loot table.
- [ ] Блок `demo_leaf`: тег `leaves`, cutout.
- [ ] Растение `demo_sapling`: своё дерево, `TreeGrower`, тег `saplings`.
- [ ] Инструмент `demo_pickaxe`: тег `pickaxes`, тултип.
- [ ] Предмет `demo_item`: тултип, топливо/компост.
- [ ] Блок `demo_obj_tree`: OBJ-модель дерева.
- [ ] Предмет `demo_obj_sword`: OBJ-модель.
- [ ] Броня `demo_armor`: OBJ-модели для 4 частей.
- [ ] GUI `demo_gui`: `onTick` (по желанию).

Для демо-мира:

- [ ] Плоский мир, снег/трава, несколько деревьев и блоков.
- [ ] 5 скриншотов: меню плагина, блок с тегами, дерево, инструмент, OBJ-модель.
- [ ] 30–60-секундная запись экрана.
- [ ] Ссылка на скачивание демо-воркспейса или демо-мода.

---

## 5. Чек-лист запуска

- [ ] Загрузить `docs/social-preview.png` в **Settings → Social preview**.
- [ ] Создать страницу плагина на **mcreator.net**.
- [ ] Проверить, что релиз содержит zip и корректные notes.
- [ ] Опубликовать пост на **MCreator Forum**.
- [ ] Написать в **MCreator Discord**.
- [ ] Пост в **Reddit r/MCreator**.
- [ ] Пост в **Telegram/VK**.
- [ ] Выложить **YouTube Shorts** или TikTok.
- [ ] Добавить в README ссылку на видео/демо (когда будет).
- [ ] Отвечать на issues и собирать фидбек первые 2 недели.
- [ ] Выпустить патч, если найдутся баги (это повышает доверие).

---

## 6. Что не стоит делать

- Не постить ссылку в тредах, где она не по теме.
- Не писать «лучший генератор» без демонстрации.
- Не спамить в Discord в нескольких каналах сразу.
- Не обещать Forge/1.21 поддержку, если её нет.
- Не скрывать ограничения: лучше честно указать, что не поддерживается.

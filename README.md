# TFabric-Generator-1.20.1

> Fabric 1.20.1 generator add-on for MCreator 2024.4 with extra block,
> item and plant features.

Аддон-генератор для MCreator 2024.4 на базе Minecraft Fabric 1.20.1
с дополнительными возможностями для блоков, предметов и растений.

## Возможности

- Loot-таблицы блоков и растений (`generateLootTable()`).
- Теги блоков: `needs_stone_tool`, `needs_iron_tool`, `needs_diamond_tool`,
  `stairs`, `slabs`, `fences`, `walls`, `leaves`, `replaceable`.
- Теги инструментов: `pickaxes`, `axes`, `swords`, `shovels`, `hoes`.
- Саженцы с `TreeGrower` (кастомные деревья из настроек растения).
- Теги растений: `saplings`, `replaceable`.
- Топливо и компост для item extension (Fabric API).
- Тултипы блоков/растений/инструментов в lang-файлах.
- OBJ-модели блоков и block-item (выбор модели у блока, авто-привязка,
  текстуры, повороты `facing`/`axis`, центрирование origin).

## Чего пока нет

- `Attribute` — кастомные атрибуты сущностей (нужны миксины).
- `Fluid` — собственные жидкости (нужен отдельный Fabric fluid API, рендер,
  ведро и теги).
- OBJ-модели предметов, инструментов и брони (для блоков и block-item
  OBJ работает).
- Энергохранилища и жидкостные баки в блоках.

## Установка

1. Установите `TFabric-Generator-1.20.1.zip` через
   **MCreator → Preferences → Manage plugins → Install plugin from file**
   или просто положите zip в `%USERPROFILE%\.mcreator\plugins`.
2. Перезапустите MCreator.

Плагин самодостаточен: отдельный Fabric-генератор устанавливать не нужно.

## Создание воркспейса

При создании нового воркспейса выберите генератор:

> TFabric-Generator-1.20.1 for 1.20.1 - 0.90.7

Старые воркспейсы, созданные на обычном `fabric-1.20.1`, этот генератор
автоматически не переключает. Для нового проекта просто выберите этот
генератор при создании воркспейса. В старом воркспейсе OBJ-поддержку можно
оставить в ручном режиме (как было настроено) либо перенести проект в новый
воркспейс с этим генератором.

## Как добавить OBJ-модель

1. Импортируйте OBJ в MCreator (**Resources → Models**), при импорте
   выберите текстуру.
2. Создайте блок и в настройках блока выберите **модель: OBJ** и
   импортированную модель.
3. Соберите проект.

Плагин сам создаёт `assets/<modid>/obj_models_generated.json` с привязкой
`блок → OBJ` и подставляет текстуру, выбранную у блока. Имя блока и имя
файла модели могут не совпадать.

Дополнительно работает авто-обнаружение: если OBJ лежит в
`assets/<modid>/models/item/<block>.obj` (или `<block>_something.obj`),
он привяжется к блоку `<block>` даже без выбора модели в редакторе.

Если текстура не задана явно, плагин ищет `textures/block/<имя_OBJ>.png`,
затем `textures/block/<имя_блока>.png`.

Если текстура называется иначе, но начинается с имени блока
(`willow_bark.png`, `willow_leaves.png` и т.п.), она тоже будет найдена,
если такой файл единственный. Иначе укажите текстуру в манифесте.

## Манифест (необязательно)

Для нестандартных имён или настроек создайте
`src/main/resources/assets/<modid>/obj_models.json`:

```json
{
  "models": {
    "mymod:willow": {
      "obj": "mymod:models/item/willow_tree.obj",
      "texture": "mymod:block/willow_bark",
      "model": "mymod:block/willow",
      "scale": 16.0,
      "flip_u": false,
      "flip_v": true,
      "ambient_occlusion": false,
      "gui_3d": true,
      "shade": true,
      "block_light": true
    }
  }
}
```

Доступные поля:

| Поле | По умолчанию | Описание |
| --- | --- | --- |
| `obj` | `models/item/<block>.obj` | путь к OBJ |
| `texture` | `block/<block>` | текстура без `textures/` и `.png` |
| `model` | `block/<block>` | id модели, которую заменяет OBJ |
| `scale` | `16.0` | масштаб: 16 — один блок |
| `center` | `false` | авто-центрирование bounding box по X/Z и низа по Y=0 вместо origin |
| `offset_x` / `offset_y` / `offset_z` | `0.5` / `0` / `0.5` | смещение в блоках; по умолчанию origin Blockbench ставится в центр блока |
| `flip_u` / `flip_v` | `false` / `true` | переворот UV |
| `ambient_occlusion` | `false` | ambient occlusion |
| `gui_3d` | `true` | 3D-отображение в GUI |
| `shade` | `true` | затенение граней |
| `block_light` | `true` | освещение как у блока |

Строковая сокращённая запись тоже поддерживается:

```json
{
  "models": {
    "mymod:willow": "mymod:models/item/willow_tree.obj"
  }
}
```

## Прозрачность

Если в OBJ есть прозрачные участки, включите у блока тип рендера
**Cutout** или **Translucent** (Render type / Transparency type).
Если тип не задан, для OBJ-блока автоматически ставится Cutout.
Явно выбранный Translucent плагин не переопределяет.

## Повороты и параметры блока

Плагин читает сгенерированный `blockstates/<block>.json` и применяет
повороты вариантов (`facing`, `axis`, `x`/`y`) к OBJ-модели, поэтому
режимы поворота MCreator (Facing, Axis и т.д.) работают.

Остальные параметры блока (хитбокс, коллизии, свет, звук, прочность,
инструмент, дроп) генерируются MCreator как обычно и от OBJ-модели
не зависят.

## Ограничения

- Одна текстура на всю модель; материалы `.mtl` не используются.
- Поддерживаются треугольники, квады и выпуклые полигоны (триангулируются
  веером). Вогнутые полигоны лучше триангулировать в Blender.
- Модель клиентская: на сервере она не нужна, но файлы ресурсов должны
  попадать в собранный мод.
- Нужен Fabric API (он и так является зависимостью генератора).

## Что генерируется

В `src/main/java/<package>/client/obj/` появляются:

- `ObjGeometry.java` — парсер OBJ;
- `ObjModelDefinition.java` — описание модели и поиск текстуры;
- `ObjUnbakedModel.java` — превращение OBJ в baked-модель;
- `ObjModelLoader.java` — регистрация через Fabric Model Loading API.

В `assets/<modid>/obj_models_generated.json` плагин записывает привязки
блоков, у которых в редакторе выбрана OBJ-модель. Этот файл пересоздаётся
при каждой сборке, редактировать его вручную не нужно.

`ClientInit.java` и `fabric.mod.json` генерируются с регистрацией загрузчика.
Все эти файлы можно заблокировать в MCreator, если нужно править вручную.

## Старый заблокированный блок

Если блок был заблокирован (`locked code`) до подключения плагина, MCreator
не перегенерирует его `models/item/<block>.json`. Сам блок в мире будет
рендериться, но предмет в инвентаре может остаться плоским. Разблокируйте
блок или создайте его заново — тогда item-модель тоже станет OBJ.

## Сборка из исходников

Нужен Python 3. Из корня репозитория:

```bash
python build_zip.py
```

Скрипт создаст `TFabric-Generator-1.20.1.zip`, который можно установить в
MCreator.

## Релизы

Готовые zip-файлы лежат в разделе [Releases](../../releases).

## Проверено на

- MCreator 2024.4 (2024004)
- Minecraft 1.20.1
- Fabric Loader 0.14.21
- Fabric API 0.90.7+1.20.1

## Лицензия и авторы

- Автор плагина: **Tommy_Whinston**
- Основа: Fabric Generator for MCreator от **Goldorion** и **300f20t**
- Лицензия: **LGPL-3.0** (см. [LICENSE](LICENSE))
- Уведомления и исходные авторы: [NOTICE](NOTICE)

Отдельные шаблоны MCreator сохраняют свои copyright-заголовки и
распространяются на условиях MCreator template exception.

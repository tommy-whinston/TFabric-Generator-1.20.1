# Contributing / Участие в разработке

[Русский](#русский) | [English](#english)

---

## English

Thanks for helping improve **TFabric-Generator-1.20.1**.

### Before you start

- This repository contains a **standalone MCreator generator add-on** for
  Fabric 1.20.1. It is not a runtime mod and does not depend on a separate
  OBJ loader mod.
- Keep changes compatible with **MCreator 2024.4** and **Fabric API
  0.90.7+1.20.1** unless the change explicitly targets another version.
- Do not commit built `*.zip` files; they are produced by `build_zip.py`.

### Local setup

1. Install Python 3.10+.
2. Clone the repository.
3. Validate the plugin structure:

   ```bash
   python tools/validate_plugin.py
   ```

4. Build the installable zip:

   ```bash
   python build_zip.py
   ```

5. Install `TFabric-Generator-1.20.1.zip` in MCreator through
   **Preferences → Manage plugins → Install plugin from file**.
6. Create a test workspace with the `TFabric-Generator-1.20.1` generator and
   regenerate the project after template changes.

### What to test

Template changes should be verified in a real workspace, not only by
compiling Java:

- a block with an OBJ model (world rendering, item model, rotation, cutout);
- an item/tool with an OBJ model (GUI, hand, ground);
- an armor element with OBJ models for each piece;
- a model with two or more materials (`usemtl`) and matching `.textures`;
- a workspace containing a tag element (save/reload must not throw);
- a plant with a generated `TreeGrower`;
- a GUI with `onTick`, if the change touches GUI templates.

Attach the generated `obj_models_generated.json`,
`obj_items_generated.json` and the relevant `latest.log` lines to the issue
or pull request when reporting a rendering problem.

### Template conventions

- OBJ support lives in `templates/modbase/obj/` and manifests in
  `templates/modbase/*.json.ftl`.
- The generated manifests are authoritative; auto-discovery is only a
  fallback.
- Do not replace the block model id itself: vanilla JSON models may use it
  as a parent, and a parent must be a `BlockModel`.
- Item/tool/armor models are resolved directly to `ObjUnbakedModel` by
  model id.
- Keep `.ftl` files valid FreeMarker and run the validator before pushing.
- Match the existing code style (tabs in generated Java, LF line endings,
  no trailing whitespace).

### Pull requests

- Describe the problem, the fix, and how it was tested.
- Keep unrelated formatting changes out of the diff.
- Update `CHANGELOG.md` for user-visible changes (both languages).
- By contributing you agree that your changes are licensed under
  **LGPL-3.0**, unless a file states otherwise.

---

## Русский

Спасибо, что помогаете развивать **TFabric-Generator-1.20.1**.

### Перед началом

- Это **самостоятельный аддон-генератор MCreator** для Fabric 1.20.1.
  Это не runtime-мод, и отдельный загрузчик OBJ не нужен.
- Изменения должны оставаться совместимыми с **MCreator 2024.4** и
  **Fabric API 0.90.7+1.20.1**, если задача явно не про другую версию.
- Не коммитьте собранные `*.zip` — они создаются через `build_zip.py`.

### Локальная настройка

1. Установите Python 3.10+.
2. Склонируйте репозиторий.
3. Проверьте структуру плагина:

   ```bash
   python tools/validate_plugin.py
   ```

4. Соберите zip:

   ```bash
   python build_zip.py
   ```

5. Установите `TFabric-Generator-1.20.1.zip` в MCreator через
   **Preferences → Manage plugins → Install plugin from file**.
6. Создайте тестовый воркспейс с генератором `TFabric-Generator-1.20.1`
   и перегенерируйте проект после правок шаблонов.

### Что проверять

Правки шаблонов нужно проверять в реальном воркспейсе, а не только
компиляцией Java:

- блок с OBJ-моделью (рендер в мире, item-модель, поворот, cutout);
- предмет/инструмент с OBJ (GUI, рука, земля);
- броня с OBJ-моделями для каждого элемента;
- модель с двумя и более материалами (`usemtl`) и `.textures`;
- воркспейс с элементом-тегом (сохранение и повторное открытие без краша);
- растение со сгенерированным `TreeGrower`;
- GUI с `onTick`, если правка касается GUI-шаблонов.

К issue/PR с проблемой рендера приложите сгенерированные
`obj_models_generated.json`, `obj_items_generated.json` и нужные строки
`latest.log`.

### Соглашения по шаблонам

- Поддержка OBJ лежит в `templates/modbase/obj/`, манифесты — в
  `templates/modbase/*.json.ftl`.
- Сгенерированные манифесты — основной источник привязок; авто-обнаружение
  остаётся запасным вариантом.
- Не подменяйте id блочной модели: ванильные JSON-модели могут использовать
  его как parent, а parent обязан быть `BlockModel`.
- Модели предметов/инструментов/брони резолвятся напрямую в
  `ObjUnbakedModel` по id модели.
- `.ftl` должны оставаться валидным FreeMarker; перед push запускайте
  валидатор.
- Соблюдайте существующий стиль (табы в генерируемой Java, LF, без
  trailing whitespace).

### Pull requests

- Опишите проблему, исправление и способ проверки.
- Не смешивайте с диффом несвязанные изменения форматирования.
- Обновляйте `CHANGELOG.md` для пользовательских изменений (на двух языках).
- Отправляя изменения, вы соглашаетесь, что они распространяются по
  **LGPL-3.0**, если в файле не указано иное.

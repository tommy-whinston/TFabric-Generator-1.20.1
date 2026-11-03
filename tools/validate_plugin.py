#!/usr/bin/env python3
"""Structural checks for the TFabric-Generator-1.20.1 MCreator add-on.

The script intentionally avoids third-party dependencies. Run it from the
repository root:

    python tools/validate_plugin.py
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
GENERATOR = ROOT / "fabric-1.20.1-tfabric"

REQUIRED_FILES = [
    "plugin.json",
    "build_zip.py",
    "README.md",
    "README_EN.md",
    "CHANGELOG.md",
    "fabric-1.20.1-tfabric/generator.yaml",
    "fabric-1.20.1-tfabric/templates/modbase/obj/ObjGeometry.java.ftl",
    "fabric-1.20.1-tfabric/templates/modbase/obj/ObjModelDefinition.java.ftl",
    "fabric-1.20.1-tfabric/templates/modbase/obj/ObjUnbakedModel.java.ftl",
    "fabric-1.20.1-tfabric/templates/modbase/obj/ObjModelLoader.java.ftl",
    "fabric-1.20.1-tfabric/templates/modbase/obj_models_generated.json.ftl",
    "fabric-1.20.1-tfabric/templates/modbase/obj_items_generated.json.ftl",
    "fabric-1.20.1-tfabric/templates/json/item_cmodel_obj.json.ftl",
]

TEMPLATE_LINE = re.compile(r"^\s*-\s*template:\s*(\S+)\s*$", re.MULTILINE)
FREEMARKER_BLOCKS = ("if", "list", "macro", "function")

errors: list[str] = []


def fail(message: str) -> None:
    errors.append(message)


def check_required_files() -> None:
    for relative in REQUIRED_FILES:
        if not (ROOT / relative).is_file():
            fail(f"missing required file: {relative}")


def check_plugin_json() -> None:
    path = ROOT / "plugin.json"
    if not path.is_file():
        return
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        fail(f"plugin.json is not valid JSON: {exc}")
        return

    for key in ("id", "supportedversions", "info"):
        if key not in data:
            fail(f"plugin.json is missing '{key}'")
    info = data.get("info", {})
    for key in ("name", "version", "author"):
        if not info.get(key):
            fail(f"plugin.json info is missing '{key}'")
    if data.get("id") and not re.fullmatch(r"[a-z0-9._-]+", str(data["id"])):
        fail("plugin.json id may only contain lowercase letters, digits, '.', '_' and '-'")


def check_changelog() -> None:
    plugin = ROOT / "plugin.json"
    changelog = ROOT / "CHANGELOG.md"
    if not plugin.is_file() or not changelog.is_file():
        return
    try:
        version = str(json.loads(plugin.read_text(encoding="utf-8")).get("info", {}).get("version", ""))
    except json.JSONDecodeError:
        return
    if version and f"## {version}" not in changelog.read_text(encoding="utf-8"):
        fail(f"CHANGELOG.md has no '## {version}' section for the plugin version")


def check_template_refs() -> None:
    """Check references to templates that this repository is expected to ship.

    The add-on overrides only a subset of the base Fabric generator templates;
    everything else is intentionally inherited at runtime.
    """
    templates = GENERATOR / "templates"
    shipped_json = {path.name for path in (templates / "json").glob("*.ftl")}
    for definition in GENERATOR.glob("*.definition.yaml"):
        text = definition.read_text(encoding="utf-8", errors="replace")
        for name in TEMPLATE_LINE.findall(text):
            if name.startswith("@"):
                continue
            required = name.startswith("modbase/") or (
                name.startswith("json/") and Path(name).name in shipped_json
            )
            if required and not (templates / name).is_file():
                fail(f"{definition.name} references missing template '{name}'")


def check_obj_render_types() -> None:
    expected = {
        "item.definition.yaml": ["renderType #= 2"],
        "tool.definition.yaml": ["renderType #= 2"],
        "armor.definition.yaml": [
            "helmetItemRenderType #= 2",
            "bodyItemRenderType #= 2",
            "leggingsItemRenderType #= 2",
            "bootsItemRenderType #= 2",
        ],
    }
    for name, markers in expected.items():
        path = GENERATOR / name
        if not path.is_file():
            fail(f"missing element definition: {name}")
            continue
        text = path.read_text(encoding="utf-8", errors="replace")
        for marker in markers:
            if marker not in text:
                fail(f"{name} does not map '{marker}' to item_cmodel_obj.json.ftl")
        if "item_cmodel_obj.json.ftl" not in text:
            fail(f"{name} does not use item_cmodel_obj.json.ftl")


def check_item_manifest() -> None:
    path = GENERATOR / "templates/modbase/obj_items_generated.json.ftl"
    if not path.is_file():
        return
    text = path.read_text(encoding="utf-8", errors="replace")
    for piece in ("_helmet", "_chestplate", "_leggings", "_boots"):
        if piece not in text:
            fail(f"obj_items_generated.json.ftl does not map armor piece '{piece}'")
    for marker in ('getElementsOfType("item")', 'getElementsOfType("tool")', 'getElementsOfType("armor")'):
        if marker not in text:
            fail(f"obj_items_generated.json.ftl is missing {marker}")


def check_freemarker_balance(path: Path) -> None:
    text = path.read_text(encoding="utf-8", errors="replace")
    for block in FREEMARKER_BLOCKS:
        opened = len(re.findall(rf"<#{block}\b", text))
        closed = len(re.findall(rf"</#{block}>", text))
        if opened != closed:
            fail(f"{path.relative_to(ROOT)}: unbalanced <#{block}> ({opened} open, {closed} close)")


def check_templates() -> None:
    for path in (GENERATOR / "templates").rglob("*.ftl"):
        check_freemarker_balance(path)


def main() -> int:
    if not GENERATOR.is_dir():
        fail(f"generator directory not found: {GENERATOR}")

    check_required_files()
    check_plugin_json()
    check_changelog()
    check_template_refs()
    check_obj_render_types()
    check_item_manifest()
    check_templates()

    if errors:
        print("Plugin validation failed:")
        for error in errors:
            print(f"  - {error}")
        return 1

    print("Plugin validation passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())

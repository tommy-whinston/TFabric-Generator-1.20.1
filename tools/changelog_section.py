#!/usr/bin/env python3
"""Print the CHANGELOG.md section for a release tag (with or without 'v')."""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CHANGELOG = ROOT / "CHANGELOG.md"


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: changelog_section.py <version>", file=sys.stderr)
        return 2

    version = sys.argv[1].strip().lstrip("vV")
    text = CHANGELOG.read_text(encoding="utf-8")
    pattern = re.compile(
        rf"^##\s+{re.escape(version)}\s*$\n(.*?)(?=^##\s+|\Z)",
        re.MULTILINE | re.DOTALL,
    )
    match = pattern.search(text)
    if not match:
        print(f"## {version}\n\nSee [CHANGELOG.md](CHANGELOG.md) for the full list of changes.")
        return 0

    print(f"## {version}")
    print(match.group(1).strip())
    print("\n**Full changelog / Полный список изменений:** "
          "[CHANGELOG.md](https://github.com/tommy-whinston/TFabric-Generator-1.20.1/blob/main/CHANGELOG.md)")
    return 0


if __name__ == "__main__":
    sys.exit(main())

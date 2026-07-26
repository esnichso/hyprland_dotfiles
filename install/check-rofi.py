#!/usr/bin/env python3
"""Validate the rofi theme files. Called by install/check.sh.

Two checks, both for failure modes that produce confusing symptoms:

1. Comments inside a property block. rofi's rasi parser silently discards
   every declaration that FOLLOWS a comment inside `{ }`. The symptom is
   "the variable 'x' failed to resolve" for exactly the names that came after
   it, while everything before it works — which points you at the wrong file.

2. Undefined variables. Every `@name` used by a theme must exist in the
   generated colors.rasi. A typo here falls back to rofi's stock light theme,
   so a dark desktop suddenly renders a white dialog.
"""

import re
import sys
from pathlib import Path

ROFI = Path(__file__).resolve().parent.parent / "config" / "rofi"
GREEN, RED, RESET = "\033[32m", "\033[31m", "\033[0m"


def main() -> int:
    failed = False
    themes = sorted(ROFI.glob("*.rasi"))
    if not themes:
        print(f"  {RED}FAIL{RESET}  no .rasi files found in {ROFI}")
        return 1

    for path in themes:
        text = path.read_text(encoding="utf-8")
        # Innermost braces only — rasi has no nested blocks.
        for block in re.finditer(r"\{[^{}]*\}", text):
            body = block.group(0)
            if "/*" in body or "//" in body:
                line = text[: block.start()].count("\n") + 1
                print(f"  {RED}FAIL{RESET}  {path.name}:{line} comment inside a "
                      "block — rofi drops every declaration after it")
                failed = True
                break

    palette = ROFI / "colors.rasi"
    if not palette.exists():
        print(f"  {RED}FAIL{RESET}  colors.rasi missing — run install/set-theme.py")
        return 1

    defined = set(re.findall(r"^\s{2}([\w-]+):", palette.read_text(encoding="utf-8"), re.M))

    for path in themes:
        if path == palette:
            continue
        used = set(re.findall(r"@([\w-]+)", path.read_text(encoding="utf-8")))
        used -= {"import", "theme", "media"}
        missing = used - defined
        if missing:
            print(f"  {RED}FAIL{RESET}  {path.name}: undefined variables: "
                  f"{', '.join(sorted(missing))}")
            failed = True

    if not failed:
        print(f"  {GREEN}OK{RESET}    {len(themes)} rasi files, all variables resolve")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())

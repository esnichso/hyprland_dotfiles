#!/usr/bin/env bash
# Validate every config file in the repo before committing.
#
#   ./install/check.sh
#
# Catches the errors that otherwise only show up as a missing bar or an
# emergency-mode banner:
#
#   Lua      syntax errors in the Hyprland config
#   JSON(C)  trailing commas, unbalanced braces
#   GTK CSS  unknown properties and pseudo-classes — GTK rejects the WHOLE
#            stylesheet on one bad selector, so the bar comes up unstyled
#   TOML     starship
#   shell    the scripts
#
# Exits non-zero if anything fails.

set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$HERE"

FAIL=0
ok()   { printf '  \033[32mOK\033[0m    %s\n' "$*"; }
bad()  { printf '  \033[31mFAIL\033[0m  %s\n' "$*"; FAIL=1; }
say()  { printf '\n\033[1;34m==>\033[0m %s\n' "$*"; }

say "Lua"
if command -v luac >/dev/null 2>&1; then
	while IFS= read -r f; do
		if luac -p "$f" 2>/dev/null; then ok "$f"; else
			bad "$f"
			luac -p "$f" 2>&1 | sed 's/^/        /'
		fi
	done < <(find config/hypr -name '*.lua' | sort)
else
	echo "  luac not found — skipping (install: pacman -S lua)"
fi

say "JSON / JSONC"
for f in config/waybar/config.jsonc config/swaync/config.json; do
	[[ -f $f ]] || continue
	if python3 - "$f" <<'PY'; then ok "$f"; else bad "$f"; fi
import json, re, sys
raw = open(sys.argv[1], encoding="utf-8").read()
raw = re.sub(r'(?m)^\s*//.*$', '', raw)          # line comments
raw = re.sub(r',(\s*[}\]])', r'\1', raw)          # trailing commas
try:
    json.loads(raw)
except Exception as e:
    print("        " + str(e)); sys.exit(1)
PY
done

say "GTK CSS"
# Uses GTK's own parser, so it agrees exactly with what waybar/swaync will do.
if python3 - <<'PY'; then :; else FAIL=1; fi
import sys
try:
    import gi
    gi.require_version("Gtk", "3.0")
    from gi.repository import Gtk, GLib
except Exception as e:
    print("  python-gi/GTK not available — skipping (install: pacman -S python-gobject)")
    sys.exit(0)

failed = False
for path in ["config/waybar/style.css", "config/swaync/style.css"]:
    errors = []
    provider = Gtk.CssProvider()
    provider.connect("parsing-error",
                     lambda p, section, error: errors.append(error.message))
    try:
        # load_from_path, not load_from_data: @import is resolved relative to
        # the file, which is how waybar and swaync load these. Passing raw
        # bytes would resolve imports against the working directory instead.
        provider.load_from_path(path)
    except GLib.Error as e:
        errors.append(str(e))
    if errors:
        failed = True
        print(f"  \033[31mFAIL\033[0m  {path}")
        for e in errors:
            print(f"        {e}")
    else:
        print(f"  \033[32mOK\033[0m    {path}")
sys.exit(1 if failed else 0)
PY

say "TOML"
if [[ -f config/starship.toml ]]; then
	if python3 -c "import tomllib,sys; tomllib.load(open('config/starship.toml','rb'))" 2>/dev/null; then
		ok "config/starship.toml"
	else
		bad "config/starship.toml"
	fi
fi

say "Shell"
while IFS= read -r f; do
	if bash -n "$f" 2>/dev/null; then ok "$f"; else
		bad "$f"
		bash -n "$f" 2>&1 | sed 's/^/        /'
	fi
done < <(find config install -name '*.sh' | sort)

say "rofi themes"
if ./install/check-rofi.py; then :; else FAIL=1; fi

say "Generated colours in sync with the theme"
THEME_STATE="${XDG_STATE_HOME:-$HOME/.local/state}/hypr/theme"
CURRENT_THEME="mocha"
[[ -f $THEME_STATE ]] && CURRENT_THEME="$(<"$THEME_STATE")"
if ./install/set-theme.py "$CURRENT_THEME" --check >/dev/null 2>&1; then
	ok "generated files match themes/$CURRENT_THEME.toml"
else
	bad "generated colour files are stale"
	./install/set-theme.py "$CURRENT_THEME" --check 2>&1 | sed 's/^/        /'
fi

say "Duplicate keybinds"
python3 - <<'PY'
import re, collections
src = open("config/hypr/conf/binds.lua", encoding="utf-8").read()
src = re.sub(r'(?m)--.*$', '', src)
submap = src.find("hl.define_submap")
src = src[:submap] if submap > 0 else src

keys = []
for m in re.finditer(r'(?<![\w.])bind\(\s*"([^"]*)"', src):
    keys.append("SUPER + " + m.group(1))
for m in re.finditer(r'hl\.bind\(\s*"([^"]*)"', src):
    keys.append(m.group(1))
keys = [k for k in keys if not k.rstrip().endswith("+")]

dupes = {k: c for k, c in collections.Counter(keys).items() if c > 1}
if dupes:
    print("  \033[31mFAIL\033[0m  duplicate binds: " + ", ".join(dupes))
    raise SystemExit(1)
print(f"  \033[32mOK\033[0m    {len(keys)} literal binds, no duplicates")
PY
[[ $? -ne 0 ]] && FAIL=1

echo
if ((FAIL)); then
	printf '\033[31mSomething failed.\033[0m Fix it before committing.\n'
	exit 1
fi
printf '\033[32mAll checks passed.\033[0m\n'

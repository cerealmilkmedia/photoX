#!/usr/bin/env python3
"""List PhotoX's default keyboard shortcuts and report conflicts.

Reads the upstream defaults from the action entry tables in app/actions/*.c
and the tool registrations in app/tools/*.c, then applies the PhotoX
overrides from app/widgets/photox-shortcuts.c.

    python3 tools/photox/list-shortcuts.py            # print every shortcut
    python3 tools/photox/list-shortcuts.py --check    # exit 1 on conflicts
"""
import re
import sys
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]

ENTRY_RE = re.compile(r'\{\s*"([a-z0-9-]+)"\s*,[^{}]*?\{\s*((?:"[^"]*"\s*,\s*)*)NULL\s*\}', re.S)
TOOL_RE = re.compile(r'"gimp-([a-z0-9-]+)-tool"\s*,.*?N_\("[^"]*"\)\s*,\s*("[^"]*"|NULL)', re.S)
OVERRIDE_RE = re.compile(r'\{\s*"([a-z0-9-]+)"\s*,\s*\{\s*((?:"[^"]*"\s*,\s*)*)NULL\s*\}\s*\}')
STR_RE = re.compile(r'"([^"]*)"')

MODS = {"primary": "ctrl", "control": "ctrl", "ctrl": "ctrl",
        "shift": "shift", "alt": "alt", "mod1": "alt"}


def normalize(accel):
    """Canonical form so '<primary><shift>z' and '<Shift><Control>Z' compare equal."""
    mods = sorted({MODS[m.lower()] for m in re.findall(r"<([^>]+)>", accel)})
    key = re.sub(r"<[^>]+>", "", accel)
    key = key.lower() if len(key) == 1 else key
    return "+".join(mods + [key])


def upstream_defaults():
    """Return ({action: default accels}, set of every known action name)."""
    defaults, names = {}, set()
    for path in sorted((ROOT / "app/actions").glob("*-actions.c")):
        for name, accels in ENTRY_RE.findall(path.read_text()):
            names.add(name)
            accels = [a for a in STR_RE.findall(accels) if a]
            if accels:
                defaults[name] = accels
    for path in sorted((ROOT / "app/tools").glob("gimp*tool.c")):
        for tool, accel in TOOL_RE.findall(path.read_text()):
            names.add("tools-" + tool)
            if accel != "NULL" and accel.strip('"'):
                defaults["tools-" + tool] = [accel.strip('"')]
    return defaults, names


def conflicts_of(mapping):
    by_key = defaultdict(list)
    for name, accels in mapping.items():
        for accel in accels:
            by_key[normalize(accel)].append(name)
    # text-tool-* actions only receive keys while editing text on the canvas,
    # so sharing a key with a global action is fine (GIMP does the same).
    return by_key, {k: sorted(v) for k, v in by_key.items()
                    if len([n for n in v if not n.startswith("text-tool-")]) > 1}


def photox_overrides():
    text = (ROOT / "app/widgets/photox-shortcuts.c").read_text()
    return {name: [a for a in STR_RE.findall(accels) if a]
            for name, accels in OVERRIDE_RE.findall(text)}


def main():
    defaults, names = upstream_defaults()
    overrides = photox_overrides()
    unknown = sorted(set(overrides) - names)
    effective = {**defaults, **overrides}

    _, upstream_conflicts = conflicts_of(defaults)
    by_key, conflicts = conflicts_of(effective)
    # Only report clashes PhotoX introduces.
    conflicts = {k: v for k, v in conflicts.items()
                 if upstream_conflicts.get(k) != v
                 and any(n in overrides for n in v)}

    if "--check" not in sys.argv:
        for key in sorted(by_key):
            mark = "  (PhotoX)" if any(n in overrides for n in by_key[key]) else ""
            print(f"{key:24} {', '.join(sorted(by_key[key]))}{mark}")
        print()
    for key, names in sorted(conflicts.items()):
        print(f"CONFLICT {key}: {', '.join(sorted(names))}")
    for name in unknown:
        print(f"UNKNOWN ACTION in photox-shortcuts.c: {name}")
    return 1 if conflicts or unknown else 0

if __name__ == "__main__":
    sys.exit(main())

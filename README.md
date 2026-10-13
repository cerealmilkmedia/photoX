# PhotoX

PhotoX is a desktop image editor built on the source code of
[GIMP](https://www.gimp.org/), with the goal of offering a workflow and
interface closer to what Photoshop users expect.

> PhotoX is an independent project. It is not affiliated with or endorsed by
> the GIMP project or Adobe. "Photoshop" is a trademark of Adobe Inc.

## Status

Early stage, based on **GIMP 3.2.6** (see [UPSTREAM.md](UPSTREAM.md)).
PhotoX-specific changes are layered on top in separate commits.

## Roadmap

- [x] Rebrand: application name, About and Welcome dialogs, logo, app icon,
      splash screen, `.desktop` entry, application ID, settings folder
      (`~/.config/PhotoX`)
- [x] Photoshop-style default keyboard shortcuts (see below)
- [x] Single-window layout with Photoshop-like panel arrangement
- [x] Dark theme tuned toward Photoshop's greys
- [ ] Horizontal tool options bar under the menu (Photoshop's "Options bar")
- [ ] Rename remaining "GIMP" strings (menus, plug-ins, translations)
- [ ] Tool naming and grouping familiar to Photoshop users

## Keyboard shortcuts

PhotoX ships Photoshop-style defaults. They are defined in one table,
[`app/widgets/photox-shortcuts.c`](app/widgets/photox-shortcuts.c); anything
not listed there keeps its GIMP default. Users can still change any shortcut
in *Edit → Keyboard Shortcuts*.

| Key | Tool | Key | Tool |
|-----|------|-----|------|
| V | Move | B / Shift+B | Paintbrush / Pencil |
| M / Shift+M | Rectangle / Ellipse select | S | Clone |
| L / Shift+L | Free select (lasso) / Scissors | J | Heal |
| W / Shift+W | Fuzzy select (magic wand) / Foreground select | E | Eraser |
| C | Crop | G / Shift+G | Gradient / Bucket fill |
| I / Shift+I | Color picker / Measure | O | Dodge / Burn |
| P | Paths (pen) | T | Text |
| Z | Zoom | Q | Quick mask |
| Ctrl+T | Unified transform (free transform) | Ctrl+Shift+X | Warp transform (liquify) |

| Shortcut | Command | Shortcut | Command |
|----------|---------|----------|---------|
| Ctrl+Shift+Z | Redo | Ctrl+J | Duplicate layer |
| Ctrl+D | Deselect | Ctrl+E | Merge down |
| Ctrl+Shift+I | Invert selection | Ctrl+Shift+E | Merge visible |
| Ctrl+I | Invert colors | Ctrl+G | New layer group |
| Ctrl+L | Levels | Ctrl+M | Curves |
| Ctrl+U | Hue-Saturation | Ctrl+B | Color balance |
| Ctrl+Shift+U | Desaturate | Ctrl+Alt+I / Ctrl+Alt+C | Image size / Canvas size |
| Ctrl+0 | Fit on screen | Ctrl+1 | 100% |
| Ctrl+= / Ctrl+- | Zoom in / out | Ctrl+R | Rulers |
| Ctrl+' / Ctrl+; | Grid / Guides | Ctrl+H | Show selection |
| Alt+Backspace / Ctrl+Backspace | Fill with FG / BG color | F5 / F6 / F7 | Brushes / Colors / Layers panels |
| Ctrl+Alt+E | Export (overwrite last export) | Ctrl+Alt+Shift+W | Export as |

After editing the table, check for clashes with:

```sh
python3 tools/photox/list-shortcuts.py --check
```

## Building

PhotoX builds like GIMP 3.2 (Meson + Ninja). On Debian/Ubuntu, one script
installs the system packages and builds the newer babl and GEGL that GIMP 3.2
needs (into `/opt/photox` by default):

```sh
tools/photox/setup-deps.sh
source tools/photox/env.sh
meson setup _build -Dprefix="$PHOTOX_PREFIX"
ninja -C _build
ninja -C _build install
gimp-3.2     # starts PhotoX
```

The executable keeps GIMP's name (`gimp-3.2`) for now, so plug-ins and
scripts written for GIMP keep working.

Claude Code cloud sessions run `.claude/hooks/session-start.sh`, which does
the dependency and configure steps automatically.

The splash screen is a committed PNG; regenerate it after design changes with
`python3 tools/photox/make-splash.py`.

## License

Like GIMP, PhotoX is free software licensed under the **GNU General Public
License, version 3 or later** (see [COPYING](COPYING) and [LICENSE](LICENSE)).
Anyone distributing PhotoX, modified or not, must also release its source
code under the same license.

The original GIMP README is kept as [README.GIMP](README.GIMP).

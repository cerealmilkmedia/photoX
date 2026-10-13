# PhotoX

PhotoX is a desktop image editor built on the source code of
[GIMP](https://www.gimp.org/), with the goal of offering a workflow and
interface closer to what Photoshop users expect.

> PhotoX is an independent project. It is not affiliated with or endorsed by
> the GIMP project or Adobe. "Photoshop" is a trademark of Adobe Inc.

## Status

Early stage. The tree currently contains an unmodified import of
**GIMP 3.2.6** (see [UPSTREAM.md](UPSTREAM.md)). PhotoX-specific changes are
layered on top in separate commits.

## Roadmap

- [ ] Rebrand: application name, icons, splash screen, `.desktop` file
- [ ] Photoshop-style default keyboard shortcuts
- [ ] Single-window layout and panel arrangement modeled on Photoshop
- [ ] Theme tuned to match a Photoshop-like dark UI
- [ ] Tool naming and grouping familiar to Photoshop users

## Building

PhotoX builds exactly like GIMP 3.2, using Meson and Ninja:

```sh
meson setup _build
ninja -C _build
ninja -C _build install   # optional
```

Key dependencies include babl, GEGL, GTK 3, GLib, Cairo, Pango and
PyGObject. See `INSTALL.in` and GIMP's developer documentation for the full
list and versions:
<https://developer.gimp.org/core/setup/build/>

## License

Like GIMP, PhotoX is free software licensed under the **GNU General Public
License, version 3 or later** (see [COPYING](COPYING) and [LICENSE](LICENSE)).
Anyone distributing PhotoX, modified or not, must also release its source
code under the same license.

The original GIMP README is kept as [README.GIMP](README.GIMP).

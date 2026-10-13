#!/usr/bin/env python3
"""Render the PhotoX splash screen (gimp-data/images/photox-splash.png).

The splash is committed as a PNG so the build doesn't depend on fonts.
Re-run this script after changing the design:

    python3 tools/photox/make-splash.py

Requires PyGObject with Rsvg 2.0 and pycairo.
"""
from pathlib import Path

import cairo
import gi

gi.require_version("Rsvg", "2.0")
from gi.repository import Rsvg  # noqa: E402

ROOT = Path(__file__).resolve().parents[2]
LOGO = ROOT / "gimp-data/images/logo/gimp-logo.svg"
OUT = ROOT / "gimp-data/images/photox-splash.png"
W, H = 1280, 720

SPLASH = f"""<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}">
  <defs>
    <radialGradient id="glow1" cx="0.18" cy="0.25" r="0.6">
      <stop offset="0" stop-color="#7B2FF7" stop-opacity="0.55"/>
      <stop offset="1" stop-color="#7B2FF7" stop-opacity="0"/>
    </radialGradient>
    <radialGradient id="glow2" cx="0.9" cy="0.95" r="0.6">
      <stop offset="0" stop-color="#FF8A3D" stop-opacity="0.45"/>
      <stop offset="1" stop-color="#FF8A3D" stop-opacity="0"/>
    </radialGradient>
    <linearGradient id="word" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0" stop-color="#ffffff"/>
      <stop offset="1" stop-color="#FFD9C2"/>
    </linearGradient>
  </defs>
  <rect width="{W}" height="{H}" fill="#16141c"/>
  <rect width="{W}" height="{H}" fill="url(#glow1)"/>
  <rect width="{W}" height="{H}" fill="url(#glow2)"/>
  <text x="508" y="372" font-family="Inter Display, Inter, DejaVu Sans, sans-serif"
        font-weight="800" font-size="150" letter-spacing="-4" fill="url(#word)">PhotoX</text>
  <text x="514" y="432" font-family="Inter, DejaVu Sans, sans-serif"
        font-weight="400" font-size="34" fill="#cfc8dc">Image Editor</text>
  <text x="1240" y="690" text-anchor="end" font-family="Inter, DejaVu Sans, sans-serif"
        font-size="18" fill="#8f879c">Based on GIMP · Free software under the GNU GPL v3</text>
</svg>"""


def render(handle, ctx, x, y, w, h):
    viewport = Rsvg.Rectangle()
    viewport.x, viewport.y, viewport.width, viewport.height = x, y, w, h
    handle.render_document(ctx, viewport)


surface = cairo.ImageSurface(cairo.FORMAT_RGB24, W, H)
ctx = cairo.Context(surface)
render(Rsvg.Handle.new_from_data(SPLASH.encode()), ctx, 0, 0, W, H)
render(Rsvg.Handle.new_from_file(str(LOGO)), ctx, 196, 196, 280, 280)
surface.write_to_png(str(OUT))
print(f"Wrote {OUT.relative_to(ROOT)}")

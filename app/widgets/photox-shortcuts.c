/* PhotoX
 * Copyright (C) 2026 The PhotoX contributors
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

/* Photoshop-style default keyboard shortcuts.
 *
 * Every entry replaces the upstream GIMP default accelerators of one
 * action. An entry with no accelerators removes the GIMP default, which
 * is needed whenever a Photoshop shortcut takes over a key GIMP used for
 * something else.
 *
 * These are *defaults*: users can still change any of them in
 * Edit > Keyboard Shortcuts, and "Reset" brings back these values.
 *
 * After editing, run tools/photox/list-shortcuts.py --check to make sure
 * no two actions share a shortcut.
 */

#include "config.h"

#include <glib.h>

#include "photox-shortcuts.h"


typedef struct
{
  const gchar *name;
  const gchar *accels[4];
} PhotoXShortcut;

static const PhotoXShortcut photox_shortcuts[] =
{
  /* Tools */
  { "tools-move",                { "v", NULL } },
  { "tools-rect-select",         { "m", NULL } },
  { "tools-ellipse-select",      { "<shift>m", NULL } },
  { "tools-free-select",         { "l", NULL } },
  { "tools-iscissors",           { "<shift>l", NULL } },
  { "tools-fuzzy-select",        { "w", NULL } },
  { "tools-foreground-select",   { "<shift>w", NULL } },
  { "tools-crop",                { "c", NULL } },
  { "tools-color-picker",        { "i", NULL } },
  { "tools-measure",             { "<shift>i", NULL } },
  { "tools-heal",                { "j", NULL } },
  { "tools-paintbrush",          { "b", NULL } },
  { "tools-pencil",              { "<shift>b", NULL } },
  { "tools-clone",               { "s", NULL } },
  { "tools-eraser",              { "e", NULL } },
  { "tools-gradient",            { "g", NULL } },
  { "tools-bucket-fill",         { "<shift>g", NULL } },
  { "tools-dodge-burn",          { "o", NULL } },
  { "tools-path",                { "p", NULL } },
  { "tools-text",                { "t", NULL } },
  { "tools-unified-transform",   { "<primary>t", NULL } },
  { "tools-warp",                { "<primary><shift>x", NULL } },

  /* GIMP tools whose old keys now belong to the tools above */
  { "tools-airbrush",            { NULL } },
  { "tools-align",               { NULL } },
  { "tools-cage",                { NULL } },
  { "tools-handle-transform",    { NULL } },
  { "tools-smudge",              { NULL } },
  { "tools-transform-3d",        { NULL } },

  { "quick-mask-toggle",         { "q", NULL } },

  /* Edit */
  { "edit-redo",                 { "<primary><shift>z", "<primary>y", NULL } },
  { "edit-strong-undo",          { "<primary><alt>z", NULL } },
  { "edit-fill-fg",              { "<alt>BackSpace", "<primary>comma", NULL } },
  { "edit-fill-bg",              { "<primary>BackSpace", "<primary>period", NULL } },
  { "edit-fill-pattern",         { NULL } },

  /* File */
  { "file-export",               { "<primary><alt>e", NULL } },
  { "file-export-as",            { "<primary><alt><shift>w", NULL } },
  { "file-close-all",            { "<primary><alt>w", "<primary><shift>w", NULL } },

  /* Select */
  { "select-none",               { "<primary>d", "<primary><shift>a", NULL } },
  { "select-invert",             { "<primary><shift>i", NULL } },

  /* Image */
  { "image-scale",               { "<primary><alt>i", NULL } },
  { "image-resize",              { "<primary><alt>c", NULL } },
  { "image-merge-layers",        { "<primary><shift>e", NULL } },
  { "image-duplicate",           { NULL } },

  /* Layers */
  { "layers-duplicate",          { "<primary>j", "<primary><shift>d", NULL } },
  { "layers-merge-down",         { "<primary>e", NULL } },
  { "layers-new-group",          { "<primary>g", NULL } },
  { "layers-anchor",             { "<primary><alt>h", NULL } },

  /* Adjustments */
  { "filters-levels",            { "<primary>l", NULL } },
  { "filters-curves",            { "<primary>m", NULL } },
  { "filters-hue-saturation",    { "<primary>u", NULL } },
  { "filters-color-balance",     { "<primary>b", NULL } },
  { "filters-desaturate",        { "<primary><shift>u", NULL } },
  { "filters-invert-perceptual", { "<primary>i", NULL } },

  /* View */
  { "view-zoom-fit-in",          { "<primary>0", "<primary><shift>j", NULL } },
  { "view-zoom-1-1",             { "<primary>1", "1", "KP_1", NULL } },
  { "view-zoom-in",              { "<primary>equal", "plus", "KP_Add", NULL } },
  { "view-zoom-out",             { "<primary>minus", "minus", "KP_Subtract", NULL } },
  { "view-show-rulers",          { "<primary>r", NULL } },
  { "view-show-grid",            { "<primary>apostrophe", NULL } },
  { "view-show-guides",          { "<primary>semicolon", NULL } },
  { "view-show-selection",       { "<primary>h", NULL } },
  { "view-shrink-wrap",          { NULL } },

  /* Panels */
  { "dialogs-layers",            { "F7", NULL } },
  { "dialogs-brushes",           { "F5", "<primary><shift>b", NULL } },
  { "dialogs-colors",            { "F6", NULL } },
  { "dialogs-toolbox",           { NULL } },
  { "dialogs-gradients",         { NULL } },
};


/**
 * photox_shortcuts_get_default:
 * @action_name:  name of a #GimpAction
 * @accelerators: the upstream GIMP default accelerators, or %NULL
 *
 * Returns: the PhotoX default accelerators for @action_name: the
 *          Photoshop-style ones if PhotoX defines any, otherwise
 *          @accelerators unchanged. A returned array may be empty
 *          (first element %NULL), meaning no default shortcut.
 */
const gchar * const *
photox_shortcuts_get_default (const gchar         *action_name,
                              const gchar * const *accelerators)
{
  static GHashTable *table = NULL;
  const PhotoXShortcut *shortcut;

  if (! table)
    {
      table = g_hash_table_new (g_str_hash, g_str_equal);

      for (gsize i = 0; i < G_N_ELEMENTS (photox_shortcuts); i++)
        g_hash_table_insert (table,
                             (gpointer) photox_shortcuts[i].name,
                             (gpointer) &photox_shortcuts[i]);
    }

  shortcut = g_hash_table_lookup (table, action_name);

  return shortcut ? shortcut->accels : accelerators;
}

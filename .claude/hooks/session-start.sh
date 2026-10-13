#!/bin/bash
# SessionStart hook for Claude Code cloud sessions: installs PhotoX's build
# dependencies (apt packages + babl/GEGL from source) and configures the
# Meson build directory, so `ninja -C _build` works right away.
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

cd "$CLAUDE_PROJECT_DIR"

# Idempotent: skips babl/GEGL if the right versions are already installed.
tools/photox/setup-deps.sh

# shellcheck source=../../tools/photox/env.sh
source tools/photox/env.sh

# Make the same environment available to every command in the session.
if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
  {
    echo "export PHOTOX_PREFIX=\"$PHOTOX_PREFIX\""
    echo "export PKG_CONFIG_PATH=\"$PKG_CONFIG_PATH\""
    echo "export LD_LIBRARY_PATH=\"$LD_LIBRARY_PATH\""
    echo "export GI_TYPELIB_PATH=\"$GI_TYPELIB_PATH\""
    echo "export XDG_DATA_DIRS=\"$XDG_DATA_DIRS\""
    echo "export PATH=\"$PATH\""
    echo "export LANG=\"$LANG\""
  } >> "$CLAUDE_ENV_FILE"
fi

if [ ! -f _build/build.ninja ]; then
  meson setup _build -Dprefix="$PHOTOX_PREFIX"
fi

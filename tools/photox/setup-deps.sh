#!/usr/bin/env bash
# Install everything needed to build PhotoX on Debian/Ubuntu.
#
# System packages come from apt. babl and GEGL are built from source because
# PhotoX (GIMP 3.2) needs newer versions than most distributions ship.
#
# Usage: tools/photox/setup-deps.sh
# Environment:
#   PHOTOX_PREFIX  install prefix for babl/GEGL/PhotoX (default: /opt/photox)
#   PHOTOX_SRC     where babl/GEGL sources are cloned (default: $PHOTOX_PREFIX/src)
set -euo pipefail

PHOTOX_PREFIX="${PHOTOX_PREFIX:-/opt/photox}"
PHOTOX_SRC="${PHOTOX_SRC:-$PHOTOX_PREFIX/src}"
BABL_TAG="BABL_0_1_128"
GEGL_TAG="GEGL_0_4_72"

SUDO=""
if [ "$(id -u)" != 0 ]; then SUDO="sudo"; fi

# Package list follows GIMP's own Debian CI job (.gitlab-ci.yml).
APT_PACKAGES=(
  build-essential git ca-certificates pkg-config
  appstream bison desktop-file-utils flex gettext gobject-introspection
  libgtk-3-bin locales meson ninja-build valac xsltproc
  glib-networking iso-codes
  libaa1-dev libappstream-dev libarchive-dev libasound2-dev libbz2-dev
  libcfitsio-dev libexiv2-dev libgexiv2-dev libgirepository1.0-dev libgs-dev
  libgtk-3-dev libgudev-1.0-dev libheif-dev libjson-glib-dev libjxl-dev
  libjpeg-dev liblcms2-dev liblzma-dev libmaxflow-dev libmng-dev
  libmypaint-dev libopenexr-dev libopenjp2-7-dev libpng-dev
  libpoppler-glib-dev libqoi-dev libraw-dev librsvg2-dev libtiff-dev
  libunwind-dev libwebp-dev libwmf-dev libxmu-dev libxpm-dev
  mypaint-brushes poppler-data
  python3 python3-gi python3-gi-cairo
  xvfb xauth
)

echo "==> Installing system packages"
$SUDO apt-get update -qq
DEBIAN_FRONTEND=noninteractive $SUDO apt-get install -qq -y --no-install-recommends "${APT_PACKAGES[@]}"

# The build (tools/gen-languages) refuses to run in the C/POSIX locale.
if ! locale -a 2>/dev/null | grep -qi '^en_US\.utf-\?8$'; then
  echo "==> Generating the en_US.UTF-8 locale"
  $SUDO sed -i 's/^# *\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen
  grep -q '^en_US.UTF-8 UTF-8' /etc/locale.gen || echo 'en_US.UTF-8 UTF-8' | $SUDO tee -a /etc/locale.gen >/dev/null
  $SUDO locale-gen >/dev/null
fi

# g-ir-scanner and python3-gi are compiled for the distribution's default
# Python. If python3 was redirected to another version (via alternatives),
# point it back, or introspection and Python plug-ins fail to load.
distro_py="python$(dpkg-query -W -f='${Version}' python3 2>/dev/null | cut -d. -f1,2)"
if [ -n "$distro_py" ] && [ -x "/usr/bin/$distro_py" ] && \
   [ "$(readlink -f /usr/bin/python3)" != "/usr/bin/$distro_py" ]; then
  echo "==> python3 is $(python3 --version); switching it to the distro default $distro_py"
  $SUDO update-alternatives --install /usr/bin/python3 python3 "/usr/bin/$distro_py" 100 >/dev/null
  $SUDO update-alternatives --set python3 "/usr/bin/$distro_py"
fi

# shellcheck source=env.sh
PHOTOX_PREFIX="$PHOTOX_PREFIX" source "$(dirname "$0")/env.sh"

$SUDO mkdir -p "$PHOTOX_PREFIX" "$PHOTOX_SRC"
$SUDO chown "$(id -u):$(id -g)" "$PHOTOX_PREFIX" "$PHOTOX_SRC"

build_dep () {
  local name="$1" tag="$2" pc="$3"
  local want="${tag#*_}"; want="${want//_/.}"
  if pkg-config --exact-version="$want" "$pc" 2>/dev/null; then
    echo "==> $name $want already installed"
    return
  fi
  echo "==> Building $name $want"
  rm -rf "$PHOTOX_SRC/$name"
  # GitHub mirrors of gitlab.gnome.org/GNOME/$name
  git clone -q --depth 1 --branch "$tag" "https://github.com/GNOME/$name.git" "$PHOTOX_SRC/$name"
  shift 3
  meson setup "$PHOTOX_SRC/$name/_build" "$PHOTOX_SRC/$name" \
    -Dprefix="$PHOTOX_PREFIX" -Dbuildtype=release "$@"
  ninja -C "$PHOTOX_SRC/$name/_build" install
}

build_dep babl "$BABL_TAG" babl-0.1 -Dwith-docs=false -Denable-gir=true
build_dep gegl "$GEGL_TAG" gegl-0.4 -Ddocs=false -Dintrospection=true

echo "==> Done. Configure PhotoX with:"
echo "    source tools/photox/env.sh && meson setup _build -Dprefix=\"$PHOTOX_PREFIX\""

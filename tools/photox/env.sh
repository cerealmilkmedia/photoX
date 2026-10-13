# Source this file to point builds and the PhotoX binary at the babl/GEGL
# (and PhotoX itself) installed under $PHOTOX_PREFIX (default: /opt/photox).
PHOTOX_PREFIX="${PHOTOX_PREFIX:-/opt/photox}"
_photox_libdir="lib/$(gcc -print-multiarch 2>/dev/null || echo x86_64-linux-gnu)"
export PHOTOX_PREFIX
export PKG_CONFIG_PATH="$PHOTOX_PREFIX/$_photox_libdir/pkgconfig:$PHOTOX_PREFIX/lib/pkgconfig:$PHOTOX_PREFIX/share/pkgconfig${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"
export LD_LIBRARY_PATH="$PHOTOX_PREFIX/$_photox_libdir:$PHOTOX_PREFIX/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export GI_TYPELIB_PATH="$PHOTOX_PREFIX/$_photox_libdir/girepository-1.0:$PHOTOX_PREFIX/lib/girepository-1.0${GI_TYPELIB_PATH:+:$GI_TYPELIB_PATH}"
export XDG_DATA_DIRS="$PHOTOX_PREFIX/share:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
export PATH="$PHOTOX_PREFIX/bin:$PATH"
# Building needs a real (non C/POSIX) locale; setup-deps.sh generates en_US.UTF-8.
case "${LC_ALL:-${LANG:-C}}" in
  C|POSIX|C.*) export LANG=en_US.UTF-8; unset LC_ALL ;;
esac
unset _photox_libdir

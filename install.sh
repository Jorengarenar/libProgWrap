#!/usr/bin/env sh

install() {
    command install -D -m 0644 -t "$2" "$1"
}

INCLUDEDIR="${INCLUDEDIR:-${XDG_INCLUDE_DIR:-$HOME/.local/include}}"
LIBDIR="${LIBDIR:-${XDG_LIB_DIR:-$HOME/.local/lib}}"

libname="progwrap"

[ -z "$NO_C_SUBDIR" ] && C_SUBDIR="c"

c=$libname.h
shell=$libname.sh

if [ "$1" != "--uninstall" ]; then
    install $c     $INCLUDEDIR/$C_SUBDIR
    install $shell $LIBDIR/shell
else
	rm $INCLUDEDIR/$C_SUBDIR/$c
    rm $LIBDIR/shell/$shell
fi

#!/usr/bin/env sh

install() {
    command install -D -m 0644 -t "$2" "$1"
}

while getopts "lu": OPTION; do
    case $OPTION in
        l) only=$OPTARG ;;
        s) uninstall=1  ;;
    esac
done

shift $(($OPTIND - 1))

if [ -n "$only" ]; then
    if [ -z "$INCLUDEDIR" -o -z "$LIBDIR" ]; then
        echo "INCLUDEDIR or LIBDIR was not specified"
        echo "To install only for one language, you need to specify both locations"
        exit 1
    fi
fi

INCLUDEDIR="${INCLUDEDIR:-${XDG_INCLUDE_DIR:-$HOME/.local/include}}"
LIBDIR="${LIBDIR:-${XDG_LIB_DIR:-$HOME/.local/lib}}"

libname="progwrap"

c=$libname.h
shell=$libname.sh

if [ -z "$uninstall" ]; then
    if [ -z "$only" ]; then
        install $c     $INCLUDEDIR/c
        install $shell $LIBDIR/shell
    else
        [ "$only" = "c" ]     && install $c     $INCLUDEDIR
        [ "$only" = "shell" ] && install $shell $LIBDIR
    fi
else
    if [ -z "$only" ]; then
        rm $INCLUDEDIR/c/$c
        rm $LIBDIR/shell/$shell
    else
        [ "$only" = "c" ]     && rm $INCLUDEDIR/$c
        [ "$only" = "shell" ] && rm $LIBDIR/$shell
    fi
fi

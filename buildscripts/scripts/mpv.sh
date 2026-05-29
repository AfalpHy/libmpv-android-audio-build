#!/bin/bash -e

. ../../include/depinfo.sh
. ../../include/path.sh

build=_build$ndk_suffix

if [ "$1" == "build" ]; then
    true
elif [ "$1" == "clean" ]; then
    rm -rf $build
    exit 0
else
    exit 255
fi

unset CC CXX # meson wants these unset

# Optimized for a lightweight audio-only music player
meson setup $build --cross-file "$prefix_dir"/crossfile.txt \
    --default-library shared -Dprefer_static=true\
    -Dlibmpv=true -Dcplayer=false \
    -Diconv=disabled \
    -Dlua=enabled \
    -Dmanpage-build=disabled \
    -Dgl=disabled \
    -Dvulkan=disabled \
    -Dandroid-media-ndk=disabled \
    -Dzimg=disabled \
    -Drubberband=disabled \
    -Dlcms2=disabled

ninja -C $build -j$cores
DESTDIR="$prefix_dir" ninja -C $build install

ln -sf "$prefix_dir"/lib/libmpv.so "$native_dir"

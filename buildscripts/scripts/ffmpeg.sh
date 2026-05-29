#!/bin/bash -e

. ../../include/depinfo.sh
. ../../include/path.sh

if [ "$1" == "build" ]; then
    true
elif [ "$1" == "clean" ]; then
    rm -rf _build$ndk_suffix
    exit 0
else
    exit 255
fi

mkdir -p _build$ndk_suffix
cd _build$ndk_suffix

cpu=armv7-a
[[ "$ndk_triple" == "aarch64"* ]] && cpu=armv8-a
[[ "$ndk_triple" == "x86_64"* ]] && cpu=generic
[[ "$ndk_triple" == "i686"* ]] && cpu="i686 --disable-asm"

cpuflags=
[[ "$ndk_triple" == "arm"* ]] && cpuflags="$cpuflags -mfpu=neon -mcpu=cortex-a8"

../configure \
    --target-os=android \
    --enable-cross-compile \
    --cross-prefix=$ndk_triple- \
    --cc=$CC \
    --cxx=$CXX \
    --ar="llvm-ar" \
    --nm="llvm-nm" \
    --ranlib="llvm-ranlib" \
    --arch=${ndk_triple%%-*} \
    --cpu=$cpu \
    --pkg-config=pkg-config \
    --extra-cflags="-I$prefix_dir/include $cpuflags" \
    --extra-ldflags="-L$prefix_dir/lib" \
    --enable-static \
    --disable-shared \
    --disable-gpl \
    --enable-version3 \
    --disable-stripping \
    --disable-doc \
    --disable-programs \
    --disable-v4l2-m2m \
    --disable-vulkan \
    --disable-encoders \
    --disable-muxers \
    --disable-devices \
    --disable-hwaccels \
    --disable-jni \
    --disable-mediacodec \
    --disable-libdav1d \
    --disable-libxml2 \
    --disable-avdevice \
    --enable-mbedtls \
    --enable-avfilter \
    --disable-everything \
    --enable-protocol=file,http,https,tcp,tls \
    --enable-demuxer=aac,ac3,aiff,amr,ape,asf,flac,matroska,mp3,mpc,mov,ogg,rm,truehd,wav,wv \
    --enable-decoder=aac,aac_latm,ac3,alac,amrnb,amrwb,ape,cook,flac,mp1,mp2,mp3,mp3float,mpc7,mpc8,opus,ra_144,ra_288,shorten,tak,truehd,vorbis,wavpack,wmalossless,wmapro,wmav1,wmav2,wmavoice \
    --enable-parser=aac,ac3,flac,mpegaudio,opus,vorbis

make -j$cores
make DESTDIR="$prefix_dir" install

# Updated symlinks (Removed non-existent libraries like libpostproc and video-centric ones)
ln -sf "$prefix_dir"/lib/libavutil.so "$native_dir"
ln -sf "$prefix_dir"/lib/libswresample.so "$native_dir"
ln -sf "$prefix_dir"/lib/libavcodec.so "$native_dir"
ln -sf "$prefix_dir"/lib/libavformat.so "$native_dir"
ln -sf "$prefix_dir"/lib/libavfilter.so "$native_dir"

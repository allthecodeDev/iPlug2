#!/bin/sh

DEPOT_TOOLS_PATH=../Build/tmp/depot_tools

if [ ! -d $DEPOT_TOOLS_PATH ]; then
  git clone 'https://chromium.googlesource.com/chromium/tools/depot_tools.git' $DEPOT_TOOLS_PATH
  export PATH="${PWD}/$DEPOT_TOOLS_PATH:${PATH}"
fi

cd ../Build/src/skia
python tools/git-sync-deps
./bin/gn gen ../../tmp/skia/macOS_x64 --args='
is_official_build = true
skia_use_system_libjpeg_turbo = false
skia_use_system_libpng = false
skia_use_system_zlib = false
skia_use_system_expat = false
skia_use_system_icu = false
skia_use_system_harfbuzz = false
skia_use_libwebp_decode = false
skia_use_libwebp_encode = false
skia_use_xps = false
skia_use_dng_sdk = false
skia_use_expat = true
skia_use_metal = true
skia_use_icu = true
skia_use_sfntly = false
skia_enable_skottie = true
skia_enable_pdf = false
skia_enable_particles = true
skia_enable_gpu = true
skia_enable_skparagraph = true
skia_enable_sksl_interpreter = true
cc = "clang"
cxx = "clang++"
target_os = "mac"
target_cpu = "x86_64"
extra_cflags = ["-mmacosx-version-min=10.9"]
extra_cflags_c = ["-Wno-error"]
'
ninja -C ../../tmp/skia/macOS_x64

if [ "$?" -ne "0" ]; then
  echo "ERROR: build failed, aborting"
  exit 1
fi

if [ ! -d ../../mac/lib_x64 ]; then
  mkdir -p ../../mac/lib_x64
fi

mv ../../tmp/skia/macOS_x64/libskia.a ../../mac/lib_x64
mv ../../tmp/skia/macOS_x64/libskottie.a ../../mac/lib_x64
mv ../../tmp/skia/macOS_x64/libskshaper.a ../../mac/lib_x64
mv ../../tmp/skia/macOS_x64/libsksg.a ../../mac/lib_x64
mv ../../tmp/skia/macOS_x64/libskparagraph.a ../../mac/lib_x64

python tools/git-sync-deps
./bin/gn gen ../../tmp/skia/macOS_arm64 --args='
is_official_build = true
skia_use_system_libjpeg_turbo = false
skia_use_system_libpng = false
skia_use_system_zlib = true
skia_use_system_expat = false
skia_use_system_icu = false
skia_use_system_harfbuzz = false
skia_use_libwebp_decode = false
skia_use_libwebp_encode = false
skia_use_xps = false
skia_use_dng_sdk = false
skia_use_expat = true
skia_use_metal = true
skia_use_icu = true
skia_use_sfntly = false
skia_enable_skottie = true
skia_enable_pdf = false
skia_enable_particles = true
skia_enable_gpu = true
skia_enable_skparagraph = true
skia_enable_sksl_interpreter = true
cc = "clang"
cxx = "clang++"
target_os = "mac"
target_cpu = "arm64"
extra_cflags = ["-mmacosx-version-min=11.0"]
extra_cflags_c = ["-Wno-error"]
'
ninja -v -C ../../tmp/skia/macOS_arm64

if [ "$?" -ne "0" ]; then
  echo "ERROR: build failed, aborting"
  exit 1
fi

if [ ! -d ../../mac/lib_arm64 ]; then
  mkdir -p ../../mac/lib_arm64
fi

mv ../../tmp/skia/macOS_arm64/libskia.a ../../mac/lib_arm64
mv ../../tmp/skia/macOS_arm64/libskottie.a ../../mac/lib_arm64
mv ../../tmp/skia/macOS_arm64/libskshaper.a ../../mac/lib_arm64
mv ../../tmp/skia/macOS_arm64/libsksg.a ../../mac/lib_arm64
mv ../../tmp/skia/macOS_arm64/libskparagraph.a ../../mac/lib_arm64


echo 'Creating universal files...'
rm ../../mac/lib/libskia.a

xcrun lipo -create ../../mac/lib_*/libskia.a -o "../../mac/lib/libskia.a"

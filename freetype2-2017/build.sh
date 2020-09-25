#!/bin/bash
# Copyright 2017 Google Inc. All Rights Reserved.
# Licensed under the Apache License, Version 2.0 (the "License");
. $(dirname $0)/../custom-build.sh $1 $2
. $(dirname $0)/../common.sh

build_lib() {
  rm -rf BUILD
  cp -rf SRC BUILD
  (cd BUILD && ./autogen.sh && ./configure --disable-shared --with-harfbuzz=no --with-bzip2=no --with-png=no && make clean && make all -j $JOBS)
}

build_exe() {
  if [[ ! -d seeds ]]; then
    mkdir seeds
    git clone https://github.com/unicode-org/text-rendering-tests.git TRT
    # TRT/fonts is the full seed folder, but they're too big
    cp TRT/fonts/TestKERNOne.otf seeds/
    cp TRT/fonts/TestGLYFOne.ttf seeds/
    rm -fr TRT
  fi

  cp BUILD/src/tools/ftfuzzer/ftfuzzer.cc target.cc
  prepare_target || exit 2

  $CXX $CXXFLAGS -std=c++11 -I BUILD/include -I BUILD/ target.cc BUILD/objs/.libs/libfreetype.a -larchive -lz -o $EXECUTABLE_NAME_BASE.$1
}

get_source() {
  if [[ ! -d SRC ]]; then
    get_git_revision git://git.sv.nongnu.org/freetype/freetype2.git cd02d359a6d0455e9d16b87bf9665961c4699538 SRC
  fi
}

get_source || exit 1

setup_normal || exit 1
build_lib || exit 1
build_exe "normal" || exit 1

setup_afl_clang || exit 1
build_lib || exit 1
build_exe "afl.clang" || exit 1

setup_afl || exit 1
build_lib || exit 1
build_exe "afl" || exit 1

#!/bin/bash
# Copyright 2016 Google Inc. All Rights Reserved.
# Licensed under the Apache License, Version 2.0 (the "License");
. $(dirname $0)/../custom-build.sh $1 $2
. $(dirname $0)/../common.sh

build_lib() {
  rm -rf BUILD
  cp -rf SRC BUILD
  (cd BUILD && ./autogen.sh && CCLD="$CXX $CXXFLAGS" ./configure --enable-static --disable-shared &&
    make -j $JOBS -C src fuzzing)
}

build_exe() {
  if [[ ! -d seeds ]]; then
    mkdir seeds
    cp BUILD/test/shaping/fonts/sha1sum/* seeds/
  fi

  cp BUILD/test/fuzzing/hb-fuzzer.cc target.cc
  prepare_target || exit 2

  $CXX $CXXFLAGS -std=c++11 -I BUILD/src/ target.cc BUILD/src/.libs/libharfbuzz-fuzzing.a -lglib-2.0 -o $EXECUTABLE_NAME_BASE.$1
}

get_source() {
  if [[ ! -d SRC ]]; then
    get_git_revision https://github.com/behdad/harfbuzz.git  f73a87d9a8c76a181794b74b527ea268048f78e3 SRC
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

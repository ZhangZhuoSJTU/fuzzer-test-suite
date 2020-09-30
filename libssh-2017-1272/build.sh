#!/bin/bash
# Copyright 2017 Google Inc. All Rights Reserved.
# Licensed under the Apache License, Version 2.0 (the "License");
. $(dirname $0)/../custom-build.sh $1 $2
. $(dirname $0)/../common.sh

build_lib() {
  rm -rf BUILD
  cp -rf SRC BUILD
  (
    set -e
    cd BUILD
    mkdir build
    cd build
    cmake -DCMAKE_C_COMPILER="$CC" \
          -DCMAKE_CXX_COMPILER="$CXX" \
          -DCMAKE_C_FLAGS="$CFLAGS -fcommon" \
          -DCMAKE_CXX_FLAGS="$CXXFLAGS -fcommon" \
          -DWITH_STATIC_LIB=ON ..
    make -j $JOBS
  )
}

build_exe() {
  cp $SCRIPT_DIR/libssh_server_fuzzer.cc target.cc
  prepare_target || exit 2

  $CXX $CXXFLAGS -std=c++11 target.cc -I BUILD/include/ BUILD/build/src/libssh.a -lcrypto -lgss -lz -o $EXECUTABLE_NAME_BASE.$1
}

get_source() {
  if [[ ! -d SRC ]]; then
    get_git_revision https://github.com/lberrymage/libssh.git 7c79b5c154ce2788cf5254a62468fee5112f7640 SRC
  fi
}

get_source || exit 1

setup_normal || exit 1
build_lib || exit 1
build_exe "normal" || exit 1

setup_afl || exit 1
build_lib || exit 1
build_exe "afl" || exit 1

setup_afl_clang || exit 1
build_lib || exit 1
build_exe "afl.clang" || exit 1

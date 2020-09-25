#!/bin/bash
# Copyright 2016 Google Inc. All Rights Reserved.
# Licensed under the Apache License, Version 2.0 (the "License");
. $(dirname $0)/../custom-build.sh $1 $2
. $(dirname $0)/../common.sh

build_lib() {
  rm -rf BUILD
  cp -rf SRC BUILD
  (cd BUILD && CC="$CC $CFLAGS" ./config && make clean && make -j $JOBS)
}

build_exe() {
  prepare_target || exit
  $CXX $CXXFLAGS target.cc -DCERT_PATH=\"$SCRIPT_DIR/\"  BUILD/libssl.a BUILD/libcrypto.a -lgcrypt -I BUILD/include -o $EXECUTABLE_NAME_BASE.$1
}

get_source() {
  if [[ ! -d SRC ]]; then
    get_git_tag https://github.com/openssl/openssl.git OpenSSL_1_0_2d SRC
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

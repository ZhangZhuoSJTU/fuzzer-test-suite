#!/bin/bash
# Copyright 2016 Google Inc. All Rights Reserved.
# Licensed under the Apache License, Version 2.0 (the "License");
. $(dirname $0)/../custom-build.sh $1 $2
. $(dirname $0)/../common.sh

build_lib() {
  rm -rf BUILD
  cp -rf SRC BUILD
  # This version of openssl has unstable parallel make => Don't use `make -j `.
  (cd BUILD && CC="$CC $CFLAGS" ./config && make clean && make)
}

build_exe() {
  prepare_target || exit
  $CXX $CXXFLAGS target.cc -DCERT_PATH=\"$SCRIPT_DIR/\"  BUILD/libssl.a BUILD/libcrypto.a -I BUILD/include -ldl -o $EXECUTABLE_NAME_BASE.$1
  rm -rf runtime
  cp -rf $SCRIPT_DIR/runtime .
}

get_source() {
  rm -rf SRC
  get_git_tag https://github.com/openssl/openssl.git OpenSSL_1_0_1f SRC
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

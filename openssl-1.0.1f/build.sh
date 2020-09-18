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
  cp $SCRIPT_DIR/target.cc target.cc
  cat $SCRIPT_DIR/../target.in >> target.cc
  $CXX $CXXFLAGS target.cc -DCERT_PATH=\"$SCRIPT_DIR/\"  BUILD/libssl.a BUILD/libcrypto.a -I BUILD/include -ldl -o $EXECUTABLE_NAME_BASE.$1
  rm -rf runtime
  cp -rf $SCRIPT_DIR/runtime .
}

get_source() {
  get_git_tag https://github.com/openssl/openssl.git OpenSSL_1_0_1f SRC
}

setup_afl_clang() {
  export CC=afl-clang-fast
  export CXX=afl-clang-fast++
  export AFL_DONT_OPTIMIZE="yes"
  export CPPFLAGS="-g -O2 -no-pie"
  export CFLAGS="-g -O2 -no-pie"
  export CXXFLAGS="-g -O2 -no-pie"
}

setup_afl() {
  export CC=afl-gcc
  export CXX=afl-g++
  export AFL_DONT_OPTIMIZE="yes"
  export CPPFLAGS="-g -O2 -no-pie"
  export CFLAGS="-g -O2 -no-pie"
  export CXXFLAGS="-g -O2 -no-pie"
}

setup_normal() {
  export CC=gcc
  export CXX=g++
  export CPPFLAGS="-g -O2 -no-pie"
  export CFLAGS="-g -O2 -no-pie"
  export CXXFLAGS="-g -O2 -no-pie"
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

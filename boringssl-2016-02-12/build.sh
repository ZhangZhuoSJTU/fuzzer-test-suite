#!/bin/bash
# Copyright 2016 Google Inc. All Rights Reserved.
# Licensed under the Apache License, Version 2.0 (the "License");
. $(dirname $0)/../custom-build.sh $1 $2
. $(dirname $0)/../common.sh

build_lib() {
  rm -rf BUILD
  cp -rf SRC BUILD
  (cd BUILD && cmake -DBUILD_SHARED_LIBS=OFF -DCMAKE_C_COMPILER="$CC" -DCMAKE_C_FLAGS="$CFLAGS -Wno-deprecated-declarations" -DCMAKE_CXX_COMPILER="$CXX" -DCMAKE_CXX_FLAGS="$CXXFLAGS -Wno-error=main" && make -j $JOBS)
}

build_exe() {
  if [[ ! -d seeds ]]; then
    mkdir seeds
    cp BUILD/fuzz/privkey_corpus/* seeds/
  fi

  cp ./BUILD/fuzz/privkey.cc target.cc
  prepare_target || exit 2

  $CXX $CXXFLAGS -I BUILD/include target.cc ./BUILD/ssl/libssl.a ./BUILD/crypto/libcrypto.a -lpthread -o $EXECUTABLE_NAME_BASE.$1
}

get_source() {
  if [[ ! -d SRC ]]; then
    get_git_revision https://github.com/google/boringssl.git  894a47df2423f0d2b6be57e6d90f2bea88213382 SRC
  fi
}

get_source || exit 1

setup_normal || exit 1
export CFLAGS="$CFLAGS -Wno-stringop-overflow"
build_lib || exit 1
build_exe "normal" || exit 1

setup_afl || exit 1
export CFLAGS="$CFLAGS -Wno-stringop-overflow"
build_lib || exit 1
build_exe "afl" || exit 1

setup_afl_clang || exit 1
build_lib || exit 1
build_exe "afl.clang" || exit 1

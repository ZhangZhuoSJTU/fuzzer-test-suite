#!/bin/bash
# Copyright 2017 Google Inc. All Rights Reserved.
# Licensed under the Apache License, Version 2.0 (the "License");
. $(dirname $0)/../custom-build.sh $1 $2
. $(dirname $0)/../common.sh

build_lib() {
  rm -rf BUILD
  cp -rf SRC BUILD
  (cd BUILD && CC="$CC $CFLAGS" ./config && make clean && make -j $JOBS)
}

get_source() {
  if [[ ! -d SRC ]]; then
    get_git_tag https://github.com/openssl/openssl.git OpenSSL_1_1_0c SRC
  fi
}

build_exe() {
  for f in bignum x509; do
    cp BUILD/fuzz/$f.c target.cc
    prepare_target || exit 2
    sed -i 's/LLVMFuzzerTestOneInput/FuzzerTestOneInput/' target.cc
    cp target.cc BUILD/fuzz/$f.target.cc

    $CC $CFLAGS -c -g BUILD/fuzz/$f.target.cc -I BUILD/include -o $f.o

    $CXX $CXXFLAGS $f.o BUILD/libssl.a BUILD/libcrypto.a -lgcrypt -lpthread -ldl -o $EXECUTABLE_NAME_BASE-$f.$1
  done
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

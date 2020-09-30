#!/bin/bash
# Copyright 2017 Google Inc. All Rights Reserved.
# Licensed under the Apache License, Version 2.0 (the "License");
. $(dirname $0)/../custom-build.sh $1 $2
. $(dirname $0)/../common.sh

build_lib() {
  rm -rf BUILD
  cp -rf SRC BUILD
  (cd BUILD && ./autogen.sh &&  ./configure --disable-shared &&  make clean  && make -j $JOBS )
}

build_exe() {
  if [[ ! -d seeds ]]; then
    mkdir seeds
    cp BUILD/nad/* seeds
  fi

  cp BUILD/test/fuzzers/standard_fuzzer.cpp target.cc
  prepare_target || exit 2

  $CXX $CXXFLAGS -std=c++11 -I BUILD/src target.cc BUILD/src/.libs/libproj.a -o $EXECUTABLE_NAME_BASE.$1 -lpthread
}

get_source() {
  if [[ ! -d SRC ]]; then
    get_git_revision https://github.com/OSGeo/proj.4.git d00501750b210a73f9fb107ac97a683d4e3d8e7a SRC
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

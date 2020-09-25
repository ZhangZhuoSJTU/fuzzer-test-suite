#!/bin/bash
# Copyright 2017 Google Inc. All Rights Reserved.
# Licensed under the Apache License, Version 2.0 (the "License");
. $(dirname $0)/../custom-build.sh $1 $2
. $(dirname $0)/../common.sh

build_lib() {
  rm -rf BUILD
  cp -rf SRC BUILD
  (cd BUILD && make guetzli_static -j $JOBS)
}

build_exe() {
  cp BUILD/fuzz_target.cc target.cc
  prepare_target || exit 2

  $CXX $CXXFLAGS -std=c++11 target.cc -I BUILD/ BUILD/bin/Release/libguetzli_static.a -o $EXECUTABLE_NAME_BASE.$1
}

get_source() {
  if [[ ! -d SRC ]]; then
    get_git_tag https://github.com/google/guetzli.git 9afd0bbb7db0bd3a50226845f0f6c36f14933b6b SRC
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

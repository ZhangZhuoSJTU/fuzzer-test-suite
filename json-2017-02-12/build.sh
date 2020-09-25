#!/bin/bash
# Copyright 2017 Google Inc. All Rights Reserved.
# Licensed under the Apache License, Version 2.0 (the "License");
. $(dirname $0)/../custom-build.sh $1 $2
. $(dirname $0)/../common.sh

build_lib() {
  rm -rf BUILD
  cp -rf SRC BUILD
  (cd BUILD && make fuzzers -Ctest -j $JOBS)
}

build_exe() {
  if [[ ! -d seeds ]]; then
    cp -r $SCRIPT_DIR/seeds .
  fi

  cp BUILD/test/src/fuzzer-parse_json.cpp target.cc
  prepare_target || exit 2

  $CXX $CXXFLAGS -std=c++11 -I BUILD/src target.cc -o $EXECUTABLE_NAME_BASE.$1
}

get_source() {
  if [[ ! -d SRC ]]; then
    get_git_revision https://github.com/nlohmann/json.git b04543ecc58188a593f8729db38c2c87abd90dc3 SRC
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

#!/bin/bash
# Copyright 2017 Google Inc. All Rights Reserved.
# Licensed under the Apache License, Version 2.0 (the "License");
. $(dirname $0)/../custom-build.sh $1 $2
. $(dirname $0)/../common.sh

build_lib() {
  rm -rf BUILD
  cp -rf SRC BUILD
  (cd BUILD && autoreconf -fiv && ./configure --disable-shared && make -j $JOBS)
}

build_exe() {
  cp $SCRIPT_DIR/libjpeg_turbo_fuzzer.cc target.cc
  prepare_target || exit 2

  $CXX $CXXFLAGS -std=c++11 -I BUILD target.cc BUILD/.libs/libturbojpeg.a -o $EXECUTABLE_NAME_BASE.$1
}

get_source() {
  if [[ ! -d SRC ]]; then
    get_git_revision https://github.com/libjpeg-turbo/libjpeg-turbo.git b0971e47d76fdb81270e93bbf11ff5558073350d SRC
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

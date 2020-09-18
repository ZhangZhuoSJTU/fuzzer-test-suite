#!/bin/bash
# Copyright 2016 Google Inc. All Rights Reserved.
# Licensed under the Apache License, Version 2.0 (the "License");
. $(dirname $0)/../custom-build.sh $1 $2
. $(dirname $0)/../common.sh

build_lib() {
  rm -rf BUILD
  cp -rf SRC BUILD
  (cd BUILD && ./autogen.sh && CCLD="$CXX $CXXFLAGS" ./configure --disable-shared && make -j $JOBS)
}

build_exe() {
  prepare_target || exit 1
  $CXX $CXXFLAGS -std=c++11 target.cc -I BUILD/include BUILD/.libs/libxml2.a -lz -o $EXECUTABLE_NAME_BASE.$1
}

get_source() {
  rm -rf SRC
  get_git_tag https://gitlab.gnome.org/GNOME/libxml2.git v2.9.2 SRC
  # get_git_revision https://github.com/google/afl e9be6bce2282e8db95221c9a17fd10aba9e901bc afl
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

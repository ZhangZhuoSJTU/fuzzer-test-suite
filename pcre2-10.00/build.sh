#!/bin/bash
# Copyright 2016 Google Inc. All Rights Reserved.
# Licensed under the Apache License, Version 2.0 (the "License");
. $(dirname $0)/../custom-build.sh $1 $2
. $(dirname $0)/../common.sh

build_lib() {
  rm -rf BUILD
  cp -rf SRC BUILD
  (cd BUILD &&
    ./autogen.sh &&
     CCLD="$CXX $CXXFLAGS" ./configure --disable-shared --enable-never-backslash-C --with-match-limit=1000 --with-match-limit-recursion=1000 &&
     make -j
  )
}

build_exe() {
  prepare_target || exit 2

  $CXX $CXXFLAGS target.cc -I BUILD/src -Wl,--whole-archive BUILD/.libs/*.a -Wl,-no-whole-archive -o $EXECUTABLE_NAME_BASE.$1
}

get_source() {
  if [[ ! -d SRC ]]; then
    get_svn_revision svn://vcs.exim.org/pcre2/code/trunk 183 SRC
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

#!/bin/bash
# Copyright 2016 Google Inc. All Rights Reserved.
# Licensed under the Apache License, Version 2.0 (the "License");
. $(dirname $0)/../custom-build.sh $1 $2
. $(dirname $0)/../common.sh

get_source() {
  if [[ ! -d SRC ]]; then
    get_svn_revision http://llvm.org/svn/llvm-project/libcxxabi/trunk 293329 SRC
  fi
}

build_exe() {
  cp SRC/fuzz/cxa_demangle_fuzzer.cpp target.cc
  prepare_target || exit 2

  $CXX $CXXFLAGS -std=c++11 target.cc SRC/src/cxa_demangle.cpp -I SRC/include -o $EXECUTABLE_NAME_BASE.$1
}

get_source || exit 1

setup_normal || exit 1
build_exe "normal" || exit 1

setup_afl || exit 1
build_exe "afl" || exit 1

setup_afl_clang || exit 1
build_exe "afl.clang" || exit 1

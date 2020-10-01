#!/bin/bash
# Copyright 2016 Google Inc. All Rights Reserved.
# Licensed under the Apache License, Version 2.0 (the "License");
. $(dirname $0)/../custom-build.sh $1 $2
. $(dirname $0)/../common.sh

get_source() {
  [ ! -e libpng-1.2.56.tar.gz ] && wget https://downloads.sourceforge.net/project/libpng/libpng12/older-releases/1.2.56/libpng-1.2.56.tar.gz
  [ ! -e SRC ] && tar xf libpng-1.2.56.tar.gz && mv libpng-1.2.56 SRC
}

build_lib() {
  rm -rf BUILD
  cp -rf SRC BUILD
  (cd BUILD && ./configure --disable-shared &&  make -j $JOBS)
}

build_exe(){
  prepare_target || exit 1
  $CXX $CXXFLAGS -std=c++11 -no-pie target.cc BUILD/.libs/libpng12.a -I BUILD/ -I BUILD -lz -o $EXECUTABLE_NAME_BASE.$1
}

get_source || exit 1

setup_afl_clang || exit 1
build_lib || exit 1
build_exe "afl.clang" || exit 1

setup_normal || exit 1
build_lib || exit 1
build_exe "normal" || exit 1

setup_afl || exit 1
build_lib || exit 1
build_exe "afl" || exit 1


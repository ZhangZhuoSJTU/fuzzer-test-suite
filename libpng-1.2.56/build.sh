#!/bin/bash
# Copyright 2016 Google Inc. All Rights Reserved.
# Licensed under the Apache License, Version 2.0 (the "License");
. $(dirname $0)/../custom-build.sh $1 $2
. $(dirname $0)/../common.sh

[ ! -e libpng-1.2.56.tar.gz ] && wget https://downloads.sourceforge.net/project/libpng/libpng12/older-releases/1.2.56/libpng-1.2.56.tar.gz
[ ! -e libpng-1.2.56 ] && tar xf libpng-1.2.56.tar.gz

build_lib() {
  rm -rf BUILD
  cp -rf libpng-1.2.56 BUILD
  (cd BUILD && ./configure --disable-shared &&  make -j $JOBS)
}

build_exe(){
  cp $SCRIPT_DIR/target.cc target.cc
  cat $SCRIPT_DIR/../target.in >> target.cc
  $CXX $CXXFLAGS -std=c++11 -no-pie target.cc BUILD/.libs/libpng12.a -I BUILD/ -I BUILD -lz -o $EXECUTABLE_NAME_BASE.$1
}

setup_afl_clang() {
  export CC=afl-clang-fast
  export CXX=afl-clang-fast++
  export AFL_DONT_OPTIMIZE="yes"
  export CPPFLAGS="-g -O2 -no-pie"
  export CFLAGS="-g -O2 -no-pie"
  export CXXFLAGS="-g -O2 -no-pie"
}

setup_afl() {
  export CC=afl-gcc
  export CXX=afl-g++
  export AFL_DONT_OPTIMIZE="yes"
  export CPPFLAGS="-g -O2 -no-pie"
  export CFLAGS="-g -O2 -no-pie"
  export CXXFLAGS="-g -O2 -no-pie"
}

setup_normal() {
  export CC=gcc
  export CXX=g++
  export CPPFLAGS="-g -O2 -no-pie"
  export CFLAGS="-g -O2 -no-pie"
  export CXXFLAGS="-g -O2 -no-pie"
}

setup_afl_clang || exit 1
build_lib || exit 1
build_exe "afl.clang" || exit 1

# setup_normal || exit 1
# build_lib || exit 1
# build_exe "normal" || exit 1
 
# setup_afl || exit 1
# build_lib || exit 1
# build_exe "afl" || exit 1


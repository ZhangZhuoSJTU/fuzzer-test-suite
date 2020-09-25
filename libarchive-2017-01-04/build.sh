#!/bin/bash
# Copyright 2016 Google Inc. All Rights Reserved.
# Licensed under the Apache License, Version 2.0 (the "License");
. $(dirname $0)/../custom-build.sh $1 $2
. $(dirname $0)/../common.sh

build_lib() {
  rm -rf BUILD
  cp -rf SRC BUILD
  (
    cd BUILD/build &&
    ./autogen.sh &&
    cd .. &&
    ./configure --disable-shared --without-nettle &&
    sed -i "1 i\#include <sys/sysmacros.h>" libarchive/*.c &&
    sed -i "1 i\#include <fcntl.h>" libarchive/archive_read_disk_posix.c &&
    sed -i "1 i\#include <sys/time.h>" libarchive/archive_read_disk_posix.c &&
    make -j $JOBS
  )
}

build_exe() {
  cp $SCRIPT_DIR/libarchive_fuzzer.cc target.cc
  prepare_target || exit 2

  $CXX $CXXFLAGS -std=c++11 target.cc -I BUILD/libarchive BUILD/.libs/libarchive.a -lz -lbz2 -lxml2 -lcrypto -lssl -llzma -o $EXECUTABLE_NAME_BASE.$1
}

get_source() {
  if [[ ! -d SRC ]]; then
    get_git_revision https://github.com/libarchive/libarchive.git 51d7afd3644fdad725dd8faa7606b864fd125f88 SRC
  fi
}

get_source || exit 1

set -x

setup_normal || exit 1
export CFLAGS="$CFLAGS -Wno-implicit-fallthrough -D_GNU_SOURCE"
build_lib || exit 1
build_exe "normal" || exit 1

setup_afl_clang || exit 1
export CFLAGS="$CFLAGS -Wno-implicit-fallthrough -D_GNU_SOURCE"
build_lib || exit 1
build_exe "afl.clang" || exit 1

setup_afl || exit 1
export CFLAGS="$CFLAGS -Wno-implicit-fallthrough -D_GNU_SOURCE"
build_lib || exit 1
build_exe "afl" || exit 1

#!/bin/bash
# Copyright 2016 Google Inc. All Rights Reserved.
# Licensed under the Apache License, Version 2.0 (the "License");
. $(dirname $0)/../custom-build.sh $1 $2
. $(dirname $0)/../common.sh

build_exe() {
  set -x
  rm -rf BUILD
  cp -r $SCRIPT_DIR BUILD
  cp BUILD/ossfuzz.c target.cc
  prepare_target || exit 2
  cp target.cc BUILD/target.cc

  $CC $CFLAGS -DSQLITE_OMIT_LOAD_EXTENSION -c BUILD/sqlite3.c -ldl -o sqlite3.o

  $CXX $CXXFLAGS -ldl -pthread BUILD/target.cc sqlite3.o -o $EXECUTABLE_NAME_BASE.$1
}

setup_normal || exit 1
build_exe "normal" || exit 1

setup_afl || exit 1
build_exe "afl" || exit 1

setup_afl_clang || exit 1
build_exe "afl.clang" || exit 1

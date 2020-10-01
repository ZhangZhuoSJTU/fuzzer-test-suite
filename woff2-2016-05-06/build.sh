#!/bin/bash
# Copyright 2016 Google Inc. All Rights Reserved.
# Licensed under the Apache License, Version 2.0 (the "License");
. $(dirname $0)/../custom-build.sh $1 $2
. $(dirname $0)/../common.sh

get_source() {
  if [[ ! -d SRC ]]; then
    get_git_revision https://github.com/google/woff2.git  9476664fd6931ea6ec532c94b816d8fbbe3aed90 SRC
  fi

  if [[ ! -d BROTLI ]]; then
    get_git_revision https://github.com/google/brotli.git 3a9032ba8733532a6cd6727970bade7f7c0e2f52 BROTLI
  fi

  if [[ ! -d seeds ]]; then
    get_git_revision https://github.com/FontFaceKit/roboto.git 0e41bf923e2599d651084eece345701e55a8bfde seeds
  fi
}

build_lib() {
  rm -f *.o
  for f in font.cc normalize.cc transform.cc woff2_common.cc woff2_dec.cc woff2_enc.cc glyph.cc table_tags.cc variable_length.cc woff2_out.cc; do
    $CXX $CXXFLAGS -std=c++11  -I BROTLI/dec -I BROTLI/enc -c SRC/src/$f &
  done
  for f in BROTLI/dec/*.c BROTLI/enc/*.cc; do
    $CXX $CXXFLAGS -c $f &
  done
  wait
}

build_exe() {
  prepare_target || exit 2

  $CXX $CXXFLAGS *.o target.cc -I SRC/src -o $EXECUTABLE_NAME_BASE.$1
}

get_source || exit 1

set -x
setup_normal || exit 1
build_lib || exit 1
build_exe "normal" || exit 1

setup_afl || exit 1
build_lib || exit 1
build_exe "afl" || exit 1

setup_afl_clang || exit 1
build_lib || exit 1
build_exe "afl.clang" || exit 1

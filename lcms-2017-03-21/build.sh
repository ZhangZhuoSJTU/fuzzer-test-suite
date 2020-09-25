#!/bin/bash
# Copyright 2017 Google Inc. All Rights Reserved.
# Licensed under the Apache License, Version 2.0 (the "License");
. $(dirname $0)/../custom-build.sh $1 $2
. $(dirname $0)/../common.sh

build_lib() {
  rm -rf BUILD
  cp -rf SRC BUILD
  (cd BUILD && ./autogen.sh && ./configure --disable-shared && make -j $JOBS)
}

build_exe() {
  cp ${SCRIPT_DIR}/cms_transform_fuzzer.c target.cc
  prepare_target || exit 2

  $CXX $CXXFLAGS -I BUILD/include/ target.cc BUILD/src/.libs/liblcms2.a -o $EXECUTABLE_NAME_BASE.$1
}

get_source() {
  if [[ ! -d SRC ]]; then
    get_git_revision https://github.com/mm2/Little-CMS.git f9d75ccef0b54c9f4167d95088d4727985133c52 SRC
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

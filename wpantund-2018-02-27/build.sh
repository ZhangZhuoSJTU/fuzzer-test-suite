#!/bin/bash
# Copyright 2018 Google Inc. All Rights Reserved.
# Licensed under the Apache License, Version 2.0 (the "License");
. $(dirname $0)/../custom-build.sh $1 $2
. $(dirname $0)/../common.sh

build_exe() {
  rm -rf BUILD
  cp -rf SRC BUILD

  if [[ ! -d seeds ]]; then
    cp -r BUILD/etc/fuzz-corpus/wpantund-fuzz seeds
  fi

  (cd BUILD && ./bootstrap.sh && ./configure \
    --enable-fuzz-targets             \
    --disable-shared                  \
    --enable-static                   \
    CC="${CC}"                        \
    CXX="${CXX}"                      \
    FUZZ_LIBS="${SCRIPT_DIR}/../normal.o"              \
    FUZZ_CFLAGS="${CFLAGS}"           \
    FUZZ_CXXFLAGS="${CXXFLAGS}"       \
    LDFLAGS="-lpthread"               \
    && make -j $JOBS)

   cp BUILD/src/wpantund/wpantund-fuzz $EXECUTABLE_NAME_BASE.$1
}

get_source() {
  if [[ ! -d SRC ]]; then
    get_git_revision https://github.com/openthread/wpantund.git 7fea6d7a24a52f6a61545610acb0ab8a6fddf503 SRC
  fi
}

get_source || exit 1

set -x
setup_normal || exit 1
build_exe "normal" || exit 1

setup_afl || exit 1
build_exe "afl" || exit 1

setup_afl_clang || exit 1
build_exe "afl.clang" || exit 1

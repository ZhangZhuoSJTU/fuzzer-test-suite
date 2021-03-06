# fuzzer-test-suite

:zap: **NOTE: For most use cases, fuzzer-test-suite is superseded by [FuzzBench](https://github.com/google/fuzzbench). 
We recommend using FuzzBench for all future fuzzer benchmarking. 
FuzzBench is based on many of the same ideas as FTS, such as realistic benchmarks (it actually uses some benchmarks from FTS) but has many improvements such as a free service and a design that makes adding new fuzzers and new benchmarks easier.**

This is a set of tests (benchmarks) for fuzzing engines (fuzzers).

The goal of this project is to have a set of fuzzing benchmarks derived from real-life
libraries that have interesting bugs, hard-to-find code paths, or other
challenges for bug finding tools.

In addition, this project provides a fuzzing engine
[comparison framework](engine-comparison/) to execute A/B tests between
different fuzzing configurations.

The current version supports [libFuzzer](http://libFuzzer.info) and
[AFL](http://lcamtuf.coredump.cx/afl/).  In future versions we may support
other fuzzing engines.

# How to use

```bash
git clone https://github.com/ZhangZhuoSJTU/fuzzer-test-suite.git
cd fuzzer-test-suite
mkdir build
cd build

/full/path/of/fuzzer-test-suite/build.sh PROJNAME
```

Above commands will build three versions of `PROJNAME`, including the one without instrumentation, the one instrumented by *afl-gcc*, and the one instrumented by *afl-clang-fast*.

# See also

* [AddressSanitizer](http://clang.llvm.org/docs/AddressSanitizer.html)

# Contributing
See [CONTRIBUTING](CONTRIBUTING) first. 
If you want to add one more benchmark to the test suite,
simply mimic one of the existing benchmarks and send the pull request. 

# Disclaimer
This is not an official Google product.

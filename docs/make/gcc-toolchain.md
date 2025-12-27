# GCC Toolchain 13.4.0 - DEVELOPER
  - Homepage: [https://gcc.gnu.org/](https://gcc.gnu.org/)
  - Manpage: [https://gcc.gnu.org/onlinedocs/](https://gcc.gnu.org/onlinedocs/)
  - Changelog: [https://gcc.gnu.org/gcc-13/changes.html](https://gcc.gnu.org/gcc-13/changes.html)
  - Repository: [https://github.com/gcc-mirror/gcc](https://github.com/gcc-mirror/gcc)
  - Package: [master/make/pkgs/gcc-toolchain/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/gcc-toolchain/)
  - Maintainer: [@Ircama](https://github.com/Ircama)

This package provides a complete GCC toolchain for on-device compilation, enabling software development directly on the router/device.

## Features
- GCC compiler (gcc, g++, cpp)
- Complete cross-compilation toolchain
- Support for C and C++ development
- Integration with uClibc runtime

## Components
- **gcc**: GNU C Compiler
- **g++**: GNU C++ Compiler  
- **cpp**: C Preprocessor
- **libgcc**: GCC runtime library
- **libstdc++**: C++ Standard Library

## Usage
After installation, you can compile C/C++ programs directly on the device:

```bash
# Compile a C program
gcc -o hello hello.c

# Compile a C++ program
g++ -o hello hello.cpp
```

## Notes
- Required for building Python extensions and other compiled packages on-device
- Uses serial compilation (`-j1`) during toolchain build to prevent race conditions

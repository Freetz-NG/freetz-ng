# libgcc_s (libgcc_s.so) 1
  - Library: [master/make/libs/libgcc_s/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/libs/libgcc_s/)
  - Maintainer: -

GCC low-level runtime library GCC provides a low-level runtime library, `libgcc.a' or `libgcc_s.so.1' on some platforms. GCC generates calls to routines in this library automatically, whenever it needs to perform some operation that is too complicated to emit inline code for. Most of the routines in libgcc handle arithmetic operations that the target processor cannot perform directly. This includes integer multiply and divide on some machines, and all floating-point operations on other machines. libgcc also includes routines for exception handling, and a handful of miscellaneous operations.

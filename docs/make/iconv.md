# iconv 1.18 (binary only)
  - Homepage: [https://www.gnu.org/software/libiconv/](https://www.gnu.org/software/libiconv/)
  - Manpage: [https://www.gnu.org/savannah-checkouts/gnu/libiconv/documentation/](https://www.gnu.org/savannah-checkouts/gnu/libiconv/documentation/)
  - Changelog: [https://ftp.gnu.org/pub/gnu/libiconv/](https://ftp.gnu.org/pub/gnu/libiconv/)
  - Repository: [https://git.savannah.gnu.org/gitweb/?p=libiconv.git](https://git.savannah.gnu.org/gitweb/?p=libiconv.git)
  - Package: [master/make/pkgs/iconv/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/iconv/)
  - Library: [master/make/pkgs/iconv/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/iconv/) (Config.in.libs)
  - Maintainer: -

## Description
GNU libiconv is a character encoding conversion library. It provides an `iconv()` implementation for systems that don't have one, or whose implementation cannot convert from/to Unicode.

It supports a wide range of encodings, including:
- European languages: ASCII, ISO-8859-{1-16}, KOI8-R/U/RU, CP{1250-1258,850,866,1131}, Mac{Roman,CentralEurope,Iceland,Croatian,Romania}, etc.
- Semitic languages: ISO-8859-{6,8}, CP{1255,1256}, CP862, Mac{Hebrew,Arabic}
- Japanese: EUC-JP, SHIFT_JIS, CP932, ISO-2022-JP, etc.
- Chinese: EUC-CN, HZ, GBK, CP936, GB18030, EUC-TW, BIG5, CP950, etc.
- Korean: EUC-KR, CP949, ISO-2022-KR, JOHAB
- And many other full Unicode encodings (UTF-8, UCS-2, UCS-4, UTF-16, UTF-32)

## Configuration Options
- **iconv (binary only)**: Includes the `iconv` command-line program for character conversion
- **libiconv (libiconv.so)**: Includes the shared library libiconv.so.2.7.0
- **External libiconv**: Allows externalizing the libiconv library instead of compiling it into the firmware

## Version Selection
The package automatically selects the appropriate libiconv version based on the uClibc toolchain:

- **uClibc 0.9.28**: Forces libiconv 1.13.1 (ABANDON) due to compatibility issues with modern libiconv
- **uClibc 0.9.29+**: Uses libiconv 1.18 (CURRENT) by default

Manual version selection is still available in menuconfig, but the CURRENT version is automatically disabled for uClibc 0.9.28 toolchains.

## Dependencies
- zlib (when used by other libraries)


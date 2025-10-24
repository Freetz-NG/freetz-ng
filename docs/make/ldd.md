# ldd (List Dynamic Dependencies)
  - Package: [master/make/pkgs/ldd/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/ldd/)
  - Maintainer: -
  - Website: [uClibc-ng](https://uclibc-ng.org/)
  - Source: [uClibc-ng GitHub](https://github.com/uClibc-ng/uClibc-ng)

**ldd** stands for **L**ist **D**ynamic **D**ependencies. It is a small
console tool that can be used to determine whether a binary depends on
other binaries (usually [dynamic libraries](http://en.wikipedia.org/wiki/Library_(computing)#Shared_libraries))
and if so, which ones.

As the description correctly suggests, *ldd* is typically used by
developers - whereas the "normal user" rarely needs it, if at all.

## Available Versions

Freetz-NG offers **two versions** of ldd to support both old and modern devices:

### Version 0.1 (Legacy - for old devices)

**Recommended for:**
- Fritz!Box 7170, 7270 v1/v2
- Devices with uClibc 0.9.29 or 0.9.30
- Old toolchains with gcc < 4.x

**Features:**
- Proven stability on ancient hardware
- Includes 4 compatibility patches for old uClibc versions
- Lightweight and minimal

### Version 1.0.55 (Modern - from uClibc-ng)

**Recommended for:**
- Modern Fritz!Box devices (7490, 7590, etc.)
- Devices with uClibc >= 0.9.32 or uClibc-ng
- Toolchains with gcc >= 4.x

**Features:**
- **28+ Architecture Support**: ARM, ARM64, MIPS, RISC-V, x86_64, etc.
- **Improved MIPS Support**: EM_MIPS + EM_MIPS_RS3_LE
- **Modern Code Base**: Actively maintained and up to date
- **Bug Fixes**: 18+ years of development since ldd 0.1
- **No patches needed**: All legacy fixes already applied upstream

**Source:** Downloaded directly from uClibc-ng GitHub tag `v1.0.55`

## Configuration

During `make menuconfig`, you can choose which version to compile:

```
Packages > Debug helpers > ldd
  → Version: [0.1 (legacy)] or [1.0.55 (modern)]
```

The default is automatically selected based on your device's uClibc version.

## Further Links

-   [ldd Man page](http://www.gsp.com/cgi-bin/man.cgi?section=1&topic=ldd)
-   [uClibc-ng ldd.c source](https://github.com/uClibc-ng/uClibc-ng/blob/v1.0.55/utils/ldd.c)
-   [Unix Tip: Viewing library dependencies with ldd](http://www.itworld.com/nls_unix_lib060727)
-   [Linker and Libraries guide](http://docsun.cites.uiuc.edu/sun_docs/C/solaris_9/SUNWdev/LLM/p14.html)



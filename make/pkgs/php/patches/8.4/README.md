# PHP 8.4.1 Patches for Freetz-NG

This directory contains patches necessary for building PHP 8.4.1 on embedded systems with uClibc.

## Mandatory Patches (Always Applied)

### 300-no_ldcxx.patch
**Purpose**: Prevents unnecessary linking with libstdc++  
**Why**: PHP doesn't require C++ library, saves 1-2 MB on embedded systems  
**Impact**: Reduces binary size without affecting functionality

### 500-ttyname_r.patch
**Purpose**: Forces HAVE_TTYNAME_R=1 during cross-compilation  
**Why**: Configure script cannot test ttyname_r() when cross-compiling  
**Impact**: Ensures posix_ttyname() is thread-safe

### 600-strange_iconv_undef.patch
**Purpose**: Comments out problematic `#undef iconv` in ext/iconv/iconv.c  
**Why**: Prevents compilation conflicts with libiconv/uClibc  
**Impact**: Fixes ICONV extension compilation

## Optional Patches (Configurable in menuconfig)

### 150-phpinfo_omit_configure_command.patch
**Purpose**: Removes full configure command from phpinfo() output  
**Default**: Enabled  
**Config**: `Build options → Omit configure command from phpinfo()`  
**Benefits**:
- Reduces binary size (~200 bytes)
- Avoids exposing build system paths
- Cleaner phpinfo() output

**Disable if**: You need to debug build configuration issues

## Patch Application Order

1. **Download & unpack** PHP source
2. **Apply mandatory patches** automatically (from `patches/8.4/`)
3. **Apply optional patch** if `FREETZ_PACKAGE_PHP_OMIT_PHPINFO_CONFIGURE=y`
4. **Configure & build**

## Version Compatibility

These patches are specific to PHP 8.4.x. Different major versions require adjusted patches due to:
- Line number differences in configure script
- Code structure changes in C source files
- Different autoconf-generated configure scripts

For other PHP versions, see:
- `patches/5.6/` - PHP 5.6.x patches
- `patches/8.3/` - PHP 8.3.x patches (from PR #1252)

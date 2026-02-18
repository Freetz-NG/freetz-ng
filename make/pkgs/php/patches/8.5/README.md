# PHP 8.5.0 Patches for Freetz-NG

This directory contains patches necessary for building PHP 8.5.0 on embedded systems with uClibc.

## Mandatory Patches (Always Applied)

### 200-fix_ai_addrconfig.patch
**Purpose**: Defines AI_ADDRCONFIG constant if missing in old uClibc versions  
**Why**: uClibc < 1.0.x doesn't define AI_ADDRCONFIG in netdb.h, causing compilation errors in sockets extension  
**Impact**: Fixes sockets extension compilation on legacy toolchains (GCC 4.6.4 + uClibc 0.9.x)

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

## Porting Impact: PHP 8.5 → 8.6

When upgrading from PHP 8.4 to 8.5, verify these patches:

### Likely Still Needed (Low Risk)
- **200-fix_ai_addrconfig.patch**: AI_ADDRCONFIG definition unlikely to change; safe to port
- **300-no_ldcxx.patch**: C++ linking avoidance should remain relevant
- **500-ttyname_r.patch**: Cross-compilation ttyname_r issue persists
- **600-strange_iconv_undef.patch**: Iconv conflicts with uClibc remain

### May Need Updates (Medium Risk)
- **150-phpinfo_omit_configure_command.patch**: Line numbers in phpinfo.c may change

### Test After Porting
1. Build on legacy toolchain (GCC 4.6.4 + uClibc 0.9.28)
2. Verify sockets extension compiles
3. Check phpinfo() output (if optional patch applied)
4. Test basic PHP functionality on embedded device
- `patches/8.3/` - PHP 8.3.x patches (from PR #1252)

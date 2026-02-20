# util-linux (binary only)
  - Homepage: [https://en.wikipedia.org/wiki/Util-linux](https://en.wikipedia.org/wiki/Util-linux)
  - Manpage: [https://linux.die.net/man/8/blkid](https://linux.die.net/man/8/blkid)
  - Changelog: [https://mirrors.kernel.org/pub/linux/utils/util-linux/](https://mirrors.kernel.org/pub/linux/utils/util-linux/)
  - Repository: [https://git.kernel.org/pub/scm/utils/util-linux/util-linux.git](https://git.kernel.org/pub/scm/utils/util-linux/util-linux.git)
  - Package: [master/make/pkgs/util-linux/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/util-linux/)
  - Maintainer: -

## Overview

**util-linux** is a standard package of Linux utilities that includes various system tools for managing disks, file systems, and other system resources.

This package is available in two versions:

### Version 2.27.1 (Legacy)
- **Release date**: November 2015
- **Binary**: `blkid-util-linux` only
- **Patches**: 7 patches for compatibility with older uClibc and toolchains
  - `0001-sscanf-no-ms-as.buildroot.patch` - Fix for uClibc without scanf_alloc_modifier
  - `0003-c.h-define-mkostemp.buildroot.patch` - mkostemp() compatibility for old uClibc
  - `0004-vipw-buildroot.patch` - Pre-ANSI compiler support removal
  - `0190-reduce_size_flags.freetz.patch` - Size optimization flags
  - `0200-reduce_libblkid_size.freetz.patch` - Disable unused filesystems (RAID/LVM/enterprise FS)
  - `0900-relax_gettext_requirements.patch` - Lower gettext version requirement
  - `0905-blkid_mtdworkaround.freetz.patch` - Skip MTD devices in blkid probe
- **Constraints**: Only available when `FREETZ_PATCH_FREETZMOUNT` is enabled
- **Use case**: Legacy devices with old firmware (AVM 06.5X and earlier) requiring FREETZMOUNT patch
- **Size**: Minimal footprint, single utility (~50KB)
- **Maintenance**: Frozen version, no updates

### Version 2.41 (Modern)
- **Binaries**: 7 utilities
  - `blkid-util-linux` - locate/print block device attributes
  - `losetup-util-linux` - set up and control loop devices
  - `mkswap-util-linux` - set up a Linux swap area
  - `swapon-util-linux` - enable devices and files for paging and swapping
  - `swapoff-util-linux` - disable devices and files for paging and swapping (symlink to swapon)
  - `lsblk` - list block devices
  - `findmnt` - find a filesystem
- **Patches**: 1 Freetz-specific patch
  - `0905-blkid_mtdworkaround.freetz.patch` - Skip MTD devices in blkid probe
- **Constraints**: 
  - Requires uClibc >= 0.9.32 (or uClibc-ng >= 1.0.0)
  - Not available with uClibc 0.9.28/0.9.29
- **Use case**: Modern devices (AVM 07.XX+), full disk/filesystem management capabilities
- **Size**: Larger footprint (~200KB total for all utilities)
- **Maintenance**: Recent stable version, security updates available

## Version Selection

The package uses "make menuconfig" to allow selection between the two versions:
- **Default**: Version 2.27.1 if `FREETZ_PATCH_FREETZMOUNT` is enabled, otherwise 2.41
- **Reason for dual-version**: Maintain backwards compatibility for legacy devices while providing modern utilities for current systems

### Selection Rules:
1. **With FREETZ_PATCH_FREETZMOUNT** (firmware 06.5X and earlier):
   - Both versions available
   - 2.27.1 selected by default (tested and guaranteed compatible)
   - Can manually switch to 2.41 if toolchain supports it

2. **Without FREETZ_PATCH_FREETZMOUNT** (firmware 07.XX+):
   - Only version 2.41 available
   - No need for legacy version with old patches

3. **uClibc constraints**:
   - Version 2.27.1: Works with uClibc >= 0.9.32
   - Version 2.41: Requires uClibc >= 0.9.32 or uClibc-ng >= 1.0.0
   - Both versions: Not available with uClibc 0.9.28/0.9.29 (missing fdopendir)

## Patches

### Version 2.41 Patches
Version 2.41 includes only 1 FRITZ!Box-specific patch:

**0905-blkid_mtdworkaround.freetz.patch**
- Prevents blkid from probing MTD (Memory Technology Device) partitions
- Reason: FRITZ!Box uses MTD for flash storage, which are not regular block devices
- Effect: Avoids potential issues with flash partitioning

Note: Version 2.41 does not require the libblkid size reduction patch as many unnecessary
filesystems (EVMS, etc.) have been removed or made optional upstream.

### Version 2.27.1 Patches
Version 2.27.1 includes 7 patches (6 for old toolchain compatibility + 1 FRITZ!Box-specific):

**0001-sscanf-no-ms-as.buildroot.patch**
- Fixes libmount build under old uClibc versions
- Removes requirement for scanf_alloc_modifier (not available in uClibc 0.9.29/0.9.30)
- Origin: Buildroot/Gentoo compatibility patches

**0003-c.h-define-mkostemp.buildroot.patch**
- Provides mkostemp() function for older uClibc versions
- Required for uClibc < 0.9.33 which lacks this function
- Origin: Buildroot compatibility patch

**0004-vipw-buildroot.patch**
- Removes pre-ANSI compiler support (__P macro)
- Fixes compilation with musl libc and old toolchains
- Origin: Buildroot compatibility patch

**0190-reduce_size_flags.freetz.patch**
- Adds compiler flags: -ffunction-sections -fdata-sections
- Adds linker flags: -Wl,--gc-sections
- Effect: Enables dead code elimination for smaller binaries

**0900-relax_gettext_requirements.patch**
- Lowers gettext version requirement from 0.18.3 to 0.18.1
- Allows building on systems with older gettext versions
- Effect: Improves compatibility with old build environments

## Usage Notes

All util-linux binaries are installed with the `-util-linux` suffix to avoid conflicts with BusyBox equivalents. For example:
- `blkid-util-linux` (instead of `blkid`)
- `losetup-util-linux` (instead of `losetup`)

This allows both BusyBox and util-linux versions to coexist, letting users choose which implementation to use.


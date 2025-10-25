# binary-tools (readelf, objdump, objcopy, nm, strings, ar, ranlib, strip, addr2line, size, patchelf)
  - Homepage: [https://www.gnu.org/software/binutils/](https://www.gnu.org/software/binutils/)
  - Manpage: [https://sourceware.org/binutils/docs/](https://sourceware.org/binutils/docs/)
  - Changelog: [https://sourceware.org/binutils/docs-2.41/binutils/](https://sourceware.org/binutils/docs-2.41/binutils/)
  - Repository: [https://sourceware.org/git/binutils-gdb.git](https://sourceware.org/git/binutils-gdb.git)
  - Patchelf: [https://github.com/NixOS/patchelf](https://github.com/NixOS/patchelf)
  - Package: [master/make/pkgs/binary-tools/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/binary-tools/)
  - Maintainer: [@Ircama](https://github.com/Ircama)

## Overview

Binary analysis and manipulation utilities from GNU Binutils package plus patchelf. Essential for debugging, inspecting, and analyzing ELF binaries on the Fritz!Box router.

## Package Information

- **Version**: Binutils 2.41 + Patchelf 0.18.0
- **Category**: Debug helpers
- **Size**: ~16 MB (varies based on architecture)
- **Dependencies**: None
- **Externalization**: Recommended for USB storage

## Installation

Select in menuconfig:
```
Debug helpers ---> binary-tools
```

### Available Tools

All tools operate on ELF (Executable and Linkable Format) binaries:

- **`readelf`** - Display information about ELF files (headers, sections, symbols)
- **`objdump`** - Display object file information (disassembly, sections)
- **`objcopy`** - Copy and translate object files
- **`nm`** - List symbols from object files
- **`strings`** - Print printable strings from binary files
- **`ar`** - Create, modify, and extract from archives (.a files)
- **`ranlib`** - Generate index for archive contents
- **`strip`** - Discard symbols and debug information from binaries
- **`addr2line`** - Convert addresses to file/line numbers (debugging)
- **`size`** - List section sizes and total size of binaries
- **`patchelf`** - Modify ELF dynamic linker and RPATH (runtime library paths)

## Usage Examples

### Inspecting Binaries

```bash
# Display ELF header information
readelf -h /usr/bin/python3

# List all symbols in a binary
nm /usr/bin/python3

# Disassemble a binary (MIPS assembly)
objdump -d /usr/bin/python3

# Show dynamic library dependencies
readelf -d /usr/bin/python3 | grep NEEDED

# Display section sizes
size /usr/bin/python3
```

### Debugging

```bash
# Find source location of crash address
addr2line -e /usr/bin/python3 0x00400abc

# Extract strings from binary (useful for reverse engineering)
strings /usr/bin/python3 | grep -i "error"

# Check if binary is stripped
file /usr/bin/python3
```

### Binary Manipulation

```bash
# Strip debug symbols to reduce size
strip --strip-debug /tmp/mybinary

# Create static library archive
ar rcs libmylib.a obj1.o obj2.o obj3.o
ranlib libmylib.a

# Copy binary and change section names
objcopy --rename-section .data=.rodata mybinary mybinary.new

# Fix dynamic linker path (useful for Freetz-NG SEPARATE_AVM_UCLIBC)
patchelf --set-interpreter /usr/lib/freetz/ld-uClibc.so.1 /usr/bin/mybinary

# Change RPATH to use custom library location
patchelf --set-rpath /usr/lib/freetz /usr/bin/mybinary

# View current interpreter and RPATH
patchelf --print-interpreter /usr/bin/mybinary
patchelf --print-rpath /usr/bin/mybinary
```

## Common Use Cases

### 1. Debugging Crashes

When a program crashes, use `readelf` and `addr2line` to identify the problem:

```bash
# Program crashed at address 0x00405678
readelf -s /usr/bin/myprogram | grep "00405678"
addr2line -e /usr/bin/myprogram 0x00405678
```

### 2. Analyzing Dependencies

Check which libraries a binary needs:

```bash
readelf -d /usr/bin/python3 | grep NEEDED
# Output shows required .so files
```

### 3. Fixing Dynamic Linker Issues

When binaries fail with "not found" errors for the dynamic linker:

```bash
# Check current interpreter
readelf -l /usr/bin/mybinary | grep interpreter

# Fix it with patchelf
patchelf --set-interpreter /usr/lib/freetz/ld-uClibc.so.1 /usr/bin/mybinary

# Verify the change
readelf -l /usr/bin/mybinary | grep interpreter
```

This is especially useful when cross-compiling binaries or when using `FREETZ_SEPARATE_AVM_UCLIBC=y`.

### 4. Reverse Engineering

Extract information from unknown binaries:

```bash
# Find human-readable strings
strings /bin/unknown_binary

# List exported functions
nm -D /lib/libssl.so.1.1

# Disassemble specific function
objdump -d /usr/bin/binary | grep -A 20 "function_name"
```

### 4. Reducing Binary Size

Strip unnecessary symbols:

```bash
# Before
size mybinary
# text    data     bss     dec     hex filename
# 123456  45678   12345  181479  2c4e7 mybinary

# Strip debug info
strip --strip-debug mybinary

# After (smaller)
size mybinary
```

## Integration with GCC Toolchain

Binary-tools is automatically selected when installing the full GCC toolchain:

```
Debug helpers ---> GCC (Native Compiler for On-Device Compilation)
  [ ] Minimal installation (GCC + essential tools only)
```

**Minimal installation**: Includes only `ld`, `as`, `ar`, `ranlib` (essential for compilation)
**Full installation**: Includes all binary-tools utilities

## Troubleshooting

### "command not found"

Binary-tools must be externalized to USB storage:

```bash
# Check if tools are externalized
ls -la /var/media/ftp/uStor01/freetz-external/binary-tools/

# If not, run externalization
modsave flash
```

### Wrong Architecture Binaries

Binary-tools are MIPS binaries that run on the router. They analyze **any** architecture's ELF files, but they themselves must run on MIPS.

```bash
# This works (MIPS binary analyzing x86 file)
readelf -h /tmp/x86_binary.elf

# This won't work (trying to run x86 binary on MIPS router)
./x86_binary
# bash: ./x86_binary: cannot execute binary file
```

## Performance Considerations

- **`objdump -d`** (disassembly) on large binaries can be slow
- Use grep to filter output: `objdump -d binary | grep pattern`
- Consider copying binaries to RAM for faster analysis: `cp /var/media/ftp/file /tmp/`

## See Also

- **[GCC Toolchain](gcc-toolchain.md)** - Native compiler for on-device development
- **[strace](strace.md)** - System call tracer (runtime debugging)
- **[gdb](gdb.md)** - GNU Debugger (interactive debugging)
- [GNU Binutils Documentation](https://sourceware.org/binutils/docs/)

---

**Version**: 2.41  
**Package**: binary-tools  
**Category**: Debug helpers

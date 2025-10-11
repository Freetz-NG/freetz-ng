# Freetz-NG Package Development Guide

This guide provides best practices and step-by-step instructions for developing packages in Freetz-NG.

## Table of Contents

1. [General Principles](#general-principles)
2. [Adding Simple Binary Packages](#adding-simple-binary-packages)
3. [Adding Packages with Data Files](#adding-packages-with-data-files)
4. [Adding Multi-Binary Packages](#adding-multi-binary-packages)
5. [Adding Python 3rd-Party Modules](#adding-python-3rd-party-modules)
6. [Makefile Best Practices](#makefile-best-practices)
7. [Common Pitfalls and Solutions](#common-pitfalls-and-solutions)
8. [Testing and Validation](#testing-and-validation)

---

## General Principles

### Directory Structure
```
make/pkgs/PACKAGE_NAME/
├── Config.in          # Package configuration
├── PACKAGE_NAME.mk    # Build instructions
├── external.in        # (Optional) Externalization config
├── external.files     # (Optional) Files to externalize
└── files/             # (Optional) Additional files to install
```

### Naming Conventions
- Package directory: `make/pkgs/package-name/`
- Makefile: `package-name.mk` (matches directory name)
- Variables: Use `$(PKG)` macro, NOT hardcoded package names
- Avoid nested variable references: Use `$(ZIP_DIR)` not `$($(PKG)_DIR)`

### SUPPORT Field
Add a SUPPORT field to track maintainership:
```makefile
### SUPPORT:=YourGitHubUsername
```

---

## Adding Simple Binary Packages

**Example: zip package**

### Step 1: Create Directory Structure
```bash
mkdir -p make/pkgs/zip
```

### Step 2: Create Config.in
```bash
cat > make/pkgs/zip/Config.in << 'EOF'
config FREETZ_PACKAGE_ZIP
	bool "zip 3.0 (binary only)"
	default n
	help
		zip - package and compress (archive) files

		Brief description of what the package does.
		
		Can be externalized to save flash memory.
EOF
```

### Step 3: Create Makefile (zip.mk)

**Important:** Handle non-standard archive directory names!

```makefile
$(call PKG_INIT_BIN, 3.0)
$(PKG)_SOURCE:=zip30.tar.gz
$(PKG)_HASH:=<sha256sum>
$(PKG)_SITE:=https://downloads.sourceforge.net/infozip
$(PKG)_SOURCE_DIR:=$(SOURCE_DIR)/$(PKG_LANG)
$(PKG)_DIR:=$($(PKG)_SOURCE_DIR)/zip30  # Actual directory name after extraction
### WEBSITE:=https://infozip.sourceforge.net/Zip.html
### SUPPORT:=YourUsername

$(PKG)_BINARY_BUILD := $(ZIP_DIR)/zip
$(PKG)_BINARY_TARGET := $($(PKG)_DEST_DIR)/usr/bin/zip

$(PKG)_MAKE_OPTIONS += -f unix/Makefile
$(PKG)_MAKE_OPTIONS += CC="$(TARGET_CC)"
$(PKG)_MAKE_OPTIONS += CPP="$(TARGET_CC) -E"
$(PKG)_MAKE_OPTIONS += CFLAGS="$(TARGET_CFLAGS)"
$(PKG)_MAKE_OPTIONS += generic

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)

# For packages without configure script
$(ZIP_DIR)/.configured: $(ZIP_DIR)/.unpacked
	touch $@

$(ZIP_BINARY_BUILD): $(ZIP_DIR)/.configured
	$(SUBMAKE) -C $(ZIP_DIR) $(ZIP_MAKE_OPTIONS)

$(ZIP_BINARY_TARGET): $(ZIP_BINARY_BUILD)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $(ZIP_BINARY_TARGET)

$(pkg)-clean:
	-$(SUBMAKE) -C $(ZIP_DIR) $(ZIP_MAKE_OPTIONS) clean

$(pkg)-uninstall:
	$(RM) $(ZIP_BINARY_TARGET)

$(PKG_FINISH)
```

**Key Points:**
- If archive extracts to a different directory name (e.g., `zip30` instead of `zip-3.0`), override `$(PKG)_DIR`
- Use direct variable names (`ZIP_DIR`) not nested `$($(PKG)_DIR)` for better make compatibility
- For packages without `./configure`, create `.configured` marker manually

---

## Adding Packages with Data Files

**Example: file package (includes magic database)**

### Additional Files in Makefile

```makefile
$(PKG)_BINARY_BUILD := $($(PKG)_DIR)/src/file
$(PKG)_BINARY_TARGET := $($(PKG)_DEST_DIR)/usr/bin/file

# Additional data file
$(PKG)_MAGIC_BUILD := $($(PKG)_DIR)/magic/magic.mgc
$(PKG)_MAGIC_TARGET := $($(PKG)_DEST_DIR)/usr/share/misc/magic.mgc

$(PKG_CONFIGURE_OPTIONS) += --enable-static
$(PKG_CONFIGURE_OPTIONS) += --disable-shared

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY_BUILD): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(FILE_DIR)

$($(PKG)_BINARY_TARGET): $($(PKG)_BINARY_BUILD)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_MAGIC_TARGET): $($(PKG)_MAGIC_BUILD)
	$(INSTALL_FILE)

$(pkg)-precompiled: $($(PKG)_BINARY_TARGET) $($(PKG)_MAGIC_TARGET)

$(pkg)-uninstall:
	$(RM) $($(PKG)_BINARY_TARGET)
	$(RM) $($(PKG)_MAGIC_TARGET)
	$(RM) -r $($(PKG)_DEST_DIR)/usr/share/misc
```

### Externalization Support

Create `external.in`:
```
config EXTERNAL_FREETZ_PACKAGE_FILE
	depends on EXTERNAL_ENABLED && FREETZ_PACKAGE_FILE && EXTERNAL_SUBDIRS
	bool "file (externalization recommended)"
	default n
	help
		Externalize file command to USB storage.
		
		Files externalized:
		- /usr/bin/file
		- /usr/share/misc/magic.mgc
```

Create `external.files`:
```bash
if [ "$EXTERNAL_FREETZ_PACKAGE_FILE" == "y" ] ; then
	EXTERNAL_FILES+=" /usr/bin/file /usr/share/misc/magic.mgc"
fi
```

---

## Adding Multi-Binary Packages

**Example: binary-tools (10 binaries from single source)**

### Makefile Structure

```makefile
$(call PKG_INIT_BIN, 2.41)
$(PKG)_SOURCE:=binutils-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=<sha256>
$(PKG)_SITE:=https://ftp.gnu.org/gnu/binutils
### SUPPORT:=YourUsername

# Define all binaries
$(PKG)_READELF_BUILD := $($(PKG)_DIR)/binutils/readelf
$(PKG)_READELF_TARGET := $($(PKG)_DEST_DIR)/usr/bin/readelf

$(PKG)_OBJDUMP_BUILD := $($(PKG)_DIR)/binutils/objdump
$(PKG)_OBJDUMP_TARGET := $($(PKG)_DEST_DIR)/usr/bin/objdump

# ... (repeat for all binaries)

$(PKG)_CONFIGURE_OPTIONS += --target=$(REAL_GNU_TARGET_NAME)
$(PKG)_CONFIGURE_OPTIONS += --disable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static

# Manual configuration to avoid conflicts with toolchain
$($(PKG)_DIR)/.configured: | $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libc.a
	mkdir -p $(BINARY_TOOLS_DIR)
	(cd $(BINARY_TOOLS_DIR); rm -f config.cache; \
		$(TARGET_CONFIGURE_ENV) \
		$(FREETZ_BASE_DIR)/$(BINARY_TOOLS_SOURCE_DIR)/configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(REAL_GNU_TARGET_NAME) \
		--target=$(REAL_GNU_TARGET_NAME) \
		$(BINARY_TOOLS_CONFIGURE_OPTIONS) \
	)
	touch $@

# Build all
$(BINARY_TOOLS_READELF_BUILD) $(BINARY_TOOLS_OBJDUMP_BUILD) ... : $(BINARY_TOOLS_DIR)/.configured
	$(SUBMAKE) -C $(BINARY_TOOLS_DIR)

# Install each binary
$(BINARY_TOOLS_READELF_TARGET): $(BINARY_TOOLS_READELF_BUILD)
	$(INSTALL_BINARY_STRIP)

# Precompiled target includes ALL binaries
$(pkg)-precompiled: $(BINARY_TOOLS_READELF_TARGET) \
                    $(BINARY_TOOLS_OBJDUMP_TARGET) \
                    # ... (all targets)

$(pkg)-uninstall:
	$(RM) $(BINARY_TOOLS_READELF_TARGET) \
	      $(BINARY_TOOLS_OBJDUMP_TARGET) \
	      # ... (all targets)
```

**Key Points:**
- Avoid using standard `PKG_SOURCE_DOWNLOAD`/`PKG_UNPACKED` macros if they conflict with toolchain
- Manual configuration gives more control
- Group all binary builds in one rule for efficiency

---

## Adding Python3 3rd-Party Modules

### Step 1: Create Package Structure

```bash
mkdir -p make/pkgs/python3-MODULENAME
```

### Step 2: Config.in

```
config FREETZ_PACKAGE_PYTHON3_MODULENAME
	bool "modulename X.Y.Z"
	depends on FREETZ_PACKAGE_PYTHON3
	select FREETZ_PACKAGE_PYTHON3_DEPENDENCY1  # if needed
	default n
	help
		Brief description
		
		Features:
		  - Feature 1
		  - Feature 2
		
		Size: ~X MB
```

Add `depends on FREETZ_SHOW_DEVELOPER` if in developer mode.

### Step 3: Makefile (python3-modulename.mk)

```makefile
$(call PKG_INIT_BIN, X.Y.Z)
$(PKG)_SOURCE:=modulename-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=<sha256>
$(PKG)_SITE:=https://files.pythonhosted.org/packages/source/m/modulename
### WEBSITE:=https://pypi.org/project/modulename/
### SUPPORT:=YourUsername

$(PKG)_DEPENDS_ON += python3
$(PKG)_DEPENDS_ON += python3-setuptools

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_DIR)/.compiled: $($(PKG)_DIR)/.configured
	$(call Build/Py3Mod/Pip, PYTHON3_MODULENAME, , )
	@touch $@

$(pkg):

$(pkg)-precompiled: $($(PKG)_DIR)/.compiled

$(pkg)-clean:
	$(RM) $(PYTHON3_MODULENAME_DIR)/{.configured,.compiled}
	$(RM) -r $(PYTHON3_MODULENAME_DIR)/build

$(pkg)-uninstall:
	$(RM) -r \
		$(PYTHON3_MODULENAME_DEST_DIR)$(PYTHON3_SITE_PKG_DIR)/modulename \
		$(PYTHON3_MODULENAME_DEST_DIR)$(PYTHON3_SITE_PKG_DIR)/modulename-*.dist-info

$(PKG_FINISH)
```

### Step 4: Add to Python3 Menu

Edit `make/pkgs/python3/Config.in` and add under "3rd-party modules":
```
source "make/pkgs/python3-modulename/Config.in"
```

---

## Makefile Best Practices

### Variable References

❌ **AVOID:**
```makefile
$($(PKG)_DIR)/.configured     # Nested variables
$(dir $@)/$(notdir $@)        # Can create double slashes
```

✅ **PREFER:**
```makefile
$(ZIP_DIR)/.configured        # Direct variable
$@                            # Use target directly
```

### Calling External Scripts

❌ **AVOID relative paths:**
```makefile
tools/script.sh packages/...  # Fails if pwd is wrong (some scripts change the current directory internally)
```

✅ **USE absolute paths:**
```makefile
$(FREETZ_BASE_DIR)/tools/script.sh $(FREETZ_BASE_DIR)/packages/...
```

### Process Substitution in Makefiles

❌ **DOESN'T WORK (requires bash):**
```makefile
while read line; do ... done < <(find ...)
```

✅ **WORKS (POSIX sh):**
```makefile
find ... > /tmp/tempfile_$$$$; \
while read line; do ... done < /tmp/tempfile_$$$$; \
rm /tmp/tempfile_$$$$
```

Or better: **Use external bash script!**

## Common Pitfalls and Solutions

### Problem: "No rule to make target 'source/.../package-X.Y'"

**Cause:** Package directory name mismatch after extraction

**Solution:** Override `$(PKG)_DIR`:
```makefile
$(PKG)_SOURCE:=zip30.tar.gz
$(PKG)_DIR:=$($(PKG)_SOURCE_DIR)/zip30  # Actual directory after extraction
```

### Problem: Makefile creates duplicate warnings

**Cause:** Multiple packages using same source (e.g., binutils)

**Solution:** Don't use standard macros for secondary packages:
```makefile
# DON'T use: $(PKG_SOURCE_DOWNLOAD), $(PKG_UNPACKED)
# Instead: manually manage dependencies
$($(PKG)_DIR)/.configured: | $(TOOLCHAIN_DEPENDENCY)
	# custom build
```

### Problem: Script fails with "file not found" in makefile

**Cause:** Script executed from build directory, relative paths broken

**Solution:** Always use `$(FREETZ_BASE_DIR)` prefix:
```makefile
$(FREETZ_BASE_DIR)/tools/script.sh $(FREETZ_BASE_DIR)/packages/...
```

### Problem: Python 3.13 "No module named 'encodings'"

**Cause:** Python 3.13 changed zip importer behavior - requires `.pyc` files at package level, not just in `__pycache__/`

**Solution:** Use fix script:
```makefile
$(if $(FREETZ_PACKAGE_PYTHON3_COMPRESS_PYC), \
	$(FREETZ_BASE_DIR)/tools/fix-python313-zip.sh $(FREETZ_BASE_DIR)/$@; \
)
```

### Build Won't Start

**Problem:** Running `make PACKAGE` does nothing or fails immediately.

**Common Causes:**

1. **Missing `-precompiled` or `-recompile` suffix**
   - ❌ Wrong: `make zip`
   - ✅ Correct: `make zip-precompiled` or `make zip-recompile`. Always use `make help` for instructions.
   
   See *00_FAQ/FAQ.en.md* in the Wiki for the **description of the make options**.

2. **Package not registered in build system**
   - Missing from `make/pkgs/Config.in.generated` (auto-generated, don't edit manually)
   - Solution: Ensure `Config.in` exists and run `make config-clean-deps`

3. **Makefile syntax errors**
   - Check for proper tab indentation (Makefiles require tabs, not spaces!)
   - Validate variable references: use `$(ZIP_DIR)` not `$($(PKG)_DIR)` for direct access

**Diagnostic Steps:**

```bash
# Step 1: List available targets for your package
make help | grep -i PACKAGE

# Step 2: Clean and rebuild configuration
make config-clean-deps
make menuconfig  # Enable your package

# Step 3: Clean build test
make PACKAGE-dirclean
make PACKAGE-precompiled

# Step 4: Check for errors in Config.in
cat make/pkgs/PACKAGE/Config.in
# Verify: proper syntax, no typos in config names

# Step 5: Validate makefile syntax
make -n PACKAGE-precompiled  # Dry run to check make logic
```

**Target Suffixes Reference:**

| Target | Description | When to Use |
|--------|-------------|-------------|
| `PACKAGE` | Alias, usually does nothing | Don't use directly |
| `PACKAGE-precompiled` | Build and install to staging | First build, fresh compile |
| `PACKAGE-recompile` | Rebuild without dirclean | Iterative development |
| `PACKAGE-clean` | Clean build artifacts | After source changes |
| `PACKAGE-dirclean` | Complete clean, re-extract source | Reset to pristine state |
| `PACKAGE-uninstall` | Remove from staging | Testing removal |

See *00_FAQ/FAQ.en.md* in the Wiki.

### Problem: While loop in makefile doesn't modify files

**Cause:** Pipe creates subshell, changes don't persist

**Solution:** Use temp file:
```makefile
find ... > /tmp/list_$$$$; \
while read item; do \
	# modifications happen in main shell
done < /tmp/list_$$$$; \
rm /tmp/list_$$$$
```

Or: **Extract to separate bash script!**

---

## Freetz-NG Specific Coding Conventions

### Shell Coding Standards

**TAB Indentation (REQUIRED)**
- Makefiles and shell scripts MUST use TAB characters (not spaces)
- Visual display: 4 spaces, but character MUST be TAB
- Continuation lines: TAB + 2 spaces

### Package Initialization Macros

**PKG_INIT_BIN vs PKG_INIT_LIB**
```makefile
# For binary packages
$(call PKG_INIT_BIN, VERSION)

# For library packages
$(call PKG_INIT_LIB, VERSION)
```

**Naming Conventions**
- `$pkg` (lowercase) = package name
- `$PKG` (uppercase) = makefile variables
- Example: `$(PKG)_VERSION`, `$(PKG)_SOURCE`, `$(PKG)_BINARY`

**Target Directory Conventions**
```makefile
# Binary packages
$(PKG)_TARGET_DIR := $(TARGET_SPECIFIC_ROOT_DIR)/usr/bin

# Library packages
$(PKG)_TARGET_DIR := $(TARGET_SPECIFIC_ROOT_DIR)$(FREETZ_LIBRARY_DIR)
```

### Standard Makefile Targets

All packages should support:
- `PACKAGE-download` - Download source archive
- `PACKAGE-source` - Download and extract source
- `PACKAGE-unpacked` - Extract and apply patches
- `PACKAGE-precompiled` - Build and install to staging
- `PACKAGE-clean` - Clean build artifacts
- `PACKAGE-dirclean` - Remove source directory completely
- `PACKAGE-list` - List installed files
- `PACKAGE-uninstall` - Remove installed files

### STARTLEVEL System

Package initialization order (00-99):
- **00**: Critical services (crond, telnetd, webcfg)
- **10-14**: Basics (inotify, usbroot, syslogd, downloader, inetd)
- **20-25**: Network interfaces and firewall
- **30**: SSH services (authorized-keys, ca-bundle, dropbear)
- **40**: DNS services (bind, dnsmasq, unbound)
- **50**: Mounting services (autofs, cifsmount, davfs2)
- **60-90**: Various application services
- **99**: Default (no runscript needed)

Set in makefile:
```makefile
$(PKG)_STARTLEVEL=50  # Custom start level
```

### Multi-Binary Packages Pattern

Use static pattern rules to avoid code duplication:

```makefile
# Define all possible binaries
$(PKG)_BINARIES_ALL := binary1 binary2 binary3

# Filter based on user selection
$(PKG)_BINARIES := $(strip $(foreach binary,$($(PKG)_BINARIES_ALL),\
    $(if $(FREETZ_PACKAGE_$(PKG)_$(shell echo $(binary) | tr [a-z] [A-Z])),$(binary))))

# Build directory paths
$(PKG)_BINARIES_BUILD_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)

# Target directory paths
$(PKG)_BINARIES_TARGET_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

# Cleanup non-included binaries
$(PKG)_NOT_INCLUDED := $(patsubst %,$($(PKG)_DEST_DIR)/usr/bin/%,\
    $(filter-out $($(PKG)_BINARIES),$($(PKG)_BINARIES_ALL)))

# Static pattern rule for installation
$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)
```

### Device Table Format

For creating device nodes without root privileges:

```
#<name>          <type> <mode> <uid> <gid> <major> <minor> <start> <inc> <count>
/dev/ttyS        c      666    0     0     4       64      0       1     4
```

**Types**: `f` (file), `d` (directory), `c` (char device), `b` (block device), `p` (fifo)

**Device Ranges**: Use start/inc/count to create multiple devices:
```
/dev/hda         b      640    0     0     3       1       1       1     15
# Creates /dev/hda1 through /dev/hda15
```

### Persistent Configuration

Packages requiring persistent settings:

**Location**: `/etc/default.$package/$package.cfg`

**Format**: Shell variables with package prefix
```bash
export PACKAGE_VARIABLE="value"
export PACKAGE_OPTION="enabled"
```

**Save Mechanism**:
```bash
pkg_pre_save() {
    # Pre-processing before save
}

pkg_apply_save() {
    # Actual save operation
    modconf set $package VAR=value
}

pkg_post_save() {
    # Post-processing after save
}
```

**User Commands**:
```bash
# Set configuration
modconf set package VARIABLE=value

# Save to package config
modconf save package

# Flash to permanent storage
modsave flash

# Shortcut (save + flash)
modsave
```

### Patch Format and Best Practices

**Patch Structure**:
```
Description of what this patch does and why

--- original/file.c
+++ modified/file.c
@@ -51,6 +51,7 @@
 context line before
 context line before
 context line before
+new line added
 context line after
 context line after
 context line after
```

**Creating Patches**:
```bash
# Single file
svn diff Config.in > Config.patch

# All changes
svn diff > all.patch

# Add new files first
svn add filename
```

**Applying Patches**:
```bash
# Apply
patch -p0 < file.patch

# Revert
patch -Rp0 < file.patch

# Failed patch creates .rej file
```

---

## Troubleshooting Build Issues

### Build Won't Start

**Symptoms**: Build fails immediately or configuration issues

**Solutions**:
1. **Clean generated config files**:
   ```bash
   rm -f make/pkgs/Config.in.generated make/pkgs/external.in.generated config/.cache.in
   make config-clean-deps
   ```

2. **Verify Config.in syntax**:
   - Check for missing `endif`, `endchoice`, `endmenu`
   - Ensure proper indentation (TABs not spaces)
   - Run `make menuconfig` to catch warnings

3. **Check dependencies**:
   - Verify `select` and `depends on` statements
   - Ensure selected packages exist

### Make Fail Strategies

**dirclean Strategy**:
```bash
make PACKAGE-dirclean
make PACKAGE-precompiled
```
- Removes source directory completely
- Regenerates all Makefiles from scratch
- Use when configure options change

**precompiled Strategy**:
```bash
make PACKAGE-precompiled
```
- Builds package from clean state
- Doesn't remove source directory
- Faster than dirclean

**recompile Strategy**:
```bash
make PACKAGE-recompile
```
- Recompiles without full cleanup
- Quick iteration during development
- May miss dependency changes

### GCC Target Compilation Troubleshooting

**CFLAGS Pollution Issue**:

**Symptom**: Host compiler receives target flags
```
error: unknown argument: '-march=34kc'
```

**Root Cause**: `TARGET_CONFIGURE_ENV` sets CFLAGS with MIPS flags, inherited by host compiler during GCC build

**Solution**: Reset CFLAGS during configure and make
```makefile
$($(PKG)_DIR)/.configured:
	CFLAGS="" CXXFLAGS="" \
	CFLAGS_FOR_BUILD="$(TOOLCHAIN_HOST_CFLAGS)" \
	CXXFLAGS_FOR_BUILD="$(TOOLCHAIN_HOST_CXXFLAGS)" \
	$(TARGET_CONFIGURE_ENV) \
	./configure $(TARGET_CONFIGURE_OPTIONS)
	touch $@

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	CFLAGS= CXXFLAGS= \
	$(MAKE) -C $($(PKG)_DIR) -j1
```

**Cached Makefiles**:
- Always use `make PACKAGE-dirclean` before rebuild after changing configure options
- GCC configure caches flags in generated Makefiles

**libcc1 Plugin Bug**:

**Symptom**: 
```
configure: line 15097: -T: command not found
```

**Root Cause**: libcc1 plugin has broken configure script for MIPS cross-compile

**Solution**: Disable libcc1 (not needed for compiler functionality)
```makefile
$(GCC_TARGET_DIR)/.configured: $(GCC_DIR)/.configured
	mkdir -p $(GCC_TARGET_DIR)
	cd $(GCC_TARGET_DIR) && \
	CFLAGS="" CXXFLAGS="" \
	$(GCC_CONFIGURE_ENV) \
	$(GCC_DIR)/configure \
		--disable-libcc1 \
		$(GCC_TARGET_CONFIGURE_OPTIONS)
	touch $@
```

### Target Suffix Reference

| Suffix | Host Compiler | Target Architecture | Example |
|--------|--------------|---------------------|---------|
| `_initial` | Build (x86_64) | Build (x86_64) | gcc_initial |
| (none/stage2) | Build (x86_64) | Target (MIPS) | gcc (cross-compiler) |
| `_target` | Target (MIPS) | Target (MIPS) | gcc_target (native) |

---

## Precompiled Host-Tools System

Freetz-NG uses a **precompiled host-tools package** to speed up builds for end users. Understanding this system is crucial when updating host-tools.

### How It Works

**1. GitHub Actions Workflow (`.github/workflows/dl-hosttools.yml`)**

The workflow automatically builds and packages all host-tools when triggered:

```yaml
on:
  push:
    branches: [ master ]
    paths:
      - '.github/workflows/dl-hosttools.yml'
      - 'tools/dl-hosttools'
      - 'make/host-tools/tools-host/tools-host.mk'
  workflow_dispatch:  # Manual trigger
```

**Triggers:**
- Push to `master` branch
- Changes to workflow, packaging script, or `tools-host.mk`
- **Manual trigger** via `workflow_dispatch` (Actions → Run workflow)

**2. Build Process (`tools/dl-hosttools` script)**

The script compiles all host-tools from source:

```bash
make tools-allexcept-local  # Compiles ALL host-tools
```

This includes:
- `patchelf` - ELF binary patcher
- `fakeroot` - Fake root privileges
- `autoconf`, `automake`, `libtool` - Build system tools
- `squashfs-tools` - Filesystem tools
- Many others (see `tools/.gitignore`)

**3. Packaging**

Creates a single tarball with all compiled tools:

```bash
tar cf - $(tools listed in .gitignore) | xz -9 - > "dl/tools-VERSION.tar.xz"
```

**4. Release**

Uploads the package to GitHub Releases for public download.

**5. Version Bump**

Updates `make/host-tools/tools-host/tools-host.mk` with new version and SHA256 hash.

### User Perspective

**Fresh Clone with Precompiled Tools (Default)**:

```bash
git clone https://github.com/Ircama/freetz-ng.git
cd freetz-ng
make menuconfig
make
```

What happens:
1. `make` detects `FREETZ_HOSTTOOLS_DOWNLOAD=y` (default)
2. Downloads `tools-VERSION.tar.xz` from GitHub Releases
3. Extracts to `tools/` directory
4. **Skips compilation** of individual host-tools (saves ~30 minutes!)

**Build from Source**:

```bash
make menuconfig
# Set: Advanced → Freetz NG Compilation Environment → Download precompiled tools → NO
make
```

What happens:
1. Compiles each host-tool from source using `make/host-tools/TOOL/TOOL.mk`
2. Takes longer but always uses latest makefile definitions

### Developer Perspective: Updating a Host-Tool

**Example: Upgrading patchelf from 0.15.0 to 0.18.0**

#### Step 1: Update the Host-Tool Makefile

```makefile
# In make/host-tools/patchelf-host/patchelf-host.mk
$(call TOOLS_INIT, 0.18.0)  # Was: 0.15.0
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_HASH:=1952b2a782ba576279c211ee942e341748fdb44997f704dd53def46cd055470b
$(PKG)_SITE:=https://github.com/NixOS/patchelf/releases/download/$($(PKG)_VERSION)
```

#### Step 2: Test Locally

**CRITICAL**: You must manually compile the tool to test your changes:

```bash
# Clean old version
make patchelf-host-dirclean

# Compile new version
make patchelf-host-precompiled

# Verify
tools/patchelf --version
# Should output: patchelf 0.18.0
```

**Why?** If you just run `make`, it will download the old precompiled package and skip compilation!

#### Step 3: Test in Real Build

```bash
# Use the updated tool in actual build
make menuconfig
# Select packages that use patchelf
make
```

#### Step 4: Submit Pull Request

Include a reminder in your PR description in case the precompiled tools package needs to be rebuilt.

Use `make TOOL-precompiled` to test locally (it forces compilation from source using your updated makefile).

### Debugging Host-Tools Issues

**Check which version is being used:**

```bash
# Check version
tools/patchelf --version

# Check file timestamp
ls -la tools/patchelf

# Check if from precompiled package or compiled locally
find source/host-tools -name "patchelf-*" -type d
# If found → compiled locally
# If not found → from precompiled package
```

**Force local compilation:**

```bash
# Remove precompiled tool
rm tools/patchelf

# Remove downloaded package
rm dl/tools-*.tar.xz

# Compile from source
make patchelf-host-precompiled
```

**Check tools-host version:**

```bash
# See current precompiled package version
grep TOOLS_INIT make/host-tools/tools-host/tools-host.mk
# Output: $(call TOOLS_INIT, r12345)
```

## Essential Wiki Documentation

The following wiki documents provide detailed information on Freetz-NG development:

### Package Development
- **[Package Development Start](../wiki/60_Development/package_development_start.en.md)** - Getting started with your first package
- **[Package Development Basics](../wiki/60_Development/package_development_basics.en.md)** - Fundamental concepts and persistent settings
- **[Package Development Makefiles](../wiki/60_Development/package_development_makefiles.en.md)** - Makefile conventions and macros
- **[Package Development Advanced](../wiki/60_Development/package_development_advanced.en.md)** - Multi-binary packages and patterns
- **[Shell Coding Conventions](../wiki/60_Development/shell_coding_conventions.en.md)** - Shell scripting standards

### Specific Topics
- **[STARTLEVEL of Packages](../wiki/60_Development/startlevel_of_packages.en.md)** - Package initialization order (00-99)
- **[Device Table](../wiki/60_Development/device_table.md)** - Creating device nodes on-the-fly
- **[Patch Format](../wiki/60_Development/patch.md)** - Creating and applying patches
- **[Package Configuration](../wiki/60_Development/package_development_config.en.md)** - modconf and modsave commands

### Troubleshooting
- **[Make Fail Strategies](../wiki/40_Troubleshooting/make_fail.md)** - dirclean, precompiled, recompile strategies

### Examples
- **[Package Example 1](../wiki/60_Development/package_development_pkgexample1.en.md)** - Simple binary package
- **[Package Example 2](../wiki/60_Development/package_development_pkgexample2.en.md)** - Package with patches
- **[Package Example 3](../wiki/60_Development/package_development_pkgexample3.en.md)** - Package with library dependencies

**Tip**: Always consult these documents when implementing complex features or troubleshooting build issues.

---

## Package Documentation

### Documentation Location

**All package-specific documentation must be placed in `docs/make/`.**

This directory contains user-facing documentation for individual packages, following a consistent naming convention:

**Naming Convention**: `package-name.md` (lowercase, hyphen-separated)

**Examples**:
- `gcc-toolchain.md` - GCC native compiler documentation
- `python3.md` - Python 3 interpreter
- `python-cffi.md` - Python CFFI module
- `binary-tools.md` - Binary utilities (readelf, objdump, etc.)

### When to Create Package Documentation

Create documentation in `docs/make/` when:

1. **Complex Setup Required** - Package needs configuration beyond default
2. **Non-Obvious Usage** - Special commands or workflows needed
3. **Important Limitations** - Size requirements, dependencies, compatibility issues
4. **Integration Examples** - How to use with other packages
5. **Troubleshooting** - Common issues and solutions

### Documentation Template

```markdown
# Package Name

## Overview
Brief description of what the package does.

## Installation
Size, dependencies, special requirements.

## Configuration
How to configure via menuconfig or config files.

## Usage
Basic usage examples and commands.

## Troubleshooting
Common issues and solutions.

## See Also
Related packages, wiki links, external resources.
```

### Current Package Documentation

The following packages have dedicated documentation in `docs/make/`:

**Development Tools**:
- `gcc-toolchain.md` - Native GCC compiler for on-device compilation
- `gcc-toolchain-summary.md` - Quick start guide and executive summary
- `gcc-toolchain-changes.md` - Technical changelog of all modifications
- `binary-tools.md` - Binary utilities (readelf, objdump, nm, strings, ar, ranlib, strip, addr2line, size)

**Python Ecosystem**:
- `python.md` - Python 2.x (legacy)
- `python3.md` - Python 3.13.7 interpreter
- `python-cffi.md` - C Foreign Function Interface for Python (1.17.1)
- `python-pycryptodome.md` - Cryptographic library for Python (3.23.0)

**Note**: Not all packages require documentation. Small, self-explanatory packages (like `file`, `zip`, `unzip`) can rely on Config.in help text alone. Create documentation when setup is complex, usage is non-obvious, or troubleshooting guidance is needed.

### Updating the Package Index

**IMPORTANT**: After creating or updating package documentation, you MUST regenerate the package index.

The file `docs/make/README.md` is **auto-generated** and should NEVER be edited manually. It serves as the main index for all packages and their documentation.

**Regeneration Process**:

```bash
# From the repository root
cd docs/make
bash generate.sh

# Or regenerate all documentation at once
cd docs
bash generate.sh
```

**What the script does**:

1. Scans all packages in `make/pkgs/`
2. Extracts package information from:
   - `Config.in` - Package title and help text
   - `PACKAGE.mk` - Metadata (SUPPORT, WEBSITE, MANPAGE, CHANGES, CVSREPO)
   - Existing `.md` files in `docs/make/` - Creates links if documentation exists
3. Organizes packages by category (Packages, Debug helpers, Unstable, etc.)
4. Generates alphabetical index with links
5. Creates both `make/pkgs/README.md` and `docs/make/README.md`

**When to regenerate**:

- After creating new package documentation (`.md` file)
- After adding new package to `make/pkgs/`
- After changing package title in `Config.in`
- After updating package metadata in `.mk` file (SUPPORT, WEBSITE, etc.)
- Before submitting a pull request

**Example workflow**:

```bash
# 1. Create your package
mkdir make/pkgs/mypackage
vim make/pkgs/mypackage/Config.in
vim make/pkgs/mypackage/mypackage.mk

# 2. Create documentation
vim docs/make/mypackage.md

# 3. Regenerate index
cd docs/make
bash generate.sh

# 4. Verify your package appears
grep "mypackage" README.md

# 5. Commit everything
git add make/pkgs/mypackage/
git add docs/make/mypackage.md
git add docs/make/README.md make/pkgs/README.md
git commit -m "Add mypackage: Brief description"
```

**Common mistakes**:

- Editing `docs/make/README.md` manually (changes will be overwritten!)
- Forgetting to regenerate after creating documentation
- Committing package without regenerating index

**Verification**:

After regeneration, check that:
- Your package appears in the correct category
- Documentation link works (if `.md` file exists)
- Help text is properly extracted from `Config.in`
- Metadata links are correct (if defined in `.mk`)

---

## Resources

- Main Makefile: `Makefile`
- Package macros: `make/pkgs/Makefile.in`
- Python helpers: `make/pkgs/python3/python3.mk`
- Existing packages: `make/pkgs/*/`
- Tools directory: `tools/`
- Wiki documentation: `docs/wiki/`
- Package documentation: `docs/make/`

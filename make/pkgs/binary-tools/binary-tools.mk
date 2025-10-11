$(call PKG_INIT_BIN, 2.41)
$(PKG)_SOURCE:=binutils-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=ae9a5789e23459e59606e6714723f2d3ffc31c03174191ef0d015bdf06007450
$(PKG)_SITE:=https://ftp.gnu.org/gnu/binutils,https://mirror.dogado.de/gnu/binutils
### WEBSITE:=https://www.gnu.org/software/binutils/
### MANPAGE:=https://sourceware.org/binutils/docs/
### CHANGES:=https://sourceware.org/binutils/docs-2.41/binutils/
### CVSREPO:=https://sourceware.org/git/binutils-gdb.git
### SUPPORT:=Ircama

# Patchelf configuration (reuse patchelf-host source)
# Note: We don't define _PATCHELF_SOURCE/_HASH here to avoid conflicts with patchelf-host
# Instead, we'll reference PATCHELF_HOST variables directly
$(PKG)_PATCHELF_DIR:=$($(PKG)_SOURCE_DIR)/patchelf-$(PATCHELF_HOST_VERSION)

# Define build and target locations for each binary following file.mk pattern
$(PKG)_READELF_BUILD := $($(PKG)_DIR)/binutils/readelf
$(PKG)_READELF_TARGET := $($(PKG)_DEST_DIR)/usr/bin/readelf

$(PKG)_OBJDUMP_BUILD := $($(PKG)_DIR)/binutils/objdump
$(PKG)_OBJDUMP_TARGET := $($(PKG)_DEST_DIR)/usr/bin/objdump

$(PKG)_OBJCOPY_BUILD := $($(PKG)_DIR)/binutils/objcopy
$(PKG)_OBJCOPY_TARGET := $($(PKG)_DEST_DIR)/usr/bin/objcopy

$(PKG)_NM_BUILD := $($(PKG)_DIR)/binutils/nm-new
$(PKG)_NM_TARGET := $($(PKG)_DEST_DIR)/usr/bin/nm

$(PKG)_STRINGS_BUILD := $($(PKG)_DIR)/binutils/strings
$(PKG)_STRINGS_TARGET := $($(PKG)_DEST_DIR)/usr/bin/strings

$(PKG)_AR_BUILD := $($(PKG)_DIR)/binutils/ar
$(PKG)_AR_TARGET := $($(PKG)_DEST_DIR)/usr/bin/ar

$(PKG)_RANLIB_BUILD := $($(PKG)_DIR)/binutils/ranlib
$(PKG)_RANLIB_TARGET := $($(PKG)_DEST_DIR)/usr/bin/ranlib

$(PKG)_STRIP_BUILD := $($(PKG)_DIR)/binutils/strip-new
$(PKG)_STRIP_TARGET := $($(PKG)_DEST_DIR)/usr/bin/strip

$(PKG)_ADDR2LINE_BUILD := $($(PKG)_DIR)/binutils/addr2line
$(PKG)_ADDR2LINE_TARGET := $($(PKG)_DEST_DIR)/usr/bin/addr2line

$(PKG)_SIZE_BUILD := $($(PKG)_DIR)/binutils/size
$(PKG)_SIZE_TARGET := $($(PKG)_DEST_DIR)/usr/bin/size

$(PKG)_PATCHELF_BUILD := $($(PKG)_PATCHELF_DIR)/src/patchelf
$(PKG)_PATCHELF_TARGET := $($(PKG)_DEST_DIR)/usr/bin/patchelf

$(PKG)_CONFIGURE_OPTIONS += --target=$(REAL_GNU_TARGET_NAME)
$(PKG)_CONFIGURE_OPTIONS += --disable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-multilib
$(PKG)_CONFIGURE_OPTIONS += --disable-werror
$(PKG)_CONFIGURE_OPTIONS += --disable-sim
$(PKG)_CONFIGURE_OPTIONS += --disable-gdb
$(PKG)_CONFIGURE_OPTIONS += --without-included-gettext
$(PKG)_CONFIGURE_OPTIONS += --enable-deterministic-archives


# Standard download and unpack for binutils
$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)

# Unpack patchelf from the same tarball used by patchelf-host
# We depend on patchelf-host download, then unpack to our own build directory
$($(PKG)_PATCHELF_DIR)/.unpacked: $(DL_DIR)/$(PATCHELF_HOST_SOURCE) | $($(PKG)_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	@$(call _ECHO,unpacking patchelf for target)
	$(RM) -r $(BINARY_TOOLS_PATCHELF_DIR)
	mkdir -p $(BINARY_TOOLS_PATCHELF_DIR)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(PATCHELF_HOST_SOURCE),$(BINARY_TOOLS_PATCHELF_DIR),1)
	$(call APPLY_PATCHES,$(PATCHELF_HOST_MAKE_DIR)/patches/$(PATCHELF_HOST_CONDITIONAL_PATCHES),$(BINARY_TOOLS_PATCHELF_DIR))
	touch $@

# Custom configuration for binutils (not using PKG_CONFIGURED_CONFIGURE to keep manual control)
$($(PKG)_DIR)/.configured: $($(PKG)_DIR)/.unpacked | $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libc.a
	mkdir -p $(BINARY_TOOLS_DIR)
	(cd $(BINARY_TOOLS_DIR); rm -f config.cache; \
		$(TARGET_CONFIGURE_ENV) \
		$(FREETZ_BASE_DIR)/$(BINARY_TOOLS_DIR)/configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--prefix=/usr \
		$(BINARY_TOOLS_CONFIGURE_OPTIONS) \
	);
	touch $@

# Patchelf separate configuration (cross-compile for MIPS target)
$($(PKG)_PATCHELF_DIR)/.configured: $($(PKG)_PATCHELF_DIR)/.unpacked | $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libc.a
	(cd $(BINARY_TOOLS_PATCHELF_DIR); \
		$(AUTORECONF) \
		rm -f config.cache; \
		$(TARGET_CONFIGURE_ENV) \
		./configure \
		$(TARGET_CONFIGURE_OPTIONS) \
	);
	touch $@

$($(PKG)_READELF_BUILD) $($(PKG)_OBJDUMP_BUILD) $($(PKG)_OBJCOPY_BUILD) $($(PKG)_NM_BUILD) $($(PKG)_STRINGS_BUILD) $($(PKG)_AR_BUILD) $($(PKG)_RANLIB_BUILD) $($(PKG)_STRIP_BUILD) $($(PKG)_ADDR2LINE_BUILD) $($(PKG)_SIZE_BUILD): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(BINARY_TOOLS_DIR)

$($(PKG)_PATCHELF_BUILD): $($(PKG)_PATCHELF_DIR)/.configured
	$(SUBMAKE) -C $(BINARY_TOOLS_PATCHELF_DIR)

$($(PKG)_READELF_TARGET): $($(PKG)_READELF_BUILD)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_OBJDUMP_TARGET): $($(PKG)_OBJDUMP_BUILD)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_OBJCOPY_TARGET): $($(PKG)_OBJCOPY_BUILD)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_NM_TARGET): $($(PKG)_NM_BUILD)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_STRINGS_TARGET): $($(PKG)_STRINGS_BUILD)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_AR_TARGET): $($(PKG)_AR_BUILD)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_RANLIB_TARGET): $($(PKG)_RANLIB_BUILD)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_STRIP_TARGET): $($(PKG)_STRIP_BUILD)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_ADDR2LINE_TARGET): $($(PKG)_ADDR2LINE_BUILD)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_SIZE_TARGET): $($(PKG)_SIZE_BUILD)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_PATCHELF_TARGET): $($(PKG)_PATCHELF_BUILD)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_READELF_TARGET) $($(PKG)_OBJDUMP_TARGET) $($(PKG)_OBJCOPY_TARGET) $($(PKG)_NM_TARGET) $($(PKG)_STRINGS_TARGET) $($(PKG)_AR_TARGET) $($(PKG)_RANLIB_TARGET) $($(PKG)_STRIP_TARGET) $($(PKG)_ADDR2LINE_TARGET) $($(PKG)_SIZE_TARGET) $($(PKG)_PATCHELF_TARGET)

$(pkg)-clean:
	-$(SUBMAKE) -C $(BINARY_TOOLS_DIR) clean
	-$(SUBMAKE) -C $(BINARY_TOOLS_PATCHELF_DIR) clean

$(pkg)-uninstall:
	$(RM) $($(PKG)_READELF_TARGET) $($(PKG)_OBJDUMP_TARGET) $($(PKG)_OBJCOPY_TARGET) $($(PKG)_NM_TARGET) $($(PKG)_STRINGS_TARGET) $($(PKG)_AR_TARGET) $($(PKG)_RANLIB_TARGET) $($(PKG)_STRIP_TARGET) $($(PKG)_ADDR2LINE_TARGET) $($(PKG)_SIZE_TARGET) $($(PKG)_PATCHELF_TARGET)

$(PKG_FINISH)
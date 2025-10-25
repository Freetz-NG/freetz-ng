$(call PKG_INIT_BIN, 2.41)
$(PKG)_SOURCE:=binutils-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=ae9a5789e23459e59606e6714723f2d3ffc31c03174191ef0d015bdf06007450
$(PKG)_SITE:=https://ftp.gnu.org/gnu/binutils,https://mirror.dogado.de/gnu/binutils
### WEBSITE:=https://www.gnu.org/software/binutils/
### MANPAGE:=https://sourceware.org/binutils/docs/
### CHANGES:=https://sourceware.org/binutils/docs-2.41/binutils/
### CVSREPO:=https://sourceware.org/git/binutils-gdb.git
### SUPPORT:=Ircama

# Patchelf configuration - using version 0.18.0 with dynamic libstdc++ linking
BINARY_TOOLS_PATCHELF_VERSION:=0.18.0
BINARY_TOOLS_PATCHELF_SOURCE:=patchelf-$(BINARY_TOOLS_PATCHELF_VERSION).tar.bz2
BINARY_TOOLS_PATCHELF_HASH:=e9dc4d53c2db7a31fd2c0d0e4b0e6b89d2d87e3fb1ba92b001f8f32432bb3444
BINARY_TOOLS_PATCHELF_SITE:=https://github.com/NixOS/patchelf/releases/download/$(BINARY_TOOLS_PATCHELF_VERSION)
BINARY_TOOLS_PATCHELF_DIR:=$(BINARY_TOOLS_SOURCE_DIR)/patchelf-$(BINARY_TOOLS_PATCHELF_VERSION)

# List of all available binutils tools
$(PKG)_BINUTILS_SIMPLE := readelf objdump objcopy strings ar ranlib addr2line size
$(PKG)_BINUTILS_RENAMED := nm strip

# Selected binutils tools based on user configuration  
$(PKG)_BINUTILS_SIMPLE_SELECTED := $(call PKG_SELECTED_SUBOPTIONS,$($(PKG)_BINUTILS_SIMPLE))
$(PKG)_BINUTILS := $($(PKG)_BINUTILS_SIMPLE_SELECTED)
ifneq ($(strip $(FREETZ_PACKAGE_BINARY_TOOLS_NM)),)
$(PKG)_BINUTILS += nm
endif
ifneq ($(strip $(FREETZ_PACKAGE_BINARY_TOOLS_STRIP)),)
$(PKG)_BINUTILS += strip
endif

# Build directory paths for binutils tools
$(PKG)_BINUTILS_SIMPLE_BUILD_DIR := $($(PKG)_BINUTILS_SIMPLE:%=$($(PKG)_DIR)/binutils/%)
$(PKG)_BINUTILS_BUILD_DIR := $($(PKG)_BINUTILS_SIMPLE_BUILD_DIR)
$(PKG)_BINUTILS_BUILD_DIR += $(BINARY_TOOLS_DIR)/binutils/nm-new
$(PKG)_BINUTILS_BUILD_DIR += $(BINARY_TOOLS_DIR)/binutils/strip-new

# Target directory paths for binutils tools
$(PKG)_BINUTILS_TARGET_DIR := $($(PKG)_BINUTILS:%=$($(PKG)_DEST_DIR)/usr/bin/%)

# Patchelf paths
BINARY_TOOLS_PATCHELF_BUILD := $(BINARY_TOOLS_PATCHELF_DIR)/src/patchelf
BINARY_TOOLS_PATCHELF_TARGET := $(BINARY_TOOLS_DEST_DIR)/usr/bin/patchelf

# All target binaries (binutils + patchelf if selected)
$(PKG)_ALL_TARGETS := $($(PKG)_BINUTILS_TARGET_DIR)
ifeq ($(strip $(FREETZ_PACKAGE_BINARY_TOOLS_PATCHELF)),y)
$(PKG)_ALL_TARGETS += $(BINARY_TOOLS_PATCHELF_TARGET)
$(PKG)_EXCLUDED := $(filter-out usr/bin/patchelf,$($(PKG)_EXCLUDED))
else
$(PKG)_EXCLUDED += usr/bin/patchelf
endif

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

# Download and unpack patchelf 0.18.0 (no patches needed with dynamic libstdc++)
$(BINARY_TOOLS_PATCHELF_DIR)/.unpacked: $(DL_DIR)/$(BINARY_TOOLS_PATCHELF_SOURCE) | $(BINARY_TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	@$(call _ECHO,unpacking patchelf $(BINARY_TOOLS_PATCHELF_VERSION) for target)
	$(RM) -r $(BINARY_TOOLS_PATCHELF_DIR)
	mkdir -p $(BINARY_TOOLS_PATCHELF_DIR)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(BINARY_TOOLS_PATCHELF_SOURCE),$(BINARY_TOOLS_PATCHELF_DIR),1)
	touch $@

# Custom configuration for binutils
$(BINARY_TOOLS_DIR)/.configured: $(BINARY_TOOLS_DIR)/.unpacked | $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libc.a
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

# Patchelf configuration (bypass wrapper to use libstdc++ instead of uClibc++)
# Use dynamic linking with libstdc++ from /usr/lib/freetz (RPATH already configured)
$(BINARY_TOOLS_PATCHELF_DIR)/.configured: $(BINARY_TOOLS_PATCHELF_DIR)/.unpacked | $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libc.a
	(cd $(BINARY_TOOLS_PATCHELF_DIR); \
		$(AUTORECONF) \
		rm -f config.cache; \
		$(TARGET_CONFIGURE_ENV) \
		CXX="$(TARGET_CROSS)g++" \
		./configure \
		$(TARGET_CONFIGURE_OPTIONS) \
	);
	touch $@

# Build all binutils tools together
$($(PKG)_BINUTILS_SIMPLE_BUILD_DIR) $(BINARY_TOOLS_DIR)/binutils/nm-new $(BINARY_TOOLS_DIR)/binutils/strip-new: $(BINARY_TOOLS_DIR)/.configured
	$(SUBMAKE) -C $(BINARY_TOOLS_DIR)

# Build patchelf
$(BINARY_TOOLS_PATCHELF_BUILD): $(BINARY_TOOLS_PATCHELF_DIR)/.configured
	$(SUBMAKE) -C $(BINARY_TOOLS_PATCHELF_DIR)

# Install binutils simple tools (no rename needed)
$(foreach binary,$($(PKG)_BINUTILS_SIMPLE_BUILD_DIR),$(eval $(call INSTALL_BINARY_STRIP_RULE,$(binary),/usr/bin)))

# Install binutils tools with renamed outputs
ifeq ($(strip $(FREETZ_PACKAGE_BINARY_TOOLS_NM)),y)
$(BINARY_TOOLS_DEST_DIR)/usr/bin/nm: $(BINARY_TOOLS_DIR)/binutils/nm-new
	$(INSTALL_BINARY_STRIP)
endif

ifeq ($(strip $(FREETZ_PACKAGE_BINARY_TOOLS_STRIP)),y)
$(BINARY_TOOLS_DEST_DIR)/usr/bin/strip: $(BINARY_TOOLS_DIR)/binutils/strip-new
	$(INSTALL_BINARY_STRIP)
endif

# Install patchelf
$(BINARY_TOOLS_PATCHELF_TARGET): $(BINARY_TOOLS_PATCHELF_BUILD)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_ALL_TARGETS)

$(pkg)-clean:
	-$(SUBMAKE) -C $(BINARY_TOOLS_DIR) clean
	-$(SUBMAKE) -C $(BINARY_TOOLS_PATCHELF_DIR) clean

$(pkg)-uninstall:
	$(RM) $($(PKG)_ALL_TARGETS)

$(PKG_FINISH)
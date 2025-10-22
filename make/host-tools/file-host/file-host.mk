$(call TOOLS_INIT, 5.45)
$(PKG)_SOURCE:=$(pkg_short)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=fc97f51029bb0e2c9f4e3bffefdaf678f0e039ee872b9de5c002a6d09c784d82
$(PKG)_SITE:=http://ftp.astron.com/pub/file,ftp://ftp.astron.com/pub/file
### WEBSITE:=https://www.darwinsys.com/file/
### MANPAGE:=https://linux.die.net/man/1/file
### CHANGES:=https://github.com/file/file/releases
### CVSREPO:=https://github.com/file/file
### SUPPORT:=fda77

$(PKG)_BINARY_BUILD:=$($(PKG)_DIR)/src/file
$(PKG)_BINARY_TARGET:=$(TOOLS_BUILD_DIR)/usr/bin/file

$(PKG)_MAGIC_BUILD := $($(PKG)_DIR)/magic/magic.mgc
$(PKG)_MAGIC_TARGET := $(TOOLS_BUILD_DIR)/usr/share/misc/magic.mgc

$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-shared
$(PKG)_CONFIGURE_OPTIONS += --disable-elf
$(PKG)_CONFIGURE_OPTIONS += --disable-elf-core
$(PKG)_CONFIGURE_OPTIONS += --disable-zlib
$(PKG)_CONFIGURE_OPTIONS += --disable-bzlib
$(PKG)_CONFIGURE_OPTIONS += --disable-xzlib
$(PKG)_CONFIGURE_OPTIONS += --disable-zstdlib
$(PKG)_CONFIGURE_OPTIONS += --disable-lzlib
$(PKG)_CONFIGURE_OPTIONS += --disable-libseccomp


ifneq ($($(PKG)_SOURCE),$(FILE_HOST_SOURCE))
$(TOOLS_SOURCE_DOWNLOAD)
endif
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY_BUILD) $($(PKG)_MAGIC_BUILD): $($(PKG)_DIR)/.configured
	$(TOOLS_SUBMAKE) -C $(FILE_HOST_DIR)

$($(PKG)_BINARY_TARGET): $($(PKG)_BINARY_BUILD)
	$(INSTALL_FILE)

$($(PKG)_MAGIC_TARGET): $($(PKG)_MAGIC_BUILD)
	$(INSTALL_FILE)

$($(PKG)_DIR)/.installed: $($(PKG)_BINARY_TARGET) $($(PKG)_MAGIC_TARGET)
	@touch $@

$(pkg)-precompiled: $($(PKG)_DIR)/.installed


$(pkg)-clean:
	-$(MAKE) -C $(FILE_HOST_DIR) clean
	$(RM) $(FILE_HOST_DIR)/.{configured,compiled,installed}

$(pkg)-dirclean:
	$(RM) -r $(FILE_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) $(FILE_HOST_BINARY_TARGET)
	$(RM) $(FILE_HOST_MAGIC_TARGET)

$(TOOLS_FINISH)

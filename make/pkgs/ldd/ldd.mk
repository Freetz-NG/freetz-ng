# Version selection based on Kconfig
$(call PKG_INIT_BIN, $(if $(FREETZ_LDD_VERSION_0_1),0.1,1.0.55))

# Legacy version 0.1 (tarball from MIRROR, with patches)
$(PKG)_SOURCE_0.1:=ldd-0.1.tar.bz2
$(PKG)_HASH_0.1:=b0b2c4edee81ac65c9706f8982b15d3a798be7c2d3865d9a7abff1e493dfadb1
$(PKG)_SITE_0.1:=@MIRROR/

# Modern version 1.0.55 (tarball from MIRROR - TODO: switch to git when available)
$(PKG)_SOURCE_1.0.55:=ldd-1.0.55.tar.bz2
$(PKG)_HASH_1.0.55:=109b02d8f5d07d2836955248979aeee826d993adce5f2e5a3654b67d4dd23952
$(PKG)_SITE_1.0.55:=@MIRROR/
# Future git-based download (when MIRROR has the tarball, we can switch to this):
# $(PKG)_SITE_1.0.55:=git@https://github.com/wbx-github/uclibc-ng.git

# Select version-specific variables
$(PKG)_SOURCE:=$($(PKG)_SOURCE_$($(PKG)_VERSION))
$(PKG)_HASH:=$($(PKG)_HASH_$($(PKG)_VERSION))
$(PKG)_SITE:=$($(PKG)_SITE_$($(PKG)_VERSION))

# Select version-specific patches directory
$(PKG)_CONDITIONAL_PATCHES+=$($(PKG)_VERSION)

### WEBSITE:=https://uclibc-ng.org/
### CHANGES:=https://cgit.uclibc-ng.org/cgi/cgit/uclibc-ng.git/log/utils/ldd.c
### CVSREPO:=https://github.com/wbx-github/uclibc-ng

$(PKG)_SOURCE_FILE:=$($(PKG)_DIR)/ldd.c
$(PKG)_BINARY:=$($(PKG)_DIR)/ldd
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/ldd
$(PKG)_CATEGORY:=Debug helpers


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(TARGET_CONFIGURE_ENV) $(FREETZ_LD_RUN_PATH) \
		$(TARGET_CC) \
		$(TARGET_CFLAGS) \
		-DUCLIBC_RUNTIME_PREFIX=\"/\" \
		$(LDD_SOURCE_FILE) -o $@ \
		$(SILENT)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(LDD_DIR) clean

$(pkg)-uninstall:
	$(RM) $(LDD_TARGET_BINARY)

$(PKG_FINISH)

$(call PKG_INIT_BIN, 1.0.55)
$(PKG)_SOURCE:=ldd-$($(PKG)_VERSION).tar.bz2
$(PKG)_HASH:=109b02d8f5d07d2836955248979aeee826d993adce5f2e5a3654b67d4dd23952
$(PKG)_SITE:=@MIRROR/
### WEBSITE:=https://uclibc-ng.org/
### CHANGES:=https://cgit.uclibc-ng.org/cgi/cgit/uclibc-ng.git/log/utils/ldd.c
### CVSREPO:=https://cgit.uclibc-ng.org/cgi/cgit/uclibc-ng.git

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

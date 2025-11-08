$(call PKG_INIT_BIN, 1.0.8)
$(PKG)_SOURCE:=bzip2-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=ab5a03176ee106d3f0fa90e381da478ddae405918153cca248e682cd0c4a2269
$(PKG)_SITE:=https://sourceware.org/pub/bzip2
### WEBSITE:=https://sourceware.org/bzip2/
### MANPAGE:=https://sourceware.org/bzip2/docs.html
### CHANGES:=https://sourceware.org/bzip2/CHANGES
### CVSREPO:=https://sourceware.org/git/bzip2.git

$(PKG)_DEPENDS_ON += libbz2

$(PKG)_CONDITIONAL_PATCHES+=$(if $(FREETZ_PACKAGE_BZIP2_STATIC),static,shared)

$(PKG)_BINARY:=$($(PKG)_DIR)/$(if $(FREETZ_PACKAGE_BZIP2_STATIC),bzip2,bzip2-shared)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/bzip2-ng

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_BZIP2_STATIC

$(PKG)_MAKE_VARS += CC="$(TARGET_CC)"
$(PKG)_MAKE_VARS += AR="$(TARGET_AR)"
$(PKG)_MAKE_VARS += RANLIB="$(TARGET_RANLIB)"
$(PKG)_MAKE_VARS += CFLAGS="$(TARGET_CFLAGS) -fPIC -D_FILE_OFFSET_BITS=64"
$(PKG)_MAKE_VARS += LDFLAGS="$(TARGET_LDFLAGS)"


ifneq ($(strip $(BZIP2_SOURCE)),$(strip $(LIBBZ2_SOURCE)))
$(PKG_SOURCE_DOWNLOAD)
endif
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
ifeq ($(strip $(FREETZ_PACKAGE_BZIP2_STATIC)),y)
	$(SUBMAKE) -C $(BZIP2_DIR) \
		$(BZIP2_MAKE_VARS) \
		libbz2.a bzip2
else
	$(SUBMAKE) -C $(BZIP2_DIR) \
		$(BZIP2_MAKE_VARS) \
		-f Makefile-libbz2_so
endif

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)
	# Create convenience symlinks
	ln -sf bzip2-ng $(dir $(BZIP2_TARGET_BINARY))bunzip2-ng
	ln -sf bzip2-ng $(dir $(BZIP2_TARGET_BINARY))bzcat-ng

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(BZIP2_DIR) clean

$(pkg)-uninstall:
	$(RM) $(BZIP2_TARGET_BINARY)
	$(RM) $(dir $(BZIP2_TARGET_BINARY))bunzip2-ng
	$(RM) $(dir $(BZIP2_TARGET_BINARY))bzcat-ng

$(PKG_FINISH)


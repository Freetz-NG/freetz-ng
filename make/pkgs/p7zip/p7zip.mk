$(call PKG_INIT_BIN, 16.02)
$(PKG)_SOURCE:=$(pkg)_$($(PKG)_VERSION)_src_all.tar.bz2
$(PKG)_HASH:=5eb20ac0e2944f6cb9c2d51dd6c4518941c185347d4089ea89087ffdd6e2341f
$(PKG)_SITE:=@SF/$(pkg)
### WEBSITE:=https://p7zip.sourceforge.net/
### MANPAGE:=https://sourceforge.net/p/p7zip/discussion/
### CHANGES:=https://sourceforge.net/projects/p7zip/files/p7zip/

$(PKG)_BINARY := $($(PKG)_DIR)/bin/7z
$(PKG)_TARGET_BINARY := $($(PKG)_DEST_DIR)/usr/bin/7z
$(PKG)_LIB := 7z.so
$(PKG)_LIB_DIR := $($(PKG)_LIB:%=$($(PKG)_DIR)/bin/%)
$(PKG)_LIB_TARGET_DIR := $($(PKG)_LIB:%=$($(PKG)_DEST_DIR)/usr/lib/p7zip/%)
$(PKG)_CODECS := Rar.so
$(PKG)_CODECS_DIR := $($(PKG)_CODECS:%=$($(PKG)_DIR)/bin/Codecs/%)
$(PKG)_CODECS_TARGET_DIR := $($(PKG)_CODECS:%=$($(PKG)_DEST_DIR)/usr/lib/p7zip/Codecs/%)


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

# Create missing wrapper symlink for ccache support
$($(PKG)_DIR)/.wrapper-linked: $($(PKG)_DIR)/.configured
	@CCACHE_BIN_DIR="$(REAL_GNU_TARGET_NAME)-ccache"; \
	CCACHE_WRAPPER="$(REAL_GNU_TARGET_NAME)-g++-wrapper"; \
	if command -v "$$CCACHE_BIN_DIR/$(REAL_GNU_TARGET_NAME)-g++" >/dev/null 2>&1 && [ ! -L "$$(dirname $$(command -v $$CCACHE_BIN_DIR/$(REAL_GNU_TARGET_NAME)-g++))/$$CCACHE_WRAPPER" ]; then \
		echo "Creating missing g++-wrapper symlink for ccache..."; \
		ln -sf "$(REAL_GNU_TARGET_NAME)-g++" "$$(dirname $$(command -v $$CCACHE_BIN_DIR/$(REAL_GNU_TARGET_NAME)-g++))/$$CCACHE_WRAPPER"; \
	fi
	@touch $@

$($(PKG)_BINARY) $($(PKG)_LIB_DIR) $($(PKG)_CODECS_DIR): $($(PKG)_DIR)/.wrapper-linked
	$(SUBMAKE) -C $(P7ZIP_DIR) DEST_HOME="$(abspath $($(PKG)_DEST_DIR))" \
	CC="$(TARGET_CC)" \
	CXX="$(TARGET_CXX)" \
	CC_SHARED="$(FPIC) -DPIC" \
	LINK_SHARED="$(FPIC) -DPIC -shared" \
	7z

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_LIB_TARGET_DIR): $($(PKG)_LIB_DIR)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_CODECS_TARGET_DIR): $($(PKG)_CODECS_DIR)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_LIB_TARGET_DIR) $($(PKG)_CODECS_TARGET_DIR) $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(P7ZIP_DIR) -f makefile clean

$(pkg)-uninstall:
	$(RM) $(P7ZIP_TARGET_BINARY) $(P7ZIP_LIB_TARGET_DIR) $(P7ZIP_CODECS_TARGET_DIR)

$(PKG_FINISH)

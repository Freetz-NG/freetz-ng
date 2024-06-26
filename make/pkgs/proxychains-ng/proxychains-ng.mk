$(call PKG_INIT_BIN, 4.17)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=36ddc7f64cb3df2ca4170627c6e0f0dea33d1a6d0730629dff6f5c633f2006f9
$(PKG)_SITE:=https://ftp.barfooze.de/pub/sabotage/tarballs
### WEBSITE:=https://proxychains-ng.sourceforge.net
### MANPAGE:=https://github.com/rofl0r/proxychains-ng#readme
### CHANGES:=https://github.com/rofl0r/proxychains-ng/releases
### CVSREPO:=https://github.com/rofl0r/proxychains-ng
### SUPPORT:=fda77

$(PKG)_BINARY:=$($(PKG)_DIR)/proxychains4
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/proxychains4

$(PKG)_MODULE:=$($(PKG)_DIR)/libproxychains4.so
$(PKG)_TARGET_MODULE := $($(PKG)_DEST_LIBDIR)/libproxychains4.so

$(PKG)_CONFIGURE_OPTIONS += --libdir="$(FREETZ_RPATH)"

$(PKG)_CFLAGS := $(TARGET_CFLAGS)
$(PKG)_CFLAGS += -D_GNU_SOURCE


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY) $($(PKG)_MODULE): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(PROXYCHAINS_NG_DIR) \
		CC=$(TARGET_CC) \
		STRIP="$(TARGET_STRIP)" \
		CFLAGS="$(PROXYCHAINS_NG_CFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_TARGET_MODULE): $($(PKG)_MODULE)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_TARGET_MODULE)


$(pkg)-clean:
	-$(SUBMAKE) -C $(PROXYCHAINS_NG_DIR) clean

$(pkg)-uninstall:
	$(RM) $(PROXYCHAINS_NG_TARGET_BINARY) $(PROXYCHAINS_NG_TARGET_MODULE)

$(PKG_FINISH)


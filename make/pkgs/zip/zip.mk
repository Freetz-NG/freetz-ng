$(call PKG_INIT_BIN, 3.0)
$(PKG)_SOURCE:=zip30.tar.gz
$(PKG)_HASH:=f0e8bb1f9b7eb0b01285495a2699df3a4b766784c1765a8f1aeedf63c0806369
$(PKG)_SITE:=https://downloads.sourceforge.net/infozip
$(PKG)_SOURCE_DIR:=$(SOURCE_DIR)/$(PKG_LANG)
$(PKG)_DIR:=$($(PKG)_SOURCE_DIR)/zip30
### WEBSITE:=https://infozip.sourceforge.net/Zip.html
### MANPAGE:=https://linux.die.net/man/1/zip
### CHANGES:=https://sourceforge.net/projects/infozip/files/Zip%203.x%20%28latest%29/
### CVSREPO:=https://sourceforge.net/projects/infozip/
### SUPPORT:=Ircama

$(PKG)_BINARY_BUILD := $(ZIP_DIR)/zip
$(PKG)_BINARY_TARGET := $($(PKG)_DEST_DIR)/usr/bin/zip

$(PKG)_MAKE_OPTIONS += -f unix/Makefile
$(PKG)_MAKE_OPTIONS += CC="$(TARGET_CC)"
$(PKG)_MAKE_OPTIONS += CPP="$(TARGET_CC) -E"
$(PKG)_MAKE_OPTIONS += CFLAGS="$(TARGET_CFLAGS)"
$(PKG)_MAKE_OPTIONS += generic


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)

# Zip doesn't need configuration, just create a marker file
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

$(call PKG_INIT_BIN, 2.0.2)
$(PKG)_SOURCE_DOWNLOAD_NAME:=v$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=3f5effa9355db140ef8ace6d17800d48815d1afdcef9d1096510451839dd8de4
$(PKG)_SITE:=https://github.com/twekkel/htpdate/archive/refs/tags,https://www.vervest.org/htp/archive/c
### WEBSITE:=https://www.vervest.org/htp/
### MANPAGE:=https://www.vervest.org/htp/?FAQ
### CHANGES:=https://github.com/twekkel/htpdate/releases
### CVSREPO:=https://github.com/twekkel/htpdate
### STEWARD:=fda77

$(PKG)_BINARIES:=$(pkg)
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_EXCLUDED+=$(if $(FREETZ_PACKAGE_HTPDATE_REMOVE_WEBIF),etc/default.htpdate etc/onlinechanged/10-htpdate etc/init.d/rc.htpdate usr/lib/cgi-bin/htpdate.cgi)


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE1) -C $(HTPDATE_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)


$(pkg)-clean:
	-$(SUBMAKE1) -C $(HTPDATE_DIR) clean
	$(RM) $(HTPDATE_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(HTPDATE_BINARIES_TARGET_DIR)

$(PKG_FINISH)

$(call PKG_INIT_BIN, 4.1.0)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION)-stable-src.tar.gz
$(PKG)_HASH:=23e4686e5848c74cb680c09c2811f0357739ecfe641f9c4072ee42399092c97b
$(PKG)_SITE:=@SF/ijbswa
### WEBSITE:=https://www.privoxy.org
### MANPAGE:=https://www.privoxy.org/user-manual/
### CHANGES:=https://www.privoxy.org/gitweb/?p=privoxy.git;a=blob;f=ChangeLog
### CVSREPO:=https://www.privoxy.org/gitweb/?p=privoxy.git
### SUPPORT:=fda77

$(PKG)_BINARY:=$($(PKG)_DIR)/privoxy
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/privoxy

$(PKG)_CONFIGURE_PRE_CMDS += autoheader;
$(PKG)_CONFIGURE_PRE_CMDS += autoconf;

$(PKG)_DEPENDS_ON += $(if $(FREETZ_PACKAGE_PRIVOXY_WITH_PCRE1),pcre,pcre2)
$(PKG)_DEPENDS_ON += $(if $(FREETZ_PACKAGE_PRIVOXY_WITH_ZLIB),zlib)

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PRIVOXY_WITH_PCRE1
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PRIVOXY_WITH_PCRE2
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PRIVOXY_WITH_ZLIB
$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_IPV6_SUPPORT

$(PKG)_CONFIGURE_OPTIONS += --sysconfdir=/mod/etc
$(PKG)_CONFIGURE_OPTIONS += --with-docbook=no
$(PKG)_CONFIGURE_OPTIONS += --disable-stats
$(PKG)_CONFIGURE_OPTIONS += --enable-dynamic-pcre
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_PRIVOXY_WITH_PCRE1),--disable-pcre2,--enable-pcre2)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_PRIVOXY_WITH_ZLIB),--enable-zlib,--disable-zlib)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_TARGET_IPV6_SUPPORT),--enable-ipv6-support,--disable-ipv6-support)
$(PKG)_CONFIGURE_OPTIONS += --without-mbedtls
$(PKG)_CONFIGURE_OPTIONS += --without-openssl
$(PKG)_CONFIGURE_OPTIONS += --without-wolfssl
$(PKG)_CONFIGURE_OPTIONS += --without-brotli


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(PRIVOXY_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)
	mkdir -p $(PRIVOXY_DEST_DIR)/etc/privoxy/templates; \
	for s in $$(find $(PRIVOXY_DIR)/templates/ -type f); do \
		d=$$(basename $$s); \
		egrep -v "^#\ " $$s | egrep -v "^#*$$" >$(PRIVOXY_DEST_DIR)/etc/privoxy/templates/$$d || true; \
	done; \
	for s in \
		$(PRIVOXY_DIR)/default.filter \
		$(PRIVOXY_DIR)/default.action \
		$(PRIVOXY_DIR)/match-all.action \
		$(PRIVOXY_DIR)/user.action \
		$(PRIVOXY_DIR)/user.filter \
	; do \
		d=$$(basename $$s); \
		egrep -v "^#" $$s | egrep -v "^$$" >$(PRIVOXY_DEST_DIR)/etc/privoxy/$$d || true; \
	done

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(PRIVOXY_DIR) clean

$(pkg)-uninstall:
	$(RM) -r $(PRIVOXY_TARGET_BINARY) $(PRIVOXY_DEST_DIR)/etc/privoxy

$(PKG_FINISH)

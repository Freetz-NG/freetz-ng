$(call PKG_INIT_BIN, 2.4.53)
$(PKG)_SOURCE:=httpd-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_SHA256:=d0bbd1121a57b5f2a6ff92d7b96f8050c5a45d3f14db118f64979d525858db63
$(PKG)_SITE:=@APACHE/httpd
### WEBSITE:=https://httpd.apache.org/
### MANPAGE:=https://httpd.apache.org/docs/2.4/
### CHANGES:=https://downloads.apache.org/httpd/CHANGES_2.4
### CVSREPO:=https://github.com/apache/httpd

$(PKG)_BINARY:=$($(PKG)_DIR)/$(pkg)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/$(pkg)

$(PKG)_APXS_SCRIPT:=$($(PKG)_DIR)/support/apxs
$(PKG)_APXS_SCRIPT_STAGING_DIR:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/apxs

$(PKG)_DEPENDS_ON += apr apr-util pcre
ifeq ($(strip $(FREETZ_PACKAGE_APACHE2_DEFLATE)),y)
$(PKG)_DEPENDS_ON += zlib
endif
ifeq ($(strip $(FREETZ_PACKAGE_APACHE2_SSL)),y)
$(PKG)_REBUILD_SUBOPTS += FREETZ_OPENSSL_SHLIB_VERSION
$(PKG)_DEPENDS_ON += openssl
endif
ifeq ($(strip $(FREETZ_PACKAGE_APACHE2_LIBXML)),y)
$(PKG)_DEPENDS_ON += libxml2
endif

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_APACHE2_DEFLATE
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_APACHE2_SSL
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_APACHE2_LIBXML
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_APACHE2_COMPILEINMODS
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_APACHE2_STATIC

$(PKG)_CONFIGURE_ENV += ap_cv_void_ptr_lt_long=no

# TODO: investigate why
#   apr_pollset_create(&event_pollset, 1, plog, APR_POLLSET_THREADSAFE | APR_POLLSET_NOCOPY);
# call fails (s. server/mpm/event/event.c) and provide a better fix than that below (if possible).
#
# Until then provide a hint that MPM=event doesn't work and let the apache configure script
# decide which MPM to use. According to http://httpd.apache.org/docs/2.4/mpm.html#defaults
# this most likely be the MPM=worker.
$(PKG)_CONFIGURE_ENV += ac_cv_have_threadsafe_pollset=no

$(PKG)_CONFIGURE_OPTIONS += --with-apr="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/apr-1-config"
$(PKG)_CONFIGURE_OPTIONS += --with-apr-util="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/apu-1-config"
$(PKG)_CONFIGURE_OPTIONS += --with-pcre="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/pcre-config"
$(PKG)_CONFIGURE_OPTIONS += --with-ssl=$(if $(FREETZ_PACKAGE_APACHE2_SSL),"$(TARGET_TOOLCHAIN_STAGING_DIR)/usr",no)
$(PKG)_CONFIGURE_OPTIONS += --with-z=$(if $(FREETZ_PACKAGE_APACHE2_DEFLATE),"$(TARGET_TOOLCHAIN_STAGING_DIR)/usr",no)

$(PKG)_CONFIGURE_OPTIONS += --with-libxml2=$(if $(FREETZ_PACKAGE_APACHE2_LIBXML),"$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/libxml2",no)

$(PKG)_LIBEXECDIR := /usr/lib/$(pkg)
$(PKG)_CONFIGURE_OPTIONS += --with-program-name=$(pkg)
$(PKG)_CONFIGURE_OPTIONS += --with-suexec-bin=/usr/sbin/suexec2
$(PKG)_CONFIGURE_OPTIONS += --sysconfdir=/etc/$(pkg)
$(PKG)_CONFIGURE_OPTIONS += --includedir=/usr/include/$(pkg)
$(PKG)_CONFIGURE_OPTIONS += --libexecdir=$($(PKG)_LIBEXECDIR)
$(PKG)_CONFIGURE_OPTIONS += --datadir=/usr/share/$(pkg)
$(PKG)_CONFIGURE_OPTIONS += --localstatedir=/var/$(pkg)

$(PKG)_CONFIGURE_OPTIONS += --enable-substitute
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_APACHE2_DEFLATE),--enable-deflate,--disable-deflate)
$(PKG)_CONFIGURE_OPTIONS += --enable-expires
$(PKG)_CONFIGURE_OPTIONS += --enable-headers
$(PKG)_CONFIGURE_OPTIONS += --enable-unique-id
$(PKG)_CONFIGURE_OPTIONS += --enable-proxy
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_APACHE2_SSL),--enable-ssl,--disable-ssl)
$(PKG)_CONFIGURE_OPTIONS += --enable-dav
$(PKG)_CONFIGURE_OPTIONS += --enable-dav-fs
$(PKG)_CONFIGURE_OPTIONS += --enable-suexec
$(PKG)_CONFIGURE_OPTIONS += --enable-rewrite
$(PKG)_CONFIGURE_OPTIONS += --enable-cgi
$(PKG)_CONFIGURE_OPTIONS += --enable-cgid
$(PKG)_CONFIGURE_OPTIONS += --disable-lua
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_APACHE2_LIBXML),--enable-xml2enc --enable-proxy-html,--disable-xml2enc --disable-proxy-html)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_APACHE2_COMPILEINMODS),--enable-mods-static=all --disable-so,--enable-mods-shared=all --enable-so)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(APACHE2_DIR) \
		$(if $(FREETZ_PACKAGE_APACHE2_STATIC),LDFLAGS="-all-static")

$($(PKG)_APXS_SCRIPT): $($(PKG)_DIR)/.configured
	touch $@

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE1) -C $(APACHE2_DIR) install \
		DESTDIR="$(FREETZ_BASE_DIR)/$(APACHE2_DEST_DIR)"
# remove unneeded files
	$(RM) -r \
		$(APACHE2_DEST_DIR)/etc/apache2/original \
		$(APACHE2_DEST_DIR)/usr/{bin,include,sbin/envvars-std,share/man} \
		$(APACHE2_DEST_DIR)/usr/share/apache2/{build,cgi-bin/*,error/README*,icons/README*,icons/*.gif,icons/*/*.gif,manual} \
		$(APACHE2_DEST_DIR)/var
# strip binaries & modules
	-$(TARGET_STRIP) $(APACHE2_DEST_DIR)/usr/sbin/* $(APACHE2_DEST_DIR)/usr/lib/apache2/*.so
# rename suexec to suexec2 manually, apache ignores --with-suexec-bin option
	mv $(APACHE2_DEST_DIR)/usr/sbin/suexec $(APACHE2_DEST_DIR)/usr/sbin/suexec2

$($(PKG)_APXS_SCRIPT_STAGING_DIR): $($(PKG)_APXS_SCRIPT)
	$(SUBMAKE1) -C $(APACHE2_DIR) \
		install-include install-build \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)"
	$(SED) -i -r -e 's,^(includedir[ \t]*=[ \t]*)(.*),\1$(TARGET_TOOLCHAIN_STAGING_DIR)\2,' \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/apache2/build/config_vars.mk
	$(INSTALL_FILE)
	chmod 755 $@
	$(SED) -i -r -e 's,my \$$STAGING_DIR = "";,my \$$STAGING_DIR = "$(TARGET_TOOLCHAIN_STAGING_DIR)";,' $@

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_APXS_SCRIPT_STAGING_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(APACHE2_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/apxs \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/apache2 \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/apache2

$(pkg)-uninstall:
	$(RM) -r $(APACHE2_DEST_DIR)

$(PKG_FINISH)

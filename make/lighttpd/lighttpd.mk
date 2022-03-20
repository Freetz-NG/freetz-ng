$(call PKG_INIT_BIN, 1.4.64)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_SOURCE_SHA256:=e1489d9fa7496fbf2e071c338b593b2300d38c23f1e5967e52c9ef482e1b0e26
$(PKG)_SITE:=https://download.lighttpd.net/lighttpd/releases-1.4.x
### WEBSITE:=https://www.lighttpd.net/
### CHANGES:=https://www.lighttpd.net/download/
### CVSREPO:=https://git.lighttpd.net/lighttpd/lighttpd1.4.git

$(PKG)_BINARY_BUILD_DIR := $($(PKG)_DIR)/src/lighttpd
$(PKG)_BINARY_TARGET_DIR := $($(PKG)_DEST_DIR)/usr/bin/lighttpd

$(PKG)_MODULES_DIR := /usr/lib/lighttpd
$(PKG)_MODULES_ALL := \
	access accesslog ajp13 alias \
	auth authn_dbi authn_file authn_gssapi authn_ldap authn_pam \
	cgi \
	deflate dirlisting \
	evasive evhost expire extforward \
	fastcgi \
	gnutls \
	indexfile \
	magnet maxminddb mbedtls \
	nss \
	openssl \
	proxy \
	redirect rewrite rrdtool \
	scgi secdownload setenv simple_vhost sockproxy ssi staticfile status \
	uploadprogress userdir usertrack \
	vhostdb vhostdb_dbi vhostdb_ldap vhostdb_mysql vhostdb_pgsql \
	webdav wolfssl wstunnel
$(PKG)_MODULES := $(call PKG_SELECTED_SUBOPTIONS,$($(PKG)_MODULES_ALL),MOD)
$(PKG)_MODULES_BUILD_DIR := $($(PKG)_MODULES:%=$($(PKG)_DIR)/src/.libs/mod_%.so)
$(PKG)_MODULES_TARGET_DIR := $($(PKG)_MODULES:%=$($(PKG)_DEST_DIR)$($(PKG)_MODULES_DIR)/mod_%.so)

$(PKG)_EXCLUDED += $(patsubst %,$($(PKG)_DEST_DIR)$($(PKG)_MODULES_DIR)/mod_%.so,$(filter-out $($(PKG)_MODULES),$($(PKG)_MODULES_ALL)))

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_LIGHTTPD_MOD_OPENSSL
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_LIGHTTPD_MOD_MBEDTLS
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_LIGHTTPD_MOD_GNUTLS
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_LIGHTTPD_WITH_LUA
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_LIGHTTPD_MOD_MAXMINDDB
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_LIGHTTPD_MOD_DEFLATE
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_LIGHTTPD_MOD_WEBDAV_WITH_PROPS
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_LIGHTTPD_MOD_WEBDAV_WITH_LOCKS
$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_IPV6_SUPPORT

$(PKG)_DEPENDS_ON += pcre

ifeq ($(strip $(FREETZ_PACKAGE_LIGHTTPD_MOD_OPENSSL)),y)
$(PKG)_REBUILD_SUBOPTS += FREETZ_OPENSSL_SHLIB_VERSION
$(PKG)_DEPENDS_ON += openssl
$(PKG)_CONFIGURE_OPTIONS += --with-openssl
$(PKG)_CONFIGURE_OPTIONS += --with-openssl-libs="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib"
$(PKG)_CONFIGURE_OPTIONS += --with-openssl-includes="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include"
endif

ifeq ($(strip $(FREETZ_PACKAGE_LIGHTTPD_MOD_MBEDTLS)),y)
$(PKG)_DEPENDS_ON += mbedtls
$(PKG)_CONFIGURE_OPTIONS += --with-mbedtls
endif

ifeq ($(strip $(FREETZ_PACKAGE_LIGHTTPD_MOD_GNUTLS)),y)
$(PKG)_DEPENDS_ON += gnutls
$(PKG)_CONFIGURE_OPTIONS += --with-gnutls
endif

ifeq ($(strip $(FREETZ_PACKAGE_LIGHTTPD_MOD_DEFLATE)),y)
$(PKG)_DEPENDS_ON += zlib
$(PKG)_CONFIGURE_OPTIONS += --with-zlib
else
$(PKG)_CONFIGURE_OPTIONS += --without-zlib
endif

ifeq ($(strip $(FREETZ_PACKAGE_LIGHTTPD_MOD_MAXMINDDB)),y)
$(PKG)_DEPENDS_ON += libmaxminddb
$(PKG)_CONFIGURE_OPTIONS += --with-maxminddb
else
$(PKG)_CONFIGURE_OPTIONS += --without-maxminddb
endif

ifeq ($(strip $(FREETZ_PACKAGE_LIGHTTPD_WITH_LUA)),y)
$(PKG)_DEPENDS_ON += lua
$(PKG)_CONFIGURE_OPTIONS += --with-lua
else
$(PKG)_CONFIGURE_OPTIONS += --without-lua
endif

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_ENV += PCRE_LIB="-lpcre"

$(PKG)_CONFIGURE_OPTIONS += --libdir=$($(PKG)_MODULES_DIR)
$(PKG)_CONFIGURE_OPTIONS += --sysconfdir=/etc/lighttpd
$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_TARGET_IPV6_SUPPORT),,--disable-ipv6)
$(PKG)_CONFIGURE_OPTIONS += --without-attr
$(PKG)_CONFIGURE_OPTIONS += --without-brotli
$(PKG)_CONFIGURE_OPTIONS += --without-bzip2
$(PKG)_CONFIGURE_OPTIONS += --without-fam
$(PKG)_CONFIGURE_OPTIONS += --without-gdbm
$(PKG)_CONFIGURE_OPTIONS += --without-krb5
$(PKG)_CONFIGURE_OPTIONS += --without-ldap
$(PKG)_CONFIGURE_OPTIONS += --without-libev
$(PKG)_CONFIGURE_OPTIONS += --without-memcached
$(PKG)_CONFIGURE_OPTIONS += --with-pcre
$(PKG)_CONFIGURE_OPTIONS += --without-pcre2
$(PKG)_CONFIGURE_OPTIONS += --without-valgrind
$(PKG)_CONFIGURE_OPTIONS += --without-mysql

ifeq ($(strip $(FREETZ_PACKAGE_LIGHTTPD_MOD_WEBDAV_WITH_PROPS)),y)
$(PKG)_DEPENDS_ON += libxml2 sqlite
$(PKG)_CONFIGURE_OPTIONS += --with-webdav-props
else
$(PKG)_CONFIGURE_OPTIONS += --without-webdav-props
endif

ifeq ($(strip $(FREETZ_PACKAGE_LIGHTTPD_MOD_WEBDAV_WITH_LOCKS)),y)
$(PKG)_DEPENDS_ON += e2fsprogs # we need libuuid from it
$(PKG)_CONFIGURE_ENV += ac_cv_header_uuid_uuid_h=yes
$(PKG)_CONFIGURE_OPTIONS += --with-webdav-locks
else
$(PKG)_CONFIGURE_OPTIONS += --without-webdav-locks
endif

ifneq ($(strip $(FREETZ_TARGET_UCLIBC_SUPPORTS_inotify)),y)
$(PKG)_CONFIGURE_ENV += ac_cv_header_sys_inotify_h=no
endif

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY_BUILD_DIR) $($(PKG)_MODULES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LIGHTTPD_DIR)

$($(PKG)_BINARY_TARGET_DIR): $($(PKG)_BINARY_BUILD_DIR)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_MODULES_TARGET_DIR): $($(PKG)_DEST_DIR)$($(PKG)_MODULES_DIR)/%: $($(PKG)_DIR)/src/.libs/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARY_TARGET_DIR) $($(PKG)_MODULES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(LIGHTTPD_DIR) clean
	$(RM) $(LIGHTTPD_DIR)/.configured

$(pkg)-uninstall:
	$(RM) -r $(LIGHTTPD_BINARY_TARGET_DIR) $(LIGHTTPD_DEST_DIR)$(LIGHTTPD_MODULES_DIR)

$(PKG_FINISH)

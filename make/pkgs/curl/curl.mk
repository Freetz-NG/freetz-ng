$(call PKG_INIT_BIN, 8.15.0)
$(PKG)_LIB_VERSION:=4.8.0
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=6cd0a8a5b126ddfda61c94dc2c3fc53481ba7a35461cf7c5ab66aa9d6775b609
$(PKG)_SITE:=https://curl.se/download,https://curl.haxx.se/download
### WEBSITE:=https://curl.se/
### MANPAGE:=https://curl.se/docs/manpage.html
### CHANGES:=https://curl.se/changes.html
### CVSREPO:=https://github.com/curl/curl
### SUPPORT:=fda77

$(PKG)_BINARY:=$($(PKG)_DIR)/src/.libs/curl
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/curl
$(PKG)_LIB_BINARY:=$($(PKG)_DIR)/lib/.libs/libcurl.so.$($(PKG)_LIB_VERSION)
$(PKG)_LIB_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libcurl.so.$($(PKG)_LIB_VERSION)
$(PKG)_LIB_TARGET_BINARY:=$($(PKG)_TARGET_LIBDIR)/libcurl.so.$($(PKG)_LIB_VERSION)

ifeq ($(strip $(FREETZ_LIB_libcurl_WITH_OPENSSL)),y)
$(PKG)_REBUILD_SUBOPTS += FREETZ_OPENSSL_SHORT_VERSION
$(PKG)_DEPENDS_ON += openssl
endif
ifeq ($(strip $(FREETZ_LIB_libcurl_WITH_MBEDTLS)),y)
$(PKG)_DEPENDS_ON += mbedtls
endif
ifeq ($(strip $(FREETZ_LIB_libcurl_WITH_SFTP)),y)
$(PKG)_DEPENDS_ON += libssh2
endif
ifeq ($(strip $(FREETZ_LIB_libcurl_WITH_ZLIB)),y)
$(PKG)_DEPENDS_ON += zlib
endif

$(PKG)_REBUILD_SUBOPTS += FREETZ_LIB_libcurl_WITH_SSL
$(PKG)_REBUILD_SUBOPTS += FREETZ_LIB_libcurl_WITH_OPENSSL
$(PKG)_REBUILD_SUBOPTS += FREETZ_LIB_libcurl_WITH_MBEDTLS
$(PKG)_REBUILD_SUBOPTS += FREETZ_LIB_libcurl_WITH_SFTP
$(PKG)_REBUILD_SUBOPTS += FREETZ_LIB_libcurl_WITH_ZLIB
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_CURL_STATIC
$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_IPV6_SUPPORT

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_ENV += curl_cv_writable_argv=yes

$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_TARGET_IPV6_SUPPORT),--enable-ipv6,--disable-ipv6)
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += --with-gnu-ld

$(PKG)_CONFIGURE_OPTIONS += --disable-ares
$(PKG)_CONFIGURE_OPTIONS += --disable-thread
$(PKG)_CONFIGURE_OPTIONS += --enable-nonblocking

$(PKG)_CONFIGURE_OPTIONS += --disable-debug
$(PKG)_CONFIGURE_OPTIONS += --disable-manual
$(PKG)_CONFIGURE_OPTIONS += --disable-verbose
$(PKG)_CONFIGURE_OPTIONS += --disable-docs

$(PKG)_CONFIGURE_OPTIONS += --enable-cookies
$(PKG)_CONFIGURE_OPTIONS += --enable-crypto-auth
$(PKG)_CONFIGURE_OPTIONS += --enable-file
$(PKG)_CONFIGURE_OPTIONS += --enable-ftp
$(PKG)_CONFIGURE_OPTIONS += --enable-http
$(PKG)_CONFIGURE_OPTIONS += --enable-proxy
$(PKG)_CONFIGURE_OPTIONS += --enable-rtsp
$(PKG)_CONFIGURE_OPTIONS += --enable-unix-sockets

$(PKG)_CONFIGURE_OPTIONS += --disable-dict
$(PKG)_CONFIGURE_OPTIONS += --disable-gopher
$(PKG)_CONFIGURE_OPTIONS += --disable-imap
$(PKG)_CONFIGURE_OPTIONS += --disable-ldap
$(PKG)_CONFIGURE_OPTIONS += --disable-ldaps
$(PKG)_CONFIGURE_OPTIONS += --disable-pop3
$(PKG)_CONFIGURE_OPTIONS += --disable-smb
$(PKG)_CONFIGURE_OPTIONS += --disable-smtp
$(PKG)_CONFIGURE_OPTIONS += --disable-sspi
$(PKG)_CONFIGURE_OPTIONS += --disable-telnet
$(PKG)_CONFIGURE_OPTIONS += --disable-tftp
$(PKG)_CONFIGURE_OPTIONS += --disable-tls-srp

$(PKG)_CONFIGURE_OPTIONS += --with-random="/dev/urandom"
$(PKG)_CONFIGURE_OPTIONS += --without-cyassl
$(PKG)_CONFIGURE_OPTIONS += --without-gnutls
$(PKG)_CONFIGURE_OPTIONS += --without-polarssl
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_LIB_libcurl_WITH_OPENSSL),--with-openssl="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr",--without-openssl)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_LIB_libcurl_WITH_MBEDTLS),--with-mbedtls="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr",--without-mbedtls)
$(PKG)_CONFIGURE_OPTIONS += $(if $(or $(FREETZ_LIB_libcurl_WITH_OPENSSL),$(FREETZ_LIB_libcurl_WITH_MBEDTLS)),,--without-ssl)
$(PKG)_CONFIGURE_OPTIONS += --without-ca-bundle
$(PKG)_CONFIGURE_OPTIONS += --without-gssapi
$(PKG)_CONFIGURE_OPTIONS += --without-libpsl
$(PKG)_CONFIGURE_OPTIONS += --without-libgsasl
$(PKG)_CONFIGURE_OPTIONS += --without-libidn2
$(PKG)_CONFIGURE_OPTIONS += --without-librtmp
$(PKG)_CONFIGURE_OPTIONS += --without-nghttp2
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_LIB_libcurl_WITH_SFTP),--with-libssh2="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr",--without-libssh2)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_LIB_libcurl_WITH_ZLIB),--with-zlib="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr",--without-zlib)


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY) $($(PKG)_LIB_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(CURL_DIR) \
		$(if $(FREETZ_PACKAGE_CURL_STATIC),STATIC_LDFLAGS=-all-static)

$($(PKG)_LIB_STAGING_BINARY): $($(PKG)_LIB_BINARY)
	$(SUBMAKE) -C $(CURL_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libcurl.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libcurl.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/curl-config

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_LIB_TARGET_BINARY): $($(PKG)_LIB_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_LIB_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(CURL_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libcurl* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/pkgconfig/libcurl.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/curl \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/curl*

$(pkg)-uninstall:
	$(RM) $(CURL_TARGET_BINARY) $(CURL_TARGET_LIBDIR)/libcurl*.so*

$(call PKG_ADD_LIB,libcurl)
$(PKG_FINISH)

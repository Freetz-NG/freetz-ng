$(call PKG_INIT_BIN, 8.3.25)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH_5.6.40:=1369a51eee3995d7fbd1c5342e5cc917760e276d561595b6052b21ace2656d1c
$(PKG)_HASH_8.1.33:=9db83bf4590375562bc1a10b353cccbcf9fcfc56c58b7c8fb814e6865bb928d1
$(PKG)_HASH_8.3.25:=187b61bb795015adacf53f8c55b44414a63777ec19a776b75fb88614506c0d37
$(PKG)_HASH:=$($(PKG)_HASH_$($(PKG)_VERSION))
$(PKG)_SITE:=https://de.php.net/distributions,http://de2.php.net/distributions

$(PKG)_CATEGORY:=Unstable

$(PKG)_CONDITIONAL_PATCHES+=$(call GET_MAJOR_VERSION,$($(PKG)_VERSION))

$(PKG)_VERSION_MAJOR := $(call GET_STRING_COMPONENT,$(PHP_VERSION),.,1)

$(PKG)_BINARY              := $($(PKG)_DIR)/sapi/cgi/php-cgi
$(PKG)_TARGET_BINARY       := $($(PKG)_DEST_DIR)/usr/bin/php-cgi

$(PKG)_CLI_BINARY          := $($(PKG)_DIR)/sapi/cli/php
$(PKG)_CLI_TARGET_BINARY   := $($(PKG)_DEST_DIR)/usr/bin/php

$(PKG)_APXS2_BINARY        := $($(PKG)_DIR)/libs/libphp$(if $(FREETZ_PHP_VERSION_5_6),$($(PKG)_VERSION_MAJOR),).so
$(PKG)_APXS2_TARGET_BINARY := $($(PKG)_DEST_DIR)/usr/lib/apache2/libphp$(if $(FREETZ_PHP_VERSION_5_6),$($(PKG)_VERSION_MAJOR),).so

$(PKG)_STARTLEVEL=90 # before lighttpd

$(PKG)_EXTRA_CFLAGS  := -ffunction-sections -fdata-sections
$(PKG)_EXTRA_LDFLAGS := -Wl,--gc-sections
ifeq ($(strip $(FREETZ_PACKAGE_PHP_STATIC)),y)
$(PKG)_EXTRA_LDFLAGS += -all-static
endif

$(PKG)_DEPENDS_ON += pcre

$(PKG)_CONFIGURE_OPTIONS += --enable-cli
$(PKG)_EXCLUDED += $(if $(FREETZ_PACKAGE_PHP_cli),,$($(PKG)_CLI_TARGET_BINARY))

ifeq ($(strip $(FREETZ_PACKAGE_PHP_apxs2)),y)
$(PKG)_DEPENDS_ON += apache2
$(PKG)_CONFIGURE_OPTIONS += --with-apxs2="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/apxs"
endif

ifeq ($(strip $(FREETZ_PACKAGE_PHP_WITH_CURL)),y)
$(PKG)_REBUILD_SUBOPTS += $(filter FREETZ_LIB_libcurl_%,$(CURL_REBUILD_SUBOPTS))
$(PKG)_DEPENDS_ON += curl
$(PKG)_CONFIGURE_OPTIONS += --with-curl="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
endif

$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_PHP_WITH_FILEINFO),--enable-fileinfo,--disable-fileinfo)

$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_PHP_WITH_FTP),--enable-ftp,--disable-ftp)

ifeq ($(strip $(FREETZ_PACKAGE_PHP_WITH_GD)),y)
$(PKG)_DEPENDS_ON += libgd
$(PKG)_CONFIGURE_OPTIONS += --with-gd="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --enable-gd-native-ttf
endif

ifeq ($(strip $(FREETZ_PACKAGE_PHP_WITH_GETTEXT)),y)
$(PKG)_DEPENDS_ON += gettext
$(PKG)_CONFIGURE_OPTIONS += --with-gettext="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
endif

ifeq ($(strip $(FREETZ_PACKAGE_PHP_WITH_ICONV)),y)
$(PKG)_CONFIGURE_OPTIONS += --with-iconv

$(PKG)_CONFIGURE_ENV += ac_cv_func_iconv=$(if $(FREETZ_PACKAGE_PHP_WITH_LIBICONV),no,yes)
$(PKG)_CONFIGURE_ENV += ac_cv_func_libiconv=$(if $(FREETZ_PACKAGE_PHP_WITH_LIBICONV),yes,no)

ifeq ($(strip $(FREETZ_PACKAGE_PHP_WITH_LIBICONV)),y)
$(PKG)_DEPENDS_ON += iconv
$(PKG)_CONFIGURE_ENV += iconv_impl_name=gnu_libiconv
$(PKG)_CONFIGURE_OPTIONS += --with-iconv-dir="$(TARGET_TOOLCHAIN_STAGING_DIR)$(LIBICONV_PREFIX)"
$(PKG)_EXTRA_LDFLAGS += -L$(TARGET_TOOLCHAIN_STAGING_DIR)$(LIBICONV_PREFIX)/lib
else
$(PKG)_CONFIGURE_ENV += ICONV_IN_LIBC_DIR="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --with-iconv-dir="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
endif

else
$(PKG)_CONFIGURE_OPTIONS += --without-iconv
endif


ifeq ($(strip $(FREETZ_PACKAGE_PHP_WITH_LIBXML)),y)
$(PKG)_DEPENDS_ON += libxml2
$(PKG)_CONFIGURE_ENV += PKG_CONFIG_PATH="$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/pkgconfig"
endif
$(PKG)_XML_SUPPORT:=$(if $(FREETZ_PACKAGE_PHP_WITH_LIBXML),enable,disable)
$(PKG)_CONFIGURE_OPTIONS += --$($(PKG)_XML_SUPPORT)-xml
$(PKG)_CONFIGURE_OPTIONS += --$($(PKG)_XML_SUPPORT)-dom
$(PKG)_CONFIGURE_OPTIONS += --$($(PKG)_XML_SUPPORT)-simplexml
$(PKG)_CONFIGURE_OPTIONS += --$($(PKG)_XML_SUPPORT)-xmlreader
$(PKG)_CONFIGURE_OPTIONS += --$($(PKG)_XML_SUPPORT)-xmlwriter

$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_PHP_WITH_MHASH),--with-mhash,--without-mhash)

$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_PHP_WITH_PCNTL),--enable-pcntl,--disable-pcntl)

$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_PHP_WITH_SESSION),--enable-session,--disable-session)

$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_PHP_WITH_SOCKETS),--enable-sockets,--disable-sockets)

ifeq ($(strip $(FREETZ_PACKAGE_PHP_WITH_SQLITE3)),y)
$(PKG)_DEPENDS_ON += sqlite
$(PKG)_CONFIGURE_OPTIONS += --with-sqlite3="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --with-pdo-sqlite="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
else
$(PKG)_CONFIGURE_OPTIONS += --without-sqlite3
$(PKG)_CONFIGURE_OPTIONS += --without-pdo-sqlite
endif

ifeq ($(strip $(FREETZ_PACKAGE_PHP_WITH_SSL)),y)
$(PKG)_REBUILD_SUBOPTS += FREETZ_OPENSSL_SHORT_VERSION
$(PKG)_REBUILD_SUBOPTS += FREETZ_LIB_libcrypto_WITH_RC4
$(PKG)_DEPENDS_ON += openssl
$(PKG)_CONFIGURE_OPTIONS += --with-openssl="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
ifeq ($(strip $(FREETZ_PACKAGE_PHP_STATIC)),y)
$(PKG)_LIBS += $(OPENSSL_LIBCRYPTO_EXTRA_LIBS)
endif
endif

$(PKG)_SYSVIPC_SUPPORT:=$(if $(FREETZ_PACKAGE_PHP_WITH_SYSVIPC),enable,disable)
$(PKG)_CONFIGURE_OPTIONS += --$($(PKG)_SYSVIPC_SUPPORT)-sysvsem
$(PKG)_CONFIGURE_OPTIONS += --$($(PKG)_SYSVIPC_SUPPORT)-sysvshm
$(PKG)_CONFIGURE_OPTIONS += --$($(PKG)_SYSVIPC_SUPPORT)-sysvmsg

ifeq ($(strip $(FREETZ_PACKAGE_PHP_WITH_ZLIB)),y)
$(PKG)_DEPENDS_ON += zlib
$(PKG)_CONFIGURE_OPTIONS += --with-zlib
$(PKG)_CONFIGURE_OPTIONS += --with-zlib-dir="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
endif

ifeq ($(strip $(FREETZ_PACKAGE_PHP_WITH_ZIP)),y)
$(PKG)_CONFIGURE_OPTIONS += --enable-zip
endif

$(PKG)_REBUILD_SUBOPTS += FREETZ_PHP_VERSION_5_6
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP_STATIC
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP_apxs2
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP_WITH_CURL
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP_WITH_FILEINFO
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP_WITH_FTP
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP_WITH_GD
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP_WITH_GETTEXT
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP_WITH_ICONV FREETZ_PACKAGE_PHP_WITH_LIBICONV
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP_WITH_JSON
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP_WITH_LIBXML FREETZ_LIB_libxml2_WITH_HTML
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP_WITH_MEMORY_LIMIT
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP_WITH_MHASH
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP_WITH_PCNTL
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP_WITH_SESSION
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP_WITH_SOCKETS
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP_WITH_SQLITE3
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP_WITH_SYSVIPC
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP_WITH_SSL
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP_WITH_ZLIB
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP_WITH_ZIP
$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_IPV6_SUPPORT

$(PKG)_CONFIGURE_ENV += php_cv_sizeof_ssize_t=4
$(PKG)_CONFIGURE_ENV += php_cv_sizeof_ptrdiff_t=4
$(PKG)_CONFIGURE_ENV += ac_cv_c_bigendian_php=$(if $(FREETZ_TARGET_ARCH_BE),yes,no)
$(PKG)_CONFIGURE_ENV += php_cv_sizeof_intmax_t=8
$(PKG)_CONFIGURE_ENV += ac_cv_func_fnmatch_works=no
$(PKG)_CONFIGURE_ENV += ac_cv_func_getaddrinfo=yes
$(PKG)_CONFIGURE_ENV += ac_cv_func_sigsetjmp=yes
$(PKG)_CONFIGURE_ENV += ac_cv_c_stack_direction=-1
$(PKG)_CONFIGURE_ENV += ac_cv_ebcdic=no
$(PKG)_CONFIGURE_ENV += ac_cv_header_atomic_h=no
$(PKG)_CONFIGURE_ENV += ac_cv_header_stdc=yes
$(PKG)_CONFIGURE_ENV += ac_cv_func_memcmp_clean=no
$(PKG)_CONFIGURE_ENV += ac_cv_func_utime_null=no
$(PKG)_CONFIGURE_ENV += ac_cv_time_r_type=POSIX
$(PKG)_CONFIGURE_ENV += ac_cv_what_readdir_r=POSIX
$(PKG)_CONFIGURE_ENV += ac_cv_write_stdout=yes
$(PKG)_CONFIGURE_ENV += ac_cv_lib_gd_gdImageCreateFromXpm=no
$(PKG)_CONFIGURE_ENV += ac_cv_lib_png_png_write_image=yes
$(PKG)_CONFIGURE_ENV += cookie_io_functions_use_off64_t=yes
$(PKG)_CONFIGURE_ENV += lt_cv_prog_gnu_ldcxx=yes
$(PKG)_CONFIGURE_ENV += lt_cv_path_NM="$(TARGET_NM) -B"

# prevent pdo_cv_inc_path from being cached in config.cache by renaming it to something that doesn't contain _cv_
# caching the value breaks a version bump as it points to a directory containing the php version number in it
$(PKG)_CONFIGURE_PRE_CMDS += $(SED) -i -r -e 's,pdo_cv_inc_path,php_pdo_inc_path,g' ./configure;

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)
ifneq ($(strip $(FREETZ_TARGET_IPV6_SUPPORT)),y)
$(PKG)_CONFIGURE_OPTIONS += --disable-ipv6
endif
$(PKG)_CONFIGURE_OPTIONS += --enable-exif
$(PKG)_CONFIGURE_OPTIONS += --enable-mbstring
$(PKG)_CONFIGURE_OPTIONS += --disable-phar
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += --with-config-file-path=/tmp/flash
$(PKG)_CONFIGURE_OPTIONS += --with-config-file-scan-dir=/tmp/flash/php
$(PKG)_CONFIGURE_OPTIONS += --without-pear

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY) $($(PKG)_CLI_BINARY) $($(PKG)_APXS2_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(PHP_DIR) \
		EXTRA_CFLAGS="$(PHP_EXTRA_CFLAGS)" \
		EXTRA_LDFLAGS_PROGRAM="$(PHP_EXTRA_LDFLAGS)" \
		ZEND_EXTRA_LIBS="$(PHP_LIBS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_CLI_TARGET_BINARY): $($(PKG)_CLI_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_APXS2_TARGET_BINARY): $($(PKG)_APXS2_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_CLI_TARGET_BINARY) $(if $(FREETZ_PACKAGE_PHP_apxs2),$($(PKG)_APXS2_TARGET_BINARY))

$(pkg)-clean:
	-$(SUBMAKE) -C $(PHP_DIR) clean
	$(RM) $(PHP_FREETZ_CONFIG_FILE)

$(pkg)-uninstall:
	$(RM) $(PHP_TARGET_BINARY) $(PHP_CLI_TARGET_BINARY) $(PHP_APXS2_TARGET_BINARY)

$(PKG_FINISH)

$(call PKG_INIT_BIN, $(if $(FREETZ_PACKAGE_PHP_VERSION_56),5.6.40,$(if $(FREETZ_PACKAGE_PHP_VERSION_82),8.2.32,$(if $(FREETZ_PACKAGE_PHP_VERSION_83),8.3.32,$(if $(FREETZ_PACKAGE_PHP_VERSION_84),8.4.23,8.5.8)))))
$(PKG)_LIB_VERSION:=$(call GET_MAJOR_VERSION,$($(PKG)_VERSION),1)
$(PKG)_SOURCE:=php-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH_5.6:=1369a51eee3995d7fbd1c5342e5cc917760e276d561595b6052b21ace2656d1c
$(PKG)_HASH_8.2:=e02aa173c236c12791696254d607da680e6d5516f8f5c2339642de7c4f944bd2
$(PKG)_HASH_8.3:=8698ec1f9402fa5e5e872ae3d0916b62f5f27503c1fbfc9cc3521e113355ea92
$(PKG)_HASH_8.4:=1ab9f52008414e43bb2427ffa288eff2a4de39e1a830f957e800ba368d887a72
$(PKG)_HASH_8.5:=58910198d19e873048fe87cdfe16bc790025417ede3d1651bfa1c4b533d573f2
$(PKG)_HASH:=$($(PKG)_HASH_$(call GET_MAJOR_VERSION,$($(PKG)_VERSION)))
$(PKG)_SITE:=https://www.php.net/distributions,https://de.php.net/distributions,https://de2.php.net/distributions
### WEBSITE:=https://www.php.net
### MANPAGE:=https://www.php.net/docs.php
### CHANGES:=https://github.com/php/php-src/releases
### CVSREPO:=https://github.com/php/php-src

$(PKG)_BINARY              := $($(PKG)_DIR)/sapi/cgi/php-cgi
$(PKG)_TARGET_BINARY       := $($(PKG)_DEST_DIR)/usr/bin/php-cgi

$(PKG)_CLI_BINARY          := $($(PKG)_DIR)/sapi/cli/php
$(PKG)_CLI_TARGET_BINARY   := $($(PKG)_DEST_DIR)/usr/bin/php

$(PKG)_APXS2_BINARY        := $($(PKG)_DIR)/libs/libphp$($(PKG)_LIB_VERSION).so
$(PKG)_APXS2_TARGET_BINARY := $($(PKG)_DEST_DIR)/usr/lib/apache2/libphp$($(PKG)_LIB_VERSION).so

$(PKG)_STARTLEVEL=90 # before lighttpd

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP_VERSION_56
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP_VERSION_82
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP_VERSION_83
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP_VERSION_84
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP_VERSION_85

$(PKG)_CONDITIONAL_PATCHES+=$(call GET_MAJOR_VERSION,$($(PKG)_VERSION))

$(PKG)_EXTRA_CFLAGS  := -ffunction-sections -fdata-sections
$(PKG)_EXTRA_LDFLAGS := -Wl,--gc-sections
ifeq ($(strip $(FREETZ_PACKAGE_PHP_STATIC)),y)
$(PKG)_EXTRA_LDFLAGS += -all-static
endif

$(PKG)_DEPENDS_ON += pcre
$(PKG)_CONFIGURE_OPTIONS += --with-pcre-regex="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"

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

$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_PHP_WITH_JSON),--enable-json,--disable-json)

ifeq ($(strip $(FREETZ_PACKAGE_PHP_WITH_LIBONIG)),y)
$(PKG)_DEPENDS_ON += libonig
$(PKG)_CONFIGURE_OPTIONS += --with-onig="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
endif

ifeq ($(strip $(FREETZ_PACKAGE_PHP_WITH_LIBXML)),y)
$(PKG)_DEPENDS_ON += libxml2
$(PKG)_CONFIGURE_OPTIONS += --with-libxml-dir="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
endif
$(PKG)_CONFIGURE_OPTIONS += --without-libexpat-dir #we only want libxml-based XML support to be enabled
$(PKG)_XML_SUPPORT:=$(if $(FREETZ_PACKAGE_PHP_WITH_LIBXML),enable,disable)
$(PKG)_CONFIGURE_OPTIONS += --$($(PKG)_XML_SUPPORT)-xml
$(PKG)_CONFIGURE_OPTIONS += --$($(PKG)_XML_SUPPORT)-libxml
$(PKG)_CONFIGURE_OPTIONS += --$($(PKG)_XML_SUPPORT)-dom
$(PKG)_CONFIGURE_OPTIONS += --$($(PKG)_XML_SUPPORT)-simplexml
$(PKG)_CONFIGURE_OPTIONS += --$($(PKG)_XML_SUPPORT)-xmlreader
$(PKG)_CONFIGURE_OPTIONS += --$($(PKG)_XML_SUPPORT)-xmlwriter

$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_PHP_WITH_MHASH),--with-mhash,--without-mhash)

$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_PHP_WITH_MEMORY_LIMIT),--enable-memory-limit,--disable-memory-limit)

$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_PHP_WITH_PCNTL),--enable-pcntl,--disable-pcntl)

$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_PHP_WITH_SESSION),--enable-session,--disable-session)

$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_PHP_WITH_SOCKETS),--enable-sockets,--disable-sockets)

$(PKG)_CONFIGURE_OPTIONS += --without-sqlite

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

ifeq ($(strip $(FREETZ_PACKAGE_PHP_WITH_FFI)),y)
$(PKG)_DEPENDS_ON += libffi
$(PKG)_CONFIGURE_OPTIONS += --with-ffi
$(PKG)_CONFIGURE_OPTIONS += --with-ffi-dir="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
endif

ifeq ($(strip $(FREETZ_PACKAGE_PHP_WITH_MYSQLND_MYSQLI)),y)
$(PKG)_CONFIGURE_OPTIONS += --with-mysqli=mysqlnd
else
$(PKG)_CONFIGURE_OPTIONS += --without-mysqli
endif

ifeq ($(strip $(FREETZ_PACKAGE_PHP_WITH_MYSQLND_PDO)),y)
$(PKG)_CONFIGURE_OPTIONS += --with-pdo-mysql=mysqlnd
else
$(PKG)_CONFIGURE_OPTIONS += --without-pdo-mysql
endif

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP_STATIC
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP_apxs2
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP_WITH_CURL
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP_WITH_FILEINFO
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP_WITH_FTP
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP_WITH_GD
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP_WITH_GETTEXT
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP_WITH_ICONV FREETZ_PACKAGE_PHP_WITH_LIBICONV
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP_WITH_JSON
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP_WITH_LIBONIG
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
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP_WITH_FFI
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP_WITH_MYSQLND_MYSQLI
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP_WITH_MYSQLND_PDO
$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_IPV6_SUPPORT

$(PKG)_CONFIGURE_ENV += ac_cv_c_bigendian_php=$(if $(FREETZ_TARGET_ARCH_BE),yes,no)
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

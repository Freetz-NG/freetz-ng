PHP8_VERSION_83 := 8.3.31
PHP8_HASH_83    := 66410cee07f4b2baeb0843140bb2a2b52ef930b5cf9b3d6e6d158b33aae8fa37
PHP8_VERSION_84 := 8.4.22
PHP8_HASH_84    := 696c0f6ad92e94c59059c1eb6e300842b8d050934226efcdf00f2a413cb083cf
PHP8_VERSION_85 := 8.5.7
PHP8_HASH_85    := 01ba2ed1c2658dacf91bebc8be6a4885f69b811c7993831fc48e26107ab29985

PHP8_VERSION := $(if $(FREETZ_PACKAGE_PHP8_VERSION_85),$(PHP8_VERSION_85),$(if $(FREETZ_PACKAGE_PHP8_VERSION_84),$(PHP8_VERSION_84),$(PHP8_VERSION_83)))
PHP8_HASH    := $(if $(FREETZ_PACKAGE_PHP8_VERSION_85),$(PHP8_HASH_85),$(if $(FREETZ_PACKAGE_PHP8_VERSION_84),$(PHP8_HASH_84),$(PHP8_HASH_83)))

$(call PKG_INIT_BIN, $(PHP8_VERSION))
$(PKG)_SOURCE:=php-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=$(PHP8_HASH)
$(PKG)_SITE:=https://www.php.net/distributions,https://de.php.net/distributions,https://de2.php.net/distributions
### WEBSITE:=https://www.php.net
### MANPAGE:=https://www.php.net/docs.php
### CHANGES:=https://github.com/php/php-src/releases
### CVSREPO:=https://github.com/php/php-src

PHP8_CGI_NAME := $(if $(FREETZ_PACKAGE_PHP5_cgi)$(FREETZ_PACKAGE_PHP_cgi),php8-cgi,php-cgi)
PHP8_CLI_NAME := $(if $(FREETZ_PACKAGE_PHP5_cli)$(FREETZ_PACKAGE_PHP_cli),php8,php)

$(PKG)_BINARY              := $($(PKG)_DIR)/sapi/cgi/php-cgi
$(PKG)_TARGET_BINARY       := $($(PKG)_DEST_DIR)/usr/bin/$(PHP8_CGI_NAME)

$(PKG)_CLI_BINARY          := $($(PKG)_DIR)/sapi/cli/php
$(PKG)_CLI_TARGET_BINARY   := $($(PKG)_DEST_DIR)/usr/bin/$(PHP8_CLI_NAME)

$(PKG)_APXS2_BINARY        := $($(PKG)_DIR)/libs/libphp.so
$(PKG)_APXS2_TARGET_BINARY := $($(PKG)_DEST_DIR)/usr/lib/apache2/libphp.so

$(PKG)_STARTLEVEL=90 # before lighttpd

$(PKG)_EXTRA_CFLAGS  := -ffunction-sections -fdata-sections
$(PKG)_EXTRA_LDFLAGS := -Wl,--gc-sections

$(PKG)_DEPENDS_ON += pcre2
$(PKG)_CONFIGURE_OPTIONS += --with-external-pcre="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --without-pcre-jit

$(PKG)_CONFIGURE_OPTIONS += --enable-cli
$(PKG)_EXCLUDED += $(if $(FREETZ_PACKAGE_PHP8_cli),,$($(PKG)_CLI_TARGET_BINARY))

ifeq ($(strip $(FREETZ_PACKAGE_PHP8_apxs2)),y)
$(PKG)_DEPENDS_ON += apache2
$(PKG)_CONFIGURE_OPTIONS += --with-apxs2="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/apxs"
endif

ifeq ($(strip $(FREETZ_PACKAGE_PHP8_WITH_CURL)),y)
$(PKG)_REBUILD_SUBOPTS += $(filter FREETZ_LIB_libcurl_%,$(CURL_REBUILD_SUBOPTS))
$(PKG)_DEPENDS_ON += curl
$(PKG)_CONFIGURE_OPTIONS += --with-curl="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
endif

$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_PHP8_WITH_FILEINFO),--enable-fileinfo,--disable-fileinfo)

$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_PHP8_WITH_FTP),--enable-ftp,--disable-ftp)

ifeq ($(strip $(FREETZ_PACKAGE_PHP8_WITH_GD)),y)
$(PKG)_DEPENDS_ON += libpng
$(PKG)_CONFIGURE_OPTIONS += --enable-gd
endif

ifeq ($(strip $(FREETZ_PACKAGE_PHP8_WITH_GETTEXT)),y)
$(PKG)_DEPENDS_ON += gettext
$(PKG)_CONFIGURE_OPTIONS += --with-gettext="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
endif

ifeq ($(strip $(FREETZ_PACKAGE_PHP8_WITH_ICONV)),y)
$(PKG)_CONFIGURE_OPTIONS += --with-iconv

$(PKG)_CONFIGURE_ENV += ac_cv_func_iconv=$(if $(FREETZ_PACKAGE_PHP8_WITH_LIBICONV),no,yes)
$(PKG)_CONFIGURE_ENV += ac_cv_func_libiconv=$(if $(FREETZ_PACKAGE_PHP8_WITH_LIBICONV),yes,no)

ifeq ($(strip $(FREETZ_PACKAGE_PHP8_WITH_LIBICONV)),y)
$(PKG)_DEPENDS_ON += iconv
$(PKG)_CONFIGURE_ENV += iconv_impl_name=gnu_libiconv
$(PKG)_CONFIGURE_OPTIONS += --with-iconv="$(TARGET_TOOLCHAIN_STAGING_DIR)$(LIBICONV_PREFIX)"
$(PKG)_EXTRA_LDFLAGS += -L$(TARGET_TOOLCHAIN_STAGING_DIR)$(LIBICONV_PREFIX)/lib
else
$(PKG)_CONFIGURE_ENV += ICONV_IN_LIBC_DIR="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --with-iconv="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
endif

else
$(PKG)_CONFIGURE_OPTIONS += --without-iconv
endif

$(PKG)_DEPENDS_ON += libxml2
ifeq ($(strip $(FREETZ_PACKAGE_PHP8_WITH_LIBXML)),y)
$(PKG)_CONFIGURE_OPTIONS += --with-libxml
endif
$(PKG)_XML_SUPPORT:=$(if $(FREETZ_PACKAGE_PHP8_WITH_LIBXML),enable,disable)
$(PKG)_CONFIGURE_OPTIONS += --$($(PKG)_XML_SUPPORT)-xml
$(PKG)_CONFIGURE_OPTIONS += --$($(PKG)_XML_SUPPORT)-dom
$(PKG)_CONFIGURE_OPTIONS += --$($(PKG)_XML_SUPPORT)-simplexml
$(PKG)_CONFIGURE_OPTIONS += --$($(PKG)_XML_SUPPORT)-xmlreader
$(PKG)_CONFIGURE_OPTIONS += --$($(PKG)_XML_SUPPORT)-xmlwriter

$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_PHP8_WITH_PCNTL),--enable-pcntl,--disable-pcntl)

$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_PHP8_WITH_SESSION),--enable-session,--disable-session)

$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_PHP8_WITH_SOCKETS),--enable-sockets,--disable-sockets)

ifeq ($(strip $(FREETZ_PACKAGE_PHP8_WITH_SQLITE3)),y)
$(PKG)_DEPENDS_ON += sqlite
$(PKG)_CONFIGURE_OPTIONS += --with-sqlite3="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --with-pdo-sqlite="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
else
$(PKG)_CONFIGURE_OPTIONS += --without-sqlite3
$(PKG)_CONFIGURE_OPTIONS += --without-pdo-sqlite
endif

ifeq ($(strip $(FREETZ_PACKAGE_PHP8_WITH_SSL)),y)
$(PKG)_REBUILD_SUBOPTS += FREETZ_OPENSSL_SHORT_VERSION
$(PKG)_DEPENDS_ON += openssl
$(PKG)_CONFIGURE_OPTIONS += --with-openssl="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
endif

$(PKG)_SYSVIPC_SUPPORT:=$(if $(FREETZ_PACKAGE_PHP8_WITH_SYSVIPC),enable,disable)
$(PKG)_CONFIGURE_OPTIONS += --$($(PKG)_SYSVIPC_SUPPORT)-sysvsem
$(PKG)_CONFIGURE_OPTIONS += --$($(PKG)_SYSVIPC_SUPPORT)-sysvshm
$(PKG)_CONFIGURE_OPTIONS += --$($(PKG)_SYSVIPC_SUPPORT)-sysvmsg

ifeq ($(strip $(FREETZ_PACKAGE_PHP8_WITH_ZLIB)),y)
$(PKG)_DEPENDS_ON += zlib
$(PKG)_CONFIGURE_OPTIONS += --with-zlib
endif

ifeq ($(strip $(FREETZ_PACKAGE_PHP8_WITH_ZIP)),y)
$(PKG)_DEPENDS_ON += libzip
$(PKG)_CONFIGURE_OPTIONS += --with-zip
endif

ifeq ($(strip $(FREETZ_PACKAGE_PHP8_WITH_FFI)),y)
$(PKG)_DEPENDS_ON += libffi
$(PKG)_CONFIGURE_OPTIONS += --with-ffi
endif

ifeq ($(strip $(FREETZ_PACKAGE_PHP8_WITH_MYSQLI)),y)
$(PKG)_CONFIGURE_OPTIONS += --with-mysqli=mysqlnd
$(PKG)_CONFIGURE_OPTIONS += --with-pdo-mysql=mysqlnd
else
$(PKG)_CONFIGURE_OPTIONS += --without-mysqli
$(PKG)_CONFIGURE_OPTIONS += --without-pdo-mysql
endif


$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP8_VERSION_83
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP8_VERSION_84
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP8_VERSION_85
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP8_apxs2
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP8_WITH_CURL
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP8_WITH_FILEINFO
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP8_WITH_FTP
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP8_WITH_GD
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP8_WITH_GETTEXT
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP8_WITH_ICONV FREETZ_PACKAGE_PHP8_WITH_LIBICONV
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP8_WITH_LIBXML FREETZ_LIB_libxml2_WITH_HTML FREETZ_LIB_libxml2_WITH_RELAXNG
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP8_WITH_PCNTL
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP8_WITH_SESSION
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP8_WITH_SOCKETS
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP8_WITH_SQLITE3
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP8_WITH_SYSVIPC
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP8_WITH_SSL
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP8_WITH_ZLIB
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP8_WITH_ZIP
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP8_WITH_FFI
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP8_WITH_MYSQLI
$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_IPV6_SUPPORT
$(PKG)_REBUILD_SUBOPTS += FREETZ_LIB_libonig
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP5_cgi
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP5_cli
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP_cgi
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP_cli

$(PKG)_CONFIGURE_ENV += php_cv_sizeof_ssize_t=$(if $(FREETZ_TARGET_BITS_32),4,8)
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

$(PKG)_CONFIGURE_DEFOPTS:=n
$(PKG)_CONFIGURE_OPTIONS += --target=$(GNU_TARGET_NAME)
$(PKG)_CONFIGURE_OPTIONS += --host=$(GNU_TARGET_NAME)
$(PKG)_CONFIGURE_OPTIONS += --build=$(GNU_HOST_NAME)
$(PKG)_CONFIGURE_OPTIONS += --prefix=/usr
$(PKG)_CONFIGURE_OPTIONS += --exec-prefix=/usr
$(PKG)_CONFIGURE_OPTIONS += --bindir=/usr/bin
$(PKG)_CONFIGURE_OPTIONS += --libdir=/usr/lib
$(PKG)_CONFIGURE_OPTIONS += --with-gnu-ld

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)
ifneq ($(strip $(FREETZ_TARGET_IPV6_SUPPORT)),y)
$(PKG)_CONFIGURE_OPTIONS += --disable-ipv6
endif
$(PKG)_DEPENDS_ON += libonig
$(PKG)_CONFIGURE_OPTIONS += --enable-exif
$(PKG)_CONFIGURE_OPTIONS += --enable-mbstring
$(PKG)_CONFIGURE_OPTIONS += --disable-phar
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += --with-config-file-path=/tmp/flash/php8
$(PKG)_CONFIGURE_OPTIONS += --with-config-file-scan-dir=/tmp/flash/php8/conf.d
$(PKG)_CONFIGURE_OPTIONS += --without-pear


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY) $($(PKG)_CLI_BINARY) $($(PKG)_APXS2_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(PHP8_DIR) \
		EXTRA_CFLAGS="$(PHP8_EXTRA_CFLAGS)" \
		EXTRA_LDFLAGS_PROGRAM="$(PHP8_EXTRA_LDFLAGS)" \
		ZEND_EXTRA_LIBS="$(PHP8_LIBS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_CLI_TARGET_BINARY): $($(PKG)_CLI_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_APXS2_TARGET_BINARY): $($(PKG)_APXS2_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_CLI_TARGET_BINARY) $(if $(FREETZ_PACKAGE_PHP8_apxs2),$($(PKG)_APXS2_TARGET_BINARY))


$(pkg)-clean:
	-$(SUBMAKE) -C $(PHP8_DIR) clean
	$(RM) $(PHP8_FREETZ_CONFIG_FILE)

$(pkg)-uninstall:
	$(RM) $(PHP8_TARGET_BINARY) $(PHP8_CLI_TARGET_BINARY) $(PHP8_APXS2_TARGET_BINARY)

$(PKG_FINISH)

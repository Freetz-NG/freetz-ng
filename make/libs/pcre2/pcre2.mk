$(call PKG_INIT_LIB, 10.46)
$(PKG)_LIB_VERSION:=0.14.0
$(PKG)_POSIX_LIB_VERSION:=3.0.6
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_HASH:=15fbc5aba6beee0b17aecb04602ae39432393aba1ebd8e39b7cabf7db883299f
$(PKG)_SITE:=https://github.com/PCRE2Project/pcre2/releases/download/pcre2-$($(PKG)_VERSION)
### WEBSITE:=https://www.pcre.org/
### MANPAGE:=https://www.pcre.org/current/doc/html/
### CHANGES:=https://github.com/PCRE2Project/pcre2/blob/master/ChangeLog
### CVSREPO:=https://github.com/PCRE2Project/pcre2

$(PKG)_LIBNAME=libpcre2-8.so.$($(PKG)_LIB_VERSION)
$(PKG)_BINARY:=$($(PKG)_DIR)/.libs/$($(PKG)_LIBNAME)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$($(PKG)_LIBNAME)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$($(PKG)_LIBNAME)

$(PKG)_POSIX_LIBNAME=libpcre2-posix.so.$($(PKG)_POSIX_LIB_VERSION)
$(PKG)_POSIX_BINARY:=$($(PKG)_DIR)/.libs/$($(PKG)_POSIX_LIBNAME)
$(PKG)_POSIX_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$($(PKG)_POSIX_LIBNAME)
$(PKG)_POSIX_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$($(PKG)_POSIX_LIBNAME)

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --enable-pcre2-8
$(PKG)_CONFIGURE_OPTIONS += --disable-pcre2-16
$(PKG)_CONFIGURE_OPTIONS += --disable-pcre2-32
$(PKG)_CONFIGURE_OPTIONS += --enable-unicode
$(PKG)_CONFIGURE_OPTIONS += --enable-jit
$(PKG)_CONFIGURE_OPTIONS += --disable-pcre2test-libreadline
$(PKG)_CONFIGURE_OPTIONS += --disable-pcre2test-libedit
$(PKG)_CONFIGURE_OPTIONS += --disable-pcre2grep-libz
$(PKG)_CONFIGURE_OPTIONS += --disable-pcre2grep-libbz2


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY) $($(PKG)_POSIX_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(PCRE2_DIR) \
		all

$($(PKG)_STAGING_BINARY) $($(PKG)_POSIX_STAGING_BINARY): $($(PKG)_BINARY) $($(PKG)_POSIX_BINARY)
	$(SUBMAKE) -C $(PCRE2_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpcre2-8.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpcre2-posix.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/pcre2-config \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libpcre2-8.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libpcre2-posix.pc

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$($(PKG)_POSIX_TARGET_BINARY): $($(PKG)_POSIX_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY) $($(PKG)_POSIX_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_POSIX_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(PCRE2_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpcre2-8.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpcre2-posix.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/pcre2.h \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/pcre2posix.h \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/pcre2-config \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/pcre2-grep \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/pcre2test \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libpcre2-8.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libpcre2-posix.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/doc/pcre2/

$(pkg)-uninstall:
	$(RM) \
		$(PCRE2_TARGET_DIR)/libpcre2-8.so* \
		$(PCRE2_TARGET_DIR)/libpcre2-posix.so*

$(PKG_FINISH)

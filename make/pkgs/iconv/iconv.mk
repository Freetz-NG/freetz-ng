$(call PKG_INIT_BIN, 1.18)
$(PKG)_LIB_VERSION := 2.7.0
$(PKG)_SOURCE:=lib$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=3b08f5f4f9b4eb82f151a7040bfd6fe6c6fb922efe4b1659c66ea933276965e8
$(PKG)_SITE:=@GNU/lib$(pkg)
### WEBSITE:=https://www.gnu.org/software/libiconv/
### MANPAGE:=https://www.gnu.org/savannah-checkouts/gnu/libiconv/documentation/
### CHANGES:=https://ftp.gnu.org/pub/gnu/libiconv/
### CVSREPO:=https://git.savannah.gnu.org/gitweb/?p=libiconv.git

ifeq ($(strip $(FREETZ_TARGET_UCLIBC_0_9_28)),y)
LIB$(PKG)_PREFIX:=/usr
else
LIB$(PKG)_PREFIX:=/usr/lib/lib$(pkg)
endif

$(PKG)_BINARY:=$($(PKG)_DIR)/src/.libs/iconv_no_i18n
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/iconv

$(PKG)_LIB_BINARY:=$($(PKG)_DIR)/lib/.libs/lib$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_LIB_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)$(LIB$(PKG)_PREFIX)/lib/lib$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_LIB_TARGET_BINARY:=$($(PKG)_TARGET_LIBDIR)/lib$(pkg).so.$($(PKG)_LIB_VERSION)

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += --enable-relocatable

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY) $($(PKG)_LIB_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(ICONV_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_LIB_STAGING_BINARY): $($(PKG)_LIB_BINARY)
	mkdir -p $(TARGET_TOOLCHAIN_STAGING_DIR)$(LIBICONV_PREFIX)/{include,lib}
	cp -a $(ICONV_DIR)/include/iconv.h.inst $(TARGET_TOOLCHAIN_STAGING_DIR)$(LIBICONV_PREFIX)/include/iconv.h
	chmod 644 $(TARGET_TOOLCHAIN_STAGING_DIR)$(LIBICONV_PREFIX)/include/iconv.h
	cat $(ICONV_DIR)/lib/libiconv.la \
		| sed -r -e 's,^(installed=)no,\1yes,g' -e "s,^(libdir=)'.*',\1'$(LIBICONV_PREFIX)/lib',g" \
		> $(TARGET_TOOLCHAIN_STAGING_DIR)$(LIBICONV_PREFIX)/lib/libiconv.la
	chmod 755 $(TARGET_TOOLCHAIN_STAGING_DIR)$(LIBICONV_PREFIX)/lib/libiconv.la
	$(PKG_FIX_LIBTOOL_LA) $(TARGET_TOOLCHAIN_STAGING_DIR)$(LIBICONV_PREFIX)/lib/libiconv.la
	cp -a $(ICONV_DIR)/lib/.libs/libiconv.{a,so*} $(TARGET_TOOLCHAIN_STAGING_DIR)$(LIBICONV_PREFIX)/lib/

$($(PKG)_LIB_TARGET_BINARY): $($(PKG)_LIB_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_LIB_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(ICONV_DIR) clean
	$(RM) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)$(LIBICONV_PREFIX)/lib/libiconv* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)$(LIBICONV_PREFIX)/include/iconv.h

$(pkg)-uninstall:
	$(RM) $(ICONV_TARGET_BINARY) $(ICONV_TARGET_LIBDIR)/libiconv*.so*

$(call PKG_ADD_LIB,libiconv)
$(PKG_FINISH)

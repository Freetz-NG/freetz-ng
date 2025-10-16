$(call PKG_INIT_LIB, 0.24)
$(PKG)_LIB_VERSION:=8.4.3
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=e1620d518b26d7d3b16ac570e5018206e8b0d725fb65c02d048397718b5cf318
$(PKG)_SITE:=@GNU/$(pkg)
### WEBSITE:=https://www.gnu.org/software/gettext/
### MANPAGE:=https://www.gnu.org/software/gettext/manual/index.html
### CHANGES:=https://ftp.gnu.org/pub/gnu/gettext/
### CVSREPO:=https://git.savannah.gnu.org/gitweb/?p=gettext.git

# we only want libintl
$(PKG)_BUILD_SUBDIR := gettext-runtime

$(PKG)_BINARY:=$($(PKG)_DIR)/$($(PKG)_BUILD_SUBDIR)/intl/.libs/libintl.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libintl.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libintl.so.$($(PKG)_LIB_VERSION)

ifeq ($(strip $(FREETZ_TARGET_UCLIBC_0_9_28)),y)
$(PKG)_DEPENDS_ON += iconv
else
$(PKG)_CONFIGURE_OPTIONS += --without-libiconv-prefix
endif

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += --enable-nls
$(PKG)_CONFIGURE_OPTIONS += --disable-java
$(PKG)_CONFIGURE_OPTIONS += --disable-native-java
$(PKG)_CONFIGURE_OPTIONS += --disable-openmp
$(PKG)_CONFIGURE_OPTIONS += --with-included-gettext
$(PKG)_CONFIGURE_OPTIONS += --without-libintl-prefix
$(PKG)_CONFIGURE_OPTIONS += --without-libexpat-prefix
$(PKG)_CONFIGURE_OPTIONS += --without-emacs
$(PKG)_CONFIGURE_OPTIONS += --disable-csharp
$(PKG)_CONFIGURE_OPTIONS += --disable-curses
$(PKG)_CONFIGURE_OPTIONS += --without-libglib-2.0-prefix
$(PKG)_CONFIGURE_OPTIONS += --without-libcroco-0.6-prefix
$(PKG)_CONFIGURE_OPTIONS += --without-libunistring-prefix
$(PKG)_CONFIGURE_OPTIONS += --without-libxml2-prefix
$(PKG)_CONFIGURE_OPTIONS += --without-libncurses-prefix
$(PKG)_CONFIGURE_OPTIONS += --without-libtermcap-prefix
$(PKG)_CONFIGURE_OPTIONS += --without-libxcurses-prefix
$(PKG)_CONFIGURE_OPTIONS += --without-bison-prefix
$(PKG)_CONFIGURE_OPTIONS += --without-libcurses-prefix
$(PKG)_CONFIGURE_OPTIONS += --without-libtextstyle-prefix
$(PKG)_CONFIGURE_OPTIONS += --without-lispdir-prefix
$(PKG)_CONFIGURE_OPTIONS += --without-git
$(PKG)_CONFIGURE_OPTIONS += --without-cvs
$(PKG)_CONFIGURE_OPTIONS += --without-bzip2
$(PKG)_CONFIGURE_OPTIONS += --without-xz


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(GETTEXT_DIR)/$(GETTEXT_BUILD_SUBDIR)/intl \
		all

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(GETTEXT_DIR)/$(GETTEXT_BUILD_SUBDIR)/intl \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libintl.la

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(GETTEXT_DIR)/$(GETTEXT_BUILD_SUBDIR) clean
	$(RM) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgettext* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libintl* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/libintl.h

$(pkg)-uninstall:
	$(RM) $(GETTEXT_TARGET_DIR)/libintl*.so*

$(PKG_FINISH)

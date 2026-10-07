$(call PKG_INIT_LIB, 3.0.4)
$(PKG)_LIB_VERSION:=14.2.0
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=e28c24fc5d9f3cb90005bc008fec8bb8eedce503753024ab650bed0ac250cbe3
$(PKG)_SITE:=https://github.com/cminyard/$(pkg)/releases/download/v$($(PKG)_VERSION)
### WEBSITE:=https://github.com/cminyard/gensio
### CHANGES:=https://github.com/cminyard/gensio/releases
### CVSREPO:=https://github.com/cminyard/gensio

$(PKG)_LIBRARIES_SHORT   := gensio gensioosh gensiomdns
$(PKG)_LIBRARIES_FILES   := $($(PKG)_LIBRARIES_SHORT:%=lib%.so.$($(PKG)_LIB_VERSION))
$(PKG)_BUILD_BINARIES    := $($(PKG)_LIBRARIES_FILES:%=$($(PKG)_DIR)/lib/.libs/%)
$(PKG)_STAGING_BINARIES  := $($(PKG)_LIBRARIES_FILES:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%)
$(PKG)_TARGET_BINARIES   := $($(PKG)_LIBRARIES_FILES:%=$($(PKG)_TARGET_DIR)/%)


$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-debug
$(PKG)_CONFIGURE_OPTIONS += --disable-doc

$(PKG)_CONFIGURE_OPTIONS += --with-all-gensios=no
$(PKG)_CONFIGURE_OPTIONS += --with-net=yes
$(PKG)_CONFIGURE_OPTIONS += --with-serialdev=yes
$(PKG)_CONFIGURE_OPTIONS += --with-telnet=yes

$(PKG)_CONFIGURE_OPTIONS += --with-cplusplus=no
$(PKG)_CONFIGURE_OPTIONS += --with-libsoapy=no
$(PKG)_CONFIGURE_OPTIONS += --with-glib=no
$(PKG)_CONFIGURE_OPTIONS += --with-tcl=no
$(PKG)_CONFIGURE_OPTIONS += --with-swig=no
$(PKG)_CONFIGURE_OPTIONS += --with-python=no
$(PKG)_CONFIGURE_OPTIONS += --with-go=no

$(PKG)_CONFIGURE_OPTIONS += --with-sctp=no
$(PKG)_CONFIGURE_OPTIONS += --with-openipmi=no
$(PKG)_CONFIGURE_OPTIONS += --with-mdns=no
$(PKG)_CONFIGURE_OPTIONS += --with-avahi=no
$(PKG)_CONFIGURE_OPTIONS += --with-dnssd=no
$(PKG)_CONFIGURE_OPTIONS += --with-winmdns=no
$(PKG)_CONFIGURE_OPTIONS += --with-alsa=no
$(PKG)_CONFIGURE_OPTIONS += --with-winsound=no
$(PKG)_CONFIGURE_OPTIONS += --with-portaudio=no
$(PKG)_CONFIGURE_OPTIONS += --with-udev=no
$(PKG)_CONFIGURE_OPTIONS += --with-openssl=no
$(PKG)_CONFIGURE_OPTIONS += --with-tcp-wrappers=no


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BUILD_BINARIES): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(GENSIO_DIR)

$($(PKG)_STAGING_BINARIES): $($(PKG)_BUILD_BINARIES)
	$(SUBMAKE) -C $(GENSIO_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgensio*.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libgensio*.pc

$($(PKG)_TARGET_BINARIES): $($(PKG)_TARGET_DIR)/lib%.so.$($(PKG)_LIB_VERSION): $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/lib%.so.$($(PKG)_LIB_VERSION)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARIES)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARIES)


$(pkg)-clean:
	-$(SUBMAKE) -C $(GENSIO_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgensio*.so* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgensio*.a \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgensio*.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libgensio*.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/gensio/

$(pkg)-uninstall:
	$(RM) $(GENSIO_TARGET_DIR)/libgensio*.so*

$(PKG_FINISH)

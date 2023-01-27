$(call PKG_INIT_LIB, 0.8.3)
$(PKG)_LIB_VERSION:=0.0.0
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=bed6f6848e22bb2f83b5f764b2aef0ed393054e803a8e3a8711cb2a39e6b492d
$(PKG)_SITE:=https://people.redhat.com/sgrubb/libcap-ng
### WEBSITE:=https://people.redhat.com/sgrubb/libcap-ng/
### CHANGES:=https://people.redhat.com/sgrubb/libcap-ng/ChangeLog
### CVSREPO:=https://github.com/stevegrubb/libcap-ng

$(PKG)_LIBNAMES_SHORT   := libcap-ng libdrop_ambient
$(PKG)_LIBNAMES_LONG    := $($(PKG)_LIBNAMES_SHORT:%=%.so.$($(PKG)_LIB_VERSION))
$(PKG)_LIBS_BUILD_DIR   := $($(PKG)_LIBNAMES_LONG:%=$($(PKG)_DIR)/src/.libs/%)
$(PKG)_LIBS_STAGING_DIR := $($(PKG)_LIBNAMES_LONG:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%)
$(PKG)_LIBS_TARGET_DIR  := $($(PKG)_LIBNAMES_LONG:%=$($(PKG)_TARGET_DIR)/%)

$(PKG)_CONFIGURE_PRE_CMDS += $(AUTORECONF)

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --prefix=/
$(PKG)_CONFIGURE_OPTIONS += --without-capability_header
$(PKG)_CONFIGURE_OPTIONS += --without-debug
$(PKG)_CONFIGURE_OPTIONS += --without-python
$(PKG)_CONFIGURE_OPTIONS += --without-python3


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_LIBS_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LIBCAP_NG_DIR)

$($(PKG)_LIBS_STAGING_DIR): $($(PKG)_LIBS_BUILD_DIR)
	$(SUBMAKE) -C $(LIBCAP_NG_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libcap-ng.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libdrop_ambient.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libcap-ng.pc

$($(PKG)_LIBS_TARGET_DIR): $($(PKG)_TARGET_DIR)/%: $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_LIBS_STAGING_DIR)

$(pkg)-precompiled: $($(PKG)_LIBS_TARGET_DIR)


$(pkg)-clean:
	-$(SUBMAKE) -C $(PANGO_DIR) clean
	$(RM) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libcap-ng.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libdrop_ambient.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libcap-ng.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/cap-ng.h \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/man/man3/capng_*.3

$(pkg)-uninstall:
	$(RM) $(PANGO_TARGET_DIR)/libcap-ng.so* $(PANGO_TARGET_DIR)/libdrop_ambient.so*

$(PKG_FINISH)

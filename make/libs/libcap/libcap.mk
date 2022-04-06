$(call PKG_INIT_LIB, 2.63)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_SOURCE_SHA256:=0c637b8f44fc7d8627787e9cf57f15ac06c1ddccb53e41feec5496be3466f77f
$(PKG)_SITE:=@KERNEL/linux/libs/security/linux-privs/libcap2

$(PKG)_DEPENDS_ON += attr

$(PKG)_BINARY:=$($(PKG)_DIR)/$(pkg)/$(pkg).so.$($(PKG)_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(pkg).so.$($(PKG)_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$(pkg).so.$($(PKG)_VERSION)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LIBCAP_DIR) \
		CC="$(TARGET_CC)" \
		AR="$(TARGET_AR)" \
		RANLIB="$(TARGET_RANLIB)" \
		CFLAGS="$(TARGET_CFLAGS) -fPIC" \
		BUILD_CC="$(CC)" \
		PAM_CAP=no \
		BUILD_CFLAGS="-W -Wall -O2" \
		lib=lib

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(LIBCAP_DIR)/libcap \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		lib=lib \
		RAISE_SETFCAP=no \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libcap.pc

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(LIBCAP_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libcap.so* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libcap.a \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/sys/capability.h \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libcap.pc

$(pkg)-uninstall:
	$(RM) $(LIBCAP_TARGET_DIR)/libcap.so*

$(PKG_FINISH)

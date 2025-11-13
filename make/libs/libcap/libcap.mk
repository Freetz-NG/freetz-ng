$(call PKG_INIT_LIB, $(if $(FREETZ_TARGET_GCC_5_MAX),2.49,2.77))
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH_ABANDON:=e98bc4d93645082ec787730b0fd1a712b38882465c505777de17c338831ee181
$(PKG)_HASH_CURRENT:=897bc18b44afc26c70e78cead3dbb31e154acc24bee085a5a09079a88dbf6f52
$(PKG)_HASH:=$($(PKG)_HASH_$(if $(FREETZ_TARGET_GCC_5_MAX),ABANDON,CURRENT))
$(PKG)_SITE:=@KERNEL/linux/libs/security/linux-privs/libcap2
### VERSION:=2.49/2.77
### WEBSITE:=https://sites.google.com/site/fullycapable/
### MANPAGE:=https://pkg.go.dev/kernel.org/pub/linux/libs/security/libcap/cap
### CHANGES:=https://sites.google.com/site/fullycapable/release-notes-for-libcap
### CVSREPO:=https://git.kernel.org/pub/scm/libs/libcap/libcap.git

$(PKG)_DEPENDS_ON += attr

$(PKG)_CONDITIONAL_PATCHES+=$(if $(FREETZ_TARGET_GCC_5_MAX),abandon,current)

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
		OBJCOPY="$(TARGET_OBJCOPY)" \
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


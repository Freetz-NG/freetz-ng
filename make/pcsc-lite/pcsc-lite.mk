$(call PKG_INIT_BIN, 1.9.5)
$(PKG)_LIB_VERSION:=1.0.0
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_SHA256:=9ee3f9b333537562177893559ad4f7b8d5c23ebe828eef53056c02db14049d08
$(PKG)_SITE:=https://pcsclite.apdu.fr/files
### WEBSITE:=https://pcsclite.apdu.fr/
### MANPAGE:=https://salsa.debian.org/rousseau/PCSC/blob/master/README
### CHANGES:=https://salsa.debian.org/rousseau/PCSC/blob/master/ChangeLog
### CVSREPO:=https://salsa.debian.org/rousseau/PCSC

$(PKG)_BINARY:=$($(PKG)_DIR)/src/pcscd
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/pcscd

$(PKG)_LIB:=$($(PKG)_DIR)/src/.libs/libpcsclite.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_LIB:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpcsclite.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_LIB:=$($(PKG)_TARGET_LIBDIR)/libpcsclite.so.$($(PKG)_LIB_VERSION)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_DEPENDS_ON += libusb1

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static

$(PKG)_CONFIGURE_OPTIONS += --enable-libusb
$(PKG)_CONFIGURE_OPTIONS += --enable-scf
$(PKG)_CONFIGURE_OPTIONS += --disable-libhal
$(PKG)_CONFIGURE_OPTIONS += --disable-libudev
$(PKG)_CONFIGURE_OPTIONS += --disable-libsystemd
$(PKG)_CONFIGURE_OPTIONS += --enable-embedded
$(PKG)_CONFIGURE_OPTIONS += --enable-usbdropdir=$(PCSC_LITE_USBDROPDIR)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY) $($(PKG)_LIB): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(PCSC_LITE_DIR) V=1

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_STAGING_LIB): $($(PKG)_LIB)
	$(SUBMAKE) -C $(PCSC_LITE_DIR)/src \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install-libLTLIBRARIES install-nodistheaderDATA install-nobase_includeHEADERS install-pcDATA
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpcsclite.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libpcsclite.pc

$($(PKG)_TARGET_LIB): $($(PKG)_STAGING_LIB)
	$(INSTALL_LIBRARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_TARGET_LIB)

$(pkg)-clean:
	-$(SUBMAKE) -C $(PCSC_LITE_DIR) clean
	$(RM) $(PCSC_LITE_DIR)/.configured
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/PCSC \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpcsclite.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libpcsclite.pc

$(pkg)-uninstall:
	$(RM) \
		$(PCSC_LITE_TARGET_BINARY) \
		$(PCSC_LITE_TARGET_LIBDIR)/libpcsclite.so*

$(call PKG_ADD_LIB,libpcsclite)
$(PKG_FINISH)

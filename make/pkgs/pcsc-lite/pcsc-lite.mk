$(call PKG_INIT_BIN, $(if $(FREETZ_LIB_libpcsclite_WITH_VERSION_ABANDON),1.9.5,2.5.3))
$(PKG)_LIB_VERSION:=$(if $(FREETZ_LIB_libpcsclite_WITH_VERSION_ABANDON),1.0.0,1)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.$(if $(FREETZ_LIB_libpcsclite_WITH_VERSION_ABANDON),bz2,xz)
$(PKG)_HASH_ABANDON:=9ee3f9b333537562177893559ad4f7b8d5c23ebe828eef53056c02db14049d08
$(PKG)_HASH_CURRENT:=fe2bb733ecf95e52768907eb00da9f9f3daf180960283e514a05dcc090afa3bd
$(PKG)_HASH:=$($(PKG)_HASH_$(if $(FREETZ_LIB_libpcsclite_WITH_VERSION_ABANDON),ABANDON,CURRENT))
$(PKG)_SITE:=https://pcsclite.apdu.fr/files
### WEBSITE:=https://pcsclite.apdu.fr/
### MANPAGE:=https://salsa.debian.org/rousseau/PCSC/blob/master/README
### CHANGES:=https://salsa.debian.org/rousseau/PCSC/blob/master/ChangeLog
### CVSREPO:=https://salsa.debian.org/rousseau/PCSC
### STEWARD:=fda77

$(PKG)_CATEGORY_LIBS:=USB & related

$(PKG)_STARTLEVEL=90

$(PKG)_BINARY:=$($(PKG)_DIR)/$(if $(FREETZ_LIB_libpcsclite_WITH_VERSION_ABANDON),src,builddir)/pcscd
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/pcscd

$(PKG)_LIB:=$($(PKG)_DIR)/$(if $(FREETZ_LIB_libpcsclite_WITH_VERSION_ABANDON),src/.libs,builddir)/libpcsclite.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_LIB:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpcsclite.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_LIB:=$($(PKG)_TARGET_LIBDIR)/libpcsclite.so.$($(PKG)_LIB_VERSION)

$(PKG)_CONDITIONAL_PATCHES+=$(if $(FREETZ_LIB_libpcsclite_WITH_VERSION_ABANDON),abandon,current)

$(PKG)_DEPENDS_ON += libusb1

ifeq ($(strip $(FREETZ_LIB_libpcsclite_WITH_VERSION_ABANDON)),y)
$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static

$(PKG)_CONFIGURE_OPTIONS += --enable-libusb
$(PKG)_CONFIGURE_OPTIONS += --enable-scf
$(PKG)_CONFIGURE_OPTIONS += --disable-libhal
$(PKG)_CONFIGURE_OPTIONS += --disable-libudev
$(PKG)_CONFIGURE_OPTIONS += --disable-libsystemd
$(PKG)_CONFIGURE_OPTIONS += --disable-polkit
$(PKG)_CONFIGURE_OPTIONS += --enable-embedded
$(PKG)_CONFIGURE_OPTIONS += --enable-usbdropdir=$(PCSC_LITE_USBDROPDIR)

else
$(PKG)_DEPENDS_ON += meson-host

$(PKG)_CONFIGURE_OPTIONS += -D backend=ninja
$(PKG)_CONFIGURE_OPTIONS += -D buildtype=release
$(PKG)_CONFIGURE_OPTIONS += -D debug=false
$(PKG)_CONFIGURE_OPTIONS += -D default_library=both

$(PKG)_CONFIGURE_OPTIONS += -D embedded=true
$(PKG)_CONFIGURE_OPTIONS += -D libsystemd=false
$(PKG)_CONFIGURE_OPTIONS += -D libudev=false
$(PKG)_CONFIGURE_OPTIONS += -D libusb=true
$(PKG)_CONFIGURE_OPTIONS += -D polkit=false
$(PKG)_CONFIGURE_OPTIONS += -D serial=false
$(PKG)_CONFIGURE_OPTIONS += -D usbdropdir=$(PCSC_LITE_USBDROPDIR)

$(PKG)_CONFIGURE_POST_CMDS += $(call PKG_PREVENT_MESON_BUILD_RPATH,builddir/build.ninja)
endif


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
ifeq ($(strip $(FREETZ_LIB_libpcsclite_WITH_VERSION_ABANDON)),y)
$(PKG_CONFIGURED_CONFIGURE)
else
$(PKG_CONFIGURED_MESON)
endif

ifeq ($(strip $(FREETZ_LIB_libpcsclite_WITH_VERSION_ABANDON)),y)
$($(PKG)_BINARY) $($(PKG)_LIB): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(PCSC_LITE_DIR) V=1
else
$($(PKG)_BINARY) $($(PKG)_LIB): $($(PKG)_DIR)/.configured
	$(SUBMESON) compile \
		-C $(PCSC_LITE_DIR)/builddir/
#meson	$(MESON) configure $(PCSC_LITE_DIR)/builddir/
endif

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

ifeq ($(strip $(FREETZ_LIB_libpcsclite_WITH_VERSION_ABANDON)),y)
$($(PKG)_STAGING_LIB): $($(PKG)_LIB)
	$(SUBMAKE) -C $(PCSC_LITE_DIR)/src \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install-libLTLIBRARIES install-nodistheaderDATA install-nobase_includeHEADERS install-pcDATA
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpcsclite.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libpcsclite.pc
else
$($(PKG)_STAGING_LIB): $($(PKG)_LIB)
	$(SUBMESON) install \
		--destdir "$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		-C $(PCSC_LITE_DIR)/builddir/
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libpcsclite.pc
#meson		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpcsclite.la
endif

$($(PKG)_TARGET_LIB): $($(PKG)_STAGING_LIB)
	$(INSTALL_LIBRARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_TARGET_LIB)


$(pkg)-clean:
	-$(SUBMAKE) -C $(PCSC_LITE_DIR) clean
	$(RM) $(PCSC_LITE_DIR)/.configured
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/PCSC/ \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpcsclite.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libpcsclite.pc

$(pkg)-uninstall:
	$(RM) \
		$(PCSC_LITE_TARGET_BINARY) \
		$(PCSC_LITE_TARGET_LIBDIR)/libpcsclite.so*

$(call PKG_ADD_LIB,libpcsclite)
$(PKG_FINISH)

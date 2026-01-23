$(call PKG_INIT_LIB, $(if $(FREETZ_LIB_libpcap_VERSION_ABANDON),1.1.1,1.10.6))
$(PKG)_LIB_VERSION:=$($(PKG)_VERSION)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH_ABANDON:=508cca15547e55d1318498b838456a21770c450beb2dc7d7d4a96d90816e5a85
$(PKG)_HASH_CURRENT:=872dd11337fe1ab02ad9d4fee047c9da244d695c6ddf34e2ebb733efd4ed8aa9
$(PKG)_HASH:=$($(PKG)_HASH_$(if $(FREETZ_LIB_libpcap_VERSION_ABANDON),ABANDON,CURRENT))
$(PKG)_SITE:=https://www.tcpdump.org/release/
### VERSION:=1.1.1/1.10.6
### WEBSITE:=https://www.tcpdump.org
### MANPAGE:=https://www.tcpdump.org/manpages/pcap-filter.7.html
### CHANGES:=https://git.tcpdump.org/libpcap/blob/HEAD:/CHANGES
### CVSREPO:=https://github.com/the-tcpdump-group/libpcap

$(PKG)_BINARY:=$($(PKG)_DIR)/$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$(pkg).so.$($(PKG)_LIB_VERSION)

$(PKG)_CONDITIONAL_PATCHES+=$(if $(FREETZ_LIB_libpcap_VERSION_ABANDON),abandon,current)

$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_IPV6_SUPPORT
$(PKG)_REBUILD_SUBOPTS += FREETZ_LIB_libpcap_VERSION_ABANDON
$(PKG)_REBUILD_SUBOPTS += FREETZ_LIB_libpcap_VERSION_CURRENT

$(PKG)_CONFIGURE_OPTIONS += --with-pcap=linux
$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-bluetooth
ifeq ($(strip $(FREETZ_LIB_libpcap_VERSION_ABANDON)),y)
$(PKG)_CONFIGURE_OPTIONS += --disable-can
$(PKG)_CONFIGURE_OPTIONS += --disable-yydebug
$(PKG)_CONFIGURE_OPTIONS += --with-build-cc="$(HOSTCC)"
else
$(PKG)_CONFIGURE_OPTIONS += --disable-usb
$(PKG)_CONFIGURE_OPTIONS += --disable-netmap
$(PKG)_CONFIGURE_OPTIONS += --disable-dbus
$(PKG)_CONFIGURE_OPTIONS += --disable-rdma
$(PKG)_CONFIGURE_OPTIONS += --without-snf
$(PKG)_CONFIGURE_OPTIONS += --without-turbocap
$(PKG)_CONFIGURE_OPTIONS += --without-dpdk
endif
$(PKG)_CONFIGURE_OPTIONS += --without-dag
$(PKG)_CONFIGURE_OPTIONS += --without-septel
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_TARGET_IPV6_SUPPORT),--enable-ipv6,--disable-ipv6)


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LIBPCAP_DIR) all \
		CCOPT="$(TARGET_CFLAGS)"

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(LIBPCAP_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/pcap-config

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(LIBPCAP_DIR) clean
	$(RM) -r $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpcap* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/pcap-config \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/pcap*

$(pkg)-uninstall:
	$(RM) $(LIBPCAP_TARGET_DIR)/libpcap*.so*

$(PKG_FINISH)

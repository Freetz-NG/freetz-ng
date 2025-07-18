$(call PKG_INIT_BIN, $(if $(FREETZ_PACKAGE_BIND_VERSION_ABANDON),9.11.37,9.20.11))
$(PKG)_LIB_VERSION:=$($(PKG)_VERSION)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.$(if $(FREETZ_PACKAGE_BIND_VERSION_ABANDON),gz,xz)
$(PKG)_HASH_ABANDON:=0d8efbe7ec166ada90e46add4267b7e7c934790cba9bd5af6b8380a4fbfb5aff
$(PKG)_HASH_CURRENT:=4da2d532e668bc21e883f6e6d9d3d81794d9ec60b181530385649a56f46ee17a
$(PKG)_HASH:=$($(PKG)_HASH_$(if $(FREETZ_PACKAGE_BIND_VERSION_ABANDON),ABANDON,CURRENT))
$(PKG)_SITE:=https://downloads.isc.org/isc/bind9/$($(PKG)_VERSION),http://ftp.isc.org/isc/bind9/$($(PKG)_VERSION)
### WEBSITE:=https://www.isc.org/bind/
### MANPAGE:=https://bind9.readthedocs.io/en/
### CHANGES:=https://downloads.isc.org/isc/bind9/cur/9.20/
### CVSREPO:=https://gitlab.isc.org/isc-projects/bind9/
### SUPPORT:=fda77

$(PKG)_STARTLEVEL=40 # multid-wrapper may start it earlier!

ifneq ($(strip $(FREETZ_PACKAGE_BIND_VERSION_ABANDON)),y)
$(PKG)_LIBRARIES_SHORT              := dns isc isccc isccfg ns
$(PKG)_LIBRARIES_FILES              := $($(PKG)_LIBRARIES_SHORT:%=lib%-$($(PKG)_LIB_VERSION).so)
$(PKG)_LIBRARIES_BUILD_DIR          := $(join $($(PKG)_LIBRARIES_SHORT:%=$($(PKG)_DIR)/lib/%/.libs/),$($(PKG)_LIBRARIES_FILES))
$(PKG)_LIBRARIES_TARGET_DIR         := $($(PKG)_LIBRARIES_FILES:%=$($(PKG)_TARGET_LIBDIR)/%)
$(PKG)_LIBRARIES_STAGING_DIR        := $($(PKG)_LIBRARIES_FILES:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%)

$(PKG)_LIBRARIES_BUILD_DIR_ONLY     := $($(PKG)_LIBRARIES_SHORT:%=$($(PKG)_DIR)/lib/%/.libs/)
$(PKG)_BINARIES_EVERY_SBIN          := ddns-confgen named rndc rndc-confgen tsig-keygen
$(PKG)_BINARIES_EVERY_BIN           := arpaname delv dig dnssec-cds dnssec-dsfromkey dnssec-importkey dnssec-keyfromlabel dnssec-keygen dnssec-revoke dnssec-settime dnssec-signzone dnssec-verify host mdig named-checkconf named-checkzone named-compilezone named-journalprint named-rrchecker nsec3hash nslookup nsupdate
endif

$(PKG)_BINARIES_DST_DIR             := sbin  sbin  bin      bin  bin  bin
$(PKG)_BINARIES_SRC_DIR             := named rndc  nsupdate dig  dig  dig
$(PKG)_BINARIES_ALL                 := named rndc  nsupdate dig  host nslookup

$(PKG)_BINARIES                     := $(call PKG_SELECTED_SUBOPTIONS,$($(PKG)_BINARIES_ALL))
ifeq ($(strip $(FREETZ_PACKAGE_BIND_VERSION_ABANDON)),y)
$(PKG)_BINARIES_BUILD_DIR           := $(join $($(PKG)_BINARIES_SRC_DIR:%=$($(PKG)_DIR)/bin/%/),$($(PKG)_BINARIES_ALL))
else
$(PKG)_BINARIES_BUILD_DIR           := $(join $($(PKG)_BINARIES_SRC_DIR:%=$($(PKG)_DIR)/bin/%/.libs/),$($(PKG)_BINARIES_ALL))
endif
$(PKG)_BINARIES_ALL_TARGET_DIR      := $(join $($(PKG)_BINARIES_DST_DIR:%=$($(PKG)_DEST_DIR)/usr/%/),$($(PKG)_BINARIES_ALL))
$(PKG)_FILTER_OUT                    = $(foreach k,$(1), $(foreach v,$(2), $(if $(subst $(notdir $(v)),,$(k)),,$(v)) ) )
$(PKG)_BINARIES_TARGET_DIR          := $(call $(PKG)_FILTER_OUT,$($(PKG)_BINARIES),$($(PKG)_BINARIES_ALL_TARGET_DIR))
$(PKG)_EXCLUDED                     += $(filter-out $($(PKG)_BINARIES_TARGET_DIR),$($(PKG)_BINARIES_ALL_TARGET_DIR))

$(PKG)_EXCLUDED+=$(if $(FREETZ_PACKAGE_BIND_NAMED),,usr/lib/bind usr/lib/cgi-bin/bind.cgi etc/default.bind etc/init.d/rc.bind)

$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_IPV6_SUPPORT
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_BIND_VERSION_ABANDON

ifneq ($(strip $(FREETZ_PACKAGE_BIND_VERSION_ABANDON)),y)
$(PKG)_DEPENDS_ON += libatomic libuv openssl libcap liburcu
endif

$(PKG)_CONDITIONAL_PATCHES+=$(if $(FREETZ_PACKAGE_BIND_VERSION_ABANDON),abandon,current)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure) 

$(PKG)_CONFIGURE_OPTIONS += BUILD_CC="$(HOSTCC)"
ifeq ($(strip $(FREETZ_PACKAGE_BIND_VERSION_ABANDON)),y)
$(PKG)_CONFIGURE_OPTIONS += --disable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --enable-atomic=no
$(PKG)_CONFIGURE_OPTIONS += --without-openssl
$(PKG)_CONFIGURE_OPTIONS += --enable-epoll=no
$(PKG)_CONFIGURE_OPTIONS += --with-lmdb=no
$(PKG)_CONFIGURE_OPTIONS += --with-randomdev="/dev/random"
$(PKG)_CONFIGURE_OPTIONS += --with-libtool
$(PKG)_CONFIGURE_OPTIONS += --without-python
$(PKG)_CONFIGURE_OPTIONS += --without-gssapi
$(PKG)_CONFIGURE_OPTIONS += --disable-isc-spnego
$(PKG)_CONFIGURE_OPTIONS += --without-pkcs11
$(PKG)_CONFIGURE_OPTIONS += --without-idnlib
$(PKG)_CONFIGURE_OPTIONS += --without-purify
$(PKG)_CONFIGURE_OPTIONS += --without-libjson
$(PKG)_CONFIGURE_OPTIONS += --without-libxml2
$(PKG)_CONFIGURE_OPTIONS += --without-zlib
$(PKG)_CONFIGURE_OPTIONS += --enable-threads
$(PKG)_CONFIGURE_OPTIONS += --disable-backtrace
$(PKG)_CONFIGURE_OPTIONS += --disable-symtable
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_TARGET_IPV6_SUPPORT),--enable-ipv6,--disable-ipv6)
else
$(PKG)_CONFIGURE_OPTIONS += --disable-geoip
$(PKG)_CONFIGURE_OPTIONS += --disable-doh
$(PKG)_CONFIGURE_OPTIONS += --disable-chroot
$(PKG)_CONFIGURE_OPTIONS += --enable-full-report
$(PKG)_CONFIGURE_OPTIONS += --without-maxminddb
$(PKG)_CONFIGURE_OPTIONS += --without-libnghttp2
$(PKG)_CONFIGURE_OPTIONS += --without-gssapi
$(PKG)_CONFIGURE_OPTIONS += --without-lmdb
$(PKG)_CONFIGURE_OPTIONS += --without-libxml2
$(PKG)_CONFIGURE_OPTIONS += --without-json-c
$(PKG)_CONFIGURE_OPTIONS += --without-zlib
$(PKG)_CONFIGURE_OPTIONS += --without-readline
$(PKG)_CONFIGURE_OPTIONS += --without-libidn2
$(PKG)_CONFIGURE_OPTIONS += --without-cmocka
$(PKG)_CONFIGURE_OPTIONS += --without-jemalloc
$(PKG)_CONFIGURE_OPTIONS += --disable-dnsrps
endif

ifeq ($(strip $(FREETZ_PACKAGE_BIND_VERSION_ABANDON)),y)
$(PKG)_MAKE_FLAGS += EXTRA_CFLAGS="-ffunction-sections -fdata-sections"
$(PKG)_MAKE_FLAGS += EXTRA_BINARY_LDFLAGS="-Wl,--gc-sections"
else
# cant find its own libs ...
$(PKG)_MAKE_FLAGS += LDFLAGS="$(TARGET_LDFLAGS) $(BIND_LIBRARIES_BUILD_DIR_ONLY:%= -Wl,-rpath-link,$(FREETZ_BASE_DIR)/%)"
endif


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR) $($(PKG)_LIBRARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(BIND_DIR) $(BIND_MAKE_FLAGS)

$($(PKG)_LIBRARIES_STAGING_DIR): $($(PKG)_LIBRARIES_BUILD_DIR)
	$(SUBMAKE) -C $(BIND_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(BIND_LIBRARIES_SHORT:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/lib%.la)

# just ignoring the unused ...
$(foreach binary,$($(PKG)_BINARIES_BUILD_DIR),$(eval $(call INSTALL_BINARY_STRIP_RULE,$(binary),/usr/sbin)))
$(foreach binary,$($(PKG)_BINARIES_BUILD_DIR),$(eval $(call INSTALL_BINARY_STRIP_RULE,$(binary),/usr/bin)))

$($(PKG)_LIBRARIES_TARGET_DIR): $($(PKG)_TARGET_LIBDIR)/%: $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_LIBRARIES_STAGING_DIR)
$($(PKG)_LIBRARIES_SHORT): $(pkg)

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR) $($(PKG)_LIBRARIES_TARGET_DIR)
$(patsubst %,%-precompiled,$($(PKG)_LIBRARIES_SHORT)): $(pkg)-precompiled


$(pkg)-clean:
	-$(SUBMAKE) -C $(BIND_DIR) clean
	$(RM) -r $(BIND_DIR)/.configured

$(pkg)-clean-staging:
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/etc/bind.keys \
		$(BIND_LIBRARIES_SHORT:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/include/%/) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/bind/ \
		$(BIND_LIBRARIES_SHORT:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/lib%-$(BIND_VERSION).so) \
		$(BIND_LIBRARIES_SHORT:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/lib%.*) \
		$(BIND_BINARIES_EVERY_BIN:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/%) \
		$(BIND_BINARIES_EVERY_SBIN:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/sbin/%) \
		$(BIND_BINARIES_EVERY_BIN:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/man/man1/%.1) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/man/man5/named.conf.5 \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/man/man5/rndc.conf.5 \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/man/man8/filter-a.8 \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/man/man8/filter-aaaa.8 \
		$(BIND_BINARIES_EVERY_SBIN:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/man/man8/%.8)

$(pkg)-uninstall:
	$(RM) $(BIND_BINARIES_ALL_TARGET_DIR) $(BIND_LIBRARIES_TARGET_DIR)

$(call PKG_ADD_LIB,libbind9)
$(call PKG_ADD_LIB,libdns)
$(call PKG_ADD_LIB,libirs)
$(call PKG_ADD_LIB,libisccc)
$(call PKG_ADD_LIB,libisccfg)
$(call PKG_ADD_LIB,libisc)
$(call PKG_ADD_LIB,libns)
$(PKG_FINISH)


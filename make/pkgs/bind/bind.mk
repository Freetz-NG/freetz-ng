$(call PKG_INIT_BIN, $(if $(FREETZ_PACKAGE_BIND_VERSION_ABANDON),9.11.37,9.16.38))
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.$(if $(FREETZ_PACKAGE_BIND_VERSION_ABANDON),gz,xz)
$(PKG)_HASH_ABANDON:=0d8efbe7ec166ada90e46add4267b7e7c934790cba9bd5af6b8380a4fbfb5aff
$(PKG)_HASH_CURRENT:=8df44c9d9a84a28ab8b49d55f3c33b624b90ef8f6a8b9ee6a4c33cc17c14c50f
$(PKG)_HASH:=$($(PKG)_HASH_$(if $(FREETZ_PACKAGE_BIND_VERSION_ABANDON),ABANDON,CURRENT))
$(PKG)_SITE:=https://downloads.isc.org/isc/bind9/$($(PKG)_VERSION),http://ftp.isc.org/isc/bind9/$($(PKG)_VERSION)
### WEBSITE:=https://www.isc.org/bind/
### MANPAGE:=https://bind9.readthedocs.io/en/v9_16/
### CHANGES:=https://bind9.readthedocs.io/en/v9_16/notes.html
### CVSREPO:=https://gitlab.isc.org/isc-projects/bind9/

$(PKG)_STARTLEVEL=40 # multid-wrapper may start it earlier!

define $(PKG)_DEFS
$(PKG)_BINARIES_ALL_$(1)            := $(2)
$(PKG)_BINARIES_$(1)                := $$(call PKG_SELECTED_SUBOPTIONS,$$($(PKG)_BINARIES_ALL_$(1)))
$(PKG)_BINARIES_BUILD_DIR_$(1)      := $$(addprefix $$($(PKG)_DIR)/bin/, $$(join $$(addsuffix /,$$($(PKG)_BINARIES_$(1))),$$($(PKG)_BINARIES_$(1))))
$(PKG)_BINARIES_ALL_TARGET_DIR_$(1) := $$($(PKG)_BINARIES_ALL_$(1):%=$$($(PKG)_DEST_DIR)/usr/$(1)/%)
$(PKG)_BINARIES_TARGET_DIR_$(1)     := $$($(PKG)_BINARIES_$(1):%=$$($(PKG)_DEST_DIR)/usr/$(1)/%)
$(PKG)_EXCLUDED                     += $$(filter-out $$($(PKG)_BINARIES_TARGET_DIR_$(1)),$$($(PKG)_BINARIES_ALL_TARGET_DIR_$(1)))
endef

$(eval $(call $(PKG)_DEFS,sbin,named rndc))
$(eval $(call $(PKG)_DEFS,bin,nsupdate dig))

$(PKG)_EXCLUDED+=$(if $(FREETZ_PACKAGE_BIND_NAMED),,usr/lib/bind usr/lib/cgi-bin/bind.cgi etc/default.bind etc/init.d/rc.bind)

$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_IPV6_SUPPORT
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_BIND_VERSION_ABANDON

ifneq ($(strip $(FREETZ_PACKAGE_BIND_VERSION_ABANDON)),y)
$(PKG)_DEPENDS_ON += libatomic libuv openssl libcap
endif

$(PKG)_CONDITIONAL_PATCHES+=$(if $(FREETZ_PACKAGE_BIND_VERSION_ABANDON),abandon,current)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure) 

$(PKG)_CONFIGURE_OPTIONS += BUILD_CC="$(HOSTCC)"
$(PKG)_CONFIGURE_OPTIONS += --disable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
ifeq ($(strip $(FREETZ_PACKAGE_BIND_VERSION_ABANDON)),y)
$(PKG)_CONFIGURE_OPTIONS += --enable-atomic=no
$(PKG)_CONFIGURE_OPTIONS += --without-openssl
endif
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

$(PKG)_MAKE_FLAGS += EXTRA_CFLAGS="-ffunction-sections -fdata-sections" EXTRA_BINARY_LDFLAGS="-Wl,--gc-sections"

$(PKG)_EXPORT_LIB_DIR := $(FREETZ_BASE_DIR)/$(BIND_DIR)/_exportlib


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_DIR)/.compiled: $($(PKG)_DIR)/.configured
	$(SUBMAKE1) -C $(BIND_DIR) $(BIND_MAKE_FLAGS)
	@touch $@

$($(PKG)_EXPORT_LIB_DIR)/.installed: $($(PKG)_DIR)/.compiled
	$(SUBMAKE1) -C $(BIND_DIR)/lib $(BIND_MAKE_FLAGS) \
		DESTDIR=$(BIND_EXPORT_LIB_DIR) \
		install
	@touch $@

$($(PKG)_BINARIES_BUILD_DIR_sbin) $($(PKG)_BINARIES_BUILD_DIR_bin): $($(PKG)_DIR)/.compiled
	@touch -c $@

$(foreach binary,$($(PKG)_BINARIES_BUILD_DIR_sbin),$(eval $(call INSTALL_BINARY_STRIP_RULE,$(binary),/usr/sbin)))
$(foreach binary,$($(PKG)_BINARIES_BUILD_DIR_bin),$(eval $(call INSTALL_BINARY_STRIP_RULE,$(binary),/usr/bin)))

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR_sbin) $($(PKG)_BINARIES_TARGET_DIR_bin) $($(PKG)_EXPORT_LIB_DIR)/.installed


$(pkg)-clean:
	-$(SUBMAKE) -C $(BIND_DIR) clean
	$(RM) -r $(BIND_DIR)/.configured $(BIND_DIR)/.compiled $(BIND_EXPORT_LIB_DIR)/.installed $(BIND_EXPORT_LIB_DIR)

$(pkg)-uninstall:
	$(RM) $(BIND_BINARIES_ALL_TARGET_DIR_sbin) $(BIND_BINARIES_ALL_TARGET_DIR_bin)

$(PKG_FINISH)


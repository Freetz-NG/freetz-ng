$(call PKG_INIT_BIN,1.3.4)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=2fabdadb8ff415a1eafcfb12ab1bf781
$(PKG)_SITE:=@SF/nfs

$(PKG)_CONDITIONAL_PATCHES+=$(if $(or $(FREETZ_TARGET_UCLIBC_0_9_28),$(FREETZ_TARGET_UCLIBC_0_9_29)),uclibc-0.9.28)

$(PKG)_DEPENDS_ON += $(if $(FREETZ_TARGET_UCLIBC_SUPPORTS_rpc),,libtirpc)

$(PKG)_BINARIES            := exportfs mountd nfsd showmount
$(PKG)_BINARIES_BUILD_DIR  := $(addprefix $($(PKG)_DIR)/utils/, $(join $($(PKG)_BINARIES),$(addprefix /,$($(PKG)_BINARIES))))
$(PKG)_BINARIES_TARGET_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/sbin/%)

$(PKG)_DEPENDS_ON += tcp_wrappers

# IPv6 support requires TIRPC
#$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_IPV6_SUPPORT
#ifeq ($(FREETZ_TARGET_IPV6_SUPPORT),y)
#$(PKG)_CONFIGURE_OPTIONS += --enable-ipv6=yes
#else
$(PKG)_CONFIGURE_OPTIONS += --enable-ipv6=no
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_TARGET_UCLIBC_SUPPORTS_rpc),--disable-tirpc,--enable-tirpc)
#endif

$(PKG)_CONFIGURE_ENV += ac_cv_type_getgroups=gid_t
$(PKG)_CONFIGURE_ENV += ac_cv_func_getgroups_works=yes
$(PKG)_CONFIGURE_ENV += ac_cv_func_stat_empty_string_bug=no
$(PKG)_CONFIGURE_ENV += ac_cv_func_lstat_empty_string_bug=no
$(PKG)_CONFIGURE_ENV += ac_cv_func_lstat_dereferences_slashed_symlink=no

$(PKG)_CONFIGURE_OPTIONS += --disable-nfsv4
$(PKG)_CONFIGURE_OPTIONS += --disable-mount
$(PKG)_CONFIGURE_OPTIONS += --disable-gss
$(PKG)_CONFIGURE_OPTIONS += --disable-uuid

ifneq ($(strip $(FREETZ_TARGET_UCLIBC_SUPPORTS_rpc)),y)
$(PKG)_CFLAGS += -I$(TARGET_TOOLCHAIN_STAGING_DIR)/include/tirpc
endif

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(NFS_UTILS_DIR) \
		CFLAGS="$(TARGET_CFLAGS) $(NFS_UTILS_CFLAGS)"

$(foreach binary,$($(PKG)_BINARIES_BUILD_DIR),$(eval $(call INSTALL_BINARY_STRIP_RULE,$(binary),/usr/sbin)))

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(NFS_UTILS_DIR) clean

$(pkg)-uninstall:
	$(RM) $(NFS_UTILS_BINARIES_TARGET_DIR)

$(PKG_FINISH)

$(call PKG_INIT_BIN,1.3.4)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=2fabdadb8ff415a1eafcfb12ab1bf781
$(PKG)_SITE:=@SF/nfs

$(PKG)_CONDITIONAL_PATCHES+=$(if $(or $(FREETZ_TARGET_UCLIBC_0_9_28),$(FREETZ_TARGET_UCLIBC_0_9_29)),uclibc-0.9.28)

$(PKG)_DEPENDS_ON += tcp_wrappers
ifeq ($(FREETZ_TARGET_UCLIBC_SUPPORTS_rpc),y)
	$(PKG)_CONFIGURE_OPTIONS += --disable-tirpc
else
	$(PKG)_DEPENDS_ON += libtirpc
	$(PKG)_CFLAGS += -I$(TARGET_TOOLCHAIN_STAGING_DIR)/include/tirpc
endif

#gss depends on kerberos:
$(PKG)_CONFIGURE_OPTIONS += --disable-gss

ifeq ($(FREETZ_PACKAGE_NFSDv4),y)
	$(PKG)_BINARIES		+=  blkmapd idmapd  nfsdcltrack nfsstat sm-notify statd
	$(PKG)_BINARIES_PATH	+=  blkmapd idmapd  nfsdcltrack nfsstat statd statd
else
	$(PKG)_CONFIGURE_OPTIONS += --disable-nfsv4 --disable-uuid --disable-ipv6
endif

#mount.nfs does not build on a fb 7490 with fw 7.29:
ifeq ($(FREETZ_PACKAGE_NFSDv4plus),y)
	$(PKG)_BINARIES		+= mount.nfs
	$(PKG)_BINARIES_PATH	+= mount 
else
	$(PKG)_CONFIGURE_OPTIONS += --disable-mount
endif

$(PKG)_BINARIES_BUILD_DIR  := $(addprefix $($(PKG)_DIR)/utils/, $(join $($(PKG)_BINARIES_PATH),$(addprefix /,$($(PKG)_BINARIES))))
$(PKG)_BINARIES_TARGET_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/sbin/%)

$(PKG)_CONFIGURE_ENV += ac_cv_type_getgroups=gid_t
$(PKG)_CONFIGURE_ENV += ac_cv_func_getgroups_works=yes
$(PKG)_CONFIGURE_ENV += ac_cv_func_stat_empty_string_bug=no
$(PKG)_CONFIGURE_ENV += ac_cv_func_lstat_empty_string_bug=no
$(PKG)_CONFIGURE_ENV += ac_cv_func_lstat_dereferences_slashed_symlink=no

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

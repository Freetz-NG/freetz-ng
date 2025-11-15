$(call PKG_INIT_BIN, 2017.3.23)
$(PKG)_CATEGORY:=Disk Tools
$(PKG)_LIB_VERSION:=88.0.0
$(PKG)_SOURCE:=ntfs-3g_ntfsprogs-$($(PKG)_VERSION).tgz
$(PKG)_HASH:=3e5a021d7b761261836dcb305370af299793eedbded731df3d6943802e1262d5
$(PKG)_SITE:=http://tuxera.com/opensource

$(PKG)_LIB_BINARY:=$($(PKG)_DIR)/libntfs-3g/.libs/libntfs-3g.so.$($(PKG)_LIB_VERSION)
$(PKG)_LIB_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libntfs-3g.so.$($(PKG)_LIB_VERSION)
$(PKG)_LIB_TARGET_BINARY:=$($(PKG)_TARGET_LIBDIR)/libntfs-3g.so.$($(PKG)_LIB_VERSION)

$(PKG)_BINARIES_ALL := mkntfs ntfscat ntfsclone ntfscluster ntfscmp ntfscp ntfsfix ntfsinfo ntfslabel ntfsls ntfsresize ntfsundelete
$(PKG)_BINARIES := $(call PKG_SELECTED_SUBOPTIONS,$($(PKG)_BINARIES_ALL))
$(PKG)_BINARIES_BUILD_DIR := $($(PKG)_DIR)/src/.libs/ntfs-3g
$(PKG)_BINARIES_BUILD_DIR += $(join $(NTFS_BINARIES:%=$($(PKG)_DIR)/ntfsprogs/.libs/),$(NTFS_BINARIES))
$(PKG)_BINARIES += ntfs-3g
$(PKG)_BINARIES_TARGET_DIR := $(NTFS_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_EXCLUDED += $(patsubst %,$($(PKG)_DEST_DIR)/usr/bin/%,$(filter-out $($(PKG)_BINARIES),$($(PKG)_BINARIES_ALL)))

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --enable-ntfs-3g
$(PKG)_CONFIGURE_OPTIONS += --enable-ntfsprogs
# TODO: enabling extras causes the following extra programs to be compiled
# ntfsck ntfsdump_logfile ntfsmftalloc ntfsmove ntfstruncate ntfswipe
$(PKG)_CONFIGURE_OPTIONS += --disable-extras
$(PKG)_CONFIGURE_OPTIONS += --disable-crypto
$(PKG)_CONFIGURE_OPTIONS += --with-fuse=internal
$(PKG)_CONFIGURE_OPTIONS += --without-uuid

# add EXTRA_(C|LD)FLAGS
$(PKG)_CONFIGURE_PRE_CMDS += $(SED) -i -r -e 's,^(C)FLAGS[ \t]*=[ \t]*@\1FLAGS@,& $$$$(EXTRA_\1FLAGS),' $(abspath $($(PKG)_DIR))/{src,ntfsprogs,libfuse-lite}/Makefile.in;
$(PKG)_CONFIGURE_PRE_CMDS += $(SED) -i -r -e 's,^(LD)FLAGS[ \t]*=[ \t]*@\1FLAGS@,& $$$$(EXTRA_\1FLAGS),' $(abspath $($(PKG)_DIR))/{src,ntfsprogs}/Makefile.in;

$(PKG)_MAKE_FLAGS += ARCH="$(TARGET_ARCH)"
$(PKG)_MAKE_FLAGS += CROSS_COMPILE="$(TARGET_CROSS)"
$(PKG)_MAKE_FLAGS += EXTRA_CFLAGS="-ffunction-sections -fdata-sections"
$(PKG)_MAKE_FLAGS += EXTRA_LDFLAGS="-Wl,--gc-sections"

$(call REPLACE_LIBTOOL)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_LIB_BINARY) $($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(NTFS_DIR) \
		$(NTFS_MAKE_FLAGS) \
		all

$($(PKG)_LIB_STAGING_BINARY): $($(PKG)_LIB_BINARY)
	$(SUBMAKE) -C $(NTFS_DIR)/libntfs-3g \
		$(NTFS_MAKE_FLAGS) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libntfs-3g.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libntfs-3g.pc
	$(SUBMAKE) -C $(NTFS_DIR)/include/ntfs-3g \
		$(NTFS_MAKE_FLAGS) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install

$(foreach binary,$($(PKG)_BINARIES_BUILD_DIR),$(eval $(call INSTALL_BINARY_STRIP_RULE,$(binary),/usr/bin)))

$($(PKG)_LIB_TARGET_BINARY): $($(PKG)_LIB_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_LIB_TARGET_BINARY) $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(NTFS_DIR) $(NTFS_MAKE_FLAGS) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libntfs-3g* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libntfs-3g.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/ntfs-3g

$(pkg)-uninstall:
	$(RM) $(NTFS_BINARIES_ALL:%=$(NTFS_DEST_DIR)/usr/bin/%) $(NTFS_TARGET_LIBDIR)/libntfs-3g.so*

$(call PKG_ADD_LIB,libntfs)
$(PKG_FINISH)

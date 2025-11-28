# Version selection based on Kconfig
$(call PKG_INIT_BIN, $(if $(FREETZ_UTIL_LINUX_VERSION_2_27_1),2.27.1,2.41))
$(PKG)_CATEGORY:=Disk Tools

# Legacy version 2.27.1 (minimal, with patches)
$(PKG)_SOURCE_2.27.1:=util-linux-2.27.1.tar.xz
$(PKG)_HASH_2.27.1:=0a818fcdede99aec43ffe6ca5b5388bff80d162f2f7bd4541dca94fecb87a290
$(PKG)_BINARIES_2.27.1:=blkid
$(PKG)_BINARIES_WITH_SUFFIX_2.27.1:=blkid
$(PKG)_BINARIES_NO_SUFFIX_2.27.1:=

# Modern version 2.41 (full featured, no patches needed)
$(PKG)_SOURCE_2.41:=util-linux-2.41.tar.xz
$(PKG)_HASH_2.41:=81ee93b3cfdfeb7d7c4090cedeba1d7bbce9141fd0b501b686b3fe475ddca4c6

# Build list of selected utilities for version 2.41
$(PKG)_BINARIES_2.41:=
$(PKG)_BINARIES_WITH_SUFFIX_2.41:=
$(PKG)_BINARIES_NO_SUFFIX_2.41:=

# Macro to add a binary conditionally
# $1 = config name (e.g., BLKID)
# $2 = binary name (e.g., blkid)
# $3 = suffix type: "with" or "no"
define UTIL_LINUX_ADD_BINARY
ifeq ($$(strip $$(FREETZ_UTIL_LINUX_$(1))),y)
$$(PKG)_BINARIES_2.41+=$(2)
ifeq ($(3),with)
$$(PKG)_BINARIES_WITH_SUFFIX_2.41+=$(2)
else
$$(PKG)_BINARIES_NO_SUFFIX_2.41+=$(2)
endif
endif
endef

$(eval $(call UTIL_LINUX_ADD_BINARY,BLKID,blkid,with))
$(eval $(call UTIL_LINUX_ADD_BINARY,LOSETUP,losetup,with))
$(eval $(call UTIL_LINUX_ADD_BINARY,MKSWAP,mkswap,with))
$(eval $(call UTIL_LINUX_ADD_BINARY,SWAPON,swapon,with))
$(eval $(call UTIL_LINUX_ADD_BINARY,LSBLK,lsblk,no))
$(eval $(call UTIL_LINUX_ADD_BINARY,FINDMNT,findmnt,no))


# Select version-specific variables
$(PKG)_SOURCE:=$($(PKG)_SOURCE_$($(PKG)_VERSION))
$(PKG)_HASH:=$($(PKG)_HASH_$($(PKG)_VERSION))
$(PKG)_SITE:=@KERNEL/linux/utils/util-linux/v$(call GET_MAJOR_VERSION,$($(PKG)_VERSION))

# Select version-specific patches directory
$(PKG)_CONDITIONAL_PATCHES+=$($(PKG)_VERSION)

### WEBSITE:=https://en.wikipedia.org/wiki/Util-linux
### MANPAGE:=https://linux.die.net/man/8/blkid
### CHANGES:=https://mirrors.kernel.org/pub/linux/utils/util-linux/
### CVSREPO:=https://git.kernel.org/pub/scm/utils/util-linux/util-linux.git

# Binaries configuration per version
$(PKG)_BINARIES:=$($(PKG)_BINARIES_$($(PKG)_VERSION))
$(PKG)_BINARIES_WITH_SUFFIX:=$($(PKG)_BINARIES_WITH_SUFFIX_$($(PKG)_VERSION))
$(PKG)_BINARIES_NO_SUFFIX:=$($(PKG)_BINARIES_NO_SUFFIX_$($(PKG)_VERSION))

# Suffix to add to util-linux binaries that conflict with busybox
$(PKG)_BINARIES_SUFFIX:=-util-linux

$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_WITH_SUFFIX_TARGET_DIR:=$($(PKG)_BINARIES_WITH_SUFFIX:%=$($(PKG)_DEST_DIR)/sbin/%$($(PKG)_BINARIES_SUFFIX))
$(PKG)_BINARIES_NO_SUFFIX_TARGET_DIR:=$($(PKG)_BINARIES_NO_SUFFIX:%=$($(PKG)_DEST_DIR)/sbin/%)

# Version-specific configure commands
ifeq ($(strip $(FREETZ_UTIL_LINUX_VERSION_2_27_1)),y)
$(PKG)_CONFIGURE_PRE_CMDS += $(AUTORECONF)
else
$(PKG)_CONFIGURE_PRE_CMDS += GTKDOCIZE=/bin/true $(AUTORECONF)
endif

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_ENV += scanf_cv_alloc_modifier=no

# Do not build any shared library to
# 1) prevent conflicts with e2fsprogs' ones
# 2) force them to be linked in statically
$(PKG)_CONFIGURE_OPTIONS += --enable-shared=no

$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += --without-libiconv-prefix
$(PKG)_CONFIGURE_OPTIONS += --without-libintl-prefix
$(PKG)_CONFIGURE_OPTIONS += --without-audit
$(PKG)_CONFIGURE_OPTIONS += --without-libz
$(PKG)_CONFIGURE_OPTIONS += --without-python
$(PKG)_CONFIGURE_OPTIONS += --without-readline
$(PKG)_CONFIGURE_OPTIONS += --without-selinux
$(PKG)_CONFIGURE_OPTIONS += --without-slang
$(PKG)_CONFIGURE_OPTIONS += --without-smack
$(PKG)_CONFIGURE_OPTIONS += --without-systemd
$(PKG)_CONFIGURE_OPTIONS += --without-termcap
$(PKG)_CONFIGURE_OPTIONS += --without-udev
$(PKG)_CONFIGURE_OPTIONS += --without-user
$(PKG)_CONFIGURE_OPTIONS += --without-utempter
$(PKG)_CONFIGURE_OPTIONS += --without-util
$(PKG)_CONFIGURE_OPTIONS += --disable-bash-completion
$(PKG)_CONFIGURE_OPTIONS += --disable-colors-default
$(PKG)_CONFIGURE_OPTIONS += --disable-tls

$(PKG)_CONFIGURE_OPTIONS += --disable-agetty
$(PKG)_CONFIGURE_OPTIONS += --disable-bfs
$(PKG)_CONFIGURE_OPTIONS += --disable-cal
$(PKG)_CONFIGURE_OPTIONS += --disable-chfn-chsh
$(PKG)_CONFIGURE_OPTIONS += --disable-cramfs
$(PKG)_CONFIGURE_OPTIONS += --disable-eject
$(PKG)_CONFIGURE_OPTIONS += --disable-fallocate
$(PKG)_CONFIGURE_OPTIONS += --disable-fdformat
$(PKG)_CONFIGURE_OPTIONS += --disable-fsck
$(PKG)_CONFIGURE_OPTIONS += --disable-hwclock
$(PKG)_CONFIGURE_OPTIONS += --disable-kill
$(PKG)_CONFIGURE_OPTIONS += --disable-last
$(PKG)_CONFIGURE_OPTIONS += --disable-libfdisk
$(PKG)_CONFIGURE_OPTIONS += --enable-libmount

# Version-specific options
ifeq ($(strip $(FREETZ_UTIL_LINUX_VERSION_2_27_1)),y)
# Legacy 2.27.1: minimal build
$(PKG)_CONFIGURE_OPTIONS += --disable-libsmartcols
$(PKG)_CONFIGURE_OPTIONS += --disable-losetup
else
# Modern 2.41: enable additional features
ifeq ($(strip $(FREETZ_UTIL_LINUX_LSBLK)),y)
$(PKG)_DEPENDS_ON += ncursesw
$(PKG)_CONFIGURE_OPTIONS += --with-ncursesw
endif
$(PKG)_CONFIGURE_OPTIONS += --disable-gtk-doc
$(PKG)_CONFIGURE_OPTIONS += --disable-year2038
$(PKG)_CONFIGURE_OPTIONS += --disable-liblastlog2
$(PKG)_CONFIGURE_OPTIONS += --enable-libsmartcols
$(PKG)_CONFIGURE_OPTIONS += --enable-losetup
endif

$(PKG)_CONFIGURE_OPTIONS += --disable-line
$(PKG)_CONFIGURE_OPTIONS += --disable-login
$(PKG)_CONFIGURE_OPTIONS += --disable-mesg
$(PKG)_CONFIGURE_OPTIONS += --disable-minix
$(PKG)_CONFIGURE_OPTIONS += --disable-more
$(PKG)_CONFIGURE_OPTIONS += --disable-mount
$(PKG)_CONFIGURE_OPTIONS += --disable-mountpoint
$(PKG)_CONFIGURE_OPTIONS += --disable-newgrp
$(PKG)_CONFIGURE_OPTIONS += --disable-nologin
$(PKG)_CONFIGURE_OPTIONS += --disable-nsenter
$(PKG)_CONFIGURE_OPTIONS += --disable-partx
$(PKG)_CONFIGURE_OPTIONS += --disable-pg
$(PKG)_CONFIGURE_OPTIONS += --disable-pivot_root
$(PKG)_CONFIGURE_OPTIONS += --disable-pylibmount
$(PKG)_CONFIGURE_OPTIONS += --disable-raw
$(PKG)_CONFIGURE_OPTIONS += --disable-rename
$(PKG)_CONFIGURE_OPTIONS += --disable-reset
$(PKG)_CONFIGURE_OPTIONS += --disable-runuser
$(PKG)_CONFIGURE_OPTIONS += --disable-schedutils
$(PKG)_CONFIGURE_OPTIONS += --disable-setpriv
$(PKG)_CONFIGURE_OPTIONS += --disable-setterm
$(PKG)_CONFIGURE_OPTIONS += --disable-su
$(PKG)_CONFIGURE_OPTIONS += --disable-sulogin
$(PKG)_CONFIGURE_OPTIONS += --disable-switch_root
$(PKG)_CONFIGURE_OPTIONS += --disable-tls
$(PKG)_CONFIGURE_OPTIONS += --disable-tunelp
$(PKG)_CONFIGURE_OPTIONS += --disable-ul
$(PKG)_CONFIGURE_OPTIONS += --disable-unshare
$(PKG)_CONFIGURE_OPTIONS += --disable-utmpdump
$(PKG)_CONFIGURE_OPTIONS += --disable-uuidd
$(PKG)_CONFIGURE_OPTIONS += --disable-vipw
$(PKG)_CONFIGURE_OPTIONS += --disable-wall
$(PKG)_CONFIGURE_OPTIONS += --disable-wdctl
$(PKG)_CONFIGURE_OPTIONS += --disable-write
$(PKG)_CONFIGURE_OPTIONS += --disable-zramctl

$(PKG)_CONFIGURE_OPTIONS += --enable-libuuid
$(PKG)_CONFIGURE_OPTIONS += --enable-libblkid


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(UTIL_LINUX_DIR) V=1 $(UTIL_LINUX_BINARIES)

# Install binaries with suffix (those that conflict with busybox)
ifneq ($(strip $($(PKG)_BINARIES_WITH_SUFFIX)),)
$($(PKG)_BINARIES_WITH_SUFFIX_TARGET_DIR): $($(PKG)_DEST_DIR)/sbin/%$($(PKG)_BINARIES_SUFFIX): $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)
endif

# Install binaries without suffix (unique to util-linux)
ifneq ($(strip $($(PKG)_BINARIES_NO_SUFFIX)),)
$($(PKG)_BINARIES_NO_SUFFIX_TARGET_DIR): $($(PKG)_DEST_DIR)/sbin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)
endif

# Create swapoff symlink to swapon (only for version 2.41)
ifeq ($(strip $(FREETZ_UTIL_LINUX_VERSION_2_41)),y)
$($(PKG)_DEST_DIR)/sbin/swapoff$($(PKG)_BINARIES_SUFFIX): $($(PKG)_DEST_DIR)/sbin/swapon$($(PKG)_BINARIES_SUFFIX)
	ln -sf $(notdir $<) $@

$(pkg)-precompiled: $($(PKG)_BINARIES_WITH_SUFFIX_TARGET_DIR) $($(PKG)_BINARIES_NO_SUFFIX_TARGET_DIR) $($(PKG)_DEST_DIR)/sbin/swapoff$($(PKG)_BINARIES_SUFFIX)

$(pkg)-uninstall:
	$(RM) $(UTIL_LINUX_BINARIES_WITH_SUFFIX_TARGET_DIR) $(UTIL_LINUX_BINARIES_NO_SUFFIX_TARGET_DIR)
	$(RM) $(UTIL_LINUX_DEST_DIR)/sbin/swapoff$(UTIL_LINUX_BINARIES_SUFFIX)
else
$(pkg)-precompiled: $($(PKG)_BINARIES_WITH_SUFFIX_TARGET_DIR) $($(PKG)_BINARIES_NO_SUFFIX_TARGET_DIR)

$(pkg)-uninstall:
	$(RM) $(UTIL_LINUX_BINARIES_WITH_SUFFIX_TARGET_DIR) $(UTIL_LINUX_BINARIES_NO_SUFFIX_TARGET_DIR)
endif

$(pkg):

$(pkg)-clean:
	-$(SUBMAKE1) -C $(UTIL_LINUX_DIR) clean
	$(RM) $(UTIL_LINUX_DIR)/.configured

$(PKG_FINISH)

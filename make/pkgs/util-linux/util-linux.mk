$(call PKG_INIT_BIN, 2.27.1)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=0a818fcdede99aec43ffe6ca5b5388bff80d162f2f7bd4541dca94fecb87a290
$(PKG)_SITE:=@KERNEL/linux/utils/$(pkg)/v$(call GET_MAJOR_VERSION,$($(PKG)_VERSION))
### WEBSITE:=https://en.wikipedia.org/wiki/Util-linux
### MANPAGE:=https://linux.die.net/man/8/blkid
### CHANGES:=https://mirrors.kernel.org/pub/linux/utils/util-linux/
### CVSREPO:=https://git.kernel.org/pub/scm/utils/util-linux/util-linux.git

# Binaries that conflict with busybox (need suffix)
$(PKG)_BINARIES_WITH_SUFFIX:=blkid losetup mkswap swapon
# Binaries unique to util-linux (no suffix needed)
$(PKG)_BINARIES_NO_SUFFIX:=lsblk findmnt
# All binaries to build
$(PKG)_BINARIES:=$($(PKG)_BINARIES_WITH_SUFFIX) $($(PKG)_BINARIES_NO_SUFFIX)

# Suffix to add to util-linux binaries that conflict with busybox
$(PKG)_BINARIES_SUFFIX:=-util-linux

$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_WITH_SUFFIX_TARGET_DIR:=$($(PKG)_BINARIES_WITH_SUFFIX:%=$($(PKG)_DEST_DIR)/sbin/%$($(PKG)_BINARIES_SUFFIX))
$(PKG)_BINARIES_NO_SUFFIX_TARGET_DIR:=$($(PKG)_BINARIES_NO_SUFFIX:%=$($(PKG)_DEST_DIR)/sbin/%)

$(PKG)_CONFIGURE_PRE_CMDS += GTKDOCIZE=/bin/true $(AUTORECONF)
$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_ENV += scanf_cv_alloc_modifier=no

# Do not build any shared library to
# 1) prevent conflicts with e2fsprogs' ones
# 2) force them to be linked in statically
$(PKG)_CONFIGURE_OPTIONS += --enable-shared=no

$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += --disable-gtk-doc
$(PKG)_CONFIGURE_OPTIONS += --without-libiconv-prefix
$(PKG)_CONFIGURE_OPTIONS += --without-libintl-prefix
$(PKG)_CONFIGURE_OPTIONS += --without-audit
$(PKG)_CONFIGURE_OPTIONS += --without-libz
$(PKG)_CONFIGURE_OPTIONS += --without-ncurses
$(PKG)_CONFIGURE_OPTIONS += --without-python
$(PKG)_CONFIGURE_OPTIONS += --without-readline
$(PKG)_CONFIGURE_OPTIONS += --without-selinux
$(PKG)_CONFIGURE_OPTIONS += --without-slang
$(PKG)_CONFIGURE_OPTIONS += --without-smack
$(PKG)_CONFIGURE_OPTIONS += --without-systemd
$(PKG)_CONFIGURE_OPTIONS += --without-termcap
$(PKG)_CONFIGURE_OPTIONS += --without-tinfo
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
$(PKG)_CONFIGURE_OPTIONS += --enable-libsmartcols

$(PKG)_CONFIGURE_OPTIONS += --disable-line
$(PKG)_CONFIGURE_OPTIONS += --disable-login
$(PKG)_CONFIGURE_OPTIONS += --enable-losetup
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
$($(PKG)_BINARIES_WITH_SUFFIX_TARGET_DIR): $($(PKG)_DEST_DIR)/sbin/%$($(PKG)_BINARIES_SUFFIX): $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

# Install binaries without suffix (unique to util-linux)
$($(PKG)_BINARIES_NO_SUFFIX_TARGET_DIR): $($(PKG)_DEST_DIR)/sbin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

# Create swapoff symlink to swapon
$($(PKG)_DEST_DIR)/sbin/swapoff$($(PKG)_BINARIES_SUFFIX): $($(PKG)_DEST_DIR)/sbin/swapon$($(PKG)_BINARIES_SUFFIX)
	ln -sf swapon$($(PKG)_BINARIES_SUFFIX) $@

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_WITH_SUFFIX_TARGET_DIR) $($(PKG)_BINARIES_NO_SUFFIX_TARGET_DIR) $($(PKG)_DEST_DIR)/sbin/swapoff$($(PKG)_BINARIES_SUFFIX)


$(pkg)-clean:
	-$(SUBMAKE1) -C $(UTIL_LINUX_DIR) clean
	$(RM) $(UTIL_LINUX_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(UTIL_LINUX_BINARIES_WITH_SUFFIX_TARGET_DIR) $(UTIL_LINUX_BINARIES_NO_SUFFIX_TARGET_DIR)
	$(RM) $(UTIL_LINUX_DEST_DIR)/sbin/swapoff$(UTIL_LINUX_BINARIES_SUFFIX)

$(PKG_FINISH)

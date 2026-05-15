$(call TOOLS_INIT, 2.42)
$(PKG)_SOURCE:=$(pkg_short)-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=3452b260bbaa775d6e749ac3bb22111785003fc1f444970025c8da26dfa758e9
$(PKG)_SITE:=@KERNEL/linux/utils/util-linux/v$(call GET_MAJOR_VERSION,$($(PKG)_VERSION))
### WEBSITE:=https://en.wikipedia.org/wiki/Util-linux
### MANPAGE:=https://linux.die.net/man/1/uuidgen
### CHANGES:=https://github.com/util-linux/util-linux/tags
### CVSREPO:=https://github.com/util-linux/util-linux
### STEWARD:=fda77

$(PKG)_BINARIES:=uuidgen
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$(TOOLS_DIR)/%)

$(PKG)_CONFIGURE_OPTIONS += --enable-uuidgen
$(PKG)_CONFIGURE_OPTIONS += --enable-libuuid
$(PKG)_CONFIGURE_OPTIONS += --disable-all-programs
$(PKG)_CONFIGURE_OPTIONS += --disable-shared
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += --disable-asciidoc
$(PKG)_CONFIGURE_OPTIONS += --disable-poman
$(PKG)_CONFIGURE_OPTIONS += --disable-liblastlog2
$(PKG)_CONFIGURE_OPTIONS += --disable-pam-lastlog2
$(PKG)_CONFIGURE_OPTIONS += --disable-libblkid
$(PKG)_CONFIGURE_OPTIONS += --disable-libmount
$(PKG)_CONFIGURE_OPTIONS += --disable-libsmartcols
$(PKG)_CONFIGURE_OPTIONS += --disable-libfdisk
$(PKG)_CONFIGURE_OPTIONS += --disable-fdisks
$(PKG)_CONFIGURE_OPTIONS += --disable-mount
$(PKG)_CONFIGURE_OPTIONS += --disable-losetup
$(PKG)_CONFIGURE_OPTIONS += --disable-zramctl
$(PKG)_CONFIGURE_OPTIONS += --disable-fsck
$(PKG)_CONFIGURE_OPTIONS += --disable-partx
$(PKG)_CONFIGURE_OPTIONS += --disable-uuidd
$(PKG)_CONFIGURE_OPTIONS += --disable-blkid
$(PKG)_CONFIGURE_OPTIONS += --disable-wipefs
$(PKG)_CONFIGURE_OPTIONS += --disable-mountpoint
$(PKG)_CONFIGURE_OPTIONS += --disable-fallocate
$(PKG)_CONFIGURE_OPTIONS += --disable-unshare
$(PKG)_CONFIGURE_OPTIONS += --disable-nsenter
$(PKG)_CONFIGURE_OPTIONS += --disable-setpriv
$(PKG)_CONFIGURE_OPTIONS += --disable-hardlink
$(PKG)_CONFIGURE_OPTIONS += --disable-eject
$(PKG)_CONFIGURE_OPTIONS += --disable-agetty
$(PKG)_CONFIGURE_OPTIONS += --disable-plymouth_support
$(PKG)_CONFIGURE_OPTIONS += --disable-cramfs
$(PKG)_CONFIGURE_OPTIONS += --disable-bfs
$(PKG)_CONFIGURE_OPTIONS += --disable-minix
$(PKG)_CONFIGURE_OPTIONS += --disable-fdformat
$(PKG)_CONFIGURE_OPTIONS += --disable-hwclock
$(PKG)_CONFIGURE_OPTIONS += --disable-hwclock-cmos
$(PKG)_CONFIGURE_OPTIONS += --disable-hwclock-gplv3
$(PKG)_CONFIGURE_OPTIONS += --disable-mkfs
$(PKG)_CONFIGURE_OPTIONS += --disable-fstrim
$(PKG)_CONFIGURE_OPTIONS += --disable-swapon
$(PKG)_CONFIGURE_OPTIONS += --disable-lsblk
$(PKG)_CONFIGURE_OPTIONS += --disable-lscpu
$(PKG)_CONFIGURE_OPTIONS += --disable-lsfd
$(PKG)_CONFIGURE_OPTIONS += --disable-lslogins
$(PKG)_CONFIGURE_OPTIONS += --disable-wdctl
$(PKG)_CONFIGURE_OPTIONS += --disable-cal
$(PKG)_CONFIGURE_OPTIONS += --disable-logger
$(PKG)_CONFIGURE_OPTIONS += --disable-whereis
$(PKG)_CONFIGURE_OPTIONS += --disable-pipesz
$(PKG)_CONFIGURE_OPTIONS += --disable-waitpid
$(PKG)_CONFIGURE_OPTIONS += --disable-enosys
$(PKG)_CONFIGURE_OPTIONS += --disable-switch_root
$(PKG)_CONFIGURE_OPTIONS += --disable-pivot_root
$(PKG)_CONFIGURE_OPTIONS += --disable-lsmem
$(PKG)_CONFIGURE_OPTIONS += --disable-chmem
$(PKG)_CONFIGURE_OPTIONS += --disable-ipcmk
$(PKG)_CONFIGURE_OPTIONS += --disable-ipcrm
$(PKG)_CONFIGURE_OPTIONS += --disable-ipcs
$(PKG)_CONFIGURE_OPTIONS += --disable-irqtop
$(PKG)_CONFIGURE_OPTIONS += --disable-lsirq
$(PKG)_CONFIGURE_OPTIONS += --disable-lsns
$(PKG)_CONFIGURE_OPTIONS += --disable-rfkill
$(PKG)_CONFIGURE_OPTIONS += --disable-dmesg
$(PKG)_CONFIGURE_OPTIONS += --disable-exch
$(PKG)_CONFIGURE_OPTIONS += --disable-scriptutils
$(PKG)_CONFIGURE_OPTIONS += --disable-bits
$(PKG)_CONFIGURE_OPTIONS += --disable-hexdump
$(PKG)_CONFIGURE_OPTIONS += --disable-tunelp
$(PKG)_CONFIGURE_OPTIONS += --disable-kill
$(PKG)_CONFIGURE_OPTIONS += --disable-getino
$(PKG)_CONFIGURE_OPTIONS += --disable-last
$(PKG)_CONFIGURE_OPTIONS += --disable-utmpdump
$(PKG)_CONFIGURE_OPTIONS += --disable-line
$(PKG)_CONFIGURE_OPTIONS += --disable-mesg
$(PKG)_CONFIGURE_OPTIONS += --disable-raw
$(PKG)_CONFIGURE_OPTIONS += --disable-rename
$(PKG)_CONFIGURE_OPTIONS += --disable-vipw
$(PKG)_CONFIGURE_OPTIONS += --disable-newgrp
$(PKG)_CONFIGURE_OPTIONS += --disable-chfn-chsh
$(PKG)_CONFIGURE_OPTIONS += --disable-login
$(PKG)_CONFIGURE_OPTIONS += --disable-nologin
$(PKG)_CONFIGURE_OPTIONS += --disable-sulogin
$(PKG)_CONFIGURE_OPTIONS += --disable-su
$(PKG)_CONFIGURE_OPTIONS += --disable-runuser
$(PKG)_CONFIGURE_OPTIONS += --disable-ul
$(PKG)_CONFIGURE_OPTIONS += --disable-more
$(PKG)_CONFIGURE_OPTIONS += --disable-pg
$(PKG)_CONFIGURE_OPTIONS += --disable-setterm
$(PKG)_CONFIGURE_OPTIONS += --disable-schedutils
$(PKG)_CONFIGURE_OPTIONS += --disable-wall
$(PKG)_CONFIGURE_OPTIONS += --disable-write
$(PKG)_CONFIGURE_OPTIONS += --disable-copyfilerange
$(PKG)_CONFIGURE_OPTIONS += --disable-bash-completion
$(PKG)_CONFIGURE_OPTIONS += --disable-pylibmount
$(PKG)_CONFIGURE_OPTIONS += --disable-pg-bell
$(PKG)_CONFIGURE_OPTIONS += --without-libiconv-prefix
$(PKG)_CONFIGURE_OPTIONS += --without-libintl-prefix
$(PKG)_CONFIGURE_OPTIONS += --without-util
$(PKG)_CONFIGURE_OPTIONS += --without-selinux
$(PKG)_CONFIGURE_OPTIONS += --without-audit
$(PKG)_CONFIGURE_OPTIONS += --without-udev
$(PKG)_CONFIGURE_OPTIONS += --without-ncursesw
$(PKG)_CONFIGURE_OPTIONS += --without-ncurses
$(PKG)_CONFIGURE_OPTIONS += --without-slang
$(PKG)_CONFIGURE_OPTIONS += --without-tinfo
$(PKG)_CONFIGURE_OPTIONS += --without-readline
$(PKG)_CONFIGURE_OPTIONS += --without-utempter
$(PKG)_CONFIGURE_OPTIONS += --without-cap-ng
$(PKG)_CONFIGURE_OPTIONS += --without-libz
$(PKG)_CONFIGURE_OPTIONS += --without-libmagic
$(PKG)_CONFIGURE_OPTIONS += --without-user
$(PKG)_CONFIGURE_OPTIONS += --without-btrfs
$(PKG)_CONFIGURE_OPTIONS += --without-systemd
$(PKG)_CONFIGURE_OPTIONS += --without-smack
$(PKG)_CONFIGURE_OPTIONS += --without-econf
$(PKG)_CONFIGURE_OPTIONS += --without-vendordir
$(PKG)_CONFIGURE_OPTIONS += --without-bashcompletiondir
$(PKG)_CONFIGURE_OPTIONS += --without-python
$(PKG)_CONFIGURE_OPTIONS += --without-cryptsetup


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(TOOLS_SUBMAKE) -C $(UTIL_LINUX_HOST_DIR) $(UTIL_LINUX_HOST_BINARIES)

$($(PKG)_BINARIES_TARGET_DIR): $(TOOLS_DIR)/%: $($(PKG)_DIR)/%
	$(INSTALL_FILE)

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)


$(pkg)-clean:
	-$(MAKE) -C $(UTIL_LINUX_HOST_DIR) clean
	$(RM) $(UTIL_LINUX_HOST_DIR)/.configured

$(pkg)-dirclean:
	$(RM) -r $(UTIL_LINUX_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) $(UTIL_LINUX_HOST_BINARIES_TARGET_DIR)

$(TOOLS_FINISH)

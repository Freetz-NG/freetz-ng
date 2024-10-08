$(call PKG_INIT_BIN, 4.89)
$(PKG)_SOURCE:=lsof_$($(PKG)_VERSION)_src.tar.xz
$(PKG)_HASH:=d1cd7530d293c79a2b3476a9ed8568da6d7ec7995139bf73b54bc8aa079a0c6c
$(PKG)_SITE:=ftp://lsof.itap.purdue.edu/pub/tools/unix/lsof,https://people.freebsd.org/~abe
### WEBSITE:=https://people.freebsd.org/~abe/
### MANPAGE:=https://lsof.readthedocs.io/
### CHANGES:=https://github.com/lsof-org/lsof/releases
### CVSREPO:=https://github.com/lsof-org/lsof

$(PKG)_BINARY:=$($(PKG)_DIR)/lsof
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/lsof
$(PKG)_CATEGORY:=Debug helpers

$(PKG)_DEPENDS_ON += wget-host

$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_IPV6_SUPPORT
ifeq ($(FREETZ_TARGET_IPV6_SUPPORT),y)
$(PKG)_HASIPV6 := Y
endif

$(PKG)_PATCH_PRE_CMDS += chmod -R u+w .;
$(PKG)_CONFIGURE_PRE_CMDS += ln -s Configure configure;

$(PKG)_CONFIGURE_DEFOPTS := n
$(PKG)_CONFIGURE_ENV += DEBUG="$(TARGET_CFLAGS)"
$(PKG)_CONFIGURE_ENV += LSOF_CC="$(TARGET_CC)"
$(PKG)_CONFIGURE_ENV += LSOF_AR="$(TARGET_AR) cr"
$(PKG)_CONFIGURE_ENV += LSOF_RANLIB="$(TARGET_RANLIB)"
$(PKG)_CONFIGURE_ENV += LSOF_CCV="$(FREETZ_TARGET_GCC_VERSION)"
$(PKG)_CONFIGURE_ENV += LSOF_TSTBIGF="$(TARGET_CFLAGS_LFS)"
$(PKG)_CONFIGURE_ENV += LINUX_HASIPV6="$(LSOF_HASIPV6)"
$(PKG)_CONFIGURE_ENV += LINUX_HASSELINUX="N"
$(PKG)_CONFIGURE_ENV += LINUX_CLIB="-DGLIBCV=2"
$(PKG)_CONFIGURE_ENV += LINUX_INCL="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include"
$(PKG)_CONFIGURE_ENV += LSOF_INCLUDE="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include"
$(PKG)_CONFIGURE_ENV += LSOF_VSTR="$(KERNEL_VERSION_MAJOR)"
$(PKG)_CONFIGURE_OPTIONS += -n linux


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LSOF_DIR) \
		DEBUG="$(TARGET_CFLAGS)" \
		LSOF_HOST="none" \
		LSOF_LOGNAME="none" \
		LSOF_SYSINFO="none" \
		LSOF_USER="none"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(LSOF_DIR) clean

$(pkg)-uninstall:
	$(RM) $(LSOF_TARGET_BINARY)

$(PKG_FINISH)

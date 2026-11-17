$(call PKG_INIT_BIN, $(if $(FREETZ_PACKAGE_AUTOFS_ABANDON),5.0.5,5.2.0))
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH_ABANDON:=9cdfb2433524ba798e9aebeb3a613931627aa4ba579466985599295e05c20205
$(PKG)_HASH_CURRENT:=131a642acbb9fe98a41fb52b05adc979e9094e025dd18a1ae7bef00ca72351b0
$(PKG)_HASH:=$($(PKG)_HASH_$(if $(FREETZ_PACKAGE_AUTOFS_ABANDON),ABANDON,CURRENT))
$(PKG)_SITE:=@KERNEL/linux/daemons/$(pkg)/v5
### WEBSITE:=https://docs.kernel.org/filesystems/autofs.html
### MANPAGE:=https://github.com/torvalds/linux/blob/master/Documentation/filesystems/autofs-mount-control.rst
### CHANGES:=https://mirrors.edge.kernel.org/pub/linux/daemons/autofs/v5/
### CVSREPO:=https://github.com/torvalds/linux/tree/master/fs/autofs
### STEWARD:=fda77

$(PKG)_STARTLEVEL=50

$(PKG)_DEPENDS_ON += $(if $(FREETZ_TARGET_UCLIBC_SUPPORTS_rpc),,libtirpc)

$(PKG)_CONDITIONAL_PATCHES+=$(if $(FREETZ_PACKAGE_AUTOFS_ABANDON),abandon,current)

$(PKG)_BINARY:=$($(PKG)_DIR)/daemon/automount
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/automount

$(PKG)_LIBRARY:=$($(PKG)_DIR)/lib/libautofs.so
$(PKG)_TARGET_LIBRARY:=$($(PKG)_DEST_LIBDIR)/libautofs.so

ifneq ($(FREETZ_PACKAGE_AUTOFS_ABANDON),y)
$(PKG)_CONFIGURE_ENV += ac_cv_path_UMOUNT=/bin/umount
$(PKG)_CONFIGURE_ENV += ac_cv_path_MOUNT=/bin/mount
$(PKG)_CONFIGURE_ENV += ac_cv_path_MOUNT_NFS=
$(PKG)_CONFIGURE_ENV += ac_cv_path_E2FSCK=
$(PKG)_CONFIGURE_ENV += ac_cv_path_E3FSCK=
$(PKG)_CONFIGURE_ENV += ac_cv_path_E4FSCK=
$(PKG)_CONFIGURE_ENV += ac_cv_linux_procfs=yes

$(PKG)_CONFIGURE_ENV += ac_cv_path_KRB5_CONFIG=no
$(PKG)_CONFIGURE_ENV += ac_cv_path_XML_CONFIG=no
$(PKG)_CONFIGURE_ENV += ac_cv_header_rpcsvc_nis_h=no
$(PKG)_CONFIGURE_ENV += ac_cv_header_rpcsvc_ypclnt_h=no
$(PKG)_CONFIGURE_ENV += ac_cv_lib_nsl_yp_match=no

$(PKG)_CONFIGURE_OPTIONS += --with-mapdir=/etc
$(PKG)_CONFIGURE_OPTIONS += --with-fifodir=/var/run/automount
$(PKG)_CONFIGURE_OPTIONS += --with-flagdir=/var/run/automount
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_TARGET_UCLIBC_SUPPORTS_rpc),--without-libtirpc,--with-libtirpc)
$(PKG)_CONFIGURE_OPTIONS += --without-dmalloc
$(PKG)_CONFIGURE_OPTIONS += --without-systemd
$(PKG)_CONFIGURE_OPTIONS += --without-hesiod
$(PKG)_CONFIGURE_OPTIONS += --without-openldap
$(PKG)_CONFIGURE_OPTIONS += --without-sasl
$(PKG)_CONFIGURE_OPTIONS += --without-systemd
$(PKG)_CONFIGURE_OPTIONS += --disable-sloppy-mount
$(PKG)_CONFIGURE_OPTIONS += --disable-ext-env
endif

ifneq ($(strip $(FREETZ_TARGET_UCLIBC_SUPPORTS_rpc)),y)
$(PKG)_CFLAGS += -I$(TARGET_TOOLCHAIN_STAGING_DIR)/include/tirpc
endif
$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_UCLIBC_SUPPORTS_rpc
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_AUTOFS_ABANDON

$(PKG)_MODULES := \
	$(if $(FREETZ_PACKAGE_AUTOFS_ABANDON),,lookup_dir.so) \
	lookup_file.so \
	lookup_hosts.so \
	lookup_multi.so \
	lookup_program.so \
	lookup_userhome.so \
	mount_afs.so \
	mount_autofs.so \
	mount_bind.so \
	mount_changer.so \
	mount_generic.so \
	mount_nfs.so \
	$(if $(FREETZ_PACKAGE_AUTOFS_ABANDON),,parse_amd.so) \
	parse_sun.so
$(PKG)_MODULES_BUILD_DIR := $($(PKG)_MODULES:%=$($(PKG)_DIR)/modules/%)
$(PKG)_MODULES_TARGET_DIR := $($(PKG)_MODULES:%=$($(PKG)_DEST_LIBDIR)/autofs/%)


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
ifeq ($(FREETZ_PACKAGE_AUTOFS_ABANDON),y)
$(PKG_CONFIGURED_NOP)
else
$(PKG_CONFIGURED_CONFIGURE)
endif

$($(PKG)_BINARY) $($(PKG)_LIBRARY) $($(PKG)_MODULES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE1) -C $(AUTOFS_DIR) \
		FREETZ=1 \
		CC="$(TARGET_CC)" \
		AUTOFS_CFLAGS="$(TARGET_CFLAGS) $(AUTOFS_CFLAGS)" \
		autofslibdir=$(FREETZ_LIBRARY_DIR)/autofs \
		daemon

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_TARGET_LIBRARY): $($(PKG)_LIBRARY)
	$(INSTALL_LIBRARY_STRIP)

$($(PKG)_MODULES_TARGET_DIR): $($(PKG)_DEST_LIBDIR)/autofs/%: $($(PKG)_DIR)/modules/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $(if $(FREETZ_PACKAGE_AUTOFS_ABANDON),,$($(PKG)_TARGET_LIBRARY)) $($(PKG)_MODULES_TARGET_DIR)


$(pkg)-clean:
	-$(SUBMAKE) -C $(AUTOFS_DIR) clean
	$(RM) $(AUTOFS_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(AUTOFS_TARGET_BINARY) $(AUTOFS_TARGET_LIBRARY) $(AUTOFS_MODULES_TARGET_DIR)

$(PKG_FINISH)

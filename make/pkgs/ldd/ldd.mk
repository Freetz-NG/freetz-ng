$(call PKG_INIT_BIN, $(if $(FREETZ_PACKAGE_LDD_VERSION_ABANDON),0.1,1.0.56))
$(PKG)_SOURCE_ABANDON:=ldd-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_CURRENT:=uClibc-ng-$($(PKG)_VERSION).tar.xz
$(PKG)_SOURCE:=$($(PKG)_SOURCE_$(if $(FREETZ_PACKAGE_LDD_VERSION_ABANDON),ABANDON,CURRENT))
$(PKG)_HASH_ABANDON:=b0b2c4edee81ac65c9706f8982b15d3a798be7c2d3865d9a7abff1e493dfadb1
$(PKG)_HASH_CURRENT:=23c9cab54c113e020fb20b9dc06be4a49560df791b78fcbc2ca899a6e8f213dd
$(PKG)_HASH:=$($(PKG)_HASH_$(if $(FREETZ_PACKAGE_LDD_VERSION_ABANDON),ABANDON,CURRENT))
$(PKG)_SITE_ABANDON:=@MIRROR/
$(PKG)_SITE_CURRENT:=https://downloads.uclibc-ng.org/releases/$($(PKG)_VERSION)
$(PKG)_SITE:=$($(PKG)_SITE_$(if $(FREETZ_PACKAGE_LDD_VERSION_ABANDON),ABANDON,CURRENT))
### WEBSITE:=https://uclibc-ng.org/
### CHANGES:=https://cgit.uclibc-ng.org/cgi/cgit/uclibc-ng.git/log/utils/ldd.c
### CVSREPO:=https://github.com/wbx-github/uclibc-ng

$(PKG)_SOURCE_FILE:=$($(PKG)_DIR)/$(if $(FREETZ_PACKAGE_LDD_VERSION_ABANDON),,utils/)ldd.c
$(PKG)_BINARY:=$($(PKG)_DIR)/ldd
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/ldd
$(PKG)_CATEGORY:=Debug helpers

$(PKG)_CONDITIONAL_PATCHES+=$(if $(FREETZ_PACKAGE_LDD_VERSION_ABANDON),abandon,current)


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(TARGET_CONFIGURE_ENV) $(FREETZ_LD_RUN_PATH) \
		$(TARGET_CC) \
		$(TARGET_CFLAGS) \
		-DUCLIBC_RUNTIME_PREFIX=\"/\" \
		$(LDD_SOURCE_FILE) -o $@ \
		$(SILENT)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(LDD_DIR) clean

$(pkg)-uninstall:
	$(RM) $(LDD_TARGET_BINARY)

$(PKG_FINISH)

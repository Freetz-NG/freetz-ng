
$(call PKG_INIT_BIN, 3.1.1)
$(PKG)_SOURCE_DOWNLOAD_NAME:=$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=c5d623ac0af400e83cd676aefaf045228f60e9fc597fea5db4c3a5bd7f6bfcf4
$(PKG)_SITE:=https://github.com/acmesh-official/acme.sh/archive/refs/tags
### WEBSITE:=https://www.acme.sh
### MANPAGE:=https://github.com/acmesh-official/acme.sh/wiki
### CHANGES:=https://github.com/acmesh-official/acme.sh/releases
### CVSREPO:=https://github.com/acmesh-official/acme.sh
### SUPPORT:=fda77

$(PKG)_ALL_ADDS:=deploy dnsapi notify acme.sh
$(PKG)_ADDS:=$(addprefix $($(PKG)_DIR)/,$($(PKG)_ALL_ADDS))
$(PKG)_TARGET_ADDS:=$(addprefix $($(PKG)_DEST_DIR)/usr/bin/acme/,$($(PKG)_ALL_ADDS))
$(PKG)_TARGET_LINK:=$($(PKG)_DEST_DIR)/usr/bin/acme.sh

$(PKG)_EXCLUDED += $(if $(FREETZ_PACKAGE_ACME_deploy),,usr/bin/acme/deploy)
$(PKG)_EXCLUDED += $(if $(FREETZ_PACKAGE_ACME_dnsapi),,usr/bin/acme/dnsapi)
$(PKG)_EXCLUDED += $(if $(FREETZ_PACKAGE_ACME_notify),,usr/bin/acme/notify)


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)


$($(PKG)_TARGET_LINK):
	ln -s acme/acme.sh $@

$($(PKG)_ADDS): $($(PKG)_DIR)/.unpacked

$($(PKG)_TARGET_ADDS): $($(PKG)_DEST_DIR)/usr/bin/acme/%: $($(PKG)_DIR)/%
	$(INSTALL_DIR)


$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_ADDS) $($(PKG)_TARGET_LINK)

$(pkg)-clean:

$(pkg)-uninstall:
	$(RM) $(ACME_TARGET_LINK)
	$(RM) -r $(ACME_DEST_DIR)/usr/bin/acme/

$(PKG_FINISH)


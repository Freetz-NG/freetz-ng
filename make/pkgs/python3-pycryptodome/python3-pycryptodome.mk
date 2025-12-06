$(call PKG_INIT_BIN, 3.23.0)
$(PKG)_SOURCE:=pycryptodome-py3-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_DOWNLOAD_NAME:=pycryptodome-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=https://files.pythonhosted.org/packages/source/p/pycryptodome
$(PKG)_HASH:=447700a657182d60338bab09fdb27518f8856aecd80ae4c6bdddb67ff5da44ef
### WEBSITE:=https://www.pycryptodome.org/
### MANPAGE:=https://www.pycryptodome.org/src/api
### CHANGES:=https://www.pycryptodome.org/src/changelog
### CVSREPO:=https://github.com/Legrandin/pycryptodome/

$(PKG)_DEPENDS_ON += python3
$(PKG)_DEPENDS_ON += python3-setuptools-host

$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)$(PYTHON3_SITE_PKG_DIR)/Crypto/__init__.py

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_TARGET_BINARY): $($(PKG)_DIR)/.configured
	$(call Build/PyMod3/PKG, PYTHON3_PYCRYPTODOME, , )

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	$(RM) $(PYTHON3_PYCRYPTODOME_DIR)/.configured
	$(RM) -r $(PYTHON3_PYCRYPTODOME_DIR)/build

$(pkg)-uninstall:
	$(RM) -r \
		$(PYTHON3_PYCRYPTODOME_DEST_DIR)$(PYTHON3_SITE_PKG_DIR)/Crypto \
		$(PYTHON3_PYCRYPTODOME_DEST_DIR)$(PYTHON3_SITE_PKG_DIR)/pycryptodome-*.egg-info

$(PKG_FINISH)

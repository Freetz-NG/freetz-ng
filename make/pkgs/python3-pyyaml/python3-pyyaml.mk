$(call PKG_INIT_BIN, 6.0.2)
$(PKG)_SOURCE:=pyyaml-py3-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_DOWNLOAD_NAME:=pyyaml-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=https://files.pythonhosted.org/packages/54/ed/79a089b6be93607fa5cdaedf301d7dfb23af5f25c398d5ead2525b063e17
$(PKG)_HASH:=d584d9ec91ad65861cc08d42e834324ef890a082e591037abe114850ff7bbc3e
### WEBSITE:=https://pyyaml.org/
### MANPAGE:=https://pyyaml.org/wiki/PyYAMLDocumentation
### CHANGES:=https://github.com/yaml/pyyaml/blob/main/CHANGES
### CVSREPO:=https://github.com/yaml/pyyaml

$(PKG)_DEPENDS_ON += python3
$(PKG)_DEPENDS_ON += python3-setuptools-host
$(PKG)_DEPENDS_ON += yaml

$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)$(PYTHON3_SITE_PKG_DIR)/yaml/__init__.py

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_TARGET_BINARY): $($(PKG)_DIR)/.configured
	$(call Build/PyMod3/PKG, PYTHON3_PYYAML, , )

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	$(RM) $(PYTHON3_PYYAML_DIR)/.configured
	$(RM) -r $(PYTHON3_PYYAML_DIR)/build

$(pkg)-uninstall:
	$(RM) -r \
		$(PYTHON3_PYYAML_DEST_DIR)$(PYTHON3_SITE_PKG_DIR)/yaml \
		$(PYTHON3_PYYAML_DEST_DIR)$(PYTHON3_SITE_PKG_DIR)/_yaml \
		$(PYTHON3_PYYAML_DEST_DIR)$(PYTHON3_SITE_PKG_DIR)/PyYAML-*.dist-info

$(PKG_FINISH)

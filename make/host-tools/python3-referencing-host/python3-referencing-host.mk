$(call TOOLS_INIT, 0.36.2)
$(PKG)_SOURCE_DOWNLOAD_NAME:=referencing-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE:=$(pkg_short)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=df2e89862cd09deabbdba16944cc3f10feb6b3e6f18e902f7cc25609a34775aa
$(PKG)_SITE:=https://github.com/python-jsonschema/referencing/releases/download/v$($(PKG)_VERSION)
### WEBSITE:=https://pypi.org/project/referencing/
### MANPAGE:=https://referencing.readthedocs.io
### CHANGES:=https://github.com/python-jsonschema/referencing/releases
### CVSREPO:=https://github.com/python-jsonschema/referencing
### SUPPORT:=fda77

$(PKG)_DEPENDS_ON+=python3-host

$(PKG)_DIRECTORY:=$($(PKG)_DIR)/referencing


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)

$($(PKG)_DIR)/.installed: $($(PKG)_DIR)/.unpacked
	cp -fa $(PYTHON3_REFERENCING_HOST_DIRECTORY) $(PYTHON3_HOST_SITE_PACKAGES)/
	@touch $@

$(pkg)-precompiled: $($(PKG)_DIR)/.installed


$(pkg)-clean:

$(pkg)-dirclean:
	$(RM) -r $(PYTHON3_REFERENCING_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) -r $(PYTHON3_HOST_SITE_PACKAGES)/referencing/

$(TOOLS_FINISH)

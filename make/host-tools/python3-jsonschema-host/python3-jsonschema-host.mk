$(call TOOLS_INIT, 4.24.0)
$(PKG)_SOURCE_DOWNLOAD_NAME:=jsonschema-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE:=$(pkg_short)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=0b4e8069eb12aedfa881333004bccaec24ecef5a8a6a4b6df142b2cc9599d196
$(PKG)_SITE:=https://github.com/python-jsonschema/jsonschema/releases/download/v$($(PKG)_VERSION)
### WEBSITE:=https://pypi.org/project/jsonschema
### MANPAGE:=https://python-jsonschema.readthedocs.io
### CHANGES:=https://github.com/python-jsonschema/jsonschema/releases
### CVSREPO:=https://github.com/python-jsonschema/jsonschema
### SUPPORT:=fda77

$(PKG)_DEPENDS_ON+=python3-host

$(PKG)_DIRECTORY:=$($(PKG)_DIR)/jsonschema


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)

$($(PKG)_DIR)/.installed: $($(PKG)_DIR)/.unpacked
	cp -fa $(PYTHON3_JSONSCHEMA_HOST_DIRECTORY) $(PYTHON3_HOST_SITE_PACKAGES)/
	@touch $@

$(pkg)-precompiled: $($(PKG)_DIR)/.installed


$(pkg)-clean:

$(pkg)-dirclean:
	$(RM) -r $(PYTHON3_JSONSCHEMA_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) -r $(PYTHON3_HOST_SITE_PACKAGES)/jsonschema/

$(TOOLS_FINISH)

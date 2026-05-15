$(call TOOLS_INIT, 4.26.0)
$(PKG)_SOURCE_DOWNLOAD_NAME:=jsonschema-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE:=$(pkg_short)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=0c26707e2efad8aa1bfc5b7ce170f3fccc2e4918ff85989ba9ffa9facb2be326
$(PKG)_SITE:=https://github.com/python-jsonschema/jsonschema/releases/download/v$($(PKG)_VERSION)
### WEBSITE:=https://pypi.org/project/jsonschema
### MANPAGE:=https://python-jsonschema.readthedocs.io
### CHANGES:=https://github.com/python-jsonschema/jsonschema/releases
### CVSREPO:=https://github.com/python-jsonschema/jsonschema
### STEWARD:=fda77

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

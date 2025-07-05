$(call TOOLS_INIT, 80.9.0)
#
$(PKG)_SOURCE_DOWNLOAD_NAME:=setuptools-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE:=$(pkg_short)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=f36b47402ecde768dbfafc46e8e4207b4360c654f1f3bb84475f0a28628fb19c
$(PKG)_SITE:=https://distfiles.macports.org/py-setuptools,https://files.pythonhosted.org/packages/18/5d/3bf57dcd21979b887f014ea83c24ae194cfcd12b9e0fda66b957c69d1fca
### WEBSITE:=https://pypi.org/project/setuptools/
### MANPAGE:=https://setuptools.pypa.io/
### CHANGES:=https://pypi.org/project/setuptools/#history
### CVSREPO:=https://github.com/pypa/setuptools
### SUPPORT:=fda77

$(PKG)_DEPENDS_ON+=python3-pip-host


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)

$($(PKG)_DIR)/.installed: $($(PKG)_DIR)/.unpacked
	$(HOST_TOOLS_DIR)/usr/bin/python3 -m pip install --no-cache-dir $(PYTHON3_SETUPTOOLS_HOST_DIR)/ $(SILENT)
	@touch $@

$(pkg)-precompiled: $($(PKG)_DIR)/.installed


$(pkg)-clean:

$(pkg)-dirclean:
	$(RM) -r $(PYTHON3_SETUPTOOLS_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) -r $(PYTHON3_HOST_SITE_PACKAGES)/setuptools/
	$(RM) -r $(PYTHON3_HOST_SITE_PACKAGES)/setuptools-*.egg-info/

$(TOOLS_FINISH)

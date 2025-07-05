$(call TOOLS_INIT, 44.1.1)
# Since version 45 only Python3 is supported!
$(PKG)_SOURCE_DOWNLOAD_NAME:=setuptools-$($(PKG)_VERSION).zip
$(PKG)_SOURCE:=$(pkg_short)-$($(PKG)_VERSION).zip
$(PKG)_HASH:=c67aa55db532a0dadc4d2e20ba9961cbd3ccc84d544e9029699822542b5a476b
$(PKG)_SITE:=https://distfiles.macports.org/py-setuptools,https://files.pythonhosted.org/packages/b2/40/4e00501c204b457f10fe410da0c97537214b2265247bc9a5bc6edd55b9e4
### WEBSITE:=https://pypi.org/project/setuptools/
### MANPAGE:=https://setuptools.pypa.io/
### CHANGES:=https://pypi.org/project/setuptools/#history
### CVSREPO:=https://github.com/pypa/setuptools
### SUPPORT:=X

$(PKG)_DEPENDS_ON+=python2-pip-host


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)

$($(PKG)_DIR)/.installed: $($(PKG)_DIR)/.unpacked
	$(HOST_TOOLS_DIR)/usr/bin/python2 -m pip install --no-cache-dir $(PYTHON2_SETUPTOOLS_HOST_DIR)/ $(SILENT)
	@touch $@

$(pkg)-precompiled: $($(PKG)_DIR)/.installed


$(pkg)-clean:

$(pkg)-dirclean:
	$(RM) -r $(PYTHON2_SETUPTOOLS_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) -r $(PYTHON2_HOST_SITE_PACKAGES)/setuptools/
	$(RM) -r $(PYTHON2_HOST_SITE_PACKAGES)/setuptools-*.egg-info/

$(TOOLS_FINISH)

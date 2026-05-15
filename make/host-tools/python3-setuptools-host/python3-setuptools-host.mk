$(call TOOLS_INIT, 82.0.1)
#
$(PKG)_SOURCE_DOWNLOAD_NAME:=setuptools-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE:=$(pkg_short)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=7d872682c5d01cfde07da7bccc7b65469d3dca203318515ada1de5eda35efbf9
$(PKG)_SITE:=https://distfiles.macports.org/py-setuptools,https://files.pythonhosted.org/packages/4f/db/cfac1baf10650ab4d1c111714410d2fbb77ac5a616db26775db562c8fab2
### WEBSITE:=https://pypi.org/project/setuptools/
### MANPAGE:=https://setuptools.pypa.io/
### CHANGES:=https://pypi.org/project/setuptools/#history
### CVSREPO:=https://github.com/pypa/setuptools
### STEWARD:=fda77

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

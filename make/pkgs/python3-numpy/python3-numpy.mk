$(call PKG_INIT_BIN, 2.3.3)
$(PKG)_SOURCE:=numpy-py3-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_DOWNLOAD_NAME:=numpy-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=https://files.pythonhosted.org/packages/d0/19/95b3d357407220ed24c139018d2518fab0a61a948e68286a25f1a4d049ff
$(PKG)_HASH:=ddc7c39727ba62b80dfdbedf400d1c10ddfa8eefbd7ec8dcb118be8b56d31029
### WEBSITE:=https://numpy.org/
### MANPAGE:=https://numpy.org/doc/stable/
### CHANGES:=https://numpy.org/doc/stable/release.html
### CVSREPO:=https://github.com/numpy/numpy

$(PKG)_DEPENDS_ON += python3
$(PKG)_DEPENDS_ON += meson-host
$(PKG)_DEPENDS_ON += ninja-host


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_DIR)/.compiled: $($(PKG)_DIR)/.configured
	$(call Build/Py3Mod/Pip, PYTHON3_NUMPY, , , isolated)
	@touch $@

$(pkg):

$(pkg)-precompiled: $($(PKG)_DIR)/.compiled


$(pkg)-clean:
	$(RM) $(PYTHON3_NUMPY_DIR)/{.configured,.compiled}
	$(RM) -r $(PYTHON3_NUMPY_DIR)/build

$(pkg)-uninstall:
	$(RM) -r \
		$(PYTHON3_NUMPY_DEST_DIR)$(PYTHON3_SITE_PKG_DIR)/numpy \
		$(PYTHON3_NUMPY_DEST_DIR)$(PYTHON3_SITE_PKG_DIR)/numpy-*.dist-info

$(PKG_FINISH)

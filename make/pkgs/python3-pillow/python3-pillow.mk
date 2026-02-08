$(call PKG_INIT_BIN, 11.0.0)
$(PKG)_SOURCE:=pillow-py3-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_DOWNLOAD_NAME:=pillow-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=https://files.pythonhosted.org/packages/source/p/pillow
$(PKG)_HASH:=72bacbaf24ac003fea9bff9837d1eedb6088758d41e100c1552930151f677739
### WEBSITE:=https://python-pillow.org/
### MANPAGE:=https://pillow.readthedocs.io/
### CHANGES:=https://pillow.readthedocs.io/en/stable/releasenotes/
### CVSREPO:=https://github.com/python-pillow/Pillow

$(PKG)_DEPENDS_ON += python3
$(PKG)_DEPENDS_ON += python3-setuptools-host
$(PKG)_DEPENDS_ON += jpeg
$(PKG)_DEPENDS_ON += libpng
$(PKG)_DEPENDS_ON += zlib

$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)$(PYTHON3_SITE_PKG_DIR)/PIL/__init__.py

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_TARGET_BINARY): $($(PKG)_DIR)/.configured
	$(call Build/PyMod3/PKG, PYTHON3_PILLOW, , )

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	$(RM) $(PYTHON3_PILLOW_DIR)/.configured
	$(RM) -r $(PYTHON3_PILLOW_DIR)/build

$(pkg)-uninstall:
	$(RM) -r \
		$(PYTHON3_PILLOW_DEST_DIR)$(PYTHON3_SITE_PKG_DIR)/PIL \
		$(PYTHON3_PILLOW_DEST_DIR)$(PYTHON3_SITE_PKG_DIR)/pillow-*.egg-info

$(PKG_FINISH)

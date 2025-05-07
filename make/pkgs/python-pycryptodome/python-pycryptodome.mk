$(call PKG_INIT_BIN, 3.22.0)
$(PKG)_SOURCE:=pycryptodome-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=https://files.pythonhosted.org/packages/source/p/pycryptodome
$(PKG)_HASH:=fd7ab568b3ad7b77c908d7c3f7e167ec5a8f035c64ff74f10d47a4edd043d723

$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/Crypto/Hash/_SHA256.so

$(PKG)_DEPENDS_ON += python gmp

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PYTHON_STATIC

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_TARGET_BINARY): $($(PKG)_DIR)/.configured
	$(call Build/PyMod/PKG, PYTHON_PYCRYPTODOME, , PYTHONHOME=$(HOST_TOOLS_DIR)/usr)
	touch -c $@

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	$(RM) -r $(PYTHON_PYCRYPTODOME_DIR)/build

$(pkg)-uninstall:
	$(RM) -r \
		$(PYTHON_PYCRYPTODOME_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/Crypto \
		$(PYTHON_PYCRYPTODOME_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/pycryptodome-*.egg-info

$(PKG_FINISH)

$(call PKG_INIT_BIN, 3.3.2)
$(PKG)_SOURCE:=cryptography-py3-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_DOWNLOAD_NAME:=cryptography-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=https://files.pythonhosted.org/packages/source/c/cryptography
$(PKG)_HASH:=5a60d3780149e13b7a6ff7ad6526b38846354d11a15e21068e57073e29e19bed
### WEBSITE:=https://cryptography.io/
### MANPAGE:=https://cryptography.io/en/latest/
### CHANGES:=https://cryptography.io/en/latest/changelog/
### CVSREPO:=https://github.com/pyca/cryptography

$(PKG)_DEPENDS_ON += openssl python3 python3-cffi

$(PKG)_CONDITIONAL_PATCHES+=$(if $(FREETZ_OPENSSL_VERSION_09),openssl-0.9,) \
	$(if $(FREETZ_OPENSSL_VERSION_10),openssl-1.0,) \
	$(if $(FREETZ_OPENSSL_VERSION_11),openssl-1.1,)

# Rebuild Python package from source, with cross-compilation setup
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PYTHON3_CRYPTOGRAPHY

$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)$(PYTHON3_SITE_PKG_DIR)/cryptography/__init__.py

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_TARGET_BINARY): $($(PKG)_DIR)/.configured
	$(call Build/PyMod3/Pip, PYTHON3_CRYPTOGRAPHY, , \
		OPENSSL_DIR="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr" \
		OPENSSL_LIB_DIR="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib" \
		OPENSSL_INCLUDE_DIR="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include" \
	)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(RM) -r $(PYTHON3_CRYPTOGRAPHY_DIR)/.configured
	-$(RM) -r $(PYTHON3_CRYPTOGRAPHY_DIR)/build

$(pkg)-uninstall:
	$(RM) -r $(PYTHON3_CRYPTOGRAPHY_DEST_DIR)/usr/lib/python$(PYTHON3_VERSION_MAJOR)/site-packages/cryptography
	$(RM) -r $(PYTHON3_CRYPTOGRAPHY_DEST_DIR)/usr/lib/python$(PYTHON3_VERSION_MAJOR)/site-packages/cryptography-$(PYTHON3_CRYPTOGRAPHY_VERSION)*.egg-info

$(PKG_FINISH)

# -----------------------
# Python PyCrypto Module
# -----------------------
$(call PKG_INIT_BIN,2.7a1)
$(PKG)_SOURCE:=pycrypto-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=ee4013e297e6a5da5c9f49a3e38dc8a5c62ae816377aa766c9e87474197be3b9
$(PKG)_SITE:=https://www.pycrypto.org/pub/dlitz/crypto/pycrypto/,https://ftp.dlitz.net/pub/dlitz/crypto/pycrypto
$(PKG)_DEPENDS_ON += python gmp python2-host
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PYTHON_STATIC

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

# Build & install
$($(PKG)_DIR)/.compiled: $($(PKG)_DIR)/.configured
	@echo "=== Building Python module: PyCrypto ==="
	@echo "Source: $(PYTHON_PYCRYPTO_DIR)"
	@echo "Dest: $(PYTHON_PYCRYPTO_DEST_DIR)"
	@echo "Python include: $(PYTHON_STAGING_INC_DIR)"
	( \
		export PYTHONHOME="$(HOST_TOOLS_DIR)/usr"; \
		export PYTHONPATH="$(PYTHON_STAGING_LIB_DIR):$(TARGET_TOOLCHAIN_STAGING_DIR)/$(PYTHON_SITE_PKG_DIR)"; \
		export PYTHONOPTIMIZE=""; \
		export PYTHONDONTWRITEBYTECODE="x"; \
		cd $(PYTHON_PYCRYPTO_DIR) && \
		echo "Current directory: $$(pwd)" && \
		echo "Files: $$(ls -la)" && \
		TARGET_ARCH_BE="$(TARGET_ARCH_BE)" \
		$(TARGET_CONFIGURE_ENV) $(FREETZ_LD_RUN_PATH) \
		$(HOST_PYTHON_BIN) ./setup.py build_ext \
			--include-dirs=$(PYTHON_STAGING_INC_DIR) \
			--library-dirs=$(PYTHON_STAGING_LIB_DIR) \
			--force --verbose \
		&& $(HOST_PYTHON_BIN) ./setup.py install \
			--prefix=/usr \
			--root=$(abspath $(PYTHON_PYCRYPTO_DEST_DIR)) \
			--install-lib=$(PYTHON_SITE_PKG_DIR) \
	)
	@touch $@

# Targets
$(pkg):
$(pkg)-precompiled: $($(PKG)_DIR)/.compiled
$(pkg)-clean:
	$(RM) $(PYTHON_PYCRYPTO_DIR)/{.configured,.compiled}
	$(RM) -r $(PYTHON_PYCRYPTO_DIR)/build
$(pkg)-uninstall:
	$(RM) -r \
		$(PYTHON_PYCRYPTO_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/Crypto \
		$(PYTHON_PYCRYPTO_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/pycrypto-*.egg-info

$(PKG_FINISH)

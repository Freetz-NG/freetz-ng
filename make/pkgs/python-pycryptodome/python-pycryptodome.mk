# -----------------------
# Python PyCryptodome Module
# -----------------------
$(call PKG_INIT_BIN,3.23.0)
$(PKG)_SOURCE:=pycryptodome-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=https://files.pythonhosted.org/packages/source/p/pycryptodome
$(PKG)_HASH:=447700a657182d60338bab09fdb27518f8856aecd80ae4c6bdddb67ff5da44ef
$(PKG)_DEPENDS_ON += python
$(PKG)_DEPENDS_ON += python2-setuptools-host
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/Crypto/Random/_random.so

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

# Build & install
$($(PKG)_TARGET_BINARY): $($(PKG)_DIR)/.configured
	@echo "=== Building Python module: PyCryptodome ==="
	@echo "Source: $(PYTHON_PYCRYPTODOME_DIR)"
	@echo "Dest: $(PYTHON_PYCRYPTODOME_DEST_DIR)"
	@echo "Python include: $(PYTHON_STAGING_INC_DIR)"
	( \
		export PYTHONHOME="$(HOST_TOOLS_DIR)/usr"; \
		export PYTHONPATH="$(PYTHON_STAGING_LIB_DIR):$(TARGET_TOOLCHAIN_STAGING_DIR)/$(PYTHON_SITE_PKG_DIR)"; \
		export PYTHONOPTIMIZE=""; \
		export PYTHONDONTWRITEBYTECODE="x"; \
		cd $(PYTHON_PYCRYPTODOME_DIR) && \
		echo "Current directory: $$(pwd)" && \
		echo "Files: $$(ls -la)" && \
		$(TARGET_CONFIGURE_ENV) $(FREETZ_LD_RUN_PATH) \
		$(HOST_PYTHON_BIN) ./setup.py build_ext \
			--include-dirs=$(PYTHON_STAGING_INC_DIR) \
			--library-dirs=$(PYTHON_STAGING_LIB_DIR) \
			--force --verbose \
		&& $(HOST_PYTHON_BIN) ./setup.py install \
			--prefix=/usr \
			--root=$(abspath $(PYTHON_PYCRYPTODOME_DEST_DIR)) \
			--install-lib=$(PYTHON_SITE_PKG_DIR) \
	)
	$(TARGET_STRIP) $(PYTHON_PYCRYPTODOME_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/Crypto/*/*.so 2>/dev/null || true

# Targets
$(pkg):
$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)
$(pkg)-clean:
	$(RM) -r $(PYTHON_PYCRYPTODOME_DIR)/build $(PYTHON_PYCRYPTODOME_DIR)/.configured $(PYTHON_PYCRYPTODOME_DIR)/.compiled
$(pkg)-uninstall:
	$(RM) -r \
		$(PYTHON_PYCRYPTODOME_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/Crypto \
		$(PYTHON_PYCRYPTODOME_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/pycryptodome-*.egg-info

$(PKG_FINISH)

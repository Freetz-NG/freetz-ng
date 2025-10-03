# -----------------------
# CFFI Python Module (Python 2.7 compatible)
# -----------------------
$(call PKG_INIT_BIN,1.15.1)
$(PKG)_SOURCE:=cffi-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=d400bfb9a37b1351253cb402671cea7e89bdecc294e8016a707f6d1d8ac934f9
$(PKG)_SITE:=https://files.pythonhosted.org/packages/source/c/cffi
$(PKG)_DEPENDS_ON += python2-setuptools-host
$(PKG)_DEPENDS_ON += python
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/_cffi_backend.so

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

# Build & install
$($(PKG)_TARGET_BINARY): $($(PKG)_DIR)/.configured
	@echo "=== Building Python module: cffi ==="
	@echo "Source: $(PYTHON_CFFI_DIR)"
	@echo "Dest: $(PYTHON_CFFI_DEST_DIR)"
	@echo "Python include: $(PYTHON_STAGING_INC_DIR)"
	( \
		export PYTHONHOME="$(HOST_TOOLS_DIR)/usr"; \
		export PYTHONPATH="$(PYTHON_STAGING_LIB_DIR):$(TARGET_TOOLCHAIN_STAGING_DIR)/$(PYTHON_SITE_PKG_DIR)"; \
		export PYTHONOPTIMIZE=""; \
		export PYTHONDONTWRITEBYTECODE="x"; \
		cd $(PYTHON_CFFI_DIR) && \
		echo "Current directory: $$(pwd)" && \
		echo "Files: $$(ls -la)" && \
		$(TARGET_CONFIGURE_ENV) $(FREETZ_LD_RUN_PATH) \
		$(HOST_PYTHON_BIN) ./setup.py build_ext \
			--include-dirs=$(PYTHON_STAGING_INC_DIR) \
			--library-dirs=$(PYTHON_STAGING_LIB_DIR) \
			--force --verbose \
		&& $(HOST_PYTHON_BIN) ./setup.py install \
			--prefix=/usr \
			--root=$(abspath $(PYTHON_CFFI_DEST_DIR)) \
			--install-lib=$(PYTHON_SITE_PKG_DIR) \
	)
	$(TARGET_STRIP) $(PYTHON_CFFI_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/_cffi_backend.so 2>/dev/null || true

# Targets
$(pkg):
$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)
$(pkg)-clean:
	$(RM) -r $(PYTHON_CFFI_DIR)/build $(PYTHON_CFFI_DIR)/.configured $(PYTHON_CFFI_DIR)/.compiled
$(pkg)-uninstall:
	$(RM) -r \
		$(PYTHON_CFFI_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/cffi \
		$(PYTHON_CFFI_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/_cffi_backend.so \
		$(PYTHON_CFFI_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/cffi-*.egg-info

$(PKG_FINISH)

# -----------------------
# Python Cheetah Module
# -----------------------
$(call PKG_INIT_BIN,2.4.4)
$(PKG)_SOURCE:=Cheetah-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=be308229f0c1e5e5af4f27d7ee06d90bb19e6af3059794e5fd536a6f29a9b550
$(PKG)_SITE:=https://pypi.python.org/packages/source/C/Cheetah
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/Cheetah/_namemapper.so
$(PKG)_DEPENDS_ON += python
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PYTHON_STATIC

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

# Build & install
$($(PKG)_TARGET_BINARY): $($(PKG)_DIR)/.configured
	@echo "=== Building Python module: Cheetah ==="
	@echo "Source: $(PYTHON_CHEETAH_DIR)"
	@echo "Dest: $(PYTHON_CHEETAH_DEST_DIR)"
	@echo "Python include: $(PYTHON_STAGING_INC_DIR)"
	( \
		export PYTHONHOME="$(HOST_TOOLS_DIR)/usr"; \
		export PYTHONPATH="$(PYTHON_STAGING_LIB_DIR):$(TARGET_TOOLCHAIN_STAGING_DIR)/$(PYTHON_SITE_PKG_DIR)"; \
		export PYTHONOPTIMIZE=""; \
		export PYTHONDONTWRITEBYTECODE="x"; \
		cd $(PYTHON_CHEETAH_DIR) && \
		echo "Current directory: $$(pwd)" && \
		echo "Files: $$(ls -la)" && \
		CHEETAH_INSTALL_WITHOUT_SETUPTOOLS="" \
		$(TARGET_CONFIGURE_ENV) $(FREETZ_LD_RUN_PATH) \
		$(HOST_PYTHON_BIN) ./setup.py build_ext \
			--include-dirs=$(PYTHON_STAGING_INC_DIR) \
			--library-dirs=$(PYTHON_STAGING_LIB_DIR) \
			--force --verbose \
		&& $(HOST_PYTHON_BIN) ./setup.py install \
			--prefix=/usr \
			--root=$(abspath $(PYTHON_CHEETAH_DEST_DIR)) \
			--install-lib=$(PYTHON_SITE_PKG_DIR) \
	)
	$(TARGET_STRIP) $(PYTHON_CHEETAH_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/Cheetah/_namemapper.so 2>/dev/null || true

# Targets
$(pkg):
$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)
$(pkg)-clean:
	$(RM) -r $(PYTHON_CHEETAH_DIR)/build
$(pkg)-uninstall:
	$(RM) -r \
		$(PYTHON_CHEETAH_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/Cheetah \
		$(PYTHON_CHEETAH_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/Cheetah-*.egg-info

$(PKG_FINISH)

# -----------------------
# Python Bjoern Module
# -----------------------
$(call PKG_INIT_BIN,37d28e5645)
$(PKG)_SOURCE:=bjoern-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=8a4a25f1357036b6a890c0dc35c34ffffd05b22294e7e205ff01c9af3b88fe65
$(PKG)_SITE:=git@https://github.com/jonashaag/bjoern.git
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/bjoern.so
$(PKG)_DEPENDS_ON += python libev
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PYTHON_STATIC

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

# Build & install
$($(PKG)_TARGET_BINARY): $($(PKG)_DIR)/.configured
	@echo "=== Building Python module: bjoern ==="
	@echo "Source: $(PYTHON_BJOERN_DIR)"
	@echo "Dest: $(PYTHON_BJOERN_DEST_DIR)"
	@echo "Python include: $(PYTHON_STAGING_INC_DIR)"
	( \
		export PYTHONHOME="$(HOST_TOOLS_DIR)/usr"; \
		export PYTHONPATH="$(PYTHON_STAGING_LIB_DIR):$(TARGET_TOOLCHAIN_STAGING_DIR)/$(PYTHON_SITE_PKG_DIR)"; \
		export PYTHONOPTIMIZE=""; \
		export PYTHONDONTWRITEBYTECODE="x"; \
		cd $(PYTHON_BJOERN_DIR) && \
		echo "Current directory: $$(pwd)" && \
		echo "Files: $$(ls -la)" && \
		$(TARGET_CONFIGURE_ENV) $(FREETZ_LD_RUN_PATH) \
		$(HOST_PYTHON_BIN) ./setup.py build_ext \
			--include-dirs=$(PYTHON_STAGING_INC_DIR) \
			--library-dirs=$(PYTHON_STAGING_LIB_DIR) \
			--force --verbose \
		&& $(HOST_PYTHON_BIN) ./setup.py install \
			--prefix=/usr \
			--root=$(abspath $(PYTHON_BJOERN_DEST_DIR)) \
			--install-lib=$(PYTHON_SITE_PKG_DIR) \
	)
	$(TARGET_STRIP) $(PYTHON_BJOERN_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/bjoern.so 2>/dev/null || true

# Targets
$(pkg):
$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)
$(pkg)-clean:
	-$(SUBMAKE) -C $(PYTHON_BJOERN_DIR) clean
$(pkg)-uninstall:
	$(RM) -r \
		$(PYTHON_BJOERN_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/bjoern.so \
		$(PYTHON_BJOERN_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/bjoern-*.egg-info

$(PKG_FINISH)

# -----------------------
# Python Imaging Library (PIL) Module
# -----------------------
$(call PKG_INIT_BIN,1.1.7)
$(PKG)_SOURCE:=Imaging-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=895bc7c2498c8e1f9b99938f1a40dc86b3f149741f105cf7c7bd2e0725405211
$(PKG)_SITE:=http://effbot.org/downloads
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/PIL/_imaging.so
$(PKG)_DEPENDS_ON += python freetype jpeg zlib
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PYTHON_STATIC

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

# Build & install
$($(PKG)_TARGET_BINARY): $($(PKG)_DIR)/.configured
	@echo "=== Building Python module: PIL ==="
	@echo "Source: $(PYTHON_IMAGING_LIBRARY_DIR)"
	@echo "Dest: $(PYTHON_IMAGING_LIBRARY_DEST_DIR)"
	@echo "Python include: $(PYTHON_STAGING_INC_DIR)"
	( \
		export PYTHONHOME="$(HOST_TOOLS_DIR)/usr"; \
		export PYTHONPATH="$(PYTHON_STAGING_LIB_DIR):$(TARGET_TOOLCHAIN_STAGING_DIR)/$(PYTHON_SITE_PKG_DIR)"; \
		export PYTHONOPTIMIZE=""; \
		export PYTHONDONTWRITEBYTECODE="x"; \
		cd $(PYTHON_IMAGING_LIBRARY_DIR) && \
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
			--root=$(abspath $(PYTHON_IMAGING_LIBRARY_DEST_DIR)) \
			--install-lib=$(PYTHON_SITE_PKG_DIR) \
		&& $(RM) -r $(PYTHON_IMAGING_LIBRARY_DEST_DIR)/usr/bin \
	)
	# Move egg-info to top-level
	@if [ -d "$(PYTHON_IMAGING_LIBRARY_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/PIL" ]; then \
		mv $(PYTHON_IMAGING_LIBRARY_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/PIL/PIL-*.egg-info $(PYTHON_IMAGING_LIBRARY_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/; \
	fi
	# Remove unnecessary test directories if they exist
	@if [ -d "$(PYTHON_IMAGING_LIBRARY_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/PIL/backend/tests" ]; then \
		rm -rf $(PYTHON_IMAGING_LIBRARY_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/PIL/backend/tests; \
	fi
	@if [ -d "$(PYTHON_IMAGING_LIBRARY_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/PIL/testing" ]; then \
		rm -rf $(PYTHON_IMAGING_LIBRARY_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/PIL/testing; \
	fi
	@if [ -d "$(PYTHON_IMAGING_LIBRARY_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/PIL/tests" ]; then \
		rm -rf $(PYTHON_IMAGING_LIBRARY_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/PIL/tests; \
	fi
	$(TARGET_STRIP) $(PYTHON_IMAGING_LIBRARY_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/PIL/_imaging.so 2>/dev/null || true

# Targets
$(pkg):
$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)
$(pkg)-clean:
	$(RM) -r $(PYTHON_IMAGING_LIBRARY_DIR)/build
$(pkg)-uninstall:
	$(RM) -r \
		$(PYTHON_IMAGING_LIBRARY_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/PIL \
		$(PYTHON_IMAGING_LIBRARY_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/PIL.pth \
		$(PYTHON_IMAGING_LIBRARY_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/PIL-*.egg-info

$(PKG_FINISH)

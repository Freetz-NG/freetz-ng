

### PKG-macros


define PKG_BUILD_PREREQ__INT
.PHONY: $(pkg)-build-prereq
$(pkg)-build-prereq: $($(PKG)_DIR)/.build-prereq-checked
$($(PKG)_DIR)/.build-prereq-checked:
ifneq ($($(PKG)_BUILD_PREREQ),)
	@MISSING_PREREQ=""; \
	for fv in $($(PKG)_BUILD_PREREQ); do \
		f=$$$$(echo $$$$fv | cut -d ':' -f 1); \
		v=$$$$(echo $$$$fv | cut -d ':' -sf 2 | sed -e 's,[.],[.],g'); \
		if ! command -v $$$$f >/dev/null 2>&1; then \
			MISSING_PREREQ="$$$$MISSING_PREREQ $$$$f"; \
		elif [ -n "$$$$v" ] && ! $$$$f --version 2>&1 | grep -q "$$$$v"; then \
			MISSING_PREREQ="$$$$MISSING_PREREQ $$$$fv"; \
		fi; \
	done; \
	if [ -n "$$$$MISSING_PREREQ" ]; then \
		echo -n -e "$(_Y)"; \
		echo -e \
			"ERROR: The following command(s) required for building '$(pkg)' are missing on your system:" \
			`echo $$$$MISSING_PREREQ | sed -e 's| |, |g'`; \
		echo "See https://freetz-ng.github.io/freetz-ng/PREREQUISITES for installation hints"; \
		if [ -n "$(strip $($(PKG)_BUILD_PREREQ_HINT))" ]; then \
			echo "$($(PKG)_BUILD_PREREQ_HINT)"; \
		fi; \
		echo -n -e "$(_N)"; \
		exit 1; \
	fi;
endif
	@mkdir -p $$(dir $$@); touch $$@;
endef


### PKG_SOURCE_DOWNLOAD - download source packages
define PKG_SOURCE_DOWNLOAD__INT
NON_LOCALSOURCE_PACKAGES+=$(pkg)
$(DL_DIR)/$($(PKG)_SOURCE): | $(DL_DIR)
	$(call _ECHO,downloading)
	@if [ -e $(MIRROR_DIR)/$($(PKG)_SOURCE) -a ! -e $(DL_DIR)/$($(PKG)_SOURCE) ]; then \
		$(call MESSAGE, Found $($(PKG)_SOURCE) in $(MIRROR_DIR), creating hard link); \
		ln $(MIRROR_DIR)/$($(PKG)_SOURCE) $(DL_DIR); \
	else \
		[ -z "$(strip $($(PKG)_HASH))" ] && echo "no checksum is set, abort." && exit 1; \
		$(DL_TOOL) \
			$(DL_DIR) \
			$(if $($(PKG)_SOURCE_DOWNLOAD_NAME),$($(PKG)_SOURCE_DOWNLOAD_NAME),$($(PKG)_SOURCE)) \
			$($(PKG)_SITE) \
			$($(PKG)_HASH) \
			$(SILENT) \
			$(if $($(PKG)_SOURCE_DOWNLOAD_NAME),&& mv -f $(DL_DIR)/$($(PKG)_SOURCE_DOWNLOAD_NAME) $(DL_DIR)/$($(PKG)_SOURCE)); \
	fi

$(pkg)-download: $(DL_DIR)/$($(PKG)_SOURCE)

$(MIRROR_DIR)/$($(PKG)_SOURCE): | $(MIRROR_DIR)
	@if [ -e $(DL_DIR)/$($(PKG)_SOURCE) ]; then \
		$(call MESSAGE, Found $($(PKG)_SOURCE) in $(DL_DIR), creating hard link); \
		ln $(DL_DIR)/$($(PKG)_SOURCE) $(MIRROR_DIR); \
	else \
		$(DL_TOOL) \
			$(MIRROR_DIR) \
			$(if $($(PKG)_SOURCE_DOWNLOAD_NAME),$($(PKG)_SOURCE_DOWNLOAD_NAME),$($(PKG)_SOURCE)) \
			$($(PKG)_SITE) \
			$($(PKG)_HASH) \
			$(SILENT) \
			$(if $($(PKG)_SOURCE_DOWNLOAD_NAME),&& mv -f $(DL_DIR)/$($(PKG)_SOURCE_DOWNLOAD_NAME) $(DL_DIR)/$($(PKG)_SOURCE)); \
	fi

$(pkg)-download-mirror: $(MIRROR_DIR)/$($(PKG)_SOURCE)

$(pkg)-check-download:
	@echo -n "Checking download for package $(pkg)..."
	@if $(DL_TOOL) check $($(PKG)_SOURCE) $($(PKG)_SITE); then \
		echo "ok."; \
	else \
		echo "ERROR: NOT FOUND!"; \
	fi

.PHONY: $(pkg)-download $(pkg)-check-download $(pkg)-download-mirror
endef


### PKG_UNPACK - unpack source archive & apply patches
# Unpack, without patch, but only if source package is defined
define PKG_UNPACK
	$(if $($(PKG)_SOURCE), \
		$(strip \
			mkdir -p $($(PKG)_DIR); \
			$(call \
				$(if $($(PKG)_CUSTOM_UNPACK),$(PKG)_CUSTOM_UNPACK,UNPACK_TARBALL), \
				$(DL_DIR)/$($(PKG)_SOURCE), \
				$($(PKG)_DIR), \
				$(strip $(filter-out 0,$($(PKG)_TARBALL_STRIP_COMPONENTS))), \
				$(strip $($(PKG)_TARBALL_INCLUDE_FILTER)) \
			) \
		) \
	)
endef


### PKG_PATCH - apply patches
define PKG_PATCH
	$(subst $(_dollar),$(_dollar)$(_dollar), \
		$(call \
			APPLY_PATCHES, \
			$($(PKG)_MAKE_DIR)/patches \
			$(if $(strip $($(PKG)_CONDITIONAL_PATCHES)),$(addprefix $($(PKG)_MAKE_DIR)/patches/,$(strip $($(PKG)_CONDITIONAL_PATCHES)))), \
			$($(PKG)_DIR) \
		) \
	)
endef

# $1: commands to execute
# $2: optional directory $1 to be executed within, default $($(PKG)_DIR)
define PKG_EXECUTE_WITHIN__INT
	$(if $(strip $(1)),(cd $(if $(strip $(2)),$(strip $(2)),$($(PKG)_DIR)); $(strip $(1))))
endef

# Removes all files under $1 except for those in $2
# During tar-host build there is no $(TAR)
define RMDIR_KEEP_FILES__INT
	[ -x $(TAR) ] && Tar='$(TAR)' || Tar='tar'; \
	$(if $2,if [ -d "$1" ]; then TMPFILE=`mktemp`; $$$${Tar} -C $1 -cf $$$$TMPFILE $2; fi;) \
	$(RM) -r $1; \
	$(if $2,if [ -n "$$$$TMPFILE" ]; then mkdir -p $1; $$$${Tar} -C $1 -xf $$$$TMPFILE; rm -f $$$$TMPFILE; fi;)
endef


## PKG_UNPACKED: Unpack and patch package
define PKG_UNPACKED__ALL_INT
$($(PKG)_DIR)/.unpacked: $(DL_DIR)/$($(PKG)_SOURCE) $(if $($(PKG)_CUSTOM_UNPACK),$($(PKG)_DIR)/.build-prereq-checked) | $($(PKG)_SOURCE_DIR)
	@$(call _ECHO,preparing)
	@$(call RMDIR_KEEP_FILES__INT,$($(PKG)_DIR),.build-prereq-checked)
	$(call PKG_UNPACK)
	$(call PKG_EXECUTE_WITHIN__INT,$($(PKG)_PATCH_PRE_CMDS))
	$(call PKG_PATCH)
	$(call PKG_EXECUTE_WITHIN__INT,$($(PKG)_PATCH_POST_CMDS))
	@touch $$@
$(pkg)-source: $($(PKG)_DIR)/.unpacked
$(pkg)-unpacked: $($(PKG)_DIR)/.unpacked
.PHONY: $(pkg)-source $(pkg)-unpacked
endef


## "unpack" (actually copy) local source package
define PKG_UNPACKED_LOCALSOURCE_PACKAGE__INT
$($(PKG)_DIR)/.unpacked: $(wildcard $($(PKG)_MAKE_DIR)/src/*) | $($(PKG)_SOURCE_DIR)
	@$(call _ECHO,preparing)
	@$(call RMDIR_KEEP_FILES__INT,$($(PKG)_DIR),.build-prereq-checked)
	mkdir -p $($(PKG)_DIR)
	cp -a $$^ $($(PKG)_DIR)
	@touch $$@
$(pkg)-source: $($(PKG)_DIR)/.unpacked
$(pkg)-unpacked: $($(PKG)_DIR)/.unpacked
.PHONY: $(pkg)-source $(pkg)-unpacked
endef


### PKG_CONFIGURED: Configure package
define PKG_CONFIGURED_COMMON__INT
$(pkg)-configured: $($(PKG)_DIR)/.configured
.PHONY: $(pkg)-configured
endef
## Configure package, using ./configure
define PKG_CONFIGURED_CONFIGURE__INT
# Must be first
$(PKG_CONFIGURED_COMMON__INT)
$($(PKG)_DIR)/.configured: $($(PKG)_DIR)/.build-prereq-checked $($(PKG)_DIR)/.unpacked
	@$(call _ECHO,configuring)
	($(CONFIGURE) \
		cd $($(PKG)_DIR); \
		$(if $($($(PKG)_CONFIGURE_DEST)_CONFIGURE_PRE_CMDS),{ $($($(PKG)_CONFIGURE_DEST)_CONFIGURE_PRE_CMDS) } $(SILENT);,) \
		$(if $($(PKG)_CONFIGURE_PRE_CMDS),{ $($(PKG)_CONFIGURE_PRE_CMDS) } $(SILENT);,) \
		$(if $(strip $($(PKG)_BUILD_SUBDIR)),cd $(strip $($(PKG)_BUILD_SUBDIR));,) \
		$($($(PKG)_CONFIGURE_DEST)_CONFIGURE_ENV) \
		$($(PKG)_CONFIGURE_ENV) \
		CONFIG_SITE=$($($(PKG)_CONFIGURE_DEST)_SITE) \
		conf_cmd \
		$(if $(findstring y,$($(PKG)_CONFIGURE_DEFOPTS)), $($($(PKG)_CONFIGURE_DEST)_CONFIGURE_OPTIONS)) \
		$($(PKG)_CONFIGURE_OPTIONS) \
		$(if $(strip $($(PKG)_BUILD_SUBDIR)),&& { cd $(abspath $($(PKG)_DIR)); },) \
		$(if $($(PKG)_CONFIGURE_POST_CMDS),&& { $($(PKG)_CONFIGURE_POST_CMDS) } $(SILENT),) \
	)
	@touch $$@
endef

## Configure package, using cmake
define PKG_CONFIGURED_CMAKE__INT
# Must be first
$(PKG_CONFIGURED_COMMON__INT)
$($(PKG)_DIR)/.configured: $($(PKG)_DIR)/.build-prereq-checked $($(PKG)_DIR)/.unpacked
	@$(call _ECHO,configuring)
	($(CONFCMAKE) \
		cd $($(PKG)_DIR); \
		$(if $($($(PKG)_CONFIGURE_DEST)_CONFIGURE_PRE_CMDS),{ $($($(PKG)_CONFIGURE_DEST)_CONFIGURE_PRE_CMDS) } $(SILENT);,) \
		$(if $($(PKG)_CONFIGURE_PRE_CMDS),{ $($(PKG)_CONFIGURE_PRE_CMDS) } $(SILENT);,) \
		$(if $(strip $($(PKG)_BUILD_SUBDIR)),cd $(strip $($(PKG)_BUILD_SUBDIR));,) \
		$($($(PKG)_CONFIGURE_DEST)_CONFIGURE_ENV) \
		$($(PKG)_CONFIGURE_ENV) \
		cmake_cmd . \
		$($(PKG)_CONFIGURE_OPTIONS) \
		$(if $(strip $($(PKG)_BUILD_SUBDIR)),&& { cd $(abspath $($(PKG)_DIR)); },) \
		$(if $($(PKG)_CONFIGURE_POST_CMDS),&& { $($(PKG)_CONFIGURE_POST_CMDS) } $(SILENT),) \
	)
	@touch $$@
endef

## Configure package, using meson
define PKG_CONFIGURED_MESON__INT
# Must be first
$(PKG_CONFIGURED_COMMON__INT)
$($(PKG)_DIR)/.configured: $($(PKG)_DIR)/.build-prereq-checked $($(PKG)_DIR)/.unpacked
	@$(call _ECHO,configuring)
	cat $(INCLUDE_DIR)/meson.cross/$(call qstrip,$(FREETZ_TARGET_UCLIBC_TRIPLET)) > $($(PKG)_DIR)/meson.freetz
	@sed \
		-e 's!%FREETZ_TARGET_UCLIBC_TRIPLET%!$(call qstrip,$(FREETZ_TARGET_UCLIBC_TRIPLET))!g' \
		\
		-e 's!%FREETZ_TARGET_MESON_FAMILY%!$(call qstrip,$(FREETZ_TARGET_MESON_FAMILY))!' \
		-e 's!%FREETZ_TARGET_MESON_CPU%!$(call qstrip,$(FREETZ_TARGET_MESON_CPU))!' \
		-e 's!%FREETZ_TARGET_MESON_ENDIAN%!$(call qstrip,$(FREETZ_TARGET_MESON_ENDIAN))!' \
		\
		-e "s!%TARGET_CFLAGS%!$(foreach X,$(TARGET_CFLAGS) $($(PKG)_EXTRA_CFLAGS),'$(X)',)!g" \
		-e "s!%TARGET_LDFLAGS%!$(foreach X,$(TARGET_LDFLAGS) $($(PKG)_EXTRA_LDFLAGS),'$(X)',)!g" \
		\
		-e 's!%TARGET_AR%!$(call qstrip,$(TARGET_AR))!g' \
		-e 's!%TARGET_AS%!$(call qstrip,$(TARGET_AS))!g' \
		-e 's!%TARGET_CC%!$(call qstrip,$(TARGET_CC))!g' \
		-e 's!%TARGET_CC%!$(call qstrip,$(TARGET_CC))!g' \
		-e 's!%TARGET_CXX%!$(call qstrip,$(TARGET_CXX))!g' \
		-e 's!%TARGET_CXX%!$(call qstrip,$(TARGET_CXX))!g' \
		-e 's!%TARGET_LD%!$(call qstrip,$(TARGET_LD))!g' \
		-e 's!%TARGET_LDCONFIG%!$(call qstrip,$(TARGET_LDCONFIG))!g' \
		-e 's!%TARGET_NM%!$(call qstrip,$(TARGET_NM))!g' \
		-e 's!%TARGET_RANLIB%!$(call qstrip,$(TARGET_RANLIB))!g' \
		-e 's!%TARGET_OBJCOPY%!$(call qstrip,$(TARGET_OBJCOPY))!g' \
		-e 's!%TARGET_READELF%!$(call qstrip,$(TARGET_READELF))!g' \
		-e 's!%TARGET_STRIP%!$(call qstrip,$(TARGET_STRIP))!g' \
		\
		-e 's!%PKGCONFIG%!$(call qstrip,$(TARGET_MAKE_PATH))/../lib/pkgconfig!g' \
		-e 's!%PYTHON%!$(call qstrip,$(TOOLS_DIR))/path/cmake!g' \
		-e 's!%CMAKE%!$(call qstrip,$(TOOLS_DIR))/path/python3!g' \
		\
		$(INCLUDE_DIR)/meson.cross/common-linux-uclibc >> $($(PKG)_DIR)/meson.freetz
#		$(INCLUDE_DIR)/meson.cross/dynamic-linux-uclibc > $($(PKG)_DIR)/meson.freetz
	($(CONFMESON) \
		cd $($(PKG)_DIR); \
		$(if $($($(PKG)_CONFIGURE_DEST)_CONFIGURE_PRE_CMDS),{ $($($(PKG)_CONFIGURE_DEST)_CONFIGURE_PRE_CMDS) } $(SILENT);,) \
		$(if $($(PKG)_CONFIGURE_PRE_CMDS),{ $($(PKG)_CONFIGURE_PRE_CMDS) } $(SILENT);,) \
		$(if $(strip $($(PKG)_BUILD_SUBDIR)),cd $(strip $($(PKG)_BUILD_SUBDIR));,) \
		$($($(PKG)_CONFIGURE_DEST)_CONFIGURE_ENV) \
		$($(PKG)_CONFIGURE_ENV) \
		meson_cmd --cross-file meson.freetz builddir . \
		$($(PKG)_CONFIGURE_OPTIONS) \
		$(if $(strip $($(PKG)_BUILD_SUBDIR)),&& { cd $(abspath $($(PKG)_DIR)); },) \
		$(if $($(PKG)_CONFIGURE_POST_CMDS),&& { $($(PKG)_CONFIGURE_POST_CMDS) } $(SILENT),) \
	)
	@touch $$@
endef


## Package needs no configuration
define PKG_CONFIGURED_NOP__INT
# Must be first
$(PKG_CONFIGURED_COMMON__INT)
$($(PKG)_DIR)/.configured: $($(PKG)_DIR)/.build-prereq-checked $($(PKG)_DIR)/.unpacked
	@touch $$@
endef



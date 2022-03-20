PATCHELF_HOST_VERSION:=0.13.1
# Versions since 0.14 require C++17 (eg Ubuntu 18)
PATCHELF_HOST_VERSION_LONG:=0.13.1.20211127.72b6d44
PATCHELF_HOST_SOURCE:=patchelf-$(PATCHELF_HOST_VERSION).tar.bz2
PATCHELF_HOST_SOURCE_SHA256:=39e8aeccd7495d54df094d2b4a7c08010ff7777036faaf24f28e07777d1598e2
PATCHELF_HOST_SITE:=https://github.com/NixOS/patchelf/releases/download/$(PATCHELF_HOST_VERSION),https://releases.nixos.org/patchelf/patchelf-$(PATCHELF_HOST_VERSION)
### WEBSITE:=https://opencollective.com/nixos
### MANPAGE:=https://sources.debian.org/patches/patchelf/
### CHANGES:=https://github.com/NixOS/patchelf/commits/master
### CVSREPO:=https://github.com/NixOS/patchelf

PATCHELF_HOST_MAKE_DIR:=$(TOOLS_DIR)/make/patchelf-host
PATCHELF_HOST_DIR:=$(TOOLS_SOURCE_DIR)/patchelf-$(PATCHELF_HOST_VERSION_LONG)


patchelf-host-source: $(DL_DIR)/$(PATCHELF_HOST_SOURCE)
$(DL_DIR)/$(PATCHELF_HOST_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(PATCHELF_HOST_SOURCE) $(PATCHELF_HOST_SITE) $(PATCHELF_HOST_SOURCE_SHA256)

patchelf-host-unpacked: $(PATCHELF_HOST_DIR)/.unpacked
$(PATCHELF_HOST_DIR)/.unpacked: $(DL_DIR)/$(PATCHELF_HOST_SOURCE) | $(TOOLS_SOURCE_DIR)
	tar -C $(TOOLS_SOURCE_DIR) $(VERBOSE) -xf $(DL_DIR)/$(PATCHELF_HOST_SOURCE)
	$(call APPLY_PATCHES,$(PATCHELF_HOST_MAKE_DIR)/patches,$(PATCHELF_HOST_DIR))
	touch $@

$(PATCHELF_HOST_DIR)/.configured: $(PATCHELF_HOST_DIR)/.unpacked
	(cd $(PATCHELF_HOST_DIR); $(RM) config.cache; \
		CC="$(TOOLS_CC)" \
		CXX="$(TOOLS_CXX)" \
		CFLAGS="$(TOOLS_CFLAGS)" \
		LDFLAGS="$(TOOLS_LDFLAGS)" \
		./configure \
		--prefix=/usr \
		$(QUIET) \
	);
	touch $@

$(PATCHELF_HOST_DIR)/src/patchelf: $(PATCHELF_HOST_DIR)/.configured
	$(MAKE) -C $(PATCHELF_HOST_DIR) all
	touch -c $@

$(TOOLS_DIR)/patchelf: $(PATCHELF_HOST_DIR)/src/patchelf
	$(INSTALL_FILE)

patchelf-host-precompiled: $(TOOLS_DIR)/patchelf


patchelf-host-clean:
	-$(MAKE) -C $(PATCHELF_HOST_DIR) clean

patchelf-host-dirclean:
	$(RM) -r $(PATCHELF_HOST_DIR)

patchelf-host-distclean: patchelf-host-dirclean
	$(RM) $(TOOLS_DIR)/patchelf


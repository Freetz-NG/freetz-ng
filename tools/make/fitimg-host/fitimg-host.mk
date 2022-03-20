FITIMG_HOST_VERSION:=0.7.2
FITIMG_HOST_SOURCE:=fitimg-$(FITIMG_HOST_VERSION).tar.gz
FITIMG_HOST_SOURCE_SHA256:=d83503f31a763143f242269e4ee834609dd4c2bcb5809ccdf19b4f06adb6f2ab
FITIMG_HOST_SITE:=https://boxmatrix.info/hosted/hippie2000
### WEBSITE:=https://boxmatrix.info/wiki/FIT-Image
### MANPAGE:=https://boxmatrix.info/wiki/FIT-Image#Usage
### CHANGES:=https://boxmatrix.info/wiki/FIT-Image#History

FITIMG_HOST_MAKE_DIR:=$(TOOLS_DIR)/make/fitimg-host
FITIMG_HOST_DIR:=$(TOOLS_SOURCE_DIR)/fitimg-$(FITIMG_HOST_VERSION)


fitimg-host-source: $(DL_DIR)/$(FITIMG_HOST_SOURCE)
$(DL_DIR)/$(FITIMG_HOST_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(FITIMG_HOST_SOURCE) $(FITIMG_HOST_SITE) $(FITIMG_HOST_SOURCE_SHA256)

fitimg-host-unpacked: $(FITIMG_HOST_DIR)/.unpacked
$(FITIMG_HOST_DIR)/.unpacked: $(DL_DIR)/$(FITIMG_HOST_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(FITIMG_HOST_SOURCE),$(TOOLS_SOURCE_DIR))
	$(call APPLY_PATCHES,$(FITIMG_HOST_MAKE_DIR)/patches,$(FITIMG_HOST_DIR))
	touch $@

$(FITIMG_HOST_DIR)/fitimg: $(FITIMG_HOST_DIR)/.unpacked

$(TOOLS_DIR)/fitimg: $(FITIMG_HOST_DIR)/fitimg
	$(INSTALL_FILE)

fitimg-host-precompiled: $(TOOLS_DIR)/fitimg


fitimg-host-clean:

fitimg-host-dirclean:
	$(RM) -r $(FITIMG_HOST_DIR)

fitimg-host-distclean: fitimg-host-dirclean
	$(RM) $(TOOLS_DIR)/fitimg


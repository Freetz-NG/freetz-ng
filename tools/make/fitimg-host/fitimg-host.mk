FITIMG_HOST_VERSION:=0.7
FITIMG_HOST_SOURCE:=fitimg-$(FITIMG_HOST_VERSION).tar.gz
FITIMG_HOST_SOURCE_MD5:=446ac12ae6e6c57538172fd6aba1744a
FITIMG_HOST_SITE:=https://boxmatrix.info/hosted/hippie2000

FITIMG_HOST_MAKE_DIR:=$(TOOLS_DIR)/make/fitimg-host
FITIMG_HOST_DIR:=$(TOOLS_SOURCE_DIR)/fitimg-$(FITIMG_HOST_VERSION)


fitimg-host-source: $(DL_DIR)/$(FITIMG_HOST_SOURCE)
$(DL_DIR)/$(FITIMG_HOST_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(FITIMG_HOST_SOURCE) $(FITIMG_HOST_SITE) $(FITIMG_HOST_SOURCE_MD5)

fitimg-host-unpacked: $(FITIMG_HOST_DIR)/.unpacked
$(FITIMG_HOST_DIR)/.unpacked: $(DL_DIR)/$(FITIMG_HOST_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(FITIMG_HOST_SOURCE),$(TOOLS_SOURCE_DIR))
	$(SED) -i "/$$section .= '.fit' unless/d" $(FITIMG_HOST_DIR)/fitimg
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


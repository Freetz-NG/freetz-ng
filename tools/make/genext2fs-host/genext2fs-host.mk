GENEXT2FS_VERSION:=4c1cc9468980448ca3e86db1cbe9600a4a084f5e
GENEXT2FS_SOURCE:=genext2fs-$(GENEXT2FS_VERSION).tar.xz
GENEXT2FS_SOURCE_SHA256:=a59f657ce6d12013d7343c7b84928723f0b8dec4a89e9542802c1257dce26ba6
GENEXT2FS_SITE:=git@https://github.com/bestouff/genext2fs.git
# see http://genext2fs.cvs.sourceforge.net/viewvc/genext2fs/genext2fs/genext2fs.c?view=log for more info
#GENEXT2FS_VERSION:=20131004
#GENEXT2FS_SOURCE_SHA256:=492052c02f774fa15e8d2dc0a49d0749d97ababbaf40ac7d3e93eda99b6fc777
#GENEXT2FS_SITE:=cvs@pserver:anonymous@genext2fs.cvs.sourceforge.net:/cvsroot/genext2fs

GENEXT2FS_MAKE_DIR:=$(TOOLS_DIR)/make/genext2fs-host
GENEXT2FS_DIR:=$(TOOLS_SOURCE_DIR)/genext2fs-$(GENEXT2FS_VERSION)


genext2fs-host-source: $(DL_DIR)/$(GENEXT2FS_SOURCE)
$(DL_DIR)/$(GENEXT2FS_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(GENEXT2FS_SOURCE) $(GENEXT2FS_SITE) $(GENEXT2FS_SOURCE_SHA256)

genext2fs-host-unpacked: $(GENEXT2FS_DIR)/.unpacked
$(GENEXT2FS_DIR)/.unpacked: $(DL_DIR)/$(GENEXT2FS_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(GENEXT2FS_SOURCE),$(TOOLS_SOURCE_DIR))
	$(call APPLY_PATCHES,$(GENEXT2FS_MAKE_DIR)/patches,$(GENEXT2FS_DIR))
	(cd $(GENEXT2FS_DIR); mv configure.in configure.ac)
	touch $@

$(GENEXT2FS_DIR)/.configured: $(GENEXT2FS_DIR)/.unpacked
	(cd $(GENEXT2FS_DIR); autoreconf -f -i; \
		CC="$(TOOLS_CC)" \
		CXX="$(TOOLS_CXX)" \
		CFLAGS="$(TOOLS_CFLAGS)" \
		LDFLAGS="$(TOOLS_LDFLAGS)" \
		./configure \
		--prefix=$(FREETZ_BASE_DIR)/$(TOOLS_DIR) \
		$(QUIET) \
	);
	touch $@

$(GENEXT2FS_DIR)/genext2fs: $(GENEXT2FS_DIR)/.configured
	$(MAKE) -C $(GENEXT2FS_DIR) all
	touch -c $@

genext2fs-host-test: $(GENEXT2FS_DIR)/.tests-passed
$(GENEXT2FS_DIR)/.tests-passed: $(GENEXT2FS_DIR)/genext2fs
	(cd $(GENEXT2FS_DIR); ./test.sh)
	touch $@

$(TOOLS_DIR)/genext2fs: $(GENEXT2FS_DIR)/genext2fs
	$(INSTALL_FILE)

genext2fs-host-precompiled: $(TOOLS_DIR)/genext2fs


genext2fs-host-clean:
	-$(MAKE) -C $(GENEXT2FS_DIR) clean
	$(RM) $(GENEXT2FS_DIR)/.configured $(GENEXT2FS_DIR)/.tests-passed

genext2fs-host-dirclean:
	$(RM) -r $(GENEXT2FS_DIR)

genext2fs-host-distclean: genext2fs-host-dirclean
	$(RM) $(TOOLS_DIR)/genext2fs


$(call PKG_INIT_BIN, 3.02.02)
$(PKG)_LIB_VERSION:=3.0.2
$(PKG)_SOURCE:=$(pkg)-ocr-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=26cd39cb3f2a6f6f1bf4050d1cc0aae35edee49eb49a92df3cb7f9487caa013d
$(PKG)_SITE:=http://tesseract-ocr.googlecode.com/files

$(PKG)_CATEGORY_LIBS:=Graphics & fonts

$(PKG)_BINARY_BUILD_DIR:=$($(PKG)_DIR)/api/.libs/$(pkg)
$(PKG)_BINARY_TARGET_DIR:=$($(PKG)_DEST_DIR)/usr/bin/$(pkg)

$(PKG)_TOOLS:=ambiguous_words classifier_tester cntraining combine_tessdata dawg2wordlist mftraining shapeclustering unicharset_extractor wordlist2dawg
$(PKG)_TOOLS_BUILD_DIR:=$($(PKG)_TOOLS:%=$($(PKG)_DIR)/training/.libs/%)
$(PKG)_TOOLS_TARGET_DIR:=$($(PKG)_TOOLS:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_TOOLS_SELECTED:=$(call PKG_SELECTED_SUBOPTIONS,$($(PKG)_TOOLS))
$(PKG)_TOOLS_EXCLUDED:=$(filter-out $($(PKG)_TOOLS_SELECTED),$($(PKG)_TOOLS))

$(PKG)_LIBNAME:=lib$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_LIBRARY_BUILD_DIR:=$($(PKG)_DIR)/api/.libs/$($(PKG)_LIBNAME)
$(PKG)_LIBRARY_STAGING_DIR:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$($(PKG)_LIBNAME)
$(PKG)_LIBRARY_TARGET_DIR:=$($(PKG)_TARGET_LIBDIR)/$($(PKG)_LIBNAME)

$(PKG)_DEPENDS_ON += libstdcxx leptonica
$(PKG)_REBUILD_SUBOPTS += FREETZ_STDCXXLIB
$(PKG)_EXCLUDED += $($(PKG)_TOOLS_EXCLUDED:%=usr/bin/%)

# remove optimization flags
$(PKG)_CONFIGURE_PRE_CMDS += $(foreach flag,-O[0-9],$(SED) -i -r -e 's,(C(XX|PP)?FLAGS="[^"]*)$(flag)(( [^"]*)?"),\1\3,g' ./configure;)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_ENV += CXX="$(TARGET_CXX_GNU)"
$(PKG)_CONFIGURE_ENV += LIBLEPT_HEADERSDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include"

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY_BUILD_DIR) $($(PKG)_TOOLS_BUILD_DIR) $($(PKG)_LIBRARY_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(TESSERACT_DIR)

$($(PKG)_LIBRARY_STAGING_DIR): $($(PKG)_LIBRARY_BUILD_DIR)
	$(SUBMAKE) -C $(TESSERACT_DIR)/api \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install-libLTLIBRARIES
	for subdir in api ccutil ccmain ccstruct; do \
		$(SUBMAKE) -C $(TESSERACT_DIR)/$${subdir} \
			DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
			install-includeHEADERS; \
	done
	$(SUBMAKE) -C $(TESSERACT_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install-pkgconfigDATA
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libtesseract.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/tesseract.pc

$($(PKG)_BINARY_TARGET_DIR): $($(PKG)_BINARY_BUILD_DIR)
	$(SUBMAKE) -C $(TESSERACT_DIR)/tessdata \
		DESTDIR="$(abspath $(TESSERACT_DEST_DIR))" \
		install
	$(INSTALL_BINARY_STRIP)

$($(PKG)_TOOLS_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/training/.libs/%
	$(INSTALL_BINARY_STRIP)

$($(PKG)_LIBRARY_TARGET_DIR): $($(PKG)_LIBRARY_STAGING_DIR)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_LIBRARY_STAGING_DIR)

$(pkg)-precompiled: $($(PKG)_BINARY_TARGET_DIR) $($(PKG)_TOOLS_TARGET_DIR) $($(PKG)_LIBRARY_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(TESSERACT_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libtesseract.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/tesseract.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/tesseract/

$(pkg)-uninstall:
	$(RM) -r \
		$(TESSERACT_BINARY_TARGET_DIR) \
		$(TESSERACT_DEST_DIR)/usr/share/tessdata \
		$(TESSERACT_TOOLS_TARGET_DIR) \
		$(TESSERACT_TARGET_LIBDIR)/libtesseract.so*

$(call PKG_ADD_LIB,libtesseract)
$(PKG_FINISH)

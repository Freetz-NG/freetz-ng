$(call PKG_INIT_BIN, 3.13.5)
$(PKG)_MAJOR_VERSION:=$(call GET_MAJOR_VERSION,$($(PKG)_VERSION))
$(PKG)_SOURCE:=Python-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=93e583f243454e6e9e4588ca2c2662206ad961659863277afcdb96801647d640
$(PKG)_SITE:=https://www.python.org/ftp/python/$($(PKG)_VERSION)
### WEBSITE:=https://www.python.org/
### MANPAGE:=https://docs.python.org/3/
### CHANGES:=https://www.python.org/downloads/
### CVSREPO:=https://github.com/python/cpython

$(PKG)_LOCAL_INSTALL_DIR:=$($(PKG)_DIR)/_install

$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/python$($(PKG)_MAJOR_VERSION).bin
$(PKG)_LIB_PYTHON3_TARGET_DIR:=$($(PKG)_TARGET_LIBDIR)/libpython$($(PKG)_MAJOR_VERSION).so.1.0
$(PKG)_ZIPPED_PYC:=usr/lib/python$(subst .,,$($(PKG)_MAJOR_VERSION)).zip
$(PKG)_ZIPPED_PYC_TARGET_DIR:=$($(PKG)_DEST_DIR)/$($(PKG)_ZIPPED_PYC)

$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/python$($(PKG)_MAJOR_VERSION)

include $(MAKE_DIR)/pkgs/python3/python3-module-macros.mk.in

include $(MAKE_DIR)/pkgs/python3/python3-filelists.mk.in

$(PKG)_MODULES_ALL := \
	audiodev audioop bsddb cmath cprofile crypt csv ctypes curses \
	eastern_codecs elementtree ensurepip grp hotshot json \
	mmap multiprocessing readline spwd sqlite ssl \
	syslog termios test unicodedata unittest wsgiref
$(PKG)_MODULES_SELECTED := $(call PKG_SELECTED_SUBOPTIONS,$($(PKG)_MODULES_ALL),MOD)
$(PKG)_MODULES_EXCLUDED := $(filter-out $($(PKG)_MODULES_SELECTED),$($(PKG)_MODULES_ALL))

$(PKG)_EXCLUDED_FILES   := $(call newline2space,$(foreach mod,$($(PKG)_MODULES_EXCLUDED),$(PyMod/$(mod)/files)))
$(PKG)_UNNECESSARY_DIRS := $(if $(FREETZ_PACKAGE_PYTHON3_COMPRESS_PYC),$(call newline2space,$(Python/unnecessary-if-compression-enabled/dirs)))
$(PKG)_UNNECESSARY_DIRS += $(call newline2space,$(foreach mod,$($(PKG)_MODULES_EXCLUDED),$(PyMod/$(mod)/dirs)))

$(PKG)_DEPENDS_ON += python3-host expat libffi zlib
$(PKG)_DEPENDS_ON += $(if $(FREETZ_PACKAGE_PYTHON3_MOD_BSDDB),db)
$(PKG)_DEPENDS_ON += $(if $(or $(FREETZ_PACKAGE_PYTHON3_MOD_CURSES),$(FREETZ_PACKAGE_PYTHON3_MOD_READLINE)),ncurses)
$(PKG)_DEPENDS_ON += $(if $(FREETZ_PACKAGE_PYTHON3_MOD_READLINE),readline)
$(PKG)_DEPENDS_ON += $(if $(FREETZ_PACKAGE_PYTHON3_MOD_SQLITE),sqlite)
$(PKG)_DEPENDS_ON += $(if $(FREETZ_PACKAGE_PYTHON3_MOD_SSL),openssl)

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PYTHON3_STATIC
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PYTHON3_MOD_BSDDB
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PYTHON3_MOD_CURSES
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PYTHON3_MOD_READLINE
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PYTHON3_MOD_SQLITE
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PYTHON3_MOD_SSL
$(PKG)_REBUILD_SUBOPTS += $(OPENSSL_REBUILD_SUBOPTS)
$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_IPV6_SUPPORT


$(PKG)_CONFIGURE_ENV += ac_cv_have_chflags=no
$(PKG)_CONFIGURE_ENV += ac_cv_have_lchflags=no
$(PKG)_CONFIGURE_ENV += ac_cv_py_format_size_t=no
$(PKG)_CONFIGURE_ENV += ac_cv_have_long_long_format=yes
$(PKG)_CONFIGURE_ENV += ac_cv_buggy_getaddrinfo=no
$(PKG)_CONFIGURE_ENV += ac_cv_file__dev_ptmx=no
$(PKG)_CONFIGURE_ENV += ac_cv_file__dev_ptc=no
$(PKG)_CONFIGURE_ENV += OPT="-fno-inline"

$(PKG)_CONFIGURE_OPTIONS += --with-system-expat
$(PKG)_CONFIGURE_OPTIONS += --with-build-python=$(abspath $(TOOLS_DIR)/path/python3)
$(PKG)_CONFIGURE_OPTIONS += --with-ensurepip=no
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_TARGET_IPV6_SUPPORT),--enable-ipv6,--disable-ipv6)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_PYTHON3_STATIC),--disable-shared,--enable-shared)

# remove local copy of libffi, we use system one
$(PKG)_CONFIGURE_PRE_CMDS += $(RM) -r Modules/_ctypes/libffi*;
# remove local copy of expat, we use system one
$(PKG)_CONFIGURE_PRE_CMDS += $(RM) -r Modules/expat;
# remove local copy of zlib, we use system one
$(PKG)_CONFIGURE_PRE_CMDS += $(RM) -r Modules/zlib;

ifneq ($(strip $(DL_DIR)/$(PYTHON3_SOURCE)),$(strip $(DL_DIR)/$(PYTHON3_HOST_SOURCE)))
$(PKG_SOURCE_DOWNLOAD)
endif
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_DIR)/.compiled: $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(PYTHON3_DIR) \
		all
	touch $@

$($(PKG)_DIR)/.installed: $($(PKG)_DIR)/.compiled
	$(SUBMAKE) -C $(PYTHON3_DIR) \
		DESTDIR="$(FREETZ_BASE_DIR)/$(PYTHON3_LOCAL_INSTALL_DIR)" \
		install
	(cd $(FREETZ_BASE_DIR)/$(PYTHON3_LOCAL_INSTALL_DIR); \
		chmod -R u+w usr; \
		$(RM) -r $(call newline2space,$(Python/unnecessary/files)); \
		\
		find usr/lib/python$(PYTHON3_MAJOR_VERSION)/ -name "*.pyo" -delete; \
		\
		[ "$(FREETZ_SEPARATE_AVM_UCLIBC)" == "y" ] && $(PATCHELF) --set-interpreter /usr/lib/freetz/ld-uClibc.so.1 usr/bin/python$(PYTHON3_MAJOR_VERSION); \
		\
		$(TARGET_STRIP) \
			usr/bin/python$(PYTHON3_MAJOR_VERSION) \
			$(if $(FREETZ_PACKAGE_PYTHON3_STATIC),,usr/lib/libpython$(PYTHON3_MAJOR_VERSION).so.1.0) \
			usr/lib/python$(PYTHON3_MAJOR_VERSION)/lib-dynload/*.so; \
		\
		mv usr/bin/python$(PYTHON3_MAJOR_VERSION) usr/bin/python$(PYTHON3_MAJOR_VERSION).bin; \
	)
	touch $@

$($(PKG)_STAGING_BINARY): $($(PKG)_DIR)/.installed
	@$(call COPY_USING_TAR,$(PYTHON3_LOCAL_INSTALL_DIR)/usr,$(TARGET_TOOLCHAIN_STAGING_DIR)/usr,--exclude='*.pyc' .) \
	$(PKG_FIX_LIBTOOL_LA) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/python-$(PYTHON3_MAJOR_VERSION).pc; \
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/python$(PYTHON3_MAJOR_VERSION).bin ; \
	touch -c $@

$($(PKG)_TARGET_BINARY): $($(PKG)_DIR)/.installed
	@$(call COPY_USING_TAR,$(PYTHON3_LOCAL_INSTALL_DIR),$(PYTHON3_DEST_DIR),--exclude='libpython$(PYTHON3_MAJOR_VERSION).so*' .) \
	(cd $(PYTHON3_DEST_DIR); \
		echo -n > usr/lib/python$(PYTHON3_MAJOR_VERSION)/config-$(PYTHON3_MAJOR_VERSION)/Makefile; \
		find usr/include/python$(PYTHON3_MAJOR_VERSION)/ -name "*.h" \! -name "pyconfig.h" \! -name "Python.h" -delete; \
		$(RM) -r $(call newline2space,$(Python/development/files)); \
	); \
	touch -c $@

ifneq ($(strip $(FREETZ_PACKAGE_PYTHON3_STATIC)),y)
$($(PKG)_LIB_PYTHON3_TARGET_DIR): $($(PKG)_DIR)/.installed
	@mkdir -p $(dir $@); \
	cp -a $(PYTHON3_LOCAL_INSTALL_DIR)/usr/lib/libpython$(PYTHON3_MAJOR_VERSION).so* $(dir $@); \
	touch -c $@
endif

$(pkg): $($(PKG)_TARGET_DIR)/.exclude-extra

$($(PKG)_TARGET_DIR)/py.lst $($(PKG)_TARGET_DIR)/pyc.lst: $($(PKG)_DIR)/.installed $(PACKAGES_DIR)/.$(pkg)-$($(PKG)_VERSION)
	@(cd $(FREETZ_BASE_DIR)/$(PYTHON3_LOCAL_INSTALL_DIR); \
		find usr -type f -name "*.$(basename $(notdir $@))"  | sort > $(FREETZ_BASE_DIR)/$@; \
	)

$($(PKG)_TARGET_DIR)/excluded-module-files.lst: $(TOPDIR)/.config $(PACKAGES_DIR)/.$(pkg)-$($(PKG)_VERSION)
	@(set -f; echo $(PYTHON3_EXCLUDED_FILES) | tr " " "\n" | sort > $@)

$($(PKG)_TARGET_DIR)/excluded-module-files-zip.lst: $($(PKG)_TARGET_DIR)/excluded-module-files.lst
	@cat $< | sed -r 's,usr/lib/python$(PYTHON3_MAJOR_VERSION)/,,g' > $@

$($(PKG)_ZIPPED_PYC_TARGET_DIR): $($(PKG)_TARGET_DIR)/excluded-module-files-zip.lst $($(PKG)_TARGET_BINARY)
	@(cd $(dir $@)/python$(PYTHON3_MAJOR_VERSION); \
		$(RM) ../$(notdir $@); \
		$(if $(FREETZ_PACKAGE_PYTHON3_COMPRESS_PYC),zip -9qyR -x@$(FREETZ_BASE_DIR)/$(PYTHON3_TARGET_DIR)/excluded-module-files-zip.lst ../$(notdir $@) . "*.pyc";) \
	); \
	touch $@

$($(PKG)_TARGET_DIR)/.exclude-extra: $(TOPDIR)/.config $($(PKG)_TARGET_DIR)/py.lst $($(PKG)_TARGET_DIR)/pyc.lst $($(PKG)_TARGET_DIR)/excluded-module-files.lst
	@echo -n "" > $@; \
	[ "$(FREETZ_PACKAGE_PYTHON3_PY)"  != y ] && cat $(PYTHON3_TARGET_DIR)/py.lst >> $@; \
	[ "$(FREETZ_PACKAGE_PYTHON3_PYC)" != y -o "$(FREETZ_PACKAGE_PYTHON3_COMPRESS_PYC)" == y ] && cat $(PYTHON3_TARGET_DIR)/pyc.lst >> $@; \
	(set -f; echo $(PYTHON3_UNNECESSARY_DIRS) | tr " " "\n" | sort >> $@); \
	[ "$(FREETZ_PACKAGE_PYTHON3_COMPRESS_PYC)" != y ] && echo "$(PYTHON3_ZIPPED_PYC)" >> $@; \
	cat $(PYTHON3_TARGET_DIR)/excluded-module-files.lst >> $@; \
	touch -c $@

$(pkg)-precompiled: $($(PKG)_STAGING_BINARY) $($(PKG)_TARGET_BINARY) $(if $(FREETZ_PACKAGE_PYTHON3_STATIC),,$($(PKG)_LIB_PYTHON3_TARGET_DIR)) $($(PKG)_ZIPPED_PYC_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(PYTHON3_DIR) clean
	$(RM) $(PYTHON3_FREETZ_CONFIG_FILE)
	$(RM) $(PYTHON3_DIR)/.configured $(PYTHON3_DIR)/.compiled $(PYTHON3_DIR)/.installed
	$(RM) $(PYTHON3_TARGET_DIR)/py.lst $(PYTHON3_TARGET_DIR)/pyc.lst
	$(RM) $(PYTHON3_TARGET_DIR)/excluded-module-files.lst $(PYTHON3_TARGET_DIR)/excluded-module-files-zip.lst $(PYTHON3_TARGET_DIR)/.exclude-extra
	$(RM) -r $(PYTHON3_LOCAL_INSTALL_DIR)
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/python*
	$(RM) -r $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/python$(PYTHON3_MAJOR_VERSION)
	$(RM) -r $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/python$(PYTHON3_MAJOR_VERSION)
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpython$(PYTHON3_MAJOR_VERSION).*
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/python*

$(pkg)-uninstall:
	$(RM) -r \
		$(PYTHON3_TARGET_BINARY) \
		$(PYTHON3_TARGET_LIBDIR)/libpython$(PYTHON3_MAJOR_VERSION).so* \
		$(PYTHON3_DEST_DIR)/usr/bin/python \
		$(PYTHON3_DEST_DIR)/usr/bin/python3 \
		$(PYTHON3_DEST_DIR)/usr/lib/python$(PYTHON3_MAJOR_VERSION) \
		$(PYTHON3_ZIPPED_PYC_TARGET_DIR) \
		$(PYTHON3_DEST_DIR)/usr/include/python$(PYTHON3_MAJOR_VERSION)

$(PKG_FINISH)

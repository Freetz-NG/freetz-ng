$(call PKG_INIT_LIB, 6.6)
$(PKG)_LIB_VERSION:=$($(PKG)_VERSION)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=355b4cbbed880b0381a04c46617b7656e362585d52e9cf84a67e2009b749ff11
$(PKG)_SITE:=@GNU/$(pkg),https://invisible-island.net/archives/ncurses
# run make/libs/ncurses/generate.sh after bump
### WEBSITE:=https://invisible-island.net/ncurses/
### MANPAGE:=https://invisible-island.net/ncurses/announce.html
### CHANGES:=https://invisible-island.net/ncurses/NEWS.html

$(PKG)_DEPENDS_ON += ncurses-host

$(PKG)_LIBCONFIG_SHORT := ncurses6-config
$(PKG)_LIBNAMES_SHORT := ncurses form menu panel
$(PKG)_LIBNAMES_LONG := $($(PKG)_LIBNAMES_SHORT:%=lib%.so.$($(PKG)_LIB_VERSION))
$(PKG)_LIBS_BUILD_DIR := $($(PKG)_LIBNAMES_LONG:%=$($(PKG)_DIR)/lib/%)
$(PKG)_LIBS_STAGING_DIR := $($(PKG)_LIBNAMES_LONG:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%)
$(PKG)_LIBS_TARGET_DIR := $($(PKG)_LIBNAMES_LONG:%=$($(PKG)_TARGET_DIR)/%)

$(PKG)_TABSET_MARKER_FILE := std
$(PKG)_TABSET_DIR := /usr/share/tabset
$(PKG)_TABSET_STAGING_DIR := $(TARGET_TOOLCHAIN_STAGING_DIR)$($(PKG)_TABSET_DIR)
$(PKG)_TABSET_TARGET_DIR := $($(PKG)_DEST_DIR)$($(PKG)_TABSET_DIR)

$(PKG)_TERMINFO_MARKER_FILE := .installed
$(PKG)_TERMINFO_DIR := /usr/share/terminfo
$(PKG)_TERMINFO_STAGING_DIR := $(TARGET_TOOLCHAIN_STAGING_DIR)$($(PKG)_TERMINFO_DIR)
$(PKG)_TERMINFO_TARGET_DIR := $($(PKG)_DEST_DIR)$($(PKG)_TERMINFO_DIR)

$(PKG)_PKGCONFIG_DIR := /usr/lib/pkgconfig

$(PKG)_CONFIGURE_ENV += cf_cv_func_nanosleep=yes
$(PKG)_CONFIGURE_ENV += cf_cv_link_dataonly=yes
# evaluated by running test program on target platform
$(PKG)_CONFIGURE_ENV += cf_cv_type_of_bool='unsigned char'
# Even though the test says that poll()-function works we prefer
# ncurses' select-based branch and set cf_cv_working_poll to 'no'
$(PKG)_CONFIGURE_ENV += cf_cv_working_poll=no

$(PKG)_CONFIGURE_OPTIONS += --enable-echo
$(PKG)_CONFIGURE_OPTIONS += --enable-const
$(PKG)_CONFIGURE_OPTIONS += --enable-overwrite
$(PKG)_CONFIGURE_OPTIONS += --enable-pc-files
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath-hack
$(PKG)_CONFIGURE_OPTIONS += --without-ada
$(PKG)_CONFIGURE_OPTIONS += --without-cxx
$(PKG)_CONFIGURE_OPTIONS += --without-cxx-binding
$(PKG)_CONFIGURE_OPTIONS += --without-debug
$(PKG)_CONFIGURE_OPTIONS += --without-profile
$(PKG)_CONFIGURE_OPTIONS += --without-progs
$(PKG)_CONFIGURE_OPTIONS += --without-manpages
$(PKG)_CONFIGURE_OPTIONS += --without-tests
$(PKG)_CONFIGURE_OPTIONS += --with-normal
$(PKG)_CONFIGURE_OPTIONS += --with-shared
$(PKG)_CONFIGURE_OPTIONS += --with-terminfo-dirs="$($(PKG)_TERMINFO_DIR)"
$(PKG)_CONFIGURE_OPTIONS += --with-default-terminfo-dir="$($(PKG)_TERMINFO_DIR)"
$(PKG)_CONFIGURE_OPTIONS += --with-pkg-config-libdir="$($(PKG)_PKGCONFIG_DIR)"

$(PKG)_CONFIGURE_OPTIONS += --disable-widec








ifneq ($(strip $(DL_DIR)/$(NCURSES_SOURCE)), $(strip $(DL_DIR)/$(NCURSES_HOST_SOURCE)))
$(PKG_SOURCE_DOWNLOAD)
endif
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_LIBS_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(NCURSES_DIR) \
		libs panel menu form headers

$($(PKG)_LIBS_STAGING_DIR): $($(PKG)_LIBS_BUILD_DIR)
	$(SUBMAKE) -C $(NCURSES_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install.libs
	$(PKG_FIX_LIBTOOL_LA) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/$(NCURSES_LIBCONFIG_SHORT)
	$(call PKG_FIX_LIBTOOL_LA,bindir datadir mandir) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/$(NCURSES_LIBCONFIG_SHORT)
	$(PKG_FIX_LIBTOOL_LA) $(NCURSES_LIBNAMES_SHORT:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/%.pc)

$($(PKG)_TABSET_STAGING_DIR)/$($(PKG)_TABSET_MARKER_FILE): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(NCURSES_DIR)/misc \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		all install.data
	touch $@

$($(PKG)_TERMINFO_STAGING_DIR)/$($(PKG)_TERMINFO_MARKER_FILE): $($(PKG)_TABSET_STAGING_DIR)/$($(PKG)_TABSET_MARKER_FILE)
	touch $@

$($(PKG)_LIBS_TARGET_DIR): $($(PKG)_TARGET_DIR)/%: $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%
	$(INSTALL_LIBRARY_STRIP)

define $(PKG)_INSTALL_T_RULE
$(1): $(2)
	$(RM) -r $$(dir $$@); \
	mkdir -p $$(dir $$@); \
	cp -a $$(dir $$<)/* $$(dir $$@); \
	touch $$@
endef

$(eval $(call $(PKG)_INSTALL_T_RULE,$($(PKG)_TABSET_TARGET_DIR)/$($(PKG)_TABSET_MARKER_FILE),$($(PKG)_TABSET_STAGING_DIR)/$($(PKG)_TABSET_MARKER_FILE)))
$(eval $(call $(PKG)_INSTALL_T_RULE,$($(PKG)_TERMINFO_TARGET_DIR)/$($(PKG)_TERMINFO_MARKER_FILE),$($(PKG)_TERMINFO_STAGING_DIR)/$($(PKG)_TERMINFO_MARKER_FILE)))

$(pkg)-terminfo: $($(PKG)_TABSET_TARGET_DIR)/$($(PKG)_TABSET_MARKER_FILE) $($(PKG)_TERMINFO_TARGET_DIR)/$($(PKG)_TERMINFO_MARKER_FILE)
$(pkg)-terminfo-precompiled: $(pkg)-terminfo

$(pkg): $($(PKG)_LIBS_STAGING_DIR)
$(pkg)-precompiled: $($(PKG)_LIBS_TARGET_DIR) $(pkg)-terminfo-precompiled


$(pkg)-terminfo-clean:
	$(RM) -r $(NCURSES_TABSET_STAGING_DIR) $(NCURSES_TERMINFO_STAGING_DIR)

$(pkg)-clean: $(pkg)-terminfo-clean
	-$(SUBMAKE) -C $(NCURSES_DIR) clean
	$(RM) \
		$(NCURSES_LIBNAMES_SHORT:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/lib%*) \
		$(NCURSES_LIBNAMES_SHORT:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/%.pc) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libncurses* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/$(NCURSES_LIBCONFIG_SHORT)
# shared	$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/{ncurses,ncurses_dll,term,curses,unctrl,termcap,eti,menu,form,panel}.h \

$(pkg)-terminfo-uninstall:
	$(RM) -r $(NCURSES_TABSET_TARGET_DIR) $(NCURSES_TERMINFO_TARGET_DIR)

$(pkg)-uninstall: $(pkg)-terminfo-uninstall
	$(RM) $(NCURSES_LIBNAMES_SHORT:%=$(NCURSES_TARGET_DIR)/lib%*)

$(PKG_FINISH)

$(call PKG_INIT_BIN, $(if $(FREETZ_GDB_VERSION_6_8),6.8,7.9.1))
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION)$(if $(FREETZ_GDB_VERSION_6_8),a).tar.$(if $(FREETZ_GDB_VERSION_6_8),bz2,xz)
$(PKG)_HASH_6.8   :=14cce3c259eb3563543a414fbf0f6b9dee4d7f2d1e89a2d8258b6918363ca522
$(PKG)_HASH_7.9.1 :=cd9c543a411a05b2b647dd38936034b68c2b5d6f10e0d51dc168c166c973ba40
$(PKG)_HASH:=$($(PKG)_HASH_$($(PKG)_VERSION))
$(PKG)_SITE:=@GNU/gdb

$(PKG)_CONDITIONAL_PATCHES+=$(call GET_MAJOR_VERSION,$($(PKG)_VERSION))
$(PKG)_PATCH_POST_CMDS += $(RM) -r ./readline;

$(PKG)_DEPENDS_ON += ncurses readline

$(PKG)_BINARIES_ALL           := gdb  gdbserver
$(PKG)_BINARIES_BUILD_SUBDIRS := gdb/ gdb/gdbserver/
$(PKG)_BINARIES               := $(call PKG_SELECTED_SUBOPTIONS,$($(PKG)_BINARIES_ALL))
$(PKG)_BINARIES_BUILD_DIR     := $(addprefix $($(PKG)_DIR)/, $(join $($(PKG)_BINARIES_BUILD_SUBDIRS),$($(PKG)_BINARIES_ALL)))
$(PKG)_BINARIES_TARGET_DIR    := $($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)
$(PKG)_EXCLUDED               += $(patsubst %,$($(PKG)_DEST_DIR)/usr/bin/%,$(filter-out $($(PKG)_BINARIES),$($(PKG)_BINARIES_ALL)))

$(PKG)_CATEGORY_PKGS:=Debug helpers

$(PKG)_REBUILD_SUBOPTS += FREETZ_GDB_VERSION_6_8
$(PKG)_REBUILD_SUBOPTS += FREETZ_GDB_VERSION_7_9

$(PKG)_CONFIGURE_ENV += CFLAGS_FOR_TARGET="$(TARGET_CFLAGS)"
$(PKG)_CONFIGURE_ENV += CPPFLAGS_FOR_TARGET="-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include"
$(PKG)_CONFIGURE_ENV += LDFLAGS_FOR_TARGET="-L$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib"

$(PKG)_CONFIGURE_OPTIONS += --enable-gdbserver
$(PKG)_CONFIGURE_OPTIONS += --enable-threads
$(PKG)_CONFIGURE_OPTIONS += --disable-tui
$(PKG)_CONFIGURE_OPTIONS += --disable-gdbtk
$(PKG)_CONFIGURE_OPTIONS += --disable-sim
$(PKG)_CONFIGURE_OPTIONS += --disable-werror

$(PKG)_CONFIGURE_OPTIONS += --with-system-readline=yes
$(PKG)_CONFIGURE_OPTIONS += --without-expat
$(PKG)_CONFIGURE_OPTIONS += --without-guile
$(PKG)_CONFIGURE_OPTIONS += --without-included-gettext
$(PKG)_CONFIGURE_OPTIONS += --without-libiconv-prefix
$(PKG)_CONFIGURE_OPTIONS += --without-python
$(PKG)_CONFIGURE_OPTIONS += --without-tcl
$(PKG)_CONFIGURE_OPTIONS += --without-tk
$(PKG)_CONFIGURE_OPTIONS += --without-uiout
$(PKG)_CONFIGURE_OPTIONS += --without-x
$(PKG)_CONFIGURE_OPTIONS += --without-zlib

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(GDB_DIR) \
		MT_CFLAGS="$(TARGET_CFLAGS)"

$(foreach binary,$($(PKG)_BINARIES_BUILD_DIR),$(eval $(call INSTALL_BINARY_STRIP_RULE,$(binary),/usr/bin)))

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(GDB_DIR) clean

$(pkg)-uninstall:
	$(RM) $(GDB_BINARIES_ALL:%=$(GDB_DEST_DIR)/usr/bin/%)

$(PKG_FINISH)

####################################################################################
#
# gdb for host
#
####################################################################################
GDB_HOST_DIR:=$(TARGET_TOOLCHAIN_DIR)/gdbhost-$(GDB_VERSION)
GDB_HOST_BINARY_BUILDDIR:=$(GDB_HOST_DIR)/gdb/gdb
GDB_HOST_BINARY_DESTDIR:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/$(TARGET_CROSS)gdb

$(GDB_HOST_DIR)/.configured: | $(GDB_DIR)/.unpacked
	mkdir -p $(GDB_HOST_DIR)
	(cd $(GDB_HOST_DIR); PATH=$(TARGET_PATH) \
		$(FREETZ_BASE_DIR)/$(GDB_DIR)/configure \
		--cache-file=/dev/null \
		--prefix=$(TARGET_TOOLCHAIN_STAGING_DIR) \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_HOST_NAME) \
		--target=$(REAL_GNU_TARGET_NAME) \
		--disable-nls \
		--enable-threads \
		--disable-tui \
		--disable-gdbtk \
		--disable-werror \
		--with-system-readline=yes \
		--without-uiout \
		--without-x \
		--without-included-gettext \
	);
	touch $@

$(GDB_HOST_BINARY_BUILDDIR): $(GDB_HOST_DIR)/.configured
	$(MAKE) -C $(GDB_HOST_DIR) \
		MAKEINFO=true
	strip $(GDB_HOST_BINARY_BUILDDIR)

$(GDB_HOST_BINARY_DESTDIR): $(GDB_HOST_BINARY_BUILDDIR)
	$(INSTALL_FILE)
	ln -sf $(TARGET_CROSS)gdb $(dir $@)/$(GNU_TARGET_NAME)-gdb

gdbhost: $(GDB_HOST_BINARY_DESTDIR)

gdbhost-clean:
	-$(MAKE) -C $(GDB_HOST_DIR) clean

gdbhost-uninstall:
	$(RM) $(GDB_HOST_BINARY_DESTDIR)

gdbhost-dirclean: gdbhost-uninstall
	$(RM) -r $(GDB_HOST_DIR)

.PHONY: gdbhost gdbhost-clean gdbhost-uninstall gdbhost-dirclean

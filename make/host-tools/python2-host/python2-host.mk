$(call TOOLS_INIT, 2.7.18)
$(PKG)_SOURCE:=Python-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=b62c0e7937551d0cc02b8fd5cb0f544f9405bafc9a54d3808ed4594812edef43
$(PKG)_SITE:=https://www.python.org/ftp/python/$($(PKG)_VERSION)
### WEBSITE:=https://www.python.org/
### MANPAGE:=https://docs.python.org/2/
### CHANGES:=https://www.python.org/downloads/
### CVSREPO:=https://github.com/python/cpython
### SUPPORT:=fda77

$(PKG)_MAJOR_VERSION:=$(call GET_MAJOR_VERSION,$($(PKG)_VERSION))
$(PKG)_MAJOR_VERSION_1:=$(call GET_MAJOR_VERSION,$($(PKG)_VERSION),1)
$(PKG)_SITE_PACKAGES:=$(HOST_TOOLS_DIR)/usr/lib/python$($(PKG)_MAJOR_VERSION)/site-packages

$(PKG)_BINARY:=$($(PKG)_DIR)/python
$(PKG)_TARGET_BINARY:=$(HOST_TOOLS_DIR)/usr/bin/python$($(PKG)_MAJOR_VERSION)

# python quirk: CFLAGS and OPT flags passed here are then used while cross-compiling -> use some target neutral flags
$(PKG)_CONFIGURE_ENV += OPT="-fno-inline"

$(PKG)_CONFIGURE_OPTIONS += --build=$(GNU_HOST_NAME)
$(PKG)_CONFIGURE_OPTIONS += --host=$(GNU_HOST_NAME)
$(PKG)_CONFIGURE_OPTIONS += --target=$(GNU_HOST_NAME)
$(PKG)_CONFIGURE_OPTIONS += --prefix=/usr
#
#

$(PKG)_CFLAGS := $(TOOLS_CFLAGS)
$(PKG)_CFLAGS += -std=gnu17


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	(PATH=$(TARGET_PATH); \
		$(TOOLS_SUBMAKE) -C $(PYTHON2_HOST_DIR) \
		CFLAGS="$(PYTHON2_HOST_CFLAGS)" \
		all Parser/pgen )
	@touch -c $@

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY) | $(HOST_TOOLS_DIR)
	mkdir -p $(HOST_TOOLS_DIR)/usr/bin
	cp -a $(PYTHON2_HOST_DIR)/Parser/pgen $(HOST_TOOLS_DIR)/usr/bin
	(PATH=$(TARGET_PATH); \
		$(TOOLS_SUBMAKE) -C $(PYTHON2_HOST_DIR) \
		DESTDIR="$(HOST_TOOLS_DIR)" \
		install )

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(MAKE) -C $(PYTHON2_HOST_DIR) clean

$(pkg)-dirclean:
	$(RM) -r $(PYTHON2_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) -r \
		$(PYTHON2_HOST_TARGET_BINARY) \
		$(HOST_TOOLS_DIR)/usr/bin/2to3 \
		$(HOST_TOOLS_DIR)/usr/bin/idle \
		$(HOST_TOOLS_DIR)/usr/bin/pgen \
		$(HOST_TOOLS_DIR)/usr/bin/pydoc \
		$(HOST_TOOLS_DIR)/usr/bin/python \
		$(HOST_TOOLS_DIR)/usr/bin/python-config \
		$(HOST_TOOLS_DIR)/usr/bin/python2* \
		$(HOST_TOOLS_DIR)/usr/bin/smtpd.py \
		$(HOST_TOOLS_DIR)/usr/include/python2* \
		$(HOST_TOOLS_DIR)/usr/lib/libpython2* \
		$(HOST_TOOLS_DIR)/usr/lib/pkgconfig/python-2* \
		$(HOST_TOOLS_DIR)/usr/lib/pkgconfig/python2* \
		$(HOST_TOOLS_DIR)/usr/lib/pkgconfig/python.pc \
		$(HOST_TOOLS_DIR)/usr/lib/python2* \
		$(HOST_TOOLS_DIR)/usr/share/man/man1/python.1 \
		$(HOST_TOOLS_DIR)/usr/share/man/man1/python2*

$(TOOLS_FINISH)

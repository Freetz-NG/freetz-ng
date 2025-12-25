$(call TOOLS_INIT, 6.6)
#$(PKG)_SOURCE_DOWNLOAD_NAME:=ncurses-$($(PKG)_VERSION).tgz
$(PKG)_SOURCE:=ncurses-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=355b4cbbed880b0381a04c46617b7656e362585d52e9cf84a67e2009b749ff11
$(PKG)_SITE:=@GNU/ncurses,https://invisible-island.net/archives/ncurses,https://invisible-island.net/archives/ncurses/current
### WEBSITE:=https://invisible-island.net/ncurses/
### MANPAGE:=https://invisible-island.net/ncurses/announce.html
### CHANGES:=https://invisible-island.net/ncurses/NEWS.html
### SUPPORT:=fda77


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_CONFIGURE)

$($(PKG)_DIR)/progs/tic: $($(PKG)_DIR)/.configured
	$(TOOLS_SUBMAKE) -C $(NCURSES_HOST_DIR) all
	touch -c $@

$(TOOLS_DIR)/tic: $($(PKG)_DIR)/progs/tic
	$(INSTALL_FILE)

$(pkg)-precompiled: $(TOOLS_DIR)/tic


$(pkg)-clean:
	-$(MAKE) -C $(NCURSES_HOST_DIR) clean

$(pkg)-dirclean:
	$(RM) -r $(NCURSES_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) $(TOOLS_DIR)/tic

$(TOOLS_FINISH)

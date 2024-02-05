$(call TOOLS_INIT, 7.5.2)
$(PKG)_SOURCE:=dos2unix-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=264742446608442eb48f96c20af6da303cb3a92b364e72cb7e24f88239c4bf3a
$(PKG)_SITE:=@SF/dos2unix
### WEBSITE:=https://dos2unix.sourceforge.io/
### MANPAGE:=https://waterlan.home.xs4all.nl/dos2unix/man1/dos2unix.htm
### CHANGES:=https://dos2unix.sourceforge.io/dos2unix/NEWS.txt
### CVSREPO:=https://sourceforge.net/p/dos2unix/dos2unix/ci/master/tree/

$(PKG)_BINARY:=$($(PKG)_DIR)/dos2unix
$(PKG)_TARGET_BINARY:=$(TOOLS_DIR)/dos2unix


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_NOP)

xx: $($(PKG)_DIR)/.configured
	echo $(DOS2UNIX_HOST_DIR)/.configured

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(TOOLS_SUBMAKE) -C $(DOS2UNIX_HOST_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_FILE)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(MAKE) -C $(DOS2UNIX_HOST_DIR) clean

$(pkg)-dirclean:
	$(RM) -r $(DOS2UNIX_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) $(DOS2UNIX_HOST_TARGET_BINARY)

$(TOOLS_FINISH)

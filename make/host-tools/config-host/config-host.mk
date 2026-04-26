$(call TOOLS_INIT, a2287c3041a3f2a204eb942e09c015eab00dc7dd)
$(PKG)_SOURCE:=$(pkg_short)-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=c92f245bfba49918f89314cbde0090b850b5bea12bac9553b7c3ab6aad255e02
$(PKG)_SITE:=git@https://https.git.savannah.gnu.org/git/config.git
#$(PKG)_SITE:=https://cgit.git.savannah.gnu.org/cgit/config.git/snapshot
### WEBSITE:=https://savannah.gnu.org/projects/config
### CHANGES:=https://cgit.git.savannah.gnu.org/cgit/config.git/log/
### CVSREPO:=https://cgit.git.savannah.gnu.org/cgit/config.git
### STEWARD:=fda77

$(PKG)_DESTDIR             := $(FREETZ_BASE_DIR)/$(TOOLS_BUILD_DIR)

$(PKG)_BINARIES            := config.guess config.sub
$(PKG)_BINARIES_BUILD_DIR  := $($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DESTDIR)/etc/%)


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_NOP)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	@touch -c $@

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DESTDIR)/etc/%: $($(PKG)_DIR)/%
	$(INSTALL_FILE)

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)


$(pkg)-clean:
	$(RM) $(CONFIG_HOST_DIR)/.{configured}

$(pkg)-dirclean:
	$(RM) -r $(CONFIG_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) $(CONFIG_HOST_BINARIES_TARGET_DIR)

$(TOOLS_FINISH)

$(call PKG_INIT_BIN, 4.0.5)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=c2e6d193cc78f84cd6ddb72aaf6d5c6a9162f0470e5992092057f5ff518562fa
$(PKG)_SITE:=@SF/procps-ng/Production
### WEBSITE:=https://gitlab.com/procps-ng/procps
### MANPAGE:=https://linux.die.net/man/1/ps
### CHANGES:=https://gitlab.com/procps-ng/procps/-/tags
### CVSREPO:=https://gitlab.com/procps-ng/procps
### SUPPORT:=Ircama

$(PKG)_BINARIES_SRC_DIR             := ps        top .    .      .      .  .   .     .     .     .    .       .     .     .     .     .      .   
$(PKG)_BINARIES_ALL                 := ps        top free uptime vmstat w pmap pgrep pkill pidof pwdx slabtop tload watch skill snice sysctl kill
$(PKG)_BINARIES_SRC                 := pscommand top free uptime vmstat w pmap pgrep pkill pidof pwdx slabtop tload watch skill snice sysctl kill

$(PKG)_BINARIES_POSTFIX             := -ng
$(PKG)_BINARIES                     := $(call PKG_SELECTED_SUBOPTIONS,$($(PKG)_BINARIES_ALL))
$(PKG)_BINARIES_TARGET              := $($(PKG)_BINARIES:%=%$($(PKG)_BINARIES_POSTFIX))
$(PKG)_BINARIES_BUILD_DIR           := $(join $($(PKG)_BINARIES_SRC_DIR:%=$($(PKG)_DIR)/src/%/),$($(PKG)_BINARIES_SRC))
$(PKG)_BINARIES_ALL_TARGET_DIR      := $($(PKG)_BINARIES_ALL:%=$($(PKG)_DEST_DIR)/usr/bin/%$($(PKG)_BINARIES_POSTFIX))
$(PKG)_FILTER_OUT                    = $(foreach k,$(1), $(foreach v,$(2), $(if $(subst $(notdir $(v)),,$(k)),,$(v)) ) )
$(PKG)_BINARIES_TARGET_DIR          := $(call $(PKG)_FILTER_OUT,$($(PKG)_BINARIES_TARGET),$($(PKG)_BINARIES_ALL_TARGET_DIR))
$(PKG)_EXCLUDED                     += $(filter-out $($(PKG)_BINARIES_TARGET_DIR),$($(PKG)_BINARIES_ALL_TARGET_DIR))

$(PKG)_CONFIGURE_PRE_CMDS += $(AUTORECONF)

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PROCPS_NG_WITH_NONE
ifneq ($(strip $(FREETZ_PACKAGE_PROCPS_NG_WITH_NCURSESW)),y)
ifneq ($(strip $(FREETZ_PACKAGE_PROCPS_NG_WITH_NCURSES)),y)
$(PKG)_CONFIGURE_OPTIONS += --without-ncurses
endif
endif

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PROCPS_NG_WITH_NCURSES
ifeq ($(strip $(FREETZ_PACKAGE_PROCPS_NG_WITH_NCURSES)),y)
$(PKG)_DEPENDS_ON += ncurses-terminfo ncurses
$(PKG)_CONFIGURE_ENV += NCURSES_LIBS=-lncurses
$(PKG)_CONFIGURE_OPTIONS += --with-ncurses
endif

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PROCPS_NG_WITH_NCURSESW
ifeq ($(strip $(FREETZ_PACKAGE_PROCPS_NG_WITH_NCURSESW)),y)
$(PKG)_DEPENDS_ON += ncurses-terminfo ncursesw
$(PKG)_CONFIGURE_ENV += NCURSES_LIBS=-lncursesw
$(PKG)_CONFIGURE_OPTIONS += --with-ncurses
endif

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-shared
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += --disable-nls
$(PKG)_CONFIGURE_OPTIONS += --enable-w-from
$(PKG)_CONFIGURE_OPTIONS += --enable-skill
$(PKG)_CONFIGURE_OPTIONS += --disable-pidwait
$(PKG)_CONFIGURE_OPTIONS += --disable-watch8bit
$(PKG)_CONFIGURE_OPTIONS += --disable-libselinux
$(PKG)_CONFIGURE_OPTIONS += --without-systemd
$(PKG)_CONFIGURE_OPTIONS += --without-elogind


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR): $(PROCPS_NG_DIR)/.configured
	$(SUBMAKE) -C $(PROCPS_NG_DIR)

$(foreach binary,$($(PKG)_BINARIES_BUILD_DIR),$(eval $(call INSTALL_BINARY_STRIP_RULE,$(binary),/usr/bin,,$(if $(filter pscommand,$(notdir $(binary))),ps, $(notdir $(binary)))$($(PKG)_BINARIES_POSTFIX))))

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)


$(pkg)-clean:
	-$(SUBMAKE) -C $(PROCPS_NG_DIR) clean
	$(RM) $(PROCPS_NG_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(PROCPS_NG_BINARIES_ALL_TARGET_DIR)

$(PKG_FINISH)

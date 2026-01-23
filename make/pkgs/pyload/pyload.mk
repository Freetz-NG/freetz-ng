$(call PKG_INIT_BIN, 0.4.x)
$(PKG)_SOURCE_DOWNLOAD_NAME:=v$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=feb94092e9f2c195a73e978bfbdf147d553b92c5e89541ce9620e8026533678e
$(PKG)_SITE:=https://github.com/pyload/pyload/archive/refs/tags
### WEBSITE:=https://www.pyload.net/
### MANPAGE:=https://github.com/pyload/pyload/wiki
### CHANGES:=https://github.com/pyload/pyload/releases
### CVSREPO:=https://github.com/pyload/pyload/commits/
### SUPPORT:=fda77

$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/opt/pyLoad/pyLoadCore.py

define pyLoad/build/files
.build-prereq-checked
.unpacked
.configured
.exclude
endef

define pyLoad/unnecessary/files
.hgignore
.gitattributes
docs
icons
LICENSE
locale
module/cli
module/gui
module/lib/wsgiserver/LICENSE.txt
module/web/servers
pavement.py
pyLoadCli.py
pyLoadGui.py
README
scripts
setup.cfg
systemCheck.py
testlinks.txt
tests
endef


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_DIR)/.exclude: $($(PKG)_DIR)/.configured
	@$(call write-list-to-file,$(call newline2space,$(pyLoad/build/files)) $(call newline2space,$(pyLoad/unnecessary/files)),$@)

$($(PKG)_TARGET_BINARY): $($(PKG)_DIR)/.exclude
	@mkdir -p $(dir $@); \
	$(call COPY_USING_TAR,$(PYLOAD_DIR),$(dir $@),--exclude-from=$< .) \
	touch -c $@

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	$(RM) $(PYLOAD_DIR)/.exclude

$(pkg)-uninstall:
	$(RM) -r $(dir $(PYLOAD_TARGET_BINARY))

$(PKG_FINISH)

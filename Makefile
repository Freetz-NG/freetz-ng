# Makefile for Freetz, Kernel 2.6 series
#
# Copyright (C) 1999-2004 by Erik Andersen <andersen@codepoet.org>
# Copyright (C) 2005-2006 by Daniel Eiband <eiband@online.de>
# Copyright (C) 2006-2018 by the Freetz developers (http://freetz.org)
# Copyright (C) 2019 by Freetz developers (https://freetz-ng.github.io/ and https://freetz.github.io)
#
# Licensed under the GPL v2, see the file COPYING in this tarball.

#--------------------------------------------------------------
# Just run 'make menuconfig', configure stuff, then run 'make'.
# You shouldn't need to mess with anything beyond this point...
#--------------------------------------------------------------
TOPDIR=.
CONFIG_IN=config/Config.in
CONFIG_IN_CACHE=config/.cache.in
CONFIG_IN_CUSTOM=config/custom.in
CONFIG=tools/config

SHELL:=/bin/bash
IMAGE:=
LOCALIP:=
RECOVER:=
export FREETZ_BASE_DIR:=$(shell pwd)
ADDON_DIR:=addon
BUILD_DIR:=build
DL_DIR:=dl
FAKEROOT_CACHE_DIR:=.fakeroot-cache
INCLUDE_DIR:=include
MAKE_DIR:=make
KERNEL_TARGET_DIR:=kernel
PACKAGES_DIR_ROOT:=packages
SOURCE_DIR_ROOT:=source
TOOLCHAIN_DIR:=toolchain
TOOLS_DIR:=tools
DL_FW_DIR:=$(DL_DIR)/fw
export FW_IMAGES_DIR:=images
MIRROR_DIR:=$(DL_DIR)/mirror

TOOLCHAIN_BUILD_DIR:=$(TOOLCHAIN_DIR)/$(BUILD_DIR)
TOOLS_BUILD_DIR:=$(TOOLS_DIR)/$(BUILD_DIR)

SED:=sed
TAR:=$(TOOLS_DIR)/tar-gnu

# Don't go parallel
.NOTPARALLEL:
# We don't use suffixes in the main make, don't waste time searching for files
.SUFFIXES:

MAKE1=make
MAKE=make -j$(FREETZ_JLEVEL)

DL_TOOL:=$(TOOLS_DIR)/freetz_download
PATCH_TOOL:=$(TOOLS_DIR)/freetz_patch
PARSE_CONFIG_TOOL:=$(TOOLS_DIR)/parse-config
CHECK_PREREQ_TOOL:=$(TOOLS_DIR)/prerequisites
GENERATE_IN_TOOL:=$(TOOLS_DIR)/genin

# do not use sorted-wildcard here, it's first defined in files included here
include $(sort $(wildcard include/make/*.mk))

# Use echo -e "$(_Y)message$(_N)" if you want to print a yellow message
IS_TTY=$(shell tty -s && echo 1 || echo 0)

ifeq ($(IS_TTY),1)
_Y:=\\033[33m
__Y:=\033[33m
_N:=\\033[m
__N:=\033[m
endif
export __Y
export __N

define MESSAGE
printf "%s\n" "$(1)" $(SILENT)
endef

define nMESSAGE
printf "\n%s" "$(1)" $(SILENT)
endef

# Print yellow error message and exit
define ERROR
printf "\n$(_Y)%s$(_N)\n" "ERROR: $(2)";  exit $(1);
endef

# check for very old linux with kernel v3 or less
ifeq ($(shell uname -r | sed 's/\..*//;s/^[1-3]//'),)
$(info Your Linux System is very old. Please upgrade it or use Freetz-Linux: https://github.com/Freetz-NG/freetz-ng/blob/master/README.md)
endif

# check for proper make version
ifneq ($(filter 3.7% 3.80 3.81,$(MAKE_VERSION)),)
$(error Your make ($(MAKE_VERSION)) is too old. Go get at least 3.82)
endif

# Current user == root? -> Error
ifeq ($(shell echo $$UID),0)
$(error Running makefile as root is prohibited! Please build Freetz as normal user)
endif

# Mod archive unpacked incorrectly (heuristics)? -> Error
ifeq ($(shell MWW=make/mod/files/root/usr/mww; \
	[ ! -L $$MWW/cgi-bin/index.cgi -o ! -x $$MWW/cgi-bin/status.cgi -o -x $$MWW/index.html ] \
	&& echo y\
),y)
$(error File permissions or links are wrong! Please unpack Freetz on a filesystem with Unix-like permissions)
endif

# Folder root/ needs 755 permissions
ifneq ($(shell stat -c %a make/mod/files/root),755)
$(error Wrong build directory permissions. Please set umask to 0022 and then unpack/checkout again in a directory having no uid-/gid-bits set)
endif

# We need umask 0022
ifneq ($(shell umask),0022)
$(error Please run "umask 0022", it is now $(shell umask))
endif

# We don't like cygwin
ifeq ($(shell uname -o),Cygwin)
$(error Cygwin is not supported! Please use a real Linux environment)
endif

# git-svn removes empty directories, check for one of them
ifneq (OK,$(shell [ -d make/mod/files/root/sys ] && echo OK))
$(error The empty directory root/sys is missing! Please do a clean checkout)
endif

# Simple checking of build prerequisites
ifneq ($(NO_PREREQ_CHECK),y)
ifneq (OK,$(shell $(CHECK_PREREQ_TOOL) >&2 && echo OK))
$(error Some build prerequisites are missing! See '.prerequisites' for why. Please install the missing packages before trying again. See https://freetz-ng.github.io/freetz-ng/PREREQUISITES for installation hints)
endif
endif

# There are known problems with mksquashfs3 and SUSE's gcc-4.5.0
ifeq ($(shell gcc --version | grep -q "gcc (SUSE Linux) 4.5.0 20100604" && echo y),y)
$(error gcc (SUSE Linux) 4.5.0 has known bugs. Please install and use a different version)
endif

# genin: (re)generate .in files if necessary
ifneq ($(findstring clean,$(MAKECMDGOALS)),clean)
# Note: the list of the packages to be treated specially (the 3rd argument of get-subdirs-containing) should match that used in genin
ifneq ($(call genin-get-considered-packages,make/Config.in.generated),$(call get-subdirs-containing,make,Config.in,libs busybox asterisk[-].* python[-].* iptables-cgi ruby-fcgi nhipt sg3_utils))
ifneq ($(shell $(GENERATE_IN_TOOL) $(if $(findstring legacy,$(MAKECMDGOALS)),legacy) >&2 && echo OK),OK)
$(error genin failed)
endif
endif
endif

all: step
world: check-dot-config-uptodateness $(DL_DIR) $(BUILD_DIR) $(KERNEL_TARGET_DIR) $(PACKAGES_DIR_ROOT) $(SOURCE_DIR_ROOT) $(TOOLCHAIN_BUILD_DIR)

KCONFIG_TARGETS:=menuconfig menuconfig-single config oldconfig olddefconfig allnoconfig allyesconfig randconfig listnewconfig config-compress

# load user configuration file
-include $(TOPDIR)/.config

ifneq ($(findstring menuconfig,$(MAKECMDGOALS)),menuconfig)
# check cpu for x86_64
ifneq ($(shell uname -m),x86_64)
ifeq ($(FREETZ_DOWNLOAD_TOOLCHAIN),y)
DLCHG:=$(shell echo 'y' ; sed 's/^# FREETZ_BUILD_TOOLCHAIN .*/FREETZ_BUILD_TOOLCHAIN=y/' -i $(TOPDIR)/.config)
DLCHG:=$(shell echo 'y' ; sed 's/^FREETZ_DOWNLOAD_TOOLCHAIN=.*/# FREETZ_DOWNLOAD_TOOLCHAIN is not set/' -i $(TOPDIR)/.config)
$(info You have no x86_64 CPU, precompiled (download) toolchains automatically disabled.)
endif
ifeq ($(FREETZ_HOSTTOOLS_DOWNLOAD),y)
DLCHG:=$(shell echo 'y' ; sed 's/^FREETZ_HOSTTOOLS_DOWNLOAD=.*/# FREETZ_HOSTTOOLS_DOWNLOAD is not set/' -i $(TOPDIR)/.config)
$(info You have no x86_64 CPU, precompiled (download) host-tools automatically disabled.)
endif
endif
# change LAST_SYSTEM_ID: 999 -> 899
ifeq ($(shell sed -n 's/^FREETZ_BUSYBOX___V..._LAST_SYSTEM_ID=//p' $(TOPDIR)/.config),999)
DLCHG:=$(shell echo 'y' ; sed 's/^\(FREETZ_BUSYBOX___V..._LAST_SYSTEM_ID\)=.*/\1=899/' -i $(TOPDIR)/.config)
$(info BusyBox LAST_SYSTEM_ID automatically changed.)
endif
#
$(if $(DLCHG),$(error Please re-run))
endif

VERBOSE:=
QUIET:=--quiet
QUIETSHORT:=-q
QUIETCMAKE:=-DCMAKE_MESSAGE_LOG_LEVEL=error

ifeq ($(strip $(FREETZ_VERBOSITY_LEVEL)),0)
.SILENT:
# Don't be silent when a menuconfig target is called
ifneq ($(findstring menuconfig,$(MAKECMDGOALS)),menuconfig)
#SILENT:= >>build.log 2>&1
SILENT:= > /dev/null 2>&1
endif
endif

ifeq ($(strip $(FREETZ_VERBOSITY_LEVEL)),2)
#VERBOSE:=-v # Show files on untar
QUIET:=
QUIETSHORT:=
QUIETCMAKE:=-DCMAKE_MESSAGE_LOG_LEVEL=status
endif

export FREETZ_VERBOSITY_LEVEL
export VERBOSE

include $(TOOLS_DIR)/make/Makefile.in
include $(call sorted-wildcard,$(TOOLS_DIR)/make/*/*.mk)

TOOLS_CACHECLEAN:=$(patsubst %,%-cacheclean,$(TOOLS))
TOOLS_CLEAN:=$(patsubst %,%-clean,$(TOOLS))
TOOLS_DIRCLEAN:=$(patsubst %,%-dirclean,$(TOOLS))
TOOLS_DISTCLEAN:=$(patsubst %,%-distclean,$(TOOLS))
TOOLS_SOURCE:=$(patsubst %,%-source,$(TOOLS))
TOOLS_PRECOMPILED:=$(patsubst %,%-precompiled,$(TOOLS))

$(DL_DIR):
	@ \
	[ ! -e "$(DL_DIR)" -a ! -L "$(DL_DIR)" ] && ln -s ~/.freetz-dl "$(DL_DIR)"; \
	[ -d "$(DL_DIR)" ] || mkdir -p "$$(readlink "$(DL_DIR)")"

$(DL_FW_DIR) $(MIRROR_DIR): | $(DL_DIR)
	@mkdir -p $@

$(BUILD_DIR) \
$(KERNEL_TARGET_DIR) \
$(PACKAGES_DIR_ROOT) \
$(SOURCE_DIR_ROOT) \
$(TOOLCHAIN_BUILD_DIR) \
$(TOOLS_BUILD_DIR) \
$(FW_IMAGES_DIR):
	@mkdir -p $@

ifneq ($(strip $(FREETZ_HAVE_DOT_CONFIG)),y)

step: menuconfig
cacheclean: $(TOOLS_CACHECLEAN) common-cacheclean
clean: $(TOOLS_CLEAN) common-clean
dirclean: $(TOOLS_DIRCLEAN) common-dirclean
distclean: $(TOOLS_DISTCLEAN) common-distclean

else

step: image world tools firmware

-include .config.cmd

include $(TOOLCHAIN_DIR)/make/Makefile.in
include $(MAKE_DIR)/Makefile.image.in
include $(MAKE_DIR)/Makefile.in
include $(call sorted-wildcard,$(MAKE_DIR)/libs/*/Makefile.in)
include $(call sorted-wildcard,$(MAKE_DIR)/*/Makefile.in)

ALL_PACKAGES:=
NON_LOCALSOURCE_PACKAGES:=
include $(call sorted-wildcard,$(MAKE_DIR)/libs/*/*.mk)
include $(call sorted-wildcard,$(MAKE_DIR)/*/*.mk)
PACKAGES_CHECK_DOWNLOADS:=$(patsubst %,%-check-download,$(NON_LOCALSOURCE_PACKAGES))
PACKAGES_MIRROR:=$(patsubst %,%-download-mirror,$(NON_LOCALSOURCE_PACKAGES))

TARGETS_CLEAN:=$(patsubst %,%-clean,$(TARGETS))
TARGETS_DIRCLEAN:=$(patsubst %,%-dirclean,$(TARGETS))
TARGETS_SOURCE:=$(patsubst %,%-source,$(TARGETS))
TARGETS_PRECOMPILED:=$(patsubst %,%-precompiled,$(TARGETS))

PACKAGES_BUILD:=$(patsubst %,%-package,$(PACKAGES))
PACKAGES_CLEAN:=$(patsubst %,%-clean,$(PACKAGES))
PACKAGES_DIRCLEAN:=$(patsubst %,%-dirclean,$(PACKAGES))
PACKAGES_LIST:=$(patsubst %,%-list,$(PACKAGES))
PACKAGES_SOURCE:=$(patsubst %,%-source,$(PACKAGES))
PACKAGES_PRECOMPILED:=$(patsubst %,%-precompiled,$(PACKAGES))

LIBS_CLEAN:=$(patsubst %,%-clean,$(LIBS))
LIBS_DIRCLEAN:=$(patsubst %,%-dirclean,$(LIBS))
LIBS_SOURCE:=$(patsubst %,%-source,$(LIBS))
LIBS_PRECOMPILED:=$(patsubst %,%-precompiled,$(LIBS))

TOOLCHAIN_CLEAN:=$(patsubst %,%-clean,$(TOOLCHAIN))
TOOLCHAIN_DIRCLEAN:=$(patsubst %,%-dirclean,$(TOOLCHAIN))
TOOLCHAIN_DISTCLEAN:=$(patsubst %,%-distclean,$(TOOLCHAIN))
TOOLCHAIN_SOURCE:=$(patsubst %,%-source,$(TOOLCHAIN))

ifeq ($(strip $(FREETZ_BUILD_TOOLCHAIN)),y)
include $(TOOLCHAIN_DIR)/make/kernel-toolchain.mk
include $(TOOLCHAIN_DIR)/make/target-toolchain.mk
else
include $(TOOLCHAIN_DIR)/make/download-toolchain.mk
endif

package-list: package-list-clean $(PACKAGES_LIST)
	@touch .packages

package-list-clean:
	@$(RM) .packages

firmware-nocompile: tools $(DL_IMAGE)
ifneq ($(strip $(FREETZ_FWMOD_SKIP_ALL)),y)
	@./fwmod \
		$(if $(call is-y,$(FREETZ_FWMOD_SKIP_UNPACK)),,-u)                                   \
		$(if $(call is-y,$(FREETZ_FWMOD_SKIP_MODIFY)),,-m)                                   \
		$(if $(call is-y,$(FREETZ_FWMOD_SKIP_PACK)),,-p)                                     \
		$(if $(call is-y,$(FREETZ_FWMOD_VALIDATE)),-v "$(strip $(FREETZ_AVM_SIGNATURE_KEY))",)                                         \
		$(if $(call is-y,$(FREETZ_FWMOD_VALIDATE)),$(if $(call is-y,$(FREETZ_DL_ALIEN)),-w "$(strip $(FREETZ_AVM_SIGNATURE_KEY2))",),) \
		$(if $(call is-y,$(FREETZ_FWMOD_VALIDATE)),$(if $(call is-y,$(FREETZ_DL_ALIEN)),-x "$(strip $(FREETZ_AVM_SIGNATURE_KEY3))",),) \
		$(if $(call is-y,$(FREETZ_FWMOD_SIGN)),-s)                                           \
		$(if $(call is-y,$(FREETZ_FWMOD_USBROOT)),-z)                                        \
		$(if $(strip $(FREETZ_FWMOD_NFSROOT_DIR)),-c "$(strip $(FREETZ_FWMOD_NFSROOT_DIR))") \
		$(if $(filter firmware-nocompile,$(MAKECMDGOALS)),-n)                                \
		$(if $(call is-y,$(FREETZ_FWMOD_FORCE_PACK)),-f)                                     \
		-d $(BUILD_DIR)                                                                      \
		$(DL_IMAGE)
endif

ifneq ($(strip $(FREETZ_FWMOD_SKIP_MODIFY)),y)
firmware-nocompile: $(PACKAGES) package-list .config.compressed
firmware: precompiled
endif

firmware: firmware-nocompile

test: $(BUILD_DIR)/modified
	@echo "no tests defined"

toolchain-depend: | $(TOOLCHAIN)
# Use KTV and TTV variables to provide new toolchain versions, i.e.
#   make KTV=freetz-0.4 TTV=freetz-0.5 toolchain
toolchain: $(DL_DIR) $(SOURCE_DIR_ROOT) $(TOOLCHAIN) tools
	@echo
	@echo "Creating toolchain tarballs ... "
	@$(call TOOLCHAIN_CREATE_TARBALL,$(KERNEL_TOOLCHAIN_STAGING_DIR),$(KTV))
	@$(call TOOLCHAIN_CREATE_TARBALL,$(TARGET_TOOLCHAIN_STAGING_DIR),$(TTV))
	@echo
	@echo "FINISHED: new download toolchains can be found in $(DL_DIR)/"

libs: $(DL_DIR) $(SOURCE_DIR_ROOT) $(LIBS_PRECOMPILED)

sources: $(DL_DIR) $(FW_IMAGES_DIR) $(SOURCE_DIR_ROOT) $(PACKAGES_DIR_ROOT) $(DL_IMAGE) \
	$(TARGETS_SOURCE) $(PACKAGES_SOURCE) $(LIBS_SOURCE) $(TOOLCHAIN_SOURCE) $(TOOLS_SOURCE)

precompiled: $(DL_DIR) $(FW_IMAGES_DIR) $(SOURCE_DIR_ROOT) $(KERNEL_TARGET_DIR) $(PACKAGES_DIR_ROOT) toolchain-depend \
	$(LIBS_PRECOMPILED) $(TARGETS_PRECOMPILED) $(PACKAGES_PRECOMPILED)

check-downloads: $(PACKAGES_CHECK_DOWNLOADS)

mirror: $(MIRROR_DIR) $(PACKAGES_MIRROR)

cacheclean: $(TOOLS_CACHECLEAN) common-cacheclean
clean: $(TARGETS_CLEAN) $(PACKAGES_CLEAN) $(LIBS_CLEAN) $(TOOLCHAIN_CLEAN) $(TOOLS_CLEAN) common-clean
dirclean: $(TOOLCHAIN_DIRCLEAN) $(TOOLS_DISTCLEAN) common-dirclean
distclean: $(TOOLCHAIN_DISTCLEAN) $(TOOLS_DISTCLEAN) common-distclean

.PHONY: firmware package-list package-list-clean sources precompiled toolchain toolchain-depend libs mirror check-downloads \
	$(TARGETS) $(TARGETS_CLEAN) $(TARGETS_DIRCLEAN) $(TARGETS_SOURCE) $(TARGETS_PRECOMPILED) \
	$(PACKAGES) $(PACKAGES_BUILD) $(PACKAGES_CLEAN) $(PACKAGES_DIRCLEAN) $(PACKAGES_LIST) $(PACKAGES_SOURCE) $(PACKAGES_PRECOMPILED) \
	$(LIBS) $(LIBS_CLEAN) $(LIBS_DIRCLEAN) $(LIBS_SOURCE) $(LIBS_PRECOMPILED) \
	$(TOOLCHAIN) $(TOOLCHAIN_CLEAN) $(TOOLCHAIN_DIRCLEAN) $(TOOLCHAIN_DISTCLEAN) $(TOOLCHAIN_SOURCE)

endif # FREETZ_HAVE_DOT_CONFIG!=y

#wrapper: $TOOL-host -> $TOOL-host-precompiled
$(filter-out $(TOOLS_BUILD_LOCAL),$(TOOLS)): % : $(if $(FREETZ_HOSTTOOLS_DOWNLOAD),tools-host,%-precompiled)
$(filter $(TOOLS_BUILD_LOCAL),$(TOOLS)): % : %-precompiled

tools: $(DL_DIR) $(SOURCE_DIR_ROOT) $(filter-out $(TOOLS_CONDITIONAL),$(TOOLS))
tools-dirclean: $(TOOLS_DIRCLEAN)
tools-distclean: $(TOOLS_DISTCLEAN)

push-firmware:
	@if [ ! -e "images/latest.image" ]; then \
		echo "Please run 'make' first."; exit 1; \
	else \
		$(TOOLS_DIR)/push_firmware; exit $?; \
	fi

recover:
	@if [ -z "$(IMAGE)" ]; then \
		echo "Specify an image to recover." 1>&2; \
		echo "e.g. make recover IMAGE=some.image" 1>&2; \
	elif [ ! -r "$(IMAGE)" ]; then \
		echo "Cannot read $(IMAGE)." 1>&2; \
	else \
		echo "This can help if your box is not booting any more"; \
		echo "(Power LED on and flashing of all LEDs every 5 secs)."; \
		echo; \
		echo "Make sure that there is only one box in your subnet."; \
		echo; \
		while true; do \
			echo "Are you sure you want to recover filesystem and kernel"; \
			echo -n "from $(IMAGE)? (y/n) "; \
			read yn; \
			case "$$yn" in \
				[yY]*) \
					echo; \
					if [ -z "$(LOCALIP)" ]; then \
						echo "If this fails try to specify a local IP adress. Your"; \
						echo "local IP has to be in the 192.168.178.0/24 subnet."; \
						echo "e.g. make recover LOCALIP=192.168.178.20"; \
						echo; \
						$(TOOLS_DIR)/recover-eva -f "$(IMAGE)"; \
					else \
						$(TOOLS_DIR)/recover-eva -l $(LOCALIP) -f "$(IMAGE)"; \
					fi; break ;; \
				[nN]*) \
					break ;; \
			esac; \
		done; \
	fi

menuconfig: config-cache $(CONFIG)/mconf
	@$(CONFIG)/mconf $(CONFIG_IN_CACHE)

menuconfig-single: config-cache $(CONFIG)/mconf
	@MENUCONFIG_MODE="single_menu" $(CONFIG)/mconf $(CONFIG_IN_CACHE)

menuconfig-nocache: $(CONFIG_IN_CUSTOM) $(CONFIG)/mconf
	@$(CONFIG)/mconf $(CONFIG_IN)

config: config-cache $(CONFIG)/conf
	@$(CONFIG)/conf $(CONFIG_IN_CACHE)

config-compress: .config.compressed
.config.compressed: .config config-cache $(CONFIG)/conf
	@$(CONFIG)/conf --savedefconfig $@ $(CONFIG_IN_CACHE)
	@sed -e "/^FREETZ_FWMOD_SIGN_PASSWORD=/d" -i $@ 2>/dev/null
#	@echo "Compressed configuration written to $@."; \
#	echo  "It is equivalent to .config, but contains only non-default user selections and no signing key password."

listnewconfig: config-cache $(CONFIG)/conf
	@$(CONFIG)/conf --listnewconfig $(CONFIG_IN_CACHE)

oldconfig olddefconfig allnoconfig allyesconfig randconfig: config-cache $(CONFIG)/conf
	@$(CONFIG)/conf --$@ $(CONFIG_IN_CACHE) && touch .config

reuseconfig: .config
	@tools/reuseconfig

config-cache: $(CONFIG_IN_CACHE)

ifneq ($(findstring clean,$(MAKECMDGOALS)),clean)
-include include/config/cache.conf.cmd

$(CONFIG_IN_CACHE) include/config/cache.conf.cmd: $(CONFIG_IN_CUSTOM) $(PARSE_CONFIG_TOOL) $(deps_config_cache)
	@mkdir -p include/config
	@$(PARSE_CONFIG_TOOL) $(CONFIG_IN) > $(CONFIG_IN_CACHE)
endif

$(CONFIG_IN_CUSTOM): | $(DL_DIR)
	@touch $@

# Macro to clean up config dependencies
#   $(1) = target name to be defined
#   $(2) = info text to be printed
#   $(3) = sub-regex for removing symbols from .config
#
# Note: We could also deactivate options which are on by default, but not
# selected by any packages, e.g. FREETZ_BUSYBOX_ETHER_WAKE or almost 20 default
# FREETZ_SHARE_terminfo_*. At the moment those options will be reactivated. To
# deactivate them as well, the 'sed' command for step 1 can be replaced by:
#   $$(SED) -i -r 's/^(FREETZ_($(3))_.+)=.+/\1=n/' .config; \
#
define CONFIG_CLEAN_DEPS
$(1):
	@{ \
	cp .config .config_tmp; \
	echo -n "Step 1: temporarily deactivate all $(2) ... "; \
	$$(SED) -i -r '/^FREETZ_BUSYBOX__VERSION_V/n;s/^(FREETZ_($(3))_)/# \1/' .config; \
	echo "DONE"; \
	echo -n "Step 2: reactivate only elements required by selected packages or active by default ... "; \
	make olddefconfig > /dev/null; \
	echo "DONE"; \
	echo "The following elements have been deactivated:"; \
	diff -U 0 .config_tmp .config | $$(SED) -rn 's/^\+# ([^ ]+) is not set$$$$/  \1/p'; \
	$$(RM) .config_tmp; \
	}
endef

# Decactivate optional stuff by category
$(eval $(call CONFIG_CLEAN_DEPS,config-clean-deps-modules,kernel modules,MODULE))
$(eval $(call CONFIG_CLEAN_DEPS,config-clean-deps-libs,shared libraries,LIB))
$(eval $(call CONFIG_CLEAN_DEPS,config-clean-deps-busybox,BusyBox applets,BUSYBOX))
$(eval $(call CONFIG_CLEAN_DEPS,config-clean-deps-terminfo,terminfos,SHARE_terminfo))
# Deactivate all optional stuff
$(eval $(call CONFIG_CLEAN_DEPS,config-clean-deps,kernel modules$(_comma) shared libraries$(_comma) BusyBox applets and terminfos,MODULE|LIB|BUSYBOX|SHARE_terminfo))
# Deactivate all optional stuff except for Busybox applets
$(eval $(call CONFIG_CLEAN_DEPS,config-clean-deps-keep-busybox,kernel modules$(_comma) shared libraries and terminfos,MODULE|LIB|SHARE_terminfo))

common-cacheclean:
	[ ! -x .fwmod_custom ] || ./.fwmod_custom clean
	./fwmod_custom clean
	$(RM) make/Config.in.generated make/external.in.generated
	$(RM) .config.compressed .config.old  .config.*.tmp
	$(RM) .packages .exclude-release-tmp $(CONFIG_IN_CACHE)
	$(RM) $(DL_FW_DIR)/*.detected.image $(DL_FW_DIR)/*.detected.image.url
	$(RM) -r $(BUILD_DIR)
	$(RM) -r $(FAKEROOT_CACHE_DIR)

common-clean: common-cacheclean

common-dirclean: common-clean $(if $(FREETZ_HAVE_DOT_CONFIG),kernel-dirclean)
	$(RM) -r $(if $(FREETZ_HAVE_DOT_CONFIG),$(PACKAGES_DIR) $(SOURCE_DIR) $(TARGET_TOOLCHAIN_DIR),$(PACKAGES_DIR_ROOT) $(SOURCE_DIR_ROOT))

common-distclean: common-dirclean
	$(RM)    .config.cmd .tmpconfig.h *.log
	$(RM) -r include/config
	$(RM) -r $(FW_IMAGES_DIR)
	$(RM) -r $(KERNEL_TARGET_DIR)
	$(RM) -r $(PACKAGES_DIR_ROOT) $(SOURCE_DIR_ROOT)
	$(RM) -r $(TOOLCHAIN_BUILD_DIR)
	$(RM) -r $(TOOLS_BUILD_DIR)
	$(RM)    $(DL_DIR)
	@echo "The files ./.config ./config/custom.in ./.fwmod_custom and the directories ~/.freetz-dl/ ~/.freetz-signature/ were not removed."

release: distclean
	version="$$(cat .version)"; \
	curdir="$$(basename $$(pwd))"; \
	dir="$$(cat .version | $(SED) -e 's#^\(freetz.*-[0-9\.]*\).*$$#\1#')"; \
	( \
		cd ../; \
		[ "$$curdir" == "$$dir" ] || mv "$$curdir" "$$dir"; \
		( \
			find "$$dir" -type f -name .gitignore; \
			$(SED) "s/^/$$dir\//" "$$dir/.exclude-release"; \
			echo "$$dir/.exclude-release-tmp"; \
		) > "$$dir/.exclude-release-tmp"; \
		echo "excluding:"; \
		cat "$$dir/.exclude-release-tmp" ; \
		echo "creating: $${version}.tar.bz2"; \
		tar --exclude-from="$${dir}/.exclude-release-tmp"  --owner=0 --group=0  -cjf "$${version}.tar.bz2" "$$dir"; \
		du -h "$${version}.tar.bz2"; \
		[ "$$curdir" == "$$dir" ] || mv "$$dir" "$$curdir"; \
		cd "$$curdir"; \
	)
	$(RM) .exclude-release-tmp

# Check .config is up-to-date. Any change to any of the menuconfig configuration files (either manual or one caused by 'svn up') require .config to be updated.
check-dot-config-uptodateness: $(CONFIG_IN_CACHE)
	@if [ -e .config -a $(CONFIG_IN_CACHE) -nt .config ]; then \
		echo -n -e $(_Y); \
		echo "ERROR: The .config file needs to be updated, because"; \
		echo "       you have either updated to a newer revision"; \
		echo "       or altered one of the menuconfig files manually."; \
		echo "       Please run 'make olddefconfig'."; \
		echo -n -e $(_N); \
		exit 3; \
	fi

help:
	@sed 's/^# /\n/;/```/d' docs/wiki/20_Advanced/make_targets.en.md

.PHONY: all world step $(KCONFIG_TARGETS) config-cache tools recover \
	config-clean-deps-modules config-clean-deps-libs config-clean-deps-busybox config-clean-deps-terminfo config-clean-deps config-clean-deps-keep-busybox \
	cacheclean clean dirclean distclean common-cacheclean common-clean common-dirclean common-distclean release \
	$(TOOLS) $(TOOLS_CACHECLEAN) $(TOOLS_CLEAN) $(TOOLS_DIRCLEAN) $(TOOLS_DISTCLEAN) $(TOOLS_SOURCE) $(TOOLS_PRECOMPILED) \
	check-dot-config-uptodateness


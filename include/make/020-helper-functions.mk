#
# returns:
#   $(1)   if it is equal to one of the values considered to be a logical true: y yes true 1 (case insensitive)
#   empty  otherwise
#
define is-y
$(if $(filter y yes true 1,$(call SUBST_MAP,$(subst $(_space),_,$(strip $(1))),$(SUBST_MAP_TOLOWER))),$(strip $(1)))
endef

#
# function imitating logical NOT
#
# returns:
#   empty value for any non-empty input
#   y for empty input
#
define not-y
$(if $(strip $(1)),,y)
endef

#
# $1 - some string possibly quoted with double quotes
#
# returns:
#   double-quote and whitespace stripped version of $(1)
#
define qstrip
$(strip $(subst ",,$(1)))
endef

#
# $1 - some string possibly containing newline chars
#
# returns:
#   the same string with all newline chars replaced with spaces
#
define newline2space
$(subst $(_newline),$(_space),$(1))
endef

#
# $1 - pattern (regular wildcard parameter)
#
# Overcomes the following deficiency of $(sort $(wildcard ...))
#
# $(sort xyz-suffix xyz):
#    returns (as expected) "xyz xyz-suffix"
# $(sort xyz-suffix/... xyz/...):
#    however returns "xyz-suffix/... xyz/..."
#    which is actually correct (ASCII code of "-" is smaller than that of "/")
#    but not what one would expect when sorting is applied to filepaths.
#
# sorted-wildcard returns "xyz/... xyz-suffix/..." for "xyz-suffix/... xyz/..."
#
define sorted-wildcard
$(strip $(subst $(_bang),/,$(sort $(subst /,$(_bang),$(wildcard $(1))))))
endef

# 1 - string spaces to (un)escape within
define escape-space
$(subst $(_space),$(_space_escape),$(1))
endef
define unescape-space
$(subst $(_space_escape),$(_space),$(1))
endef

#
# $1            - some string like FOO-BAR1-BAR2-...
#                 the string is allowed to contain spaces
# $2 (optional) - delimiter character, default '-' if omitted
#                 the delimiter character it NOT allowed to be one of the (lower-case) hex digits, i.e. 0-9 a-f
# $3 (optional) - component index, default 1
#
# returns:
#   the $(3) component of $(1), i.e. BAR1 for $(call GET_STRING_COMPONENT,FOO-BAR1-BAR2-BAR3,-,2)
#
define GET_STRING_COMPONENT
$(call unescape-space,$(subst $(_space),$(if $(strip $(2)),$(strip $(2)),-),$(word $(if $(strip $(3)),$(strip $(3)),1),$(subst $(if $(strip $(2)),$(strip $(2)),-),$(_space),$(call escape-space,$(1))))))
endef

#
# $1            - some string like FOO-BAR1-BAR2-...
#                 the string is allowed to contain spaces
# $2 (optional) - delimiter character, default '-' if omitted
#                 the delimiter character it NOT allowed to be one of the (lower-case) hex digits, i.e. 0-9 a-f
# $3 (optional) - number of components to be included, default 2
#
# returns:
#   the first $(3) components of $(1), i.e. FOO-BAR for FOO-BAR1-BAR2-...
#
define GET_STRING_COMPONENTS
$(call unescape-space,$(subst $(_space),$(if $(strip $(2)),$(strip $(2)),-),$(wordlist 1,$(if $(strip $(3)),$(strip $(3)),2),$(subst $(if $(strip $(2)),$(strip $(2)),-),$(_space),$(call escape-space,$(1))))))
endef

#
# $1 - some string representing a version of some package
# $2 (optional) - number of version components to be included, default 2
#
# returns:
#   major version of the package, i.e. x.y for x.y.z
#
define GET_MAJOR_VERSION
$(call GET_STRING_COMPONENTS,$(strip $(1)),.,$(if $(strip $(2)),$(strip $(2)),2))
endef


# SUBST_MAP
# Substitute according to map src:dst
#  $1 - some string
#  $2 - list of src:dst pairs
SUBST_MAP = $(strip		\
	$(eval __tmp := $1)	\
	$(foreach s,$2,		\
		$(eval __tmp := $(subst $(word 1,$(subst :, ,$s)),$(word 2,$(subst :, ,$s)),$(__tmp))))	\
	$(__tmp))
SUBST_MAP_TOLOWER := A:a B:b C:c D:d E:e F:f G:g H:h I:i J:j K:k L:l M:m N:n O:o P:p Q:q R:r S:s T:t U:u V:v W:w X:x Y:y Z:z
SUBST_MAP_TOUPPER := a:A b:B c:C d:D e:E f:F g:G h:H i:I j:J k:K l:L m:M n:N o:O p:P q:Q r:R s:S t:T u:U v:V w:W x:X y:Y z:Z
SUBST_MAP_LEGAL_VARNAME := -:_ .:_
SUBST_MAP_TOUPPER_NAME := $(SUBST_MAP_TOUPPER) $(SUBST_MAP_LEGAL_VARNAME)
SUBST_MAP_TOLOWER_NAME := $(SUBST_MAP_TOLOWER) $(SUBST_MAP_LEGAL_VARNAME)

# TOUPPER_NAME/TOLOWER_NAME
# Changes case of the letters to the opposite one, replaces all characters which cannot be used in identifier names with underscore
#   $1 = string to convert
TOUPPER_NAME = $(call SUBST_MAP,$1,$(SUBST_MAP_TOUPPER_NAME))
TOLOWER_NAME = $(call SUBST_MAP,$1,$(SUBST_MAP_TOLOWER_NAME))

# LEGAL_VARNAME
# Converts all characters which cannot be used in identifiers to underscore
#   $1 = string to convert
LEGAL_VARNAME = $(call SUBST_MAP,$1,$(SUBST_MAP_LEGAL_VARNAME))

# Use $< (first prerequisite) rather than $^ (all prerequisites), because
# otherwise there will be errors when make tries to copy multiple source files
# into one target binary.
define INSTALL_FILE
mkdir -p $(dir $@); \
cp $< $@;
endef
define INSTALL_DIR
mkdir -p $(dir $@); \
cp -r $< $@;
endef

# $1: path to the file to be unpacked
# $2: directory files to be unpacked to
# $3: file extension
# $4: (optional) number of leading path components to strip
# $5: (optional) include filter
define UNPACK_TARBALL__INT
	$(if $(filter .gz .tgz .taz,$(3)),                                                                         $(TOOLS_DIR)/gunzip     -c $(1)) \
	$(if $(filter .bzip2 .bz2 .bz .tbz2 .tbz,$(3)),                                                            $(TOOLS_DIR)/bunzip2    -c $(1)) \
	$(if $(filter .xz .txz,$(3)),                                                                              $(TOOLS_DIR)/unxz       -c $(1)) \
	$(if $(filter .lz .tlz,$(3)),                                                                              $(TOOLS_DIR)/lunzip     -c $(1)) \
	$(if $(filter .lzma .tlzma,$(3)),                                                                          $(TOOLS_DIR)/unlzma     -c $(1)) \
	$(if $(filter .Z .taZ,$(3)),                                                                               $(TOOLS_DIR)/uncompress -c $(1)) \
	$(if $(filter .tar,$(3)),                                                                                               cat           $(1)) \
	$(if $(filter .zip,$(3)),                                                                                  $(TOOLS_DIR)/unzip $(QUIETSHORT) $(1) -d $(2) $(if $(4),                                        -J $(4)) $(5)) \
	$(if $(filter .gz .tgz .taz .bzip2 .bz2 .bz .tbz2 .tbz .xz .txz .lz .tlz .lzma .tlzma .Z .taZ .tar,$(3)),| $(TAR)          -x $(VERBOSE)         -C $(2) $(if $(4),--transform='s|^./\+||' --strip-components=$(4)) $(5))
endef

# $1: path to the file to be unpacked
# $2: directory files to be unpacked to
# $3: (optional) number of leading path components to strip
# $4: (optional) include filter
define UNPACK_TARBALL
	$(strip $(call UNPACK_TARBALL__INT,$(strip $(1)),$(strip $(2)),$(suffix $(strip $(1))),$(strip $(3)),$(strip $(4))))
endef

UNPACK_TARBALL_PREREQUISITES := busybox-host tar-host

# $1: list of directories containing the patches
# $2: directory to apply the patches to
define APPLY_PATCHES
	set -e; shopt -s nullglob; for i in $(strip $(foreach dir,$(strip $1),$(dir)/*.patch*)); do \
		case $(_dollar)i in \
			*.patch|*.patch.gz|*.patch.bzip2|*.patch.bz2|*.patch.bz|*.patch.xz|*.patch.lz|*.patch.lzma|*.patch.Z) ;; \
			*) continue ;; \
		esac; \
		$(PATCH_TOOL) $(strip $2) $(_dollar)i; \
	done;
endef

# $1: from dir
# $2: to dir
# $3: (optional) tar parameters specifying files to be copied, default all except for version control and freetz build-system related files
define COPY_USING_TAR
	$(TAR) -cf - -C $(strip $(1)) \
		--exclude=.svn \
		--exclude=.git \
		--exclude=.gitignore \
		--exclude=.build-prereq-checked \
		--exclude=.unpacked \
		--exclude=.configured \
		--exclude=.compiled \
		--exclude=.installed \
		$(if $(strip $(3)),$(strip $(3)),.) \
	| $(TAR) -xf - -C $(strip $(2));
endef

PATTERN_LIBRARY_NAME             := lib[a-zA-Z]([a-zA-Z0-9_+-])*
PATTERN_NUMERIC_VERSION_OPTIONAL := ([.][0-9]+)*
PATTERN_NUMERIC_VERSION          := [0-9]+$(PATTERN_NUMERIC_VERSION_OPTIONAL)

# $1: shared library basename, e.g. libz.so.1.2.8
# $2: optional replacement for the version number right before .so
# $3: optional additional library name suffix, e.g. a for static library name
define LIBRARY_NAME_TO_SHELL_PATTERN
$(shell echo "$(1)" | $(SED) -r -n \
	-e 's,^($(PATTERN_LIBRARY_NAME))(-$(PATTERN_NUMERIC_VERSION))[.]so($(PATTERN_NUMERIC_VERSION_OPTIONAL))$(_dollar),\1$(if $2,$2,\3).so*$(if $3, \1.$3),p' \
	-e 's,^($(PATTERN_LIBRARY_NAME))[.]so($(PATTERN_NUMERIC_VERSION_OPTIONAL))$(_dollar),\1.so*$(if $3, \1.$3),p' \
)
endef

#
# $1 - git repository
# $2 - (optional) branch name, if omitted "master" is used
#
# returns:
#   latest revision of the specified branch
#
define git-get-latest-revision
$(shell rev=$$(git ls-remote --heads $(strip $(1)) $(if $(strip $(2)),$(strip $(2)),master) | sed -rn -e 's,^([0-9a-f]{10})[0-9a-f]{30}.*,\1,p'); echo "$${rev:-FAILED_TO_DETERMINE_LATEST_REVISION}")
endef

#
# $1 - git repository
# $2 - tag name
#
# returns:
#   revision of the specified tag
#
define git-get-tag-revision
$(shell rev=$$(git ls-remote --tags $(strip $(1)) $(strip $(2)) | sed -rn -e 's,^([0-9a-f]{10})[0-9a-f]{30}.*,\1,p'); echo "$${rev:-FAILED_TO_DETERMINE_TAG_REVISION}")
endef

#
# $1 - menuconfig file
# $2 - (optional) dir name, if omitted "make" is used
#
define genin-get-considered-packages
$(shell cat $1 2>/dev/null | sed -r -n -e 's,^[ \t]*source[ \t]+"$(if $(strip $(2)),$(strip $(2)),make)/([^/]+)/(Config|external)[.]in(.libs)?.*,\1,p' | sort -u)
endef

#
# $1 - dir
# $2 - name of the file to look for
# $3 - (optional) subdirs to exclude
#
define get-subdirs-containing
$(shell find -L $(strip $(1)) -maxdepth 2 -name "$(strip $(2))" -printf "%h\n" $(if $(strip $(3)),| grep -v -E "$(strip $(1))/$(subst $(_space),|,$(strip $(3)))") | sed -r -e 's,^$(strip $(1))/,,' | sort -u)
endef

#
# Writes list entries to a file, each entry on a new line
#
# $1 - list (trailing slashes will be removed)
# $2 - name of the file list entries to be written to
#
define write-list-to-file
(set -f; $(RM) $(strip $(2)); printf $(if $(strip $(1)),"%s\n" $(strip $(1)) | sed 's/\/$$$$//g' | sort -u,"") >$(strip $(2)));
endef

#
# Joins list with given string, i.e. creates from list "foo1 foo2 bar" and the separator string XYZ the string "foo1XYZfoo2XYZbar"
#
# $1 - separator string
# $2 - (space-separated) list to join
define join-with
$(subst $(_space),$(1),$(strip $(2)))
endef

#
# Calculates complement to a file set specified by list of files (shell patterns are allowed) to include
#
# $1 - dir
# $2 - list of patterns defining the file set complement to be found to
define fileset-complement
	(cd $(strip $(1)); find . -type f $(if $(strip $(2)),\! \( $(subst =,$(_space),$(call join-with, -o ,$(foreach p,$(strip $(2)),-path="./$(p)"))) \)) | $(SED) -e 's,^./,,' | sort)
endef

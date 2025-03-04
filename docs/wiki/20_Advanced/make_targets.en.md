# Targets of Freetz's "make"


```
help                                    Shows docs/wiki/20_Advanced/make_targets.en.md
hilfe                                   Shows docs/wiki/20_Advanced/make_targets.de.md

menuconfig                              Configuration with Ncurses (needs ncurses-devel)
menuconfig-single                       Configuration with Ncurses (single-menu)
menuconfig-nocache                      Configuration with Ncurses (without caching of .in files)
nconfig                                 Alternative configuration (needs ncurses-devel)
nconfig-single                          Alternative configuration (single-menu)
gconfig                                 Configuration with GTK+2 (needs libglade2-devel)
xconfig                                 Configuration with QT5 (needs qt5-qtbase-devel)
config                                  Configuration (Dialog)

olddefconfig                            Updates existing .config file automatically
oldconfig                               Updates existing .config file interactive
reuseconfig                             Removes device and toolchain related settings from .config file
allnoconfig                             Sets everything to (n)o
allyesconfig                            Sets everything to (y)es
listnewconfig                           Shows a list of any new config symbols, one per line
config-compress                         Keeps only non-default selections and no signing key password

config-clean-deps                       Deselects everything not mandatory
config-clean-deps-keep-busybox          Deselects all except BusyBox applets
config-clean-deps-modules               Deselects all kernel modules
config-clean-deps-libs                  Deselects all libraries
config-clean-deps-busybox               Deselects all BusyBox applets
config-clean-deps-terminfo              Deselects all terminfos

cacheclean                              Removes small cached files and directories
clean                                   Remove unpacked images and some cache files
dirclean                                Clean sources (except tools and .config)
distclean                               Clean everything except the download directory

$(pkg)-unpacked                         Unpacks and patches $(pkg)
$(pkg)-precompiled                      Compiles package/library $(pkg)
$(pkg)-recompile                        Recompiles package/library $(pkg)
$(pkg)-autofix                          Adjusts patches of package/library $(pkg)
$(pkg)-dirclean                         Removes build-directory of $(pkg)
$(pkg)-distclean                        Removes build-directory and all target files of $(pkg)

kernel-menuconfig                       Configuration of selected kernel
kernel-precompiled                      Compiles the selected kernel
kernel-dirclean                         Cleans everything of the selected kernel

tools-push_firmware                     Builds the tools required by push_firmware (pfp)
tools                                   Builds the tools required by current selection
tools-all                               Builds all available tools of Freetz
tools-allexcept-local                   Builds all non-local tools of Freetz (dl-tools)
tools-distclean-local                   Cleans everything of local tools (dl-tools)
tools-dirclean                          Cleans everything of all Freetz tools

uclibc-autofix                          Adjusts patches of selected uClibc
uclibc-menuconfig                       Configuration of selected uClibc
uclibc-olddefconfig                     Updates selected uClibc .config file

firmware-nocompile                      Creates firmware without packages and libraries
mirror                                  Downloads all selected package sources files
release                                 Creates a release file (change .version before)

push_firmware                           Calls tools/push_firmware with images/latest.image (pf)
                                        For more options, run: tools/push_firmware -h
recover                                 Calls tools/recover-eva with configured firmware
```



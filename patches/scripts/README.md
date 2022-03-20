# undisableable patches

### mandatory
 - 010-no_exits_from_rc.S.sh        - !SYSTEMD_CORE_MOD_DIR
 - 102-add_inittab.sh               - all
 - 102-dont-change-tty-settings.sh  - FREETZ_AVM_VERSION_06_0X_MIN
 - 115-patch-ds_off.sh              - all
 - 130-add_fstab.sh                 - all
 - 180-patch_printk.sh              - !6810 6820 6842 7270_V1 7272 7412 7430
 - 190-add_freetz_webmenu.sh        - !FREETZ_AVM_HAS_ONLY_LUA
 - 222-drop_noexec.sh               - FREETZ_AVM_HAS_NOEXEC
 - 250-remove_avm_inetd.sh          - FREETZ_AVM_HAS_INETD
 - 700-set_lang_to_utf8.sh          - FREETZ_BUSYBOX_UNICODE_SUPPORT
 - 840-remove_smd_httpd.sh          - FREETZ_CPU_MODEL_ARM_cortex_a9

### wrapper
 - 105-wrapper_ctlmgr.sh            - FREETZ_LIB_libctlmgr
 - 106-wrapper_multid.sh            - all (rextd on extender)

### fixes
 - 090-var_install_fixes.sh         - all
 - 196-storage_fixes.sh             - all
 - 261-update_avm-rootca.sh         - non updated from FOS 5.2x - <07.29
 - 521-fix_dect_update.sh           - FREETZ_TARGET_ARCH_X86

### other
 - 080-start_plugin.sh              - FREETZ_AVM_HAS_PLUGINS_UPDATE
 - 105-S06-logging.sh               - FREETZ_AVM_VERSION_05_2X_MIN
 - 108-patch_multid-wait.sh         - FREETZ_AVM_VERSION_06_5X_MAX
 - 391-symlink_blkid.sh             - !FREETZ_BUSYBOX__KEEP_BINARIES || FREETZ_PACKAGE_E2FSPROGS_BLKID
 - 401-remove_ftpd_banner.sh        - FREETZ_AVM_HAS_NAS
 - 620-symlink_wget.sh              - FREETZ_BUSYBOX_WGET || FREETZ_PACKAGE_WGET


[ "$FREETZ_CPU_MODEL_ARM_cortex_a9" == "y" ] || return 0
[ -e "${FILESYSTEM_MOD_DIR}/etc/cms_entity_info.d/eid_bcm_mgmt.txt" ] || return 0
echo1 "removing smd-httpd"

if [ "$FREETZ_AVM_VERSION_07_2X_MIN" == "y" ] ; then
	PVER="07_2X"
elif [ "$FREETZ_AVM_VERSION_07_1X_MIN" == "y" ] ; then
	PVER="07_1X"
fi

modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_COND_DIR}/840-remove_smd_httpd/840-remove_smd_httpd_${PVER}.patch"


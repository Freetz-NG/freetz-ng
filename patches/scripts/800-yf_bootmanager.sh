[ "$FREETZ_PATCH_MODFS_BOOT_MANAGER" == "y" ] || return 0
echo1 "adding yf-bootmanager"

TEMPDIR=$(mktemp -d)
pushd "${TOOLS_DIR}/yf/bootmanager" >/dev/null
TMP="$TEMPDIR" \
  TARGET_SYSTEM_VERSION="autodetect" \
  TARGET_DIR="${ABS_BASE_DIR}/${FILESYSTEM_MOD_DIR}" \
  sh "./add_to_system_reboot.sh" 2>&1 | sed 's/^/    /g'  # >/dev/null
popd >/dev/null
rmdir "$TEMPDIR"


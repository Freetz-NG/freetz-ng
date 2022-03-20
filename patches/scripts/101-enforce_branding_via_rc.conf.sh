[ -n "$FREETZ_ENFORCE_FIRMWARE_VERSION_VIA_RCCONF" ] || return 0
echo1 "force branding '${FREETZ_ENFORCE_FIRMWARE_VERSION_VIA_RCCONF}'"

for oem in $(supported_brandings); do
	if [ "${FREETZ_ENFORCE_FIRMWARE_VERSION_VIA_RCCONF}" == "$oem" ]; then
		echo2 "hardcoding branding in /etc/init.d/rc.conf"
		modsed "s|^\([ \t]*export OEM\)\$|\1=${FREETZ_ENFORCE_FIRMWARE_VERSION_VIA_RCCONF}|" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf" "export OEM=${FREETZ_ENFORCE_FIRMWARE_VERSION_VIA_RCCONF}\$"
		return 0
	fi
done

error 1 "selected branding '${FREETZ_ENFORCE_FIRMWARE_VERSION_VIA_RCCONF}' is not supported by this firmware"


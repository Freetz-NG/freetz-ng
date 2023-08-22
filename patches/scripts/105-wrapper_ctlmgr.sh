[ "$FREETZ_AVM_HAS_AVMCTLMGR_PRELOAD" == "y" ] || return 0
echo1 "preparing ctlmgr wrapper"

create_LD_PRELOAD_wrapper /usr/bin/ctlmgr libctlmgr.so

if [ -f "${FILESYSTEM_MOD_DIR}/lib/systemd/system/ctlmgr.service" ] ; then
	echo1 "preparing ctlmgr service"

	ENV_FILE="/etc/.environment.ctlmgr"
	# create env file
	echo \
	  'export LD_PRELOAD="libctlmgr.so${LD_PRELOAD:+:}${LD_PRELOAD}"' > \
	  "${FILESYSTEM_MOD_DIR}/${ENV_FILE}"
	# use own env file
	modsed -r \
	  "s/^(EnvironmentFile)=.*/\1=${ENV_FILE//\//\\/}/" \
	  "${FILESYSTEM_MOD_DIR}/lib/systemd/system/ctlmgr.service" \
	  "=${ENV_FILE}$"
	# dont use wrapper
	modsed \
	  's,^ExecStart=.*/,&avm/,' \
	  "${FILESYSTEM_MOD_DIR}/lib/systemd/system/ctlmgr.service" \
	  "/avm/ctlmgr$"
fi


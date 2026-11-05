[ "$FREETZ_REMOVE_DSL_CONTROL" == "y" ] || [ "$FREETZ_REMOVE_DSL_DAEMON" == "y" ] || return 0

[ "$FREETZ_REMOVE_DSL_CONTROL" == "y" ] && echo1 "removing dsl_control"
[ "$FREETZ_REMOVE_DSL_DAEMON" == "y" ] && echo1 "removing dsl_daemon"

for files in \
  usr/sbin/dsl_daemon \
  usr/sbin/control_pmi \
  usr/sbin/vr10/dsl_control \
  usr/sbin/dsl_control \
  usr/sbin/dsl_pipe \
  usr/sbin/dpm_manager \
  usr/sbin/eth_oam \
  usr/sbin/oamd \
  etc/dsl/ \
  usr/sbin/dsl_monitor \
  ; do
	rm_files "${FILESYSTEM_MOD_DIR}/$files"
done


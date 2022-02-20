#!/bin/sh

. /usr/lib/libmodcgi.sh

#

sec_begin "Start type"

cgi_print_radiogroup_service_starttype "enabled" "$NFSD_ENABLED" "" "" 0

sec_end

#

sec_begin "Options"

cgi_print_checkbox_p "no_nfs_v4" "$NFSD_NO_NFS_V4" \
  "use only NFSv3"

sec_end

#

sec_begin "Ports"

cgi_print_textline_p "mountd_port" "$NFSD_MOUNTD_PORT" 6/5 \
  "mountd:&nbsp;" "&nbsp;empty=random"

cgi_print_textline_p "nfsd_port" "$NFSD_NFSD_PORT" 6/5 \
  "nfsd:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" "&nbsp;empty=2049, client has to be configured accordingly"

sec_end

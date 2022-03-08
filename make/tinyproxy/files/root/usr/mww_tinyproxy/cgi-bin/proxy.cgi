#!/bin/sh

. /mod/etc/conf/tinyproxy.cfg

[ -z $CONFIG_HOSTNAME ] && CONFIG_HOSTNAME="fritz.box"
HTTP_CONFIG_HOSTNAME="http://$CONFIG_HOSTNAME"
HTTP_CONFIG_HOSTNAME_LEN=`echo -n $HTTP_CONFIG_HOSTNAME | wc -m`

cat << EOF
Content-type: application/x-ns-proxy-autoconfig

function FindProxyForURL(url, host) {
        if ((url.substring(0,5) == "http:" || url.substring(0,6) == "https:") && url.substring(0,$HTTP_CONFIG_HOSTNAME_LEN) != "$HTTP_CONFIG_HOSTNAME" && host.substring(0, 9) != "127.0.0.1") {
                return "PROXY $CONFIG_HOSTNAME:$TINYPROXY_PORT";
        }
        else {
                return "DIRECT";
        }
}

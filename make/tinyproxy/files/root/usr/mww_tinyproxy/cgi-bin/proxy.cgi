#!/bin/sh

. /mod/etc/conf/tinyproxy.cfg

[ -z "$CONFIG_HOSTNAME" ] && CONFIG_HOSTNAME="fritz.box"
HTTP_CONFIG_HOSTNAME="http://$CONFIG_HOSTNAME"

cat << EOF
Content-type: application/x-ns-proxy-autoconfig

function FindProxyForURL(url, host) {
        if ((url.substring(0,5) == "http:" || url.substring(0,6) == "https:") && url.substring(0,${#HTTP_CONFIG_HOSTNAME}) != "$HTTP_CONFIG_HOSTNAME") {
                return "PROXY $CONFIG_HOSTNAME:$TINYPROXY_PORT";
        }
        else {
                return "DIRECT";
        }
}
EOF


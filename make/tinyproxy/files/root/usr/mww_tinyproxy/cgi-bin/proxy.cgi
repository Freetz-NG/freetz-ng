#!/bin/sh

. /mod/etc/conf/tinyproxy.cfg
HTTP_CONFIG_HOSTNAME="http://$TINYPROXY_HOSTNAME"

cat << EOF
Content-type: application/x-ns-proxy-autoconfig

function FindProxyForURL(url, host) {
        if ((url.substring(0,5) == "http:" || url.substring(0,6) == "https:") && url.substring(0,${#HTTP_CONFIG_HOSTNAME}) != "$HTTP_CONFIG_HOSTNAME") {
                return "PROXY $TINYPROXY_HOSTNAME:$TINYPROXY_PORT";
        }
        else {
                return "DIRECT";
        }
}
EOF


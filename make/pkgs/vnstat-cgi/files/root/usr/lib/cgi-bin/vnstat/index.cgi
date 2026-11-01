#!/bin/sh

. /usr/lib/libmodcgi.sh

cgi_begin "vnstat"

source /usr/lib/cgi-bin/vnstat/stats.cgi

cgi_end


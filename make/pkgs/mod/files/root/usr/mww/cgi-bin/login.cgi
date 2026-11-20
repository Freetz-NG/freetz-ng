#!/bin/sh

if [ "$REQUEST_METHOD" == "POST" ]; then
	source /usr/mww/cgi-bin/login_check.sh
else
	source /usr/mww/cgi-bin/login_page.sh
fi


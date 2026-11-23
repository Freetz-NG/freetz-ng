#!/bin/sh

echo "<center>"
echo "<br />"
echo "<a href='$(html "${QUERY_STRING:+?$QUERY_STRING}")' class='image'>"
echo "<p><img src='/l4l/lcd4linux.png?nocache=$(date -Iseconds | sed 's/T/_/g;s/+.*$//g;s/:/-/g')' alt='LCD4linux' border='0'/></p>"
echo "</a>"
echo "</center>"


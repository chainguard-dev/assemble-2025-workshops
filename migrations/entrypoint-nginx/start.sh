#!/bin/sh
cat /var/lib/nginx/html/index.html | envsubst > /var/lib/nginx/html/index.html

exec /usr/sbin/nginx -c /etc/nginx/nginx.conf -e /dev/stderr -g 'daemon off;'

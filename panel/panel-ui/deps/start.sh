#!/bin/sh

# start sub-shell for debugging purposes -- Cloud Run is hard to debug
tail -n 100 /var/www/pterodactyl/storage/logs/laravel-$(date +%F).log &

# /usr/sbin/php-fpm8.1 --nodaemonize -c='/usr/local/etc/php/php.ini-development'
/usr/sbin/php-fpm8.1 -D -c='/usr/local/etc/php/php.ini-development'
/usr/sbin/nginx -g "daemon off;"
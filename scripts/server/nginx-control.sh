#!/bin/bash

SCRIPT_NAME="$(cd $(dirname "$0"); pwd -P)/$(basename "$0")"
SCRIPT_DIR="$(dirname "$SCRIPT_NAME")"

. $SCRIPT_DIR/setup-default-php-env.sh
$SCRIPT_DIR/replace-templates.php

if [ -n "$LOG_TO_SRV" ] && [ "$LOG_TO_SRV" != "0" ]; then
  mkdir -p /srv/system/log/nginx/
  chown root:adm /srv/system/log/nginx/
  chmod -R 777 /srv/system/
  chmod -R 777 /srv/system/log/nginx/
  touch /srv/system/log/nginx/access.log /srv/system/log/nginx/error.log
  chown www-data /srv/system/log/nginx/*
fi

case "$1" in
  stop)
    exec service nginx stop
	;;

  restart)
    exec service nginx restart
	;;

  reload)
    exec service nginx reload
	;;

  status)
    exec service nginx status
	;;

  start|*)
    exec service nginx start
	;;

esac

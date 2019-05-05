#!/bin/bash

SCRIPT_NAME="$(cd $(dirname "$0"); pwd -P)/$(basename "$0")"
SCRIPT_DIR="$(dirname "$SCRIPT_NAME")"

. $SCRIPT_DIR/setup-default-php-env.sh
$SCRIPT_DIR/update-default-website.php

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

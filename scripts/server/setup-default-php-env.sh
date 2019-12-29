#!/bin/bash
SCRIPT_NAME="$(cd $(dirname "$0"); pwd -P)/$(basename "$0")"
SCRIPT_DIR="$(dirname "$SCRIPT_NAME")"

file="/srv/php-version"
if [ -f "$file" ]; then
  line="$(head -n 1 $file)"
  export PHP_VERSION="$line"
  echo "setting default PHP version to $line from file: $file"
fi

if [ -n "$PHP_VERSION" ]; then
  if [ "$PHP_VERSION" != "7.1" ] && [ "$PHP_VERSION" != "7.2" ] && [ "$PHP_VERSION" != "7.3" ] && [ "$PHP_VERSION" != "7.4" ]; then
    echo "Unsetting invalid PHP version value: [$PHP_VERSION]"
    PHP_VERSION=
  fi
fi

if [ -z "$PHP_VERSION" ]; then
  export PHP_VERSION="7.4"
  echo "setting default PHP version to 7.4 default"
fi


${SCRIPT_DIR}/set-php-version.sh $PHP_VERSION

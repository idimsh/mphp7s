#!/bin/bash

SCRIPT_NAME="$(cd $(dirname "$0"); pwd -P)/$(basename "$0")"
SCRIPT_DIR="$(dirname "$SCRIPT_NAME")"
versions_file="${SCRIPT_DIR}/php-versions.txt"
versions=$(head -n1 $versions_file)

version="$1"

for v in $versions; do
  if [ "$version" = "$v" ]; then
    update-alternatives --quiet --set phar /usr/bin/phar${v} && \
    update-alternatives --quiet --set phar.phar /usr/bin/phar.phar${v} && \
    update-alternatives --quiet --set php /usr/bin/php${v} && \
    [ -f /usr/bin/php-config${v} ] && update-alternatives --quiet --set php-config /usr/bin/php-config${v} || true && \
    [ -f /usr/bin/phpize${v} ] && update-alternatives --quiet --set phpize /usr/bin/phpize${v} || true

    echo "updated default PHP version to ${v}"
    exit 0;
  fi
done

echo "unsupported PHP version: '${v}'" >&2
exit 1

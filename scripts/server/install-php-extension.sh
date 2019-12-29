#!/bin/bash
set -e

SCRIPT_NAME="$(cd $(dirname "$0"); pwd -P)/$(basename "$0")"
SCRIPT_DIR="$(dirname "$SCRIPT_NAME")"
VERSIONS_FILE="${SCRIPT_DIR}/php-versions.txt"
VERSIONS=$(head -n1 $VERSIONS_FILE)

extension_name="$1"

if [ -z "$extension_name" ]; then
  echo "extension name must be provided" >&2
  exit 1;
fi

if echo "$extension_name" | grep -q ' '; then
  echo "extension name [$extension_name] must not contain a space, not supported for multiple" >&2
  exit 1;
fi

declare -A VERSIONS_API
declare -A VERSIONS_LIB_PATH
VERSIONS_API["7.1"]="20160303"
VERSIONS_API["7.2"]="20170718"
VERSIONS_API["7.3"]="20180731"
VERSIONS_API["7.4"]="20190902"
VERSIONS_LIB_PATH["7.1"]="/usr/lib/php/20160303"
VERSIONS_LIB_PATH["7.2"]="/usr/lib/php/20170718"
VERSIONS_LIB_PATH["7.3"]="/usr/lib/php/20180731"
VERSIONS_LIB_PATH["7.4"]="/usr/lib/php/20190902"

[ -z "$ZEND_EXTENSIONS" ] && ZEND_EXTENSIONS="xdebug"

for v in $VERSIONS; do
  $SCRIPT_DIR/set-php-version.sh $v
  pecl channel-update pecl.php.net
  echo | pecl install --force $extension_name
  pecl uninstall --register-only $extension_name
  strip ${VERSIONS_LIB_PATH[$v]}/$extension_name.so
  if echo "$ZEND_EXTENSIONS" | egrep -q '(^| )'"$extension_name"'( |$)'; then
    echo "zend_extension=${VERSIONS_LIB_PATH[$v]}/$extension_name.so" > /etc/php/$v/mods-available/$extension_name.ini
  else
    echo "extension=$extension_name.so" > /etc/php/$v/mods-available/$extension_name.ini
  fi
  ln -sf /etc/php/$v/mods-available/$extension_name.ini /etc/php/$v/cli/conf.d/30-$extension_name.ini
  ln -sf /etc/php/$v/mods-available/$extension_name.ini /etc/php/$v/apache2/conf.d/30-$extension_name.ini
done

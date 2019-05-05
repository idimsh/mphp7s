#!/bin/bash

file="/srv/php-version"
if [ -f "$file" ]; then
  line="$(head -n 1 $file)"
  if [ "$line" = "7.1" ] || [ "$line" = "7.2" ] || [ "$line" = "7.3" ]; then
    export PHP_VERSION="$line"
    echo "setting default PHP version to $line from file: $file"
  fi
fi

if [ -n "$PHP_VERSION" ]; then
  if [ "$PHP_VERSION" != "7.1" ] && [ "$PHP_VERSION" != "7.2" ] && [ "$PHP_VERSION" != "7.3" ]; then
    echo "Unsetting invalid PHP version value: [$PHP_VERSION]"
    PHP_VERSION=
  fi
fi

if [ -z "$PHP_VERSION" ]; then
  export PHP_VERSION="7.3"
  echo "setting default PHP version to 7.3 default"
fi


if [ "$PHP_VERSION" = "7.1" ]; then
    update-alternatives --set phar /usr/bin/phar7.1 && \
    update-alternatives --set phar.phar /usr/bin/phar.phar7.1 && \
    update-alternatives --set php /usr/bin/php7.1 && \
    update-alternatives --set php-config /usr/bin/php-config7.1 && \
    update-alternatives --set phpize /usr/bin/phpize7.1
fi

if [ "$PHP_VERSION" = "7.2" ]; then
    update-alternatives --set phar /usr/bin/phar7.2 && \
    update-alternatives --set phar.phar /usr/bin/phar.phar7.2 && \
    update-alternatives --set php /usr/bin/php7.2 && \
    update-alternatives --set php-config /usr/bin/php-config7.2 && \
    update-alternatives --set phpize /usr/bin/phpize7.2
fi

if [ "$PHP_VERSION" = "7.3" ]; then
    update-alternatives --set phar /usr/bin/phar7.3 && \
    update-alternatives --set phar.phar /usr/bin/phar.phar7.3 && \
    update-alternatives --set php /usr/bin/php7.3 && \
    update-alternatives --set php-config /usr/bin/php-config7.3 && \
    update-alternatives --set phpize /usr/bin/phpize7.3
fi

FROM ubuntu:18.04
MAINTAINER Abdulrahman Dimashki <idimsh@gmail.com>

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

RUN apt-get update --fix-missing && \
    apt-get install -y --no-install-recommends software-properties-common && \
    add-apt-repository ppa:ondrej/php && \
    apt-get update

############################
## Install packages
############################
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
# Required
    apache2 \
    supervisor \
    incron \
    libmemcached11 \
    nginx-full \
# required for pecl
    pkg-php-tools \
    sed \
    tzdata \
    curl \
# good to have
    bsdmainutils \
    bzip2 \
    dpkg \
    git \
    grep \
    nano \
    net-tools \
    wget \
    zip \
    ""

############################
## PHP 7.1 without extensions
############################
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
libapache2-mod-php7.1 \
php7.1-bcmath \
php7.1-bz2 \
php7.1-cli \
php7.1-curl \
php7.1-dba \
php7.1-gd \
php7.1-gmp \
php7.1-imap \
php7.1-intl \
php7.1-mbstring \
php7.1-mcrypt \
php7.1-mysql \
php7.1-pgsql \
php7.1-pspell \
php7.1-readline \
php7.1-recode \
php7.1-soap \
php7.1-sqlite3 \
php7.1-tidy \
php7.1-xml \
php7.1-xmlrpc \
php7.1-xsl \
php7.1-zip \
""

############################
## PHP 7.2 without extensions
############################
## php7.2-mcrypt does not exists and is replaced with Sodium, can be added throw pecl, but will not include it here

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
libapache2-mod-php7.2 \
php7.2-bcmath \
php7.2-bz2 \
php7.2-cli \
php7.2-curl \
php7.2-dba \
php7.2-gd \
php7.2-gmp \
php7.2-imap \
php7.2-intl \
php7.2-mbstring \
php7.2-mysql \
php7.2-pgsql \
php7.2-pspell \
php7.2-readline \
php7.2-recode \
php7.2-soap \
php7.2-sqlite3 \
php7.2-tidy \
php7.2-xml \
php7.2-xmlrpc \
php7.2-xsl \
php7.2-zip \
""

############################
## PHP 7.3 without extensions
############################
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
libapache2-mod-php7.3 \
php7.3-bcmath \
php7.3-bz2 \
php7.3-cli \
php7.3-curl \
php7.3-dba \
php7.3-gd \
php7.3-gmp \
php7.3-imap \
php7.3-intl \
php7.3-json \
php7.3-mbstring \
php7.3-mysql \
php7.3-pgsql \
php7.3-pspell \
php7.3-readline \
php7.3-recode \
php7.3-soap \
php7.3-sqlite3 \
php7.3-tidy \
php7.3-xml \
php7.3-xmlrpc \
php7.3-xsl \
php7.3-zip \
""

############################
## PHP 7.4 without extensions
############################
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
libapache2-mod-php7.4 \
php7.4-bcmath \
php7.4-bz2 \
php7.4-cli \
php7.4-curl \
php7.4-dba \
php7.4-gd \
php7.4-gmp \
php7.4-imap \
php7.4-intl \
php7.4-json \
php7.4-mbstring \
php7.4-mysql \
php7.4-pgsql \
php7.4-pspell \
php7.4-readline \
php7.4-soap \
php7.4-sqlite3 \
php7.4-tidy \
php7.4-xml \
php7.4-xmlrpc \
php7.4-xsl \
php7.4-zip \
""


## The default PHP version
## This can be overridden by existance of file /srv/php-version which should include the intended version as one line
ENV PHP_VERSION=7.4

## Set the document root directory as relative path to '/srv/' which is the Base Docroot.
## This allows mounting Laravel project for example to '/srv/' and setting this DOCROOT
## to 'public' or './public' or 'public/' to serve files from '/srv/public/'.
## '.' means '/srv/'
## Empty value is not supported due to Apcahe internal startup scripts. If we want to support
## empty value, the start command must be a custom bash script which sets it to '.' before
## calling supervisor, which is not intended to run the process ID 1 to be bash.
ENV DOCROOT=.

# Log to /srv/system instead of /var/log/ when the value is 1
ENV LOG_TO_SRV=0

## Space separated list of Extensions which are considered Zend-Extensions
ARG BUILD_ZEND_EXTENSIONS="xdebug"
ENV ZEND_EXTENSIONS=$BUILD_ZEND_EXTENSIONS

## Space separated list of extensions to compile and install via pecl
ARG BUILD_EXTENSIONS="xdebug inotify ev apcu memcached mongodb igbinary redis swoole"
ENV EXTENSIONS=$BUILD_EXTENSIONS


############################
## Copy required script to install extentions
############################
COPY scripts/server/set-php-version.sh /opt/scripts/set-php-version.sh
COPY scripts/server/install-php-extension.sh /opt/scripts/install-php-extension.sh
COPY scripts/server/php-versions.txt /opt/scripts/php-versions.txt
COPY config/php/idimsh-xdebug-config.ini /opt/idimsh-xdebug-config.ini
RUN chmod +x /opt/scripts/*.sh && \
    sed -i 's#\r##g' /opt/scripts/*.sh && \
    \
    for php_ver in "7.1" "7.2" "7.3" "7.4"; do \
      ln -s /opt/idimsh-xdebug-config.ini /etc/php/$php_ver/mods-available/idimsh-xdebug-config.ini && \
      ln -s /etc/php/$php_ver/mods-available/idimsh-xdebug-config.ini /etc/php/$php_ver/cli/conf.d/40-idimsh-xdebug-config.ini && \
      ln -s /etc/php/$php_ver/mods-available/idimsh-xdebug-config.ini /etc/php/$php_ver/apache2/conf.d/40-idimsh-xdebug-config.ini && \
      \
      ln -sf /srv/system/php/php.ini /etc/php/$php_ver/mods-available/zzz-overrides.ini && \
      ln -sf /etc/php/$php_ver/mods-available/zzz-overrides.ini /etc/php/$php_ver/cli/conf.d/zzz-overrides.ini && \
      ln -sf /etc/php/$php_ver/mods-available/zzz-overrides.ini /etc/php/$php_ver/apache2/conf.d/zzz-overrides.ini && \
      true; \
    done

############################
## Dev packages which should be removed later
############################
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    zlib1g-dev libmemcached-dev pkg-config \
    php7.1-dev php7.2-dev php7.3-dev php7.4-dev \
    build-essential

RUN for ext in $EXTENSIONS; do /opt/scripts/install-php-extension.sh $ext; done

############################
## Finalize PHP
############################
RUN for i in /etc/php/*/mods-available/*.ini; do [ -f $i ] && chmod 644 $i || true; done

RUN apt-get purge -y \
        zlib1g-dev libmemcached-dev pkg-config \
        php7.1-dev php7.2-dev php7.3-dev php7.4-dev \
        build-essential
RUN mkdir -p /var/log/php && \
    chown www-data /var/log/php/

############################
## install composer
############################
RUN curl -sS https://getcomposer.org/installer -o /root/composer-setup.php && \
    php /root/composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
    rm -f /root/composer-setup.php && \
    printf '#!/bin/bash\nexec /usr/bin/php7.1 /usr/local/bin/composer "$@"\n' > /usr/local/bin/composer-7.1 && \
    printf '#!/bin/bash\nexec /usr/bin/php7.2 /usr/local/bin/composer "$@"\n' > /usr/local/bin/composer-7.2 && \
    printf '#!/bin/bash\nexec /usr/bin/php7.3 /usr/local/bin/composer "$@"\n' > /usr/local/bin/composer-7.3 && \
    printf '#!/bin/bash\nexec /usr/bin/php7.4 /usr/local/bin/composer "$@"\n' > /usr/local/bin/composer-7.4 && \
    chmod +x /usr/local/bin/composer-*


############################
## Terminal enhancements
############################
RUN cd /root && \
    git clone https://gist.github.com/1980f616aef1d17106df06304d993d56.git && \
    mv 1980f616aef1d17106df06304d993d56/bash-aliases.sh /opt/bash-aliases && \
    rm -rf 1980f616aef1d17106df06304d993d56 && \
    /bin/echo -e "\n\n## idimsh bash aliases ####\n. /opt/bash-aliases\n\n" | tee -a /root/.bashrc /etc/skel/.bashrc && \
    true

############################
## Apache
############################
RUN DEBIAN_FRONTEND=noninteractive a2enmod macro vhost_alias rewrite status expires headers mime_magic mime remoteip ssl
RUN DEBIAN_FRONTEND=noninteractive a2dismod -f php* autoindex ssl

RUN mv /etc/apache2/ports.conf /etc/apache2/ports.conf.disabled && \
    mv /etc/apache2/envvars /etc/apache2/envvars.disabled && \
    mkdir /root/bin/

COPY scripts/setup-instance-modified /root/bin/
COPY scripts/secondary-init-script /root/bin/
RUN chmod +x /root/bin/setup-instance-modified /root/bin/secondary-init-script && \
    /root/bin/setup-instance-modified php7.1 && \
    /root/bin/setup-instance-modified php7.2 && \
    /root/bin/setup-instance-modified php7.3 && \
    /root/bin/setup-instance-modified php7.4 && \
    true

COPY config/apache2-main/apache2.conf /etc/apache2/apache2.conf
COPY config/apache2-main/envvars-common /etc/apache2/
COPY config/apache2-php7.1/ /etc/apache2-php7.1/
COPY config/apache2-php7.2/ /etc/apache2-php7.2/
COPY config/apache2-php7.3/ /etc/apache2-php7.3/
COPY config/apache2-php7.4/ /etc/apache2-php7.4/
RUN mkdir -p \
    /etc/apache2-php7.1/sites-enabled/ \
    /etc/apache2-php7.2/sites-enabled/ \
    /etc/apache2-php7.3/sites-enabled/ \
    /etc/apache2-php7.4/sites-enabled/


COPY config/apache2-common/sites-enabled/ /etc/apache2/sites-enabled/
COPY config/apache2-common/sites-enabled/ /etc/apache2-php7.1/sites-enabled/
COPY config/apache2-common/sites-enabled/ /etc/apache2-php7.2/sites-enabled/
COPY config/apache2-common/sites-enabled/ /etc/apache2-php7.3/sites-enabled/
COPY config/apache2-common/sites-enabled/ /etc/apache2-php7.4/sites-enabled/
RUN chmod 644 /etc/apache2*/* /etc/apache2*/*/* && \
    cp -p /usr/sbin/apache2ctl /usr/sbin/apache2ctl-php7.1 && \
    cp -p /usr/sbin/apache2ctl /usr/sbin/apache2ctl-php7.2 && \
    cp -p /usr/sbin/apache2ctl /usr/sbin/apache2ctl-php7.3 && \
    cp -p /usr/sbin/apache2ctl /usr/sbin/apache2ctl-php7.4 && \
    true

RUN chmod 644 /etc/apache2*/* /etc/apache2*/*/* && \
    ln -sf /etc/apache2/sites-enabled/000-default.conf /etc/apache2-php7.1/sites-enabled/000-default.conf && \
    ln -sf /etc/apache2/sites-enabled/000-default.conf /etc/apache2-php7.2/sites-enabled/000-default.conf && \
    ln -sf /etc/apache2/sites-enabled/000-default.conf /etc/apache2-php7.3/sites-enabled/000-default.conf && \
    ln -sf /etc/apache2/sites-enabled/000-default.conf /etc/apache2-php7.4/sites-enabled/000-default.conf && \
    true

############################
## Nginx
############################
COPY config/nginx/ /etc/nginx/
RUN rm -f /etc/nginx/sites-*/* && \
    rmdir /etc/nginx/sites-*/ && \
    find /etc/nginx/ -type f -print0 | xargs -0 chmod 644


############################
## Copy scripts
############################
COPY scripts/server /opt/scripts
RUN find /opt/scripts -type f -print0 | xargs -0 chmod 644 && \
    find /opt/scripts -type f \( -name "*.php" -o -name "*.sh" \) -print0 | xargs -0 chmod +x && \
    find /opt/scripts -type f \( -name "*.php" -o -name "*.sh" \) -print0 | xargs -0 sed -i 's#\r##g' && \
    for file in /opt/scripts/*; do ln -s $file /usr/local/bin/; done

############################
## Incron
############################
RUN echo "root" > /etc/incron.allow && \
    mkdir -p /var/spool/incron && \
    echo '/srv/php-version IN_MODIFY,IN_CREATE,IN_DELETE,IN_DELETE_SELF,IN_CLOSE_WRITE /opt/scripts/nginx-control.sh reload' > /var/spool/incron/root


############################
## Supervisord
############################
RUN mkdir -p /var/log/supervisor && \
    mkdir -p /etc/supervisor/conf.d
COPY config/supervisor/supervisor.conf /etc/supervisor.conf


############################
## Clear/Clean
############################
RUN DEBIAN_FRONTEND=noninteractive apt-get -y --purge autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

## This soecial for my mounts
RUN groupadd --gid 999 vboxfs && usermod -aG 999 www-data

EXPOSE 80

CMD ["supervisord", "-c", "/etc/supervisor.conf"]

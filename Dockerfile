FROM ubuntu:18.04

MAINTAINER Abdulrahman Dimashki <idimsh@gmail.com>

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
RUN apt-get update --fix-missing && \
    apt-get install -y --no-install-recommends software-properties-common && \
    add-apt-repository ppa:ondrej/php && \
    apt-get update

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
# Required
    apache2 \
    curl \
    exim4-daemon-light \
    incron \
    libmemcached11 \
    nginx-full \
    ## required for pecl
    pkg-php-tools \
    sed \
    supervisor \
    tzdata \
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
php7.1-zip


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
php7.2-zip


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
php7.3-zip

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    zlib1g-dev libmemcached-dev pkg-config

############################
## Php 7.1
############################
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends php7.1-dev && \
    update-alternatives --set phar /usr/bin/phar7.1 && \
    update-alternatives --set phar.phar /usr/bin/phar.phar7.1 && \
    update-alternatives --set php /usr/bin/php7.1 && \
    update-alternatives --set php-config /usr/bin/php-config7.1 && \
    update-alternatives --set phpize /usr/bin/phpize7.1

COPY config/php/xdebug.ini /etc/php/7.1/mods-available/xdebug.ini
RUN pecl install --force xdebug-2.6.0 && \
    pecl uninstall -r xdebug-2.6.0 && \
    strip /usr/lib/php/20160303/xdebug.so && \
    sed -i 's#^zend_extension.*#zend_extension=/usr/lib/php/20160303/xdebug.so#g' /etc/php/7.1/mods-available/xdebug.ini && \
    ln -s /etc/php/7.1/mods-available/xdebug.ini /etc/php/7.1/cli/conf.d/ && \
    ln -s /etc/php/7.1/mods-available/xdebug.ini /etc/php/7.1/apache2/conf.d/

RUN pecl install --force inotify && \
    pecl uninstall -r inotify && \
    strip /usr/lib/php/20160303/inotify.so && \
    echo "extension=inotify.so" > /etc/php/7.1/mods-available/inotify.ini && \
    ln -s /etc/php/7.1/mods-available/inotify.ini /etc/php/7.1/cli/conf.d/ && \
    ln -s /etc/php/7.1/mods-available/inotify.ini /etc/php/7.1/apache2/conf.d/

RUN pecl install --force ev && \
    pecl uninstall -r ev && \
    strip /usr/lib/php/20160303/ev.so && \
    echo "extension=ev.so" > /etc/php/7.1/mods-available/ev.ini && \
    ln -s /etc/php/7.1/mods-available/ev.ini /etc/php/7.1/cli/conf.d/ && \
    ln -s /etc/php/7.1/mods-available/ev.ini /etc/php/7.1/apache2/conf.d/

RUN echo | pecl install --force apcu && \
    pecl uninstall -r apcu && \
    strip /usr/lib/php/20160303/apc*.so && \
    echo "extension=apcu.so" > /etc/php/7.1/mods-available/apcu.ini && \
    ln -s /etc/php/7.1/mods-available/apcu.ini /etc/php/7.1/cli/conf.d/ && \
    ln -s /etc/php/7.1/mods-available/apcu.ini /etc/php/7.1/apache2/conf.d/

RUN pecl install --force memcached && \
    pecl uninstall -r memcached && \
    strip /usr/lib/php/20160303/memcached.so && \
    echo "extension=memcached.so" > /etc/php/7.1/mods-available/memcached.ini && \
    ln -s /etc/php/7.1/mods-available/memcached.ini /etc/php/7.1/cli/conf.d/ && \
    ln -s /etc/php/7.1/mods-available/memcached.ini /etc/php/7.1/apache2/conf.d/

RUN pecl install --force mongodb && \
    pecl uninstall -r mongodb && \
    strip /usr/lib/php/20160303/mongodb.so && \
    echo "extension=mongodb.so" > /etc/php/7.1/mods-available/mongodb.ini && \
    ln -s /etc/php/7.1/mods-available/mongodb.ini /etc/php/7.1/cli/conf.d/ && \
    ln -s /etc/php/7.1/mods-available/mongodb.ini /etc/php/7.1/apache2/conf.d/

############################
## Php 7.2
############################
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends php7.2-dev && \
    update-alternatives --set phar /usr/bin/phar7.2 && \
    update-alternatives --set phar.phar /usr/bin/phar.phar7.2 && \
    update-alternatives --set php /usr/bin/php7.2 && \
    update-alternatives --set php-config /usr/bin/php-config7.2 && \
    update-alternatives --set phpize /usr/bin/phpize7.2

COPY config/php/xdebug.ini /etc/php/7.2/mods-available/xdebug.ini
RUN pecl channel-update pecl.php.net && \
    echo | pecl install --force xdebug inotify ev apcu memcached mongodb
RUN pecl uninstall -r xdebug
RUN pecl uninstall -r inotify ev apcu memcached mongodb
RUN strip /usr/lib/php/20170718/*.so
RUN for i in xdebug inotify ev apcu memcached mongodb; do \
    [ "$i" = "xdebug" ] \
    && sed -i 's#^zend_extension.*#zend_extension=/usr/lib/php/20170718/xdebug.so#g' /etc/php/7.2/mods-available/xdebug.ini \
    || echo "extension=$i.so" > /etc/php/7.2/mods-available/$i.ini; \
    ln -s /etc/php/7.2/mods-available/$i.ini /etc/php/7.2/cli/conf.d/ && \
    ln -s /etc/php/7.2/mods-available/$i.ini /etc/php/7.2/apache2/conf.d/ ; \
    done

############################
## Php 7.3
############################
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends php7.3-dev && \
    update-alternatives --set phar /usr/bin/phar7.3 && \
    update-alternatives --set phar.phar /usr/bin/phar.phar7.3 && \
    update-alternatives --set php /usr/bin/php7.3 && \
    update-alternatives --set php-config /usr/bin/php-config7.3 && \
    update-alternatives --set phpize /usr/bin/phpize7.3

COPY config/php/xdebug.ini /etc/php/7.3/mods-available/xdebug.ini
RUN pecl channel-update pecl.php.net && \
    echo | pecl install --force xdebug inotify ev apcu memcached mongodb
RUN pecl uninstall -r xdebug
RUN pecl uninstall -r inotify ev apcu memcached mongodb
RUN strip /usr/lib/php/20180731/*.so
RUN for i in xdebug inotify ev apcu memcached mongodb; do \
    [ "$i" = "xdebug" ] \
    && sed -i 's#^zend_extension.*#zend_extension=/usr/lib/php/20180731/xdebug.so#g' /etc/php/7.3/mods-available/xdebug.ini \
    || echo "extension=$i.so" > /etc/php/7.3/mods-available/$i.ini; \
    ln -s /etc/php/7.3/mods-available/$i.ini /etc/php/7.3/cli/conf.d/ && \
    ln -s /etc/php/7.3/mods-available/$i.ini /etc/php/7.3/apache2/conf.d/ ; \
    done


############################
## Finalize PHP
############################
RUN chmod 644 /etc/php/*/mods-available/*.ini /usr/lib/php/*/*.so
RUN apt-get purge -y php7.3-dev php7.2-dev php7.1-dev zlib1g-dev libmemcached-dev pkg-config
RUN mkdir -p /var/log/php && \
    chown www-data /var/log/php/

# install composer
RUN curl -sS https://getcomposer.org/installer -o /root/composer-setup.php && \
    php /root/composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
    rm -f /root/composer-setup.php && \
    printf '#!/bin/bash\nexec /usr/bin/php7.1 /usr/local/bin/composer "$@"\n' > /usr/local/bin/composer-7.1 && \
    printf '#!/bin/bash\nexec /usr/bin/php7.2 /usr/local/bin/composer "$@"\n' > /usr/local/bin/composer-7.2 && \
    printf '#!/bin/bash\nexec /usr/bin/php7.3 /usr/local/bin/composer "$@"\n' > /usr/local/bin/composer-7.3 && \
    chmod +x /usr/local/bin/composer-*

############################
## Terminal enhancements
############################
RUN printf "\nexport EDITOR=nano\nexport HISTSIZE=2000\n\nexport PS1='${debian_chroot:+($debian_chroot)}\[\033[1;31m\]\h\[\033[0m\]:\[\033[1;32m\]\w\[\033[0m\]\$ '\n\nalias rm='rm -i'\nalias cp='cp -i'\nalias mv='mv -i'\n\nalias egrep='egrep --color=auto'\nalias fgrep='fgrep --color=auto'\nalias grep='grep --color=auto'\n\nalias chown='chown --preserve-root'\nalias chmod='chmod --preserve-root'\n\nalias ll='ls -lAph --color=auto'\nalias lt='ls -lAph --color=auto -t'\n\nalias ps1='ps -efH'\nalias ps2='ps aux -H'\nalias ns='netstat -vntlp'\n" >> /root/.bashrc

############################
## Exim
############################
RUN sed -i "s#dc_eximconfig_configtype=.*#dc_eximconfig_configtype='internet'#g" /etc/exim4/update-exim4.conf.conf

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
    /root/bin/setup-instance-modified php7.3

COPY config/apache2-main/apache2.conf /etc/apache2/apache2.conf
COPY config/apache2-php7.1/ /etc/apache2-php7.1/
COPY config/apache2-php7.2/ /etc/apache2-php7.2/
COPY config/apache2-php7.3/ /etc/apache2-php7.3/
RUN mkdir -p /etc/apache2-php7.1/sites-enabled/ /etc/apache2-php7.2/sites-enabled/ /etc/apache2-php7.3/sites-enabled/
COPY config/apache2-common/sites-enabled/ /etc/apache2/sites-enabled/
COPY config/apache2-common/sites-enabled/ /etc/apache2-php7.1/sites-enabled/
COPY config/apache2-common/sites-enabled/ /etc/apache2-php7.2/sites-enabled/
COPY config/apache2-common/sites-enabled/ /etc/apache2-php7.3/sites-enabled/
RUN chmod 644 /etc/apache2*/* /etc/apache2*/*/* && \
    cp -p /usr/sbin/apache2ctl /usr/sbin/apache2ctl-php7.1 && \
    cp -p /usr/sbin/apache2ctl /usr/sbin/apache2ctl-php7.2 && \
    cp -p /usr/sbin/apache2ctl /usr/sbin/apache2ctl-php7.3


############################
## Nginx
############################
COPY config/nginx/ /etc/nginx/
RUN rm -f /etc/nginx/sites-*/* && \
    rmdir /etc/nginx/sites-*/ && \
    find /etc/nginx/ -type f -print0 | xargs -0 chmod 644


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
## Finalize hosts/scripts
############################
COPY scripts/server /opt/scripts
RUN find /opt/scripts -type f -print0 | xargs -0 chmod 644 && \
    find /opt/scripts -type f \( -name "*.php" -o -name "*.sh" \) -print0 | xargs -0 chmod +x && \
    find /opt/scripts -type f \( -name "*.php" -o -name "*.sh" \) -print0 | xargs -0 sed -i 's#\r##g' && \
    printf 'export PATH=$PATH:/opt/scripts' >> /root/.bashrc

############################
## Clear/Clean
############################
RUN DEBIAN_FRONTEND=noninteractive apt-get -y --purge autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN for dir in $(/bin/ls -1d /etc/{apache*,php}); do find ${dir} -type d -print0 | xargs -0 chmod 755;  done

## This soecial for my mounts
RUN groupadd --gid 999 vboxfs && usermod -aG 999 www-data


EXPOSE 80
ENV HOST_IN_LOG_NAME=0

CMD ["supervisord", "-c", "/etc/supervisor.conf"]


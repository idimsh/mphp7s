FROM idimsh/mphp7s:1.0

MAINTAINER Abdulrahman Dimashki <idimsh@gmail.com>

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
RUN apt-get update && apt-get install -y build-essential

RUN mkdir /root/swoole-src && \
    cd /root/swoole-src && \
    git clone https://github.com/swoole/swoole-src.git .

############################
## Php 7.1
############################
RUN for php_ver in "7.1" "7.2" "7.3"; do \
    apt-get install -y --no-install-recommends php${php_ver}-dev && \
    update-alternatives --set phar /usr/bin/phar${php_ver} && \
    update-alternatives --set phar.phar /usr/bin/phar.phar${php_ver} && \
    update-alternatives --set php /usr/bin/php${php_ver} && \
    update-alternatives --set php-config /usr/bin/php-config${php_ver} && \
    update-alternatives --set phpize /usr/bin/phpize${php_ver} && \
    cd /root/swoole-src && \
    make clean; \
    phpize && \
    ./configure --enable-sockets --enable-openssl --enable-http2 --enable-swoole  --enable-mysqlnd && \
    make && \
    make install && \
    strip /usr/lib/php/*/swoole.so && \
    echo "extension=swoole.so" > /etc/php/${php_ver}/mods-available/swoole.ini && \
    ln -s /etc/php/${php_ver}/mods-available/swoole.ini /etc/php/${php_ver}/cli/conf.d/ && \
    ln -s /etc/php/${php_ver}/mods-available/swoole.ini /etc/php/${php_ver}/apache2/conf.d/; \
    done

RUN rm -rf /root/swoole-src

RUN apt-get -y purge build-essential && apt-get -y --purge autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 80
ENV HOST_IN_LOG_NAME=0

CMD ["supervisord", "-c", "/etc/supervisor.conf"]


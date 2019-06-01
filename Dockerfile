FROM idimsh/mphp7s:1.1

MAINTAINER Abdulrahman Dimashki <idimsh@gmail.com>

COPY config/apache2-main/envvars-common /etc/apache2/
COPY config/apache2-php7.1/ /etc/apache2-php7.1/
COPY config/apache2-php7.2/ /etc/apache2-php7.2/
COPY config/apache2-php7.3/ /etc/apache2-php7.3/
COPY config/apache2-common/sites-enabled/ /etc/apache2/sites-enabled/
RUN chmod 644 /etc/apache2*/* /etc/apache2*/*/* && \
    ln -sf /etc/apache2/sites-enabled/000-default.conf /etc/apache2-php7.1/sites-enabled/000-default.conf && \
    ln -sf /etc/apache2/sites-enabled/000-default.conf /etc/apache2-php7.2/sites-enabled/000-default.conf && \
    ln -sf /etc/apache2/sites-enabled/000-default.conf /etc/apache2-php7.3/sites-enabled/000-default.conf

RUN for file in /opt/scripts/*; do ln -s $file /usr/local/bin/; done

############################
## Supervisord
############################
COPY config/supervisor/supervisor.conf /etc/supervisor.conf

EXPOSE 80
ENV PHP_VERSION=7.3

## Set the document root directory as relative path to '/srv/' which is the Base Docroot.
## This allows mounting Laravel project for example to '/srv/' and setting this DOCROOT
## to 'public' or './public' or 'public/' to serve files from '/srv/public/'.
## '.' means '/srv/'
## Empty value is not supported due to Apcahe internal startup scripts. If we want to support
## empty value, the start command must be a custom bash script which sets it to '.' before
## calling supervisor, which is not intended to run the process ID 1 to be bash.
ENV DOCROOT=.

CMD ["supervisord", "-c", "/etc/supervisor.conf"]


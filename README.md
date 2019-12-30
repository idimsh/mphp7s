# MPHP7 Single (Multi PHP - Single Site) Docker Image on mod_php

[![Total Downloads](https://img.shields.io/docker/pulls/idimsh/mphp7s?style=square)](https://hub.docker.com/repository/docker/idimsh/mphp7s)
[![MicroBadger Layers](https://img.shields.io/microbadger/layers/idimsh/mphp7s/latest)](https://hub.docker.com/repository/docker/idimsh/mphp7s)
[![MicroBadger Image Size](https://img.shields.io/microbadger/image-size/idimsh/mphp7s/latest)](https://hub.docker.com/repository/docker/idimsh/mphp7s)


## Why
I am a fan of mod_php with Apache and not much into PHP-FPM, in this image 
Nginx works as reverse proxy to Apache instances which run a specific 
version of PHP using mod_php.

## Purpose
To host a single web-application with the desired PHP version and to be 
able to change the PHP version from the project (web project) document 
root via config file. 
The configuration for Nginx is generated automatically.

## Structure
The image is based on Ubuntu 18.04 and runs Nginx on port 80 which works as 
revers proxy.  
3 Apache instances run on different ports for 3 versions of 
PHP: 7.1, 7.2, 7.3, 7.4.  
Each apache instance operates mod_prefork and listens on 
ports: 83, 84, 85, 86 
respectively, each of which uses a different mod_php version.  
  
A main directory which contains the web application is supposed to 
be mounted to the container r/w to '/srv/' directory which is the 
main DocumentRoot.

## Features:  
In addition to most of the commonly used PHP extensions from Ubuntu,
The following extra PHP Extensions are available:
- xdebug
- inotify
- ev
- apcu
- memcached
- mongodb
- igbinary
- redis
- swoole
  
And they are all compiled (by default) using `pecl` when the image was created.

The compilation of extension is controlled by build argument (`--build-arg`) `BUILD_EXTENSIONS` which is a space separated list of extension names to be installed for every PHP version.    


## Environment variables:
`PHP_VERSION`: (default: 7.4) The version of PHP which serves the website 
and which runs the cli 'php' command.  
Supported values: 7.1, 7.2, 7.3, 7.4 
  
`DOCROOT`: (default: ".") Must me set, it is the relative path inside `'/srv/'`
directory which will be the document root.
  
`LOG_TO_SRV`: (default: "0") If set to non "0", the log files of Apache, Nginx, and PHP will reside in `/srv/system/log/`
directory where each service will have a subdirectory there, otherwise they will be in the default '/var/log/' inside the container.  
Further tests on permissions need to be conducted on Linux docker hosts.  

## Running:
To run and auto start all services:  
`docker run -it idimsh/mphp7s:latest`  
  
It will execute the default supervisor command which starts all services.  
Pressing Ctrl+C in the running container will kill supervisor and 
services running then terminate the container.  
  
Or go to shell by  
`docker run -it idimsh/mphp7s:latest /bin/bash`  
  
Then execute:  
`run.sh`  
To get supervisor running in the foreground. Pressing Ctrl+C will kill 
supervisor but keep all services running and return to shell.  
  
#### Note
Supervisor is not really *controlling* the processes, it just call the start
`service` or `init.d` command, I did not build commands to control Apache or
Nginx using supervisor (to support auto reload, exit status monitoring, 
signals, ...). The implementation of supervisor is simple.  
  
##### Full command:
`docker run --rm -it -v .:/srv --hostname d1.mphp7s.loc -e PHP_VERSION=7.2 -e DOCROOT=public -e LOG_TO_SRV=1 -p 8080:80 idimsh/mphp7s:latest`  
  
`-v .:/srv`: mounts current directory to base directory '/srv/' (which must be '/srv').  
`--hostname d1.mphp7.loc`: Set host name of the container to a FQDN which reduces Apaches' startup warnings.  
`-e PHP_VERSION=7.2`: Set PHP version to 7.2.  
`-e DOCROOT=public`: Set the serving docroot to '/srv/public/', it is a relative directory.  
`-e LOG_TO_SRV=1`: Write log files for services to '/srv/system/log/'.  
  
## Controlling PHP version from PHP Project:  
In the mounted DocRoot to '/srv/', a file named: 'php-version' is read and
the first line of it controls the PHP version, supported values: 7.1, 7.2, 7.3, 7.4.  
  
The existence of this file overrides the PHP version passed in environment 
(`-e` param), moreover: this file is constantly being monitored for changes
using `incron` daemon from the container and any changes to it will cause
the Nginx server to reload and serve the changed PHP version.  
For this to work however, the file '/srv/php-version' should exists when 
the container is starting. (i.e: it is not monitored for creation).  

## Building from Dockerfile:
Build locally by cloning the repository
```bash
git clone git@github.com:idimsh/mphp7s.git .
cd mphp7s
docker build -t "idimsh-mphp7s:latest" .
```  
This will build the image with all extra PHP extensions (the default ones) which are: `xdebug inotify ev apcu memcached mongodb igbinary redis swoole`  
  
To build with custom extensions:
```bash
docker build -t "idimsh-mphp7s:latest" --build-arg BUILD_EXTENSIONS="apcu" .
```  
This will build only with `acpu` extension

## Comsuming the image from docker-compose:  
Here is an example of docker-compose.yaml
```docker
version: '3.5'
services:
  my-web:
    image: idimsh/mphp7s:latest
    container_name: my-web
    hostname: my-web.loc
    args:                                                                      
        BUILD_EXTENSIONS: 'apcu memcached'
    environment:
        PHP_VERSION: 7.3
        DOCROOT: public
    ports:
      - '8082:80'
    volumes:
      - '.:/srv:rw'
    networks:
      default:
        aliases:
          - my-web
          - my-web.loc
```




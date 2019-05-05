# MPHP7 Single (Multi PHP - Single Site) Docker Image on mod_php (version 1)

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
PHP: 7.1, 7.2, 7.3.  
Each apache instance operates mod_prefork and listens on 
ports: 83, 84, 85 
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
  
And they are all compiled using `pecl` when the image was created.   


## Environment variables:
`PHP_VERSION`: (default: 7.3) The version of PHP which serves the website 
and which runs the cli 'php' command.  
Supported values: 7.1, 7.2, 7.3  
  
`HOST_IN_LOG_NAME`: (default: "") Better to keep it empty, it is here from a 
different image I built. In quick: If set to non empty will cause log 
file names (for Apache, Nginx, PHP) to have the host name of the 
container prepended to the default name.

## Running:
To run and auto start all services:  
`docker run -it idimsh-mphp7s:v1`  
  
It will execute the default supervisor command which starts all services.  
Pressing Ctrl+C in the running container will kill supervisor and 
services running then terminate the container.  
  
Or go to shell by  
`docker run -it idimsh-mphp7s:v1 /bin/bash`  
  
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
`docker run -it -v $(pwd):/srv --hostname d1.mphp7s.loc -e PHP_VERSION=7.2 -p 80:80 idimsh-mphp7s:v1`  
  
`-v $(pwd):/srv`: mounts current directory to document root (supposing 
your docker host is linux).  
`--hostname d1.mphp7.loc`: Set host name of the container to a FQDN which reduces
Apaches' startup warnings.  
`-e PHP_VERSION=7.2`: Set PHP version to 7.2.  
  
## Controlling PHP version from PHP Project:  
In the mounted DocRoot to '/srv/', a file named: 'php-version' is read and
the first line of it controls the PHP version, supported values: 7.1, 7.2, 7.3.  
  
The existence of this file overrides the PHP version passed in environment 
(`-e` param), moreover: this file is constantly being monitored for changes
using `incron` daemon from the container and any changes to it will cause
the Nginx server to reload and serve the changed PHP version.  
For this to work however, the file '/srv/php-version' should exists when 
the container is starting. (i.e: it is not monitored for creation).  

## Building from Dockerfile:
`docker build -t "idimsh-mphp7s:v1" .`

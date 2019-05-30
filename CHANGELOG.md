# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project Do NOT adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2] - 2019-05-30
### Added
- Exposed environment variable `PHP_VERSION` in Dockerfile
- Added environment variable `DOCROOT` which is a relative path inside '/srv'
to serve files from

### Changed
Nothing major:
- envvars file for each apache instance is shortened, and now "sourcing" 
one common file: /etc/apache2/envvars-common
- 000-default.conf is generated via template file, the replacement 
(replacing ${DOCROOT} with the value of the env-var defined)
is done in /etc/apache2/envvars-common
- 000-default.conf (default virtual host) is now a single, 
definitions for the 3 apache instances are symlinks to one file, 
previously they were the same copy.
- Supervisor command for apache processes are now using init.d scripts
previously they where calling 'service' wrapper, this is required to pass
environment variables to apache init script.

## [1.1] - 2019-05-27
### Added
- PHP extension: swoole, to all PHP versions

## [1.0] - 2019-05-05
### Added
- Initial Release


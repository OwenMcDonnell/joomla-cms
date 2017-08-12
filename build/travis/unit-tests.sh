#!/bin/bash
# Script for preparing the unit tests in Joomla!

# PHP 7+ needs to have the LDAP extension manually enabled
if [[ $TRAVIS_PHP_VERSION = 5.* || $TRAVIS_PHP_VERSION = "7.0" ]]; then echo 'extension=ldap.so' >> ~/.phpenv/versions/$(phpenv version-name)/etc/conf.d/travis.ini; fi
if [[ $TRAVIS_PHP_VERSION -ge 7.1 || $TRAVIS_PHP_VERSION != "nightly" ]]; then sudo apt-get install "php$TRAVIS_PHP_VERSION-ldap"; fi

# Path to the Joomla! installation
BASE="$1"

# Abort travis execution if setup fails
set -e

# Disable xdebug.
phpenv config-rm xdebug.ini || echo "xdebug not available"

# Make sure all dev dependencies are installed, ignore platform requirements because Travis is missing the LDAP tooling on all new images
composer install --ignore-platform-reqs

# Setup databases for testing
mysql -u root -e 'create database joomla_ut;'
mysql -u root joomla_ut < "$BASE/tests/unit/schema/mysql.sql"
psql -c 'create database joomla_ut;' -U postgres
psql -d joomla_ut -a -f "$BASE/tests/unit/schema/postgresql.sql"

# Set up Apache
# - ./build/travis/php-apache.sh
# Enable additional PHP extensions

if [[ $INSTALL_MEMCACHE == "yes" ]]; then phpenv config-add "$BASE/build/travis/phpenv/memcache.ini"; fi
if [[ $INSTALL_MEMCACHED == "yes" ]]; then phpenv config-add "$BASE/build/travis/phpenv/memcached.ini"; fi
if [[ $INSTALL_APC == "yes" ]]; then phpenv config-add "$BASE/build/travis/phpenv/apc-$TRAVIS_PHP_VERSION.ini"; fi
if [[ $INSTALL_APCU == "yes" && $TRAVIS_PHP_VERSION = 5.* ]]; then printf "\n" | pecl install apcu-4.0.10 && phpenv config-add "$BASE/build/travis/phpenv/apcu-$TRAVIS_PHP_VERSION.ini"; fi
if [[ $INSTALL_APCU == "yes" && $TRAVIS_PHP_VERSION = 7.* ]]; then printf "\n" | pecl install apcu && phpenv config-add "$BASE/build/travis/phpenv/apcu-$TRAVIS_PHP_VERSION.ini"; fi
if [[ $INSTALL_REDIS == "yes" ]]; then phpenv config-add "$BASE/build/travis/phpenv/redis.ini"; fi

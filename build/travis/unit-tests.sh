#!/bin/bash
# Script for preparing the unit tests in Joomla!

# Path to the Joomla! installation
BASE="$1"

# Abort travis execution if setup fails
set -e

# Disable xdebug on php 7.0.* and lower.
if [[ ( $TRAVIS_PHP_VERSION = 5.* ) || ( $TRAVIS_PHP_VERSION = 7.0 ) ]]; then phpenv config-rm xdebug.ini; fi

# Disable xdebug in hhvm.
if [[ $TRAVIS_PHP_VERSION = hhv* ]]; then echo 'xdebug.enable = 0' >> /etc/hhvm/php.ini; fi
if [[ $TRAVIS_PHP_VERSION = hhv* ]]; then alias composer="hhvm -v ResourceLimit.SocketDefaultTimeout=30 -v Http.SlowQueryThreshold=30000 -v Eval.Jit=false /usr/local/bin/composer"; fi

# Make sure all dev dependencies are installed
composer install
if [[ $HHVMPHP7 == "yes" ]]; then echo hhvm.php7.all=1 >> /etc/hhvm/php.ini; fi
if [[ $TRAVIS_PHP_VERSION = hhvm-3.12 ]]; then sudo wget --directory-prefix=./ https://github.com/PocketRent/hhvm-pgsql/raw/releases/3.12.0/ubuntu/trusty/pgsql.so; fi
if [[ $TRAVIS_PHP_VERSION = hhvm ]]; then sudo wget --directory-prefix=./ https://github.com/PocketRent/hhvm-pgsql/raw/releases/3.14.0/ubuntu/trusty/pgsql.so; fi
if [[ $TRAVIS_PHP_VERSION = hhvm-3.12 ]]; then echo hhvm.dynamic_extensions[pgsql] = pgsql.so >> /etc/hhvm/php.ini; fi
if [[ $TRAVIS_PHP_VERSION = hhvm ]]; then echo hhvm.dynamic_extensions[pgsql] = pgsql.so >> /etc/hhvm/php.ini; fi

# Setup databases for testing
mysql -u root -e 'create database joomla_ut;'
mysql -u root joomla_ut < "$BASE/tests/unit/schema/mysql.sql"
psql -c 'create database joomla_ut;' -U postgres
psql -d joomla_ut -a -f "$BASE/tests/unit/schema/postgresql.sql"

# Set up Apache
# - ./build/travis/php-apache.sh
# Enable additional PHP extensions

if [[ $INSTALL_MEMCACHE == "yes"  && $TRAVIS_PHP_VERSION != hhv* ]]; then phpenv config-add "$BASE/build/travis/phpenv/memcache.ini"; fi
if [[ $INSTALL_MEMCACHED == "yes"  && $TRAVIS_PHP_VERSION != hhv* ]]; then phpenv config-add "$BASE/build/travis/phpenv/memcached.ini"; fi
if [[ $INSTALL_APC == "yes"  && $TRAVIS_PHP_VERSION != hhv* ]]; then phpenv config-add "$BASE/build/travis/phpenv/apc-$TRAVIS_PHP_VERSION.ini"; fi
if [[ $INSTALL_APCU == "yes" && $TRAVIS_PHP_VERSION = 5.* ]]; then printf "\n" | pecl install apcu-4.0.10 && phpenv config-add "$BASE/build/travis/phpenv/apcu-$TRAVIS_PHP_VERSION.ini"; fi
if [[ $INSTALL_APCU == "yes" && $TRAVIS_PHP_VERSION = 7.* ]]; then printf "\n" | pecl install apcu-beta && phpenv config-add "$BASE/build/travis/phpenv/apcu-$TRAVIS_PHP_VERSION.ini"; fi
if [[ $INSTALL_APCU_BC_BETA == "yes" ]]; then printf "\n" | pecl install apcu_bc-beta; fi
if [[ $INSTALL_REDIS == "yes" && $TRAVIS_PHP_VERSION != hhv* ]]; then phpenv config-add "$BASE/build/travis/phpenv/redis.ini"; fi
if [[ $INSTALL_REDIS == "yes" && $TRAVIS_PHP_VERSION = hhv* ]]; then cat "$BASE/build/travis/phpenv/redis.ini" >> /etc/hhvm/php.ini; fi

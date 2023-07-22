# syntax=docker/dockerfile:1.5-labs
# vim:set ts=2 sw=2 ft=dockerfile :
FROM salmatron/baseimage:sal-jammy-5.0.5

# Custom cache invalidation
# https://www.freecodecamp.org/news/docker-cache-tutorial/
# Just provide a random ---build-arg to invalidate nasty cache isssues. e.g.,:
# `docker build -t my-image --build-arg CACHEBUST=$(date +%s)`

ARG SAL__SACHEBUST=1
ENV SAL__SACHEBUST=$SAL__SACHEBUST

ARG SAL__ENV=development
ENV SAL__ENV=$SAL__ENV

# Nginx
EXPOSE 80

# MariaDB
EXPOSE 3306

# Nginx logs
VOLUME ["/var/log/nginx"]

# PHP-FPM logs
VOLUME ["/var/log/php-fpm"]

# MariaDB data
VOLUME ["/var/lib/mysql"]

# MariaDB logs (the official container doesn't use/specify a volume for this, I think relies on stdout/err and `docker logs`)
VOLUME ["/var/log/mysql"]

COPY /toolkit/image/bin/* /usr/local/bin/

#RUN \
#    . /saldrc.lib.sh || exit; \
#    umask 0000; \
#    mkdir /lewp-cache;

RUN \
    --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt/lists \
    --mount=type=cache,target=/lewp-cache,mode=777 \
    . /saldrc.lib.sh || exit; \
    chmod -R a=rwX /lewp-cache; \
    apt-get update; \
    saldrc__apt_install nginx

ARG PHP_VERSION=8.1
ENV PHP_VERSION=$PHP_VERSION

RUN \
    --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt/lists \
    --mount=type=cache,target=/lewp-cache,mode=777 \
    . /saldrc.lib.sh || exit; \
    saldrc__apt_install \
        php8.1 \
        php8.1-fpm \
        php8.1-curl \
        php8.1-gd \
        php8.1-intl \
        php8.1-mbstring \
        php8.1-mysql \
        php8.1-xml \
        php8.1-xmlrpc \
        php8.1-zip \
        php8.1-soap \
        php8.1-gmp \
        php8.1-bcmath \
        php8.1-imap \
        php8.1-bz2 \
        php8.1-tidy \
        php8.1-sqlite3 \
        php8.1-imagick \
        php8.1-opcache \
        php8.1-yaml \
        php8.1-xdebug; \
        \
        installedVersion="$(php --version | sed -nE 's@^PHP\s+([0-9]+\.[0-9]+).*@\1@ip')"; \
        [ "$PHP_VERSION" = "$installedVersion" ] || { >&2 printf '%s\n' "PHP's version has changed, please update Dockerfile."; exit 1; }

## PHP version command example output: ##
#php --version
#>
#PHP 8.1.2 (cli) (built: Apr  7 2022 17:46:26) (NTS)
#Copyright (c) The PHP Group
#Zend Engine v4.1.2, Copyright (c) Zend Technologies
#    with Zend OPcache v8.1.2, Copyright (c), by Zend Technologies
#    with Xdebug v3.1.2, Copyright (c) 2002-2021, by Derick Rethans


## ----


# Explicitly set mysql user/group IDs
# mysql user gets a random uid on install, but we need exact uid so volumes work without having to chown
# '20420' is just what I happened to use elsewhere for mysql uid, no other significance to it.

ARG SAL__UID__MYSQL=20420
ENV SAL__UID__MYSQL=$SAL__UID__MYSQL

RUN \
    . /saldrc.lib.sh || exit; \
    groupadd --system --gid="$SAL__UID__MYSQL" mysql; \
    useradd --system --uid="$SAL__UID__MYSQL" --gid="$SAL__UID__MYSQL" --home-dir=/var/lib/mysql --shell=/bin/bash mysql; \
    # Set a random password to fully activate the account
    printf '%s:%s\n' mysql "$(xxd -plain -len 20 /dev/urandom)" | chpasswd; \
    mkdir -p /var/lib/mysql /var/run/mysqld; \
    chown -R 'mysql:mysql' /var/lib/mysql /var/run/mysqld; \
    # ensure that /var/run/mysqld (used for socket and lock files) is writable regardless of the UID our mysqld instance ends up having at runtime
    chmod 777 /var/run/mysqld;

ARG MARIADB_MAJOR=10.6
ENV MARIADB_MAJOR=$MARIADB_MAJOR

RUN \
    --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt/lists \
    --mount=type=cache,target=/lewp-cache,mode=777 \
    . /saldrc.lib.sh || exit; \
    \
    saldrc__apt_install \
        # MariaDB deps:
        # Install "libjemalloc2" as it offers better performance in some cases. Use with LD_PRELOAD
        # Install "pwgen" for randomizing passwords
        # Install "tzdata" for /usr/share/zoneinfo/
        libjemalloc2 \
        pwgen \
        tzdata \
        mariadb-server \
        mariadb-backup; \
    \
    installedMajor="$(mysql --version | sed -E 's@^mysql\s+Ver.+Distrib\s+([0-9]+\.[0-9]+).*@\1@i')"; \
    [ "$MARIADB_MAJOR" = "$installedMajor" ] || { >&2 printf '%s\n' "MariaDB's _major_ version has changed, please update the Dockerfile and migrate your data volumes."; exit 1; }; \
    \
    # comment out a few problematic configuration values
    find /etc/mysql/ -name '*.cnf' -print0 | xargs -0 grep -lZE '^(bind-address|log|user\s)' | xargs -rt -0 sed -Ei 's/^(bind-address|log|user\s)/#&/'; \
    # don't reverse lookup hostnames, they are usually another container
    # Issue #327 Correct order of reading directories /etc/mysql/mariadb.conf.d before /etc/mysql/conf.d (mount-point per documentation)
    if [ ! -L /etc/mysql/my.cnf ]; then \
        sed -i -e '/includedir/i[mariadb]\nskip-host-cache\nskip-name-resolve\n' /etc/mysql/my.cnf; \
    # 10.5+
    else \
        sed -i -e '/includedir/ {N;s/\(.*\)\n\(.*\)/[mariadbd]\nskip-host-cache\nskip-name-resolve\n\n\2\n\1/}' /etc/mysql/mariadb.cnf; \
    fi; \
    sed -i 's@^ *\(skip_log_error\|syslog\) *$@#&@g' /etc/mysql/mariadb.conf.d/50-mysqld_safe.cnf;


## MariaDB version string example output: ##
#mysql --version
#mysql  Ver 15.1 Distrib 10.6.7-MariaDB, for debian-linux-gnu (x86_64) using  EditLine wrapper

ARG SAL__MYSQL_ROOT_PWD="hunter2"
ENV SAL__MYSQL_ROOT_PWD=$SAL__MYSQL_ROOT_PWD


ARG SAL__UID__ADMIN=1000
ENV SAL__UID__ADMIN=$SAL__UID__ADMIN

ARG SAL__USER__ADMIN="salmatron"
ENV SAL__USER__ADMIN=$SAL__USER__ADMIN

ENV SAL__HOME__ADMIN="/home/$SAL__USER__ADMIN"

RUN \
    . /saldrc.lib.sh || exit; \
    # `docker_env` is a group created by phusion baseimage for providing acccess to container_environment.sh
    useradd --uid "$SAL__UID__ADMIN" --create-home --user-group --shell /bin/bash --groups "adm,sudo,docker_env" "$SAL__USER__ADMIN"; \
    # Set a random password to fully activate the account
    printf '%s:%s\n' "$SAL__USER__ADMIN" "$(xxd -plain -len 20 /dev/urandom)" | chpasswd; \
    # Enable password-less sudo
    printf '\n%s %s\n' "$SAL__USER__ADMIN" 'ALL=(ALL:ALL) NOPASSWD:ALL' >> /etc/sudoers;


ARG SAL__UID__WEB=$SAL__UID__ADMIN
ENV SAL__UID__WEB=$SAL__UID__WEB

ARG SAL__UID__NGINX=$SAL__UID__WEB
ENV SAL__UID__NGINX=$SAL__UID__NGINX

ARG SAL__UID__PHP_FPM=$SAL__UID__NGINX
ENV SAL__UID__PHP_FPM=$SAL__UID__PHP_FPM

ARG SAL__MYSQL_ROOT_PWD=megaultrasonic
ENV SAL__MYSQL_ROOT_PWD=$SAL__MYSQL_ROOT_PWD

ARG SAL__CO_HOSTNAME="abc.sal.ac"
ENV SAL__CO_HOSTNAME=$SAL__CO_HOSTNAME

ARG SAL__NGINX_DEFAULT_HOST=$SAL__CO_HOSTNAME
ENV SAL__NGINX_DEFAULT_HOST=$SAL__NGINX_DEFAULT_HOSTp

ARG SAL__WEB_PUBLIC_ROOT=/var/www/html
ENV SAL__WEB_PUBLIC_ROOT=$SAL__WEB_PUBLIC_ROOT

ARG SAL__PHP_FPM_PID__FILE=/run/php-fpm.pid
ENV SAL__PHP_FPM_PID__FILE=$SAL__PHP_FPM_PID__FILE

# Composer
# https://getcomposer.org/

# https://getcomposer.org/doc/03-cli.md#composer-home
ARG COMPOSER_HOME=/composer
ENV COMPOSER_HOME=$COMPOSER_HOME

# https://getcomposer.org/doc/03-cli.md#composer-cache-dir
ARG COMPOSER_CACHE_DIR=/var/cache/sal-composer
ENV COMPOSER_CACHE_DIR=$COMPOSER_CACHE_DIR

# https://getcomposer.org/doc/03-cli.md#composer-htaccess-protect
# Defaults to 1. If set to 0, Composer will not create .htaccess files in the Composer home, cache, and data directories.
ENV COMPOSER_HTACCESS_PROTECT=0

RUN \
    --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt/lists \
    --mount=type=cache,target=/lewp-cache,mode=777 \
    #--mount=type=cache,target="$COMPOSER_CACHE_DIR" \
    . /saldrc.lib.sh || exit; \
    # Composer - Dependency manager for PHP
    saldrc__apt_install composer; \
    ( umask 0002 && mkdir -p "$COMPOSER_HOME" "$COMPOSER_CACHE_DIR"; );

# Default $PATH for the record:
# PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV PATH="$COMPOSER_HOME/bin:$PATH"

#RUN \
#    --mount=type=cache,target=/var/cache/sal,mode=0777 \
#    --mount=type=cache,target=$COMPOSER_CACHE_DIR \
#    . /saldrc.lib.sh || exit; \
#    # Very handy REPL
#    composer global require psy/psysh;


# https://wpengineer.com/2382/wordpress-constants-overview/


ARG SAL__SSH_KEY_PUB
ENV SAL__SSH_KEY_PUB=$SAL__SSH_KEY_PUB


ARG SAL__SSH_PUB_KEY__FILE="/sal__ssh_pub_key.pub"
ENV SAL__SSH_PUB_KEY__FILE=$SAL__SSH_PUB_KEY__FILE


# The name of the MySQL database for WordPress
ARG WORDPRESS__DB_NAME=lensify_wp
ENV WORDPRESS__DB_NAME=$WORDPRESS__DB_NAME
# MySQL database username
ARG WORDPRESS__DB_USER=lensify_wp_user
ENV WORDPRESS__DB_USER=$WORDPRESS__DB_USER
# MySQL database password
ARG WORDPRESS__DB_PASSWORD=hunter2
ENV WORDPRESS__DB_PASSWORD=$WORDPRESS__DB_PASSWORD
# MySQL hostname
ARG WORDPRESS__DB_HOST=localhost
ENV WORDPRESS__DB_HOST=$WORDPRESS__DB_HOST
# Database Charset to use in creating database tables.
ARG WORDPRESS__DB_CHARSET=utf8mb4
ENV WORDPRESS__DB_CHARSET=$WORDPRESS__DB_CHARSET
# The Database Collate type. Don't change this if in doubt.
ARG WORDPRESS__DB_COLLATE=utf8mb4_general_ci
ENV WORDPRESS__DB_COLLATE=$WORDPRESS__DB_COLLATE


ENV WORDPRESS__ABSPATH=""

ENV WORDPRESS__SITEURL=""

ENV WORDPRESS__HOME=""

ENV WORDPRESS__WPMU_PLUGIN_DIR=""

ENV WORDPRESS__WPMU_PLUGIN_URL=""

# Booleans. Set to '1', '0', or leave blank to use defaults
ENV WORDPRESS__WP_DEBUG=""

ENV WORDPRESS__WP_DEBUG_DISPLAY=""

ENV WORDPRESS__WP_CLI=""

ENV WORDPRESS__FORCE_SSL_LOGIN=""

ENV WORDPRESS__FORCE_SSL_ADMIN=""

COPY /toolkit/image /image

ENV SAL__XDEBUG__ENABLE=default

ENV XDEBUG_CONFIG=""


RUN ["/image/install-image"]



WORKDIR $SAL__WEB_PUBLIC_ROOT



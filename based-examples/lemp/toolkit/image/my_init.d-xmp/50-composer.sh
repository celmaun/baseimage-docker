#!/bin/bash

set -euxo pipefail

#if [[ -d "/var/www/html" && ! -d "/var/www/html/vendor" ]]; then
#  cd /var/www/html
#  gosu "$SAL__UID__ADMIN" composer install
#  # chown -R "$SAL__UID__ADMIN:$SAL__UID__ADMIN" vendor
#fi

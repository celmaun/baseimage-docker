#!/usr/bin/env bash

set -euxo pipefail
shopt -s failglob

# --delete
# delete extraneous files from dest dirs

#rsync --archive --delete /opt/lensify-original/ /opt/lensify/
#rsync --archive --delete /opt/lensify-original/ /opt/lensify/


# if [ -z "$(find -H /var/lib/apt/lists -maxdepth 0 -mtime -7 -print -quit)" ]; then
#   :
#   #>&2 echo "Refreshing APT cache..."
#   #apt-get update
# fi

# if test -d "/root/.config/composer/vendor/bin"; then
#   case ":$PATH:" in *":$_:"*) ;; *) PATH="$_:$PATH" ;; esac
# fi



#####
# OpenSSH clears all our docker ENV vars when logging in :(. The following code is for fixing that.
#####

# The inverted grep is to fix following issue:
#-bash: warning: setlocale: LC_ALL: cannot change locale ("en_US.UTF-8")

# First remove comments then 2. Remove loading "export " with `cut`
grep -v '^ *#' /etc/container_environment.sh | cut -c 8- | grep -v '^\(LC_\|LANG\)' > /etc/environment

#sed 's/^export \(\w\+\)=\(.*\)/\1="\2"/' /etc/container_environment.sh | grep -v '^\(LC_\|LANG\)' > /etc/environment

cp -t /root/.ssh/ /etc/environment

#install --o "$SAL__UID__ADMIN" -g "$SAL__UID__ADMIN" -t "$SAL_ADMIN_HOME/.ssh/" /etc/environment
install --{owner,group}="$SAL__UID__ADMIN" -t "$SAL__HOME__ADMIN/.ssh/" /etc/environment


# Add to Dockerfile
# ===================
# ARG SAL__SSH_KEY_PUB
# ENV SAL__SSH_KEY_PUB=$SAL__SSH_KEY_PUB
# ARG SAL__SSH_PUB_KEY__FILE="/sal__ssh_pub_key.pub"
# ENV SAL__SSH_PUB_KEY__FILE=$SAL__SSH_PUB_KEY__FILE


# Must be non-empty
if [ -s "${SAL__SSH_PUB_KEY__FILE:?}" ]; then :; else
  >&2 printf '%s "%s"\n' "Error: Public key is missing or blank" "${SAL__SSH_PUB_KEY__FILE:?}"
  exit 1
fi

install -m 0400 --{owner,group}=root "$SAL__SSH_PUB_KEY__FILE" "/root/.ssh/authorized_keys"
install -m 0400 --{owner,group}="$SAL__UID__ADMIN" "$SAL__SSH_PUB_KEY__FILE" "$SAL__HOME__ADMIN/.ssh/authorized_keys"


# cp /etc/ssh/ssh_host_ecdsa_key; \
# cp /etc/ssh/ssh_host_ecdsa_key.pub; \
# cp /etc/ssh/ssh_host_ed25519_key; \
# cp /etc/ssh/ssh_host_ed25519_key.pub; \
# cp /etc/ssh/ssh_host_rsa_key; \
# cp /etc/ssh/ssh_host_rsa_key.pub; \


copy_sshd_host_keys() (
  set -eux

  export keys volPath etcPath k volKey volPub etcKey etcPub

  keys=(
    ecdsa
    ed25519
    rsa
  )

  volPath="/var/sshd_host_keys/ssh_host_"
  etcPath="/etc/ssh/ssh_host_"

  for k in "${keys[@]}"; do
    volKey="${volPath}${k}_key"
    volPub="${volKey}.pub"

    etcKey="${etcPath}${k}_key"
    etcPub="${etcKey}.pub"

    if [ -f "$volKey" ] && [ -f "$volPub" ]; then
      if cmp "$volKey" "$etcKey"; then :;
      else
        cp -p "$volKey" "$etcKey"
        cp -p "$volPub" "$etcPub"
      fi
    else
      cp -p "$etcKey" "$volKey"
      cp -p "$etcPub" "$volPub"
    fi
  done
)

copy_sshd_host_keys


## Fix permissions

# chown -cR "$SAL__UID__ADMIN:$SAL__UID__ADMIN" /gradle-user-home/
# chown -cR "$SAL__UID__ADMIN:$SAL__UID__ADMIN" /lensify-backend/.gradle/
#
# chown -cR "$SAL__UID__SOLR:$SAL__UID__SOLR" "/solr" "$SOLR_HOME" "$SOLR_LOGS_DIR"

# chown -cR mysql:mysql /var/lib/mysql/



## MySQL

# find /var/lib/mysql/ \! -user mysql -print0 | xargs -rt -0 chown -c mysql:mysql

#ls -alh /var/log/mysql/error.log
#-rw-rw----. 1 mysql adm 570K Jun  5 12:13 /var/log/mysql/error.log

# if test -f "/var/log/mysql/error.log"; then :;
# else
#   install -m 660 -o mysql -g adm -T /dev/null "$_"
#   echo > "$_"
# fi



# PHP/Nginx

# SAL__USER__WEB="$(id -un "$SAL__UID__WEB")"
# export SAL__USER__WEB

# mkdir -p "${SAL__WEB_PUBLIC_ROOT:?}"

# find "$SAL__WEB_PUBLIC_ROOT" \! -user "$SAL__USER__WEB" -print0 | xargs -rt -0 chown -c "$SAL__USER__WEB:" --




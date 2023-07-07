#!/usr/bin/env sh

set -eux
#set -euxo pipefail

# --delete
# delete extraneous files from dest dirs

#rsync --archive --delete /opt/lensify-original/ /opt/lensify/
rsync --archive --delete /opt/lensify-original/ /opt/lensify/


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
# [salmatron@fedtrooper tmp]$ ssh co-lensify-backend-dev
#Last login: Mon Dec 13 13:17:51 2021 from 192.168.44.1
#-bash: warning: setlocale: LC_ALL: cannot change locale ("en_US.UTF-8")

# Remove loading "export "
cut -c 8- < /etc/container_environment.sh | grep -v '^\(LC_\|LANG\)' > /etc/environment

#sed 's/^export \(\w\+\)=\(.*\)/\1="\2"/' /etc/container_environment.sh | grep -v '^\(LC_\|LANG\)' > /etc/environment

cp -t /root/.ssh/ /etc/environment


install --owner="$SAL__UID__ADMIN" --group="$SAL__UID__ADMIN" -t "$SAL__HOME__ADMIN/.ssh/" /etc/environment



# cp /etc/ssh/ssh_host_ecdsa_key; \
# cp /etc/ssh/ssh_host_ecdsa_key.pub; \
# cp /etc/ssh/ssh_host_ed25519_key; \
# cp /etc/ssh/ssh_host_ed25519_key.pub; \
# cp /etc/ssh/ssh_host_rsa_key; \
# cp /etc/ssh/ssh_host_rsa_key.pub; \

#copy_sshd_host_keys() {
#  local keys volPath etcPath k volKey volPub etcKey etcPub
#
#  keys=(
#    ecdsa
#    ed25519
#    rsa
#  )
#
#  volPath="/var/sshd_host_keys/ssh_host_"
#  etcPath="/etc/ssh/ssh_host_"
#
#  for k in "${keys[@]}"; do
#    volKey="${volPath}${k}_key"
#    volPub="${volKey}.pub"
#
#    etcKey="${etcPath}${k}_key"
#    etcPub="${etcKey}.pub"
#
#    if [ -f "$volKey" ] && [ -f "$volPub" ]; then
#      if cmp "$volKey" "$etcKey"; then :; else
#        cp -p "$volKey" "$etcKey"
#        cp -p "$volPub" "$etcPub"
#      fi
#    else
#      cp -p "$etcKey" "$volKey"
#      cp -p "$etcPub" "$volPub"
#    fi
#  done
#}
#
#copy_sshd_host_keys

if [ -e /sal__ssh_auth_key.pub ]; then :; else
  >&2 printf '%s\n' "Error: Public key is missing: '/sal__ssh_auth_key.pub' "
  exit 1
fi

install -T -p -b -v -m 0600 -g 0 -o 0 /sal__ssh_auth_key.pub "/root/.ssh/authorized_keys"
install -T -p -b -v -m 0600 -g "$SAL__UID__ADMIN" -o "$SAL__UID__ADMIN"  /sal__ssh_auth_key.pub "$SAL__HOME__ADMIN/.ssh/authorized_keys"

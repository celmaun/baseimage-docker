#!/bin/sh
# vim:set ft=sh ts=2 sw=2 et :
# shellcheck shell=sh

# NOTE: No Bash-isms allowed, this file must be POSIX (and `dash``) compatible


# This is more reliable as functions are not always exported(???) and `source`ing again is needed
if PATH='' command -v saldrc__loaded >/dev/null; then return; fi

set -eu

case $- in *a*) ;; *) _saldrc__un_set="set +a"; set -a;; esac

saldrc__loaded() { true; }

saldrc__validate_build_args() {
  : "${SAL__ENV:?'Build arg $SAL__ENV is required'}" || return

  # Copied values from `man hostnamectl` deployment values and added 'test' because it's commonly used.
  case $SAL__ENV in development|integration|staging|production|test)
      return;;
  esac

  >&2 printf '%s\n' "Build arg \$SAL__ENV has invalid value: '$SAL__ENV'"
  return 1
}

saldrc__apt_setup() (
  set -eu

  cd /etc/apt/apt.conf.d/

  rm -f ./docker-clean

  if [ -e ./15update-stamp ]; then :; else
    printf '%s\n' 'APT::Update::Post-Invoke-Success {"touch /var/lib/apt/periodic/update-success-stamp 2>/dev/null || true";};' > ./15update-stamp
  fi


  if [ -e ./99zsal-keep-cache ]; then :; else
    printf '%s\n' 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > ./99zsal-keep-cache;
  fi
)

# Only `apt-get update` if cache older than a week
# https://askubuntu.com/questions/410247/how-to-know-last-time-apt-get-update-was-executed#answer-904259
saldrc__apt_update_maybe () {
  if [ -n "$(find -L /var/lib/apt/lists -maxdepth 0 -mtime -7 \! -empty -print -quit 2>/dev/null ||:)" ] && \
     [ -n "$(find -L /var/lib/apt/periodic/update-success-stamp -maxdepth 0 -mtime -7 -print -quit 2>/dev/null ||:)" ] \
  ; then
    return
  fi

  # Cache is older than 7 days
  >&2 printf '%s\n' "Refreshing APT cache..."
  apt-get update
}

saldrc__apt_install() {
  saldrc__apt_update_maybe || return

  apt-get -y install --no-install-recommends "$@"
}


# 1 = sha256 hash
# 2 = file path
saldrc__sha256_require() (
  set -eu

  sha256_hash=${1}
  : "${sha256_hash:?}"
  
  file_path=${2}
  : "${file_path:?}"

  sha256sum -c <<SH
$sha256_hash *$file_path
SH

)

# check silently 
saldrc__sha256_check() {
  saldrc__sha256_require "$@" >/dev/null 2>&1 ||:
}


${_saldrc__un_set-}


set -x

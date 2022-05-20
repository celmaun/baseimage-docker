ARG BASE_IMAGE=ubuntu:jammy
FROM $BASE_IMAGE

ARG QEMU_ARCH
#ADD x86_64_qemu-${QEMU_ARCH}-static.tar.gz /usr/bin

COPY . /bd_build

COPY lib/saldrc.lib.sh /

RUN /bd_build/prepare.sh && \
	/bd_build/system_services.sh && \
	/bd_build/utilities.sh && \
	/bd_build/cleanup.sh

ENV TZ="UTC" \
    DEBIAN_FRONTEND="teletype" \
    LANG="en_US.UTF-8" \
    LANGUAGE="en_US:en" \
    LC_ALL="en_US.UTF-8"

# SSH
EXPOSE 22

# SSHD keys
VOLUME ["/var/sshd_host_keys"]
# Superuser SSH data
VOLUME ["/root/.ssh"]

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

ENV PIP_CACHE_DIR=/var/cache/pip

# Enable apt caching as we intend to use --mount=cache
# https://github.com/moby/buildkit/blob/master/frontend/dockerfile/docs/syntax.md#example-cache-apt-packages
# https://github.com/moby/buildkit/blob/87e1fa7/frontend/dockerfile/docs/syntax.md#example-cache-apt-package

# Ubuntu non-Docker comes with a /etc/apt/apt.conf.d/15update-stamp file that's handy to determine when `apt-get update` was last run.
# https://serverfault.com/questions/20747/find-last-time-update-was-performed-with-apt-get#answer-425237
# We restore it when missing
# APT::Update::Post-Invoke-Success {"touch /var/lib/apt/periodic/update-success-stamp 2>/dev/null || true";};

RUN \
    . /saldrc.lib.sh; \
    # saldrc__validate_build_args; \
    saldrc__apt_setup; \
    mkdir -p "$PIP_CACHE_DIR"; \
    chmod -R a+rX "$PIP_CACHE_DIR"; \
    mkdir -p /saba-cache/; \
    chmod -R a+rwX /saba-cache/;

RUN \
    . /saldrc.lib.sh; \
    # Enabling SSH
    # https://github.com/phusion/baseimage-docker#enabling-ssh
    # Baseimage-docker disables the SSH server by default. Add the following to your Dockerfile to enable it:
    rm -f /etc/service/sshd/down; \
    # Generate host keys
    /etc/my_init.d/00_regen_ssh_host_keys.sh; \
    (umask 0077; mkdir /var/sshd_host_keys; mkdir -p /root/.ssh); \
    cp -pt /var/sshd_host_keys/ /etc/ssh/ssh_host_*_key /etc/ssh/ssh_host_*_key.pub;

RUN \
    --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt/lists \
    --mount=type=cache,target=/saba-cache,mode=0777 \
    . /saldrc.lib.sh; \
    saldrc__apt_install \
        vim \
        git \
        git-lfs \
        logrotate \
        cron \
        ssh-client \
        less \
        lsof \
        curl \
        wget \
        ca-certificates \
        gnupg \
        sudo \
        jq \
        unzip \
        fontconfig \
        iproute2 \
        rsync \
        gosu \
    	socat

# Python
RUN \
    --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt/lists \
    --mount=type=cache,target=/var/cache/pip \
    --mount=type=cache,target=/saba-cache,mode=0777 \
    . /saldrc.lib.sh; \
    saldrc__apt_install python3 python3-pip; \
    \
	# Ensure pip, setuptools, and wheel are up to date \
	# While pip alone is sufficient to install from pre-built binary archives, up to date copies of the setuptools and wheel projects are
	# useful to ensure you can also install from source archives:
	pip3 --no-input install -U pip setuptools wheel; \
    \
    # Install 'requests' library
    # https://pypi.org/project/requests/
    pip3 --no-input install -U requests; \
    \
    # Install ranger file manager and its suggestions
    # https://github.com/ranger/ranger
	# ranger is a console file manager with VI key bindings.  It provides a
	# minimalistic and nice curses interface with a view on the directory hierarchy.
	# It ships with `rifle`, a file launcher that is good at automatically finding
	# out which program to use for what file type.
	### Optional dependencies
	# For general usage:
	# * `file` for determining file types
	# * `chardet` (Python package) for improved encoding detection of text files
	# * `sudo` to use the "run as root" feature
	# * `python-bidi` (Python package) to display right-to-left file names correctly
	#   (Hebrew, Arabic)
	# For enhanced file previews (with `scope.sh`):
	# * `img2txt` (from `caca-utils`) for ASCII-art image previews
	# * `w3mimgdisplay`, `ueberzug`, `mpv`, `iTerm2`, `kitty`, `terminology` or `urxvt` for image previews
	# * `convert` (from `imagemagick`) to auto-rotate images
	# * `rsvg-convert` (from [`librsvg`](https://wiki.gnome.org/Projects/LibRsvg)) for SVG previews
	# * `ffmpeg`, or `ffmpegthumbnailer` for video thumbnails
	# * `highlight`, `bat` or `pygmentize` for syntax highlighting of code
	# * `atool`, `bsdtar`, `unrar` and/or `7z` to preview archives
	# * `bsdtar`, `tar`, `unrar`, `unzip` and/or `zipinfo` (and `sed`) to preview archives as their first image
	# * `lynx`, `w3m` or `elinks` to preview html pages
	# * `pdftotext` or `mutool` (and `fmt`) for textual `pdf` previews, `pdftoppm` to preview as image
	# * `djvutxt` for textual DjVu previews, `ddjvu` to preview as image
	# * `calibre` or `epub-thumbnailer` for image previews of ebooks
	# * `transmission-show` for viewing BitTorrent information
	# * `mediainfo` or `exiftool` for viewing information about media files
	# * `odt2txt` for OpenDocument text files (`odt`, `ods`, `odp` and `sxw`)
	# * `python` or `jq` for JSON files
	# * `fontimage` for font previews
	# * `openscad` for 3D model previews (`stl`, `off`, `dxf`, `scad`, `csg`)
	# ----
	# Note by Salman: Best syntax highlighting package is 'bat'
	apt-get -y install file bat mediainfo libimage-exiftool-perl jq; \
    pip3 --no-input install -U ranger-fm chardet pygments python-bidi



# ARG SAL__ENV
# ENV SAL__ENV=$SAL__ENV

# ARG SAL__UID__ADMIN=1000
# ENV SAL__UID__ADMIN=$SAL__UID__ADMIN
#
# ARG SAL__USER__ADMIN=salmatron
# ENV SAL__USER__ADMIN=$SAL__USER__ADMIN
#
# ARG SABA__PREFIX=/opt/saba
# ENV SABA__PREFIX=$SABA__PREFIX
#

# Generate root key pair
# RUN \
#    . /saldrc.lib.sh; \
#    # Generate root key pair
#    ssh-keygen -t rsa -m PEM -N '' -C "root@$(hostname)" -f /root/.ssh/id_rsa


# RUN \
#    . /saldrc.lib.sh; \
#    # `docker_env` is a group created by phusion baseimage for providing acccess to container_environment.sh
#    useradd --uid "$SAL__UID__ADMIN" --create-home --user-group --shell /bin/bash --groups "adm,sudo,docker_env" "$SAL__USER__ADMIN"; \
#    # Set a random password to fully activate the account
#    printf '%s:%s\n' "$SAL__USER__ADMIN" "$(xxd -plain -len 20 /dev/urandom)" | chpasswd; \
#    # Enable password-less sudo
#    printf '\n%s %s\n' "$SAL__USER__ADMIN" 'ALL=(ALL:ALL) NOPASSWD:ALL' >> /etc/sudoers; \
#    # Create the prefix directory
#    mkdir -p $SABA__PREFIX; \
#    touch "$SABA__PREFIX/.gitkeep"; \
#    chown -R "$SAL__UID__ADMIN:$SAL__UID__ADMIN" "$SABA__PREFIX"; \
#    chmod -R a+rX "$SABA__PREFIX";

ARG BASE_IMAGE=ubuntu:jammy
FROM $BASE_IMAGE

ARG QEMU_ARCH
#ADD x86_64_qemu-${QEMU_ARCH}-static.tar.gz /usr/bin

COPY . /bd_build

COPY lib/saldrc.lib.sh /

ENV TZ="UTC"

ENV PIP_CACHE_DIR=/var/cache/pip

# Enable apt caching as we intend to use --mount=cache
# https://github.com/moby/buildkit/blob/master/frontend/dockerfile/docs/syntax.md#example-cache-apt-packages
# https://github.com/moby/buildkit/blob/87e1fa7/frontend/dockerfile/docs/syntax.md#example-cache-apt-package

# Ubuntu non-Docker comes with a /etc/apt/apt.conf.d/15update-stamp file that's handy to determine when `apt-get update` was last run.
# https://serverfault.com/questions/20747/find-last-time-update-was-performed-with-apt-get#answer-425237
# We restore it when missing
# APT::Update::Post-Invoke-Success {"touch /var/lib/apt/periodic/update-success-stamp 2>/dev/null || true";};

RUN \
    set -eu; . /saldrc.lib.sh; set -x ;\
    # saldrc__validate_build_args ;\
    mkdir -p "$PIP_CACHE_DIR" ;\
    chmod -R a+rX "$PIP_CACHE_DIR" ;\
    mkdir -p /saba-cache/ ;\
    chmod -R a+rwX /saba-cache/ ;\
    :;


# Following RUN was originally a file: /bd_build/prepare.sh
RUN \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,target=/saba-cache,sharing=locked,mode=0777 \
    set -eu; . /saldrc.lib.sh; set -x ;\
    ## Prevent initramfs updates from trying to run grub and lilo.
    ## https://journal.paul.querna.org/articles/2013/10/15/docker-ubuntu-on-rackspace/
    ## http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=594189
    export INITRD=no ;\
    mkdir -p /etc/container_environment ;\
    printf %s no > /etc/container_environment/INITRD ;\
    #
    ## Setup APT
    saldrc__apt_setup ;\
    #
    ## Enable Ubuntu Universe, Multiverse, and deb-src for main.
    sed -i 's/^#\s*\(deb.*main restricted\)$/\1/g' /etc/apt/sources.list ;\
    sed -i 's/^#\s*\(deb.*universe\)$/\1/g' /etc/apt/sources.list ;\
    sed -i 's/^#\s*\(deb.*multiverse\)$/\1/g' /etc/apt/sources.list ;\
    saldrc__apt_update ;\
    #
    ## Fix some issues with APT packages.
    ## See https://github.com/dotcloud/docker/issues/1024
    dpkg-divert --local --rename --add /sbin/initctl ;\
    ln -sf /bin/true /sbin/initctl ;\
    #
    ## Replace the 'ischroot' tool to make it always return true.
    ## Prevent initscripts updates from breaking /dev/shm.
    ## https://journal.paul.querna.org/articles/2013/10/15/docker-ubuntu-on-rackspace/
    ## https://bugs.launchpad.net/launchpad/+bug/974584
    dpkg-divert --local --rename --add /usr/bin/ischroot ;\
    ln -sf /bin/true /usr/bin/ischroot ;\
    #
    # apt-utils fix for Ubuntu 16.04
    saldrc__apt_install apt-utils ;\
    #
    ## Install HTTPS support for APT.
    saldrc__apt_install apt-transport-https ca-certificates ;\
    #
    ## Install add-apt-repository
    saldrc__apt_install software-properties-common ;\
    #
    ## Upgrade all packages.
    saldrc__apt_dist_upgrade ;\
    #
    ## Fix locale.
    saldrc__apt_install language-pack-en ;\
    locale-gen en_US ;\
    update-locale LANG=en_US.UTF-8 LC_CTYPE=en_US.UTF-8 ;\
    printf %s en_US.UTF-8 > /etc/container_environment/LANG ;\
    printf %s en_US.UTF-8 > /etc/container_environment/LC_CTYPE ;

# Following RUN was originally a file: /bd_build/system_services.sh
RUN \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,target=/saba-cache,sharing=locked,mode=0777 \
    set -eu; . /saldrc.lib.sh; set -x ;\
    #
    ## Install init process.
    cp /bd_build/bin/my_init /sbin/ ;\
    mkdir -p /etc/my_init.d ;\
    mkdir -p /etc/my_init.pre_shutdown.d ;\
    mkdir -p /etc/my_init.post_shutdown.d ;\
    mkdir -p /etc/container_environment ;\
    touch \
        /etc/container_environment.sh \
        /etc/container_environment_defaults.sh \
        /etc/container_environment_fill_defaults.sh \
        /etc/container_environment.env \
        /etc/container_environment.json ;\
    #
    chmod 700 /etc/container_environment ;\
    #
    groupadd -g 8377 docker_env ;\
    #
    chown :docker_env \
        /etc/container_environment.sh \
        /etc/container_environment_defaults.sh \
        /etc/container_environment_fill_defaults.sh \
        /etc/container_environment.env \
        /etc/container_environment.json ;\
        #
    chmod 640 \
        /etc/container_environment.sh \
        /etc/container_environment_defaults.sh \
        /etc/container_environment_fill_defaults.sh \
        /etc/container_environment.env \
        /etc/container_environment.json ;\
    #
    ln -s /etc/container_environment.sh /etc/profile.d/ ;\
    #
    ## Install runit.
    saldrc__apt_install runit ;\
    #
    ## Install a syslog daemon and logrotate.
    /bd_build/services/syslog-ng/syslog-ng.sh ;\
    #
    ## Install the SSH server.
    /bd_build/services/sshd/sshd.sh ;\
    #
    ## Install cron daemon.
    /bd_build/services/cron/cron.sh ;

# Following RUN was originally a file: /bd_build/utilities.sh
RUN \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,target=/saba-cache,sharing=locked,mode=0777 \
    set -eu; . /saldrc.lib.sh; set -x ;\
    #
    ## Often used tools.
    saldrc__apt_install wget curl less psmisc gpg-agent dirmngr vim ;\
    ##
    test -e /usr/bin/vim || ln -s /usr/bin/vim.basic /usr/bin/vim ;\
    update-alternatives --install /usr/bin/editor editor /usr/bin/vim 100 ;\
    #
    ## This tool runs a command as another user and sets $HOME.
    cp /bd_build/bin/setuser /sbin/setuser ;\
    #
    ## This tool allows installation of apt packages with automatic cache cleanup.
    cp /bd_build/bin/install_clean /sbin/install_clean ;


RUN \
    set -eu; . /saldrc.lib.sh; set -x ;\
    # Enabling SSH
    # https://github.com/phusion/baseimage-docker#enabling-ssh
    # Baseimage-docker disables the SSH server by default. Add the following to your Dockerfile to enable it:
    rm -f /etc/service/sshd/down ;\
    # Generate host keys
    /etc/my_init.d/00_regen_ssh_host_keys.sh ;\
    (umask 0077; mkdir /var/sshd_host_keys; mkdir -p /root/.ssh) ;\
    cp -pt /var/sshd_host_keys/ /etc/ssh/ssh_host_*_key /etc/ssh/ssh_host_*_key.pub;

RUN \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,target=/saba-cache,sharing=locked,mode=0777 \
    set -eu; . /saldrc.lib.sh; set -x ;\
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
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,target=/var/cache/pip,sharing=locked \
    --mount=type=cache,target=/saba-cache,sharing=locked,mode=0777 \
    set -eu; . /saldrc.lib.sh; set -x ;\
    saldrc__apt_install python3 python3-pip ;\
	# Ensure pip, setuptools, and wheel are up to date \
	# While pip alone is sufficient to install from pre-built binary archives, up to date copies of the setuptools and wheel projects are
	# useful to ensure you can also install from source archives:
	pip3 --no-input install -U pip setuptools wheel ;\
    # Install 'requests' library
    # https://pypi.org/project/requests/
    pip3 --no-input install -U requests ;\
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
	saldrc__apt_install file bat mediainfo libimage-exiftool-perl ;\
    pip3 --no-input install -U ranger-fm chardet pygments python-bidi

# Following RUN was originally a file: /bd_build/cleanup.sh
RUN \
    set -eux ;\
    export LC_ALL="C" ;\
    #
    DEBIAN_FRONTEND=noninteractive apt-get clean ;\
    find /bd_build/ -not \( -name 'bd_build' -or -name 'buildconfig' -or -name 'cleanup.sh' \) -delete ;\
    rm -rf /tmp/* /var/tmp/* ;\
    rm -rf /var/lib/apt/lists/* ;\
    #
    rm -f /etc/ssh/ssh_host_* ;\
    # clean up python bytecode
    find / -mount -name '*.pyc' -delete ;\
    find / -mount -name '*__pycache__*' -delete ;

ENV DEBIAN_FRONTEND="teletype" \
    LANG="en_US.UTF-8" \
    LANGUAGE="en_US:en" \
    LC_ALL="en_US.UTF-8"

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

ONBUILD RUN \
	set -eu; . /saldrc.lib.sh ;\
	>&2 printf '%s\n' "# Sam says hi! Thanks for building on my base image. :)" ;\
	>&2 printf '%s\n' "# Please remember to append the following instructions to your Dockerfile (modify as you see fit):" ;\
    >&2 printf '\t\n' ;\
	>&2 printf '\t%s\n' '# Sets APT package manager interactive behavior.' ;\
	>&2 printf '\t%s\n' 'ENV DEBIAN_FRONTEND="teletype"' ;\
    >&2 printf '\t\n' ;\
	>&2 printf '\t%s\n' '# Sets the default file editor.' ;\
	>&2 printf '\t%s\n' 'ENV EDITOR="/usr/bin/vim"' ;\
    >&2 printf '\t\n' ;\
    >&2 printf '\t\n' ;\
	>&2 printf '\t%s\n' '# SSH' ;\
	>&2 printf '\t%s\n' 'EXPOSE 22' ;\
    >&2 printf '\t\n' ;\
    >&2 printf '\t\n' ;\
    >&2 printf '\t%s\n' '# SSHD keys' ;\
    >&2 printf '\t%s\n' 'VOLUME /var/sshd_host_keys' ;\
    >&2 printf '\t\n' ;\
    >&2 printf '\t%s\n' '# Superuser SSH configuration' ;\
    >&2 printf '\t%s\n' 'VOLUME /root/.ssh' ;\
    >&2 printf '\t\n' ;\
    :;

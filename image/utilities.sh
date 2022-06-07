#!/bin/bash
set -e
source /bd_build/buildconfig
set -x

## Often used tools.
$minimal_apt_get_install wget curl less psmisc gpg-agent dirmngr


if [ "${BUILT_IMAGE_SIZE:?}" = "thin" ]; then
	$minimal_apt_get_install vim-tiny
	ln -s /usr/bin/vim.tiny /usr/bin/vim
else
	apt-get install -y vim

	# apt-get install -y vim vim-{asciidoc,editorconfig,scripts,snipmate,snippets,syntastic}
	# TODO: Add needed repo to install above extras

	# vim-asciidoc/focal 9.0.0~rc1-1 all
	#  Vim syntax highlighting files for asciidoc
	# ---
	# vim-editorconfig/focal 0.3.3+dfsg-2 all
	#  EditorConfig Plugin for Vim
	# ---
	# vim-scripts/focal 20180807ubuntu1 all
	#  plugins for vim, adding bells and whistles
	#
	# vim-snipmate/focal 0.87-3 all
	#  Vim script that implements some of TextMate's snippets features.
	# ---
	# vim-snippets/focal 1.0.0-4 all
	#  Snippets files for various programming languages.
	# ---
	# vim-syntastic/focal 3.10.0-2 all
	#  Syntax checking hacks for vim

	test -e /usr/bin/vim || ln -s /usr/bin/vim.basic /usr/bin/vim
fi

update-alternatives --install /usr/bin/editor editor /usr/bin/vim 100

## This tool runs a command as another user and sets $HOME.
cp /bd_build/bin/setuser /sbin/setuser

## This tool allows installation of apt packages with automatic cache cleanup.
cp /bd_build/bin/install_clean /sbin/install_clean

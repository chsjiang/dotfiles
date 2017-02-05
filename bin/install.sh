#!/bin/bash
set -e

# install.sh
#	This script installs my basic setup

# get the user that is not root
# TODO: makes a pretty bad assumption that there is only one other user
USERNAME=$(find /home/* -maxdepth 0 -printf "%f" -type d)

check_is_sudo() {
	if [ "$EUID" -ne 0 ]; then
		echo "Please run as root."
		exit
	fi
}

# sets up apt sources
# assumes you are going to use debian stretch
setup_sources() {

	yum install -y yum-utils

	# add docker repo
	yum-config-manager --add-repo https://docs.docker.com/engine/installation/linux/repo_files/centos/docker.repo
	rpm --import https://yum.dockerproject.org/gpg

}

# installs base packages
# the utter bare minimal shit
base() {
	yum update

	yum install -y \
		automake \
		bzip2 \
		ca-certificates \
		cmake \
		coreutils \
		curl \
		file \
		findutils \
		gcc \
		git \
		gnupg \
		grep \
		gzip \
		hostname \
		indent \
		iptables \
		jq \
		less \
		locales \
		lsof \
		make \
		mount \
		iproute \
		network-manager \
		openvpn \
		rxvt-unicode-256color \
		s3cmd \
		scdaemon \
		ssh \
		strace \
		sudo \
		tar \
		tree \
		tzdata \
		unzip \
		xclip \
		zip \

	yum clean

	install_docker
	install_sublimetext_
}

# installs docker master
# and adds necessary items to boot params
install_docker() {
	yum makecache fast
	# create docker group
	groupadd docker
	usermod -aG docker "$USERNAME"

	yum -y install docker-engine

	systemctl enable docker

	echo "Docker has been installed."
}

install_sublimetext() {
	wget http://c758482.r82.cf2.rackcdn.com/sublime_text_3_build_3065_x64.tar.bz2
	tar -vxjf sublime_text_3_build_3065_x64.tar.bz2 -C /opt
	ln -s /opt/sublime_text_3/sublime_text /usr/bin/subl
}

install_atom() {
	wget https://atom.io/download/rpm
	sudo yum install -y atom.x86_64.rpm
	pkcon install libXScrnSaver
	apm install particle-dev-complete
}

get_dotfiles() {
	# create subshell
	(
	cd "/home/$USERNAME"

	# install dotfiles from repo
	git clone git@github.com:jfrazelle/dotfiles.git "/home/$USERNAME/dotfiles"
	cd "/home/$USERNAME/dotfiles"

	# installs all the things
	make

	# enable dbus for the user session
	systemctl --user enable dbus.socket


	cd "/home/$USERNAME"

	)
}


usage() {
	echo -e "install.sh\n\tThis script installs my basic setup\n"
	echo "Usage:"
	echo "  sources                     - setup sources & install base pkgs"
	echo "  dotfiles                    - get dotfiles"
	echo "  sublime                     - install Sublime Text 3"
	echo "  atom                        - install Atom Text Editor"
}

main() {
	local cmd=$1

	if [[ -z "$cmd" ]]; then
		usage
		exit 1
	fi

	if [[ $cmd == "sources" ]]; then
		check_is_sudo

		setup_sources

		base
	elif [[ $cmd == "dotfiles" ]]; then
		get_dotfiles
	elif [[ $cmd == "sublime" ]]; then
		install_sublimetext
	elif [[ $cmd == "atom" ]]; then
		install_atom
	else
		usage
	fi
}

main "$@"

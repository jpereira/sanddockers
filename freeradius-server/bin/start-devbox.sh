#!/bin/bash
# Author: Jorge Pereira <jpereira@freeradius.org>
#

export LC_ALL=C

docker_rootfs="$HOME/Docker/storage/freeradius/"
cwd="/root/Devel/FreeRADIUS/freeradius-server.git"
arg0="$(basename $0)"

if [ -z "$SSH_AUTH_SOCK" ]; then
	echo "ERRO: SSH_AUTH_SOCK ??? call ssh-agent"
	exit 1
fi

if [ "$1" = "centos" ]; then
	image_os="freeradius-server-centos7"
#	image_name="jpereiran/devbox-freeradius-server:centos7"
	image_name="freeradius-centos7"
else
	image_os="freeradius-server-ubuntu2004"
	image_name="jpereiran/devbox-freeradius-server:latest"
fi
shift

docker_image="devbox-$image_os"

if [ "$1" = "reset" ]; then
	echo "# Removing $docker_image (relaunch)"
	docker rm -f $docker_image
fi

mkdir -p $docker_rootfs

if [ -d "$docker_rootfs" ]; then
	extra_opts="-v $docker_rootfs:/opt"
fi

#
#	Settings for X11 forward
#
if [ -z "$nox11" ]; then
	uname_s="$(uname -s)"

	echo "${arg0}: [**] Setup X11 settings"
	xhost + 1> /dev/null 2>&1

	case ${uname_s} in
		Linux)
			ipaddr4="$(ifconfig docker0 | awk '/inet /{ print $2}')"
			cwd="${cwd}"
			x11_args="-v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=${DISPLAY}"
		;;

		Darwin)
			ipaddr4="$(ifconfig en0 | awk '/inet /{ print $2}')"
			cwd="${cwd}-linux"
			x11_args="-e DISPLAY=${ipaddr4}:0"

			echo "${arg0}: [**] Starting - socat TCP-LISTEN:6000,reuseaddr,fork UNIX-CLIENT:\"$DISPLAY\""
			killall -9 socat 1> /dev/null 2>&1
			socat TCP-LISTEN:6000,reuseaddr,fork "UNIX-CLIENT:\"$DISPLAY\"" &
		;;
	esac

	echo "${arg0}: [**] Appending x11_args='$x11_args'"
fi

#set -fx
if ! docker ps -a --format  '{{.Names}}' | grep "^$docker_image$"; then
	docker run ${docker_opts[*]} --name="$docker_image"            \
			--privileged                                           \
			${x11_args[*]}                                         \
			${extra_opts[*]}                                       \
			--cap-add=ALL                                          \
			-h "$docker_image"                                     \
			-v $HOME/Devel/:/root/Devel                            \
			-w "$cwd"                                              \
			-e LC_ALL=C                                            \
			-p 1812:1812/udp -p 1813:1813/udp -p 3799:3799/udp     \
			-v $(dirname $SSH_AUTH_SOCK):$(dirname $SSH_AUTH_SOCK) \
			-e SSH_AUTH_SOCK=$SSH_AUTH_SOCK                        \
			-e SHELL=$SHELL -e COLUMNS=$COLUMNS                    \
			-e LINES=$LINES -e TERM=$TERM                          \
			-dti $image_name /bin/bash
else
	docker start "$docker_image"
fi

docker attach "$docker_image"

#set +fx

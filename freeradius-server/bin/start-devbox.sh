#!/bin/bash
# Author: Jorge Pereira <jpereira@freeradius.org>
#

export LC_ALL=C

docker_rootfs="$HOME/Docker/storage/freeradius/"
cwd="/root/Devel/FreeRADIUS/freeradius-server.git"

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

if [ -z "$nox11" ]; then
	x11_args="-e DISPLAY=192.168.1.11:0"

	echo "Starting - socat TCP-LISTEN:6000,reuseaddr,fork UNIX-CLIENT:\"$DISPLAY\""
	killall -9 socat 1> /dev/null 2>&1
	socat TCP-LISTEN:6000,reuseaddr,fork UNIX-CLIENT:\"$DISPLAY\" &

	echo "Appending x11_args='$x11_args'"
fi

[ "$(uname -s)" != "Linux" ] && cwd="${cwd}-linux"

#set -fx
if ! docker ps -a --format  '{{.Names}}' | grep "^$docker_image$"; then
	docker run ${docker_opts[*]} --name="$docker_image" \
			--privileged \
			${x11_args[*]} \
			--cap-add=ALL \
			-p 1812:1812/udp -p 1813:1813/udp -p 3799:3799/udp \
			-h "$docker_image" \
			-v $HOME/Devel/:/root/Devel \
			-w "$cwd" \
			${extra_opts[*]} \
			-v $(dirname $SSH_AUTH_SOCK):$(dirname $SSH_AUTH_SOCK) \
			-e LC_ALL=C \
			-e SSH_AUTH_SOCK=$SSH_AUTH_SOCK \
			-e SHELL=$SHELL -e COLUMNS=$COLUMNS -e LINES=$LINES -e TERM=$TERM \
			-dti $image_name /bin/bash
else
	docker start "$docker_image"
fi

docker attach "$docker_image"

#set +fx

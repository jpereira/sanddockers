#!/bin/bash
# Author: Jorge Pereira <jpereira@freeradius.org>
#

export LC_ALL=C

if [ -z "$SSH_AUTH_SOCK" ]; then
	echo "ERRO: SSH_AUTH_SOCK ??? call ssh-agent"
	exit 1
fi

if [ "$1" = "centos" ]; then
	image_os="freeradius-server-centos7"
	image_name="jpereiran/devbox-freeradius-server:centos7"
else
	image_os="freeradius-server-ubuntu1804"
	image_name="jpereiran/devbox-freeradius-server:ubuntu1804"
fi
shift

docker_image="devbox-$image_os"
extra_opts="-v /opt/docker-rootfs/freeradius/:/opt"

if [ "$1" = "reset" ]; then
	echo "# Removing $docker_image (relaunch)"
	docker rm -f $docker_image
fi

mkdir -p ~/Devel /opt/docker-rootfs/freeradius/

#set -fx
if ! docker ps -a --format  '{{.Names}}' | grep "^$docker_image$"; then
	docker run ${docker_opts[*]} --name="$docker_image" \
			--privileged \
			--cap-add SYS_PTRACE \
			-h "$docker_image" \
			-v ~/Devel/:/root/Devel \
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

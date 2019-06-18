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
	image_name="jpereiran/sanddockers:devbox-freeradius-server-centos7"
else
	image_os="freeradius-server-ubuntu16"
	image_name="jpereiran/sanddockers:devbox-freeradius-server"
fi

image_name="freeradius/build-ubuntu18:latest"

docker_image="devbox-$image_os"

extra_opts="-v /opt/docker-rootfs/freeradius/:/opt"

mkdir -p ~/Devel

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
			-dti $image_name /bin/bash
else
	docker start "$docker_image"
fi

docker attach "$docker_image"

#set +fx

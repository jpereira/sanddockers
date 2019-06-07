#!/bin/bash

export LC_ALL=C

if [ "$1" = "centos" ]; then
	image_os="centos7"
	image_name="jpereira/build-centos7"
else
	image_os="ubuntu16"
	image_name="jpereira/build-ubuntu16-deps"
fi

set +fx

if [ -z "$SSH_AUTH_SOCK" ]; then
	echo "ERRO: SSH_AUTH_SOCK ??? call ssh-agent"
	exit 1
fi

docker_image="freeradius-$image_os"

if ! docker ps -a --format  '{{.Names}}' | grep "^$docker_image$"; then
	docker run --name="$docker_image" \
			--privileged \
			--cap-add SYS_PTRACE \
			-h "docker-$docker_image" \
			-v /home/jpereira/Devel/:/root/Devel \
			-v /docker/freeradius/:/opt/ \
			-v $(dirname $SSH_AUTH_SOCK):$(dirname $SSH_AUTH_SOCK) \
			-e LC_ALL=C \
			-e SSH_AUTH_SOCK=$SSH_AUTH_SOCK \
			-w /root/Devel/FreeRadius/freeradius-server.git \
			-dti $image_name /bin/bash
else
	docker start "$docker_image"
fi

docker attach "$docker_image"

set -fx

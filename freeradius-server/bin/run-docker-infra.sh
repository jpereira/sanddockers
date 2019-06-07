#!/bin/bash

set +fx

cmd="$1"

docker() {
	echo "docker $@"
	/usr/bin/docker $@
}

docker_image="jpereira/freeradius-infra"
docker_id=$(docker ps -a --format  '{{.Names}}' | grep "^$docker_image$")
docker_image_short=$(basename $docker_image)

[ "$cmd" = "reset" ] && {
	docker rm -f $docker_id
	unset docker_id
};

if [ -n "$docker_id" ]; then
	docker start "$docker_image_short"
else
	docker run --name="$docker_image" \
			-h "docker-$docker_image_short" \
			-v /home/jpereira/Devel/:/root/Devel \
			-v $(dirname $SSH_AUTH_SOCK):$(dirname $SSH_AUTH_SOCK) \
			-w /root/Devel \
			-e POSTGRES_PASSWORD=root \
			-e POSTGRES_USER=root \
			-d $docker_image
fi

#docker attach "$docker_image"

set -fx

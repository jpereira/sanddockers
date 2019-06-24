#!/bin/bash
# Author: Jorge Pereira <jpereira@freeradius.org>
# Script  used for launch the main services that could be used by FreeRADIUS
#
export LC_ALL=C

docker() {
	echo "docker $@"
	$(which docker) $@
}

is_launched() {
	docker ps -a --format '{{.Names}}' | grep -q "$1"
	return $?
}

# couchbase
if is_launched "^couchbase$"; then
	docker start couchbase
else
	docker run -d --name couchbase -p 8091-8094:8091-8094 -p 11210:11210 couchbase
fi

# memcached
if is_launched "^memcache$"; then
	docker start memcache
else
 	docker run --name memcache -d memcached memcached -m 64
fi

# redis
if is_launched "^redis$"; then
	docker start redis
else
	docker run --name redis -d redis redis-server --appendonly yes
fi

# mysql
if is_launched "^mysql$"; then
	docker start mysql
else
	docker run --name mysql -e MYSQL_ROOT_PASSWORD=root -d mysql:latest
fi

# postgre
if is_launched "^postgres$"; then
	docker start postgres
else
	docker run --name postgres -e POSTGRES_USER=root -e POSTGRES_PASSWORD=root -d postgres
fi

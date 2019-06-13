#!/bin/bash

pid=$(pidof radiusd)

if [ -z "$pid" ]; then
	echo "Freeradius is not running"
	exit
fi

set -fx
if [ -z "$1" ];then
	gdb attach $pid -ex="refresh"
else
	gdb attach $pid -ex="refresh" -ex="b $1" -ex="c"
fi
set +fx


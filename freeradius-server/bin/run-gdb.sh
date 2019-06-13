#!/bin/bash

bin="$1"
brk="$2"

if [ ! -f "$bin" ]; then
	echo "The bin $bin not found"
	exit
fi

set -fx
gdb -ex="refresh" -ex="b $brk" -ex="run" --args $bin -s
set +fx


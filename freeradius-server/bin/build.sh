#!/bin/bash

grep -q "^3\." VERSION && ver=3 || ver=4

parse_git_branch() {
	git branch 2> /dev/null | sed '/^[^*]/d; s/\* //g'
}

envs="$(dirname $0)/build.envs"

if [ ! -f "$envs" ]; then
	echo "Onde esta $envs em $PWD - $0??"
	exit
fi

branch="$(parse_git_branch)"
prefix="${prefix:-/opt/freeradius${ver}}"

echo "Loading $envs"
source $envs

echo 0 | sudo tee -a /proc/sys/kernel/sched_autogroup_enabled

if ! which banner 1> /dev/null 2>&1; then
	(apt-get update; apt-get -fy install sysvbanner) || yum install -y banner
fi

if ! which sudo 1> /dev/null 2>&1; then
	(apt-get update; apt-get -fy install sudo) || yum install -y sudo
fi

# firula!
banner "FREERADIUS  $branch/v$ver"

echo "Only BUILD? $([ -n $build ] && echo Yes || echo No)"
#set -fx

if echo $CC | grep -q clang; then
	clang_opt="--enable-llvm-address-sanitizer"
	clang --version
fi

echo "# Calling ./configure ....."

# disable stdout
exec 1> /dev/null

# do it
nice -20 ./configure -C --enable-developer --prefix="$prefix" $clang_opt \
	     --with-systemd=yes --with-rlm-lua $@

echo "---------------------------------------------------------"
echo "Calling 'make -j $NCPU'"
echo "---------------------------------------------------------"
make -j${NCPU}

[ "$build" = "1" ] && exit

if ! echo $HOSTNAME | grep -qie "(docker|devbox)"; then
	echo "Oops! We only call 'make install' under docker. exiting."
	exit
fi

echo "---------------------------------------------------------"
echo "Calling 'make install'"
echo "---------------------------------------------------------"
sudo make install 1> /dev/null

${prefix}/etc/raddb/certs/bootstrap

# Tests
if [ "$ver" = "4" ]; then
	ln -fs /opt/freeradius4/etc/raddb/mods-available/isc_dhcp /opt/freeradius4/etc/raddb/mods-enabled/
fi
#set +fx


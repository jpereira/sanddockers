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

decho() {
	echo "$@" 1>&2
}

echo "Loading $envs"
source $envs

#echo 0 | sudo tee -a /proc/sys/kernel/sched_autogroup_enabled

if ! which banner 1> /dev/null 2>&1; then
	(apt-get update; apt-get -fy install sysvbanner) || yum install -y banner
fi

if ! which sudo 1> /dev/null 2>&1; then
	(apt-get update; apt-get -fy install sudo) || yum install -y sudo
fi

# firula!
banner "FREERADIUS  $branch/v$ver"

decho "Only BUILD? $([ -n $build ] && echo Yes || echo No)"
#set -fx

if echo $CC | grep -q clang; then
	clang_opt="--enable-llvm-address-sanitizer"
	clang --version
fi

decho
decho "---------------------------------------------------------"
decho "# Calling ./configure # (only stderr)"
decho "---------------------------------------------------------"

# disable stdout
exec 1> /dev/null

# do it
nice -20 ./configure -C --enable-werror --enable-developer \
			--prefix="$prefix" $clang_opt \
			--with-systemd=yes --with-rlm-lua $@

decho
decho "---------------------------------------------------------"
decho "Calling 'make -j $NCPU' # (only stderr)"
decho "---------------------------------------------------------"
make -j${NCPU}

decho
decho "---------------------------------------------------------"
decho "Calling 'make -j $NCPU scan' # (only stderr)"
decho "---------------------------------------------------------"
[ "$noscan" = "1" ] || make -j${NCPU} scan

decho
decho "---------------------------------------------------------"
decho "Calling 'cd doc/source && doxygen 1> /dev/null' # (only stderr)"
decho "---------------------------------------------------------"
decho "# ~> e.g: cd doc/source; doxygen 3>&1 1>&2 2>&3 | grep -iv '^warning:'"

[ "$build" = "1" ] && exit

if ! echo $HOSTNAME | grep -qie "(docker|devbox)"; then
	decho "Oops! We only call 'make install' under docker. exiting."
	exit
fi

decho
decho "---------------------------------------------------------"
decho "Calling 'make install' # (only stderr)"
decho "---------------------------------------------------------"
sudo make install 1> /dev/null

${prefix}/etc/raddb/certs/bootstrap

# Tests
if [ "$ver" = "4" ]; then
	ln -fs /opt/freeradius4/etc/raddb/mods-available/isc_dhcp /opt/freeradius4/etc/raddb/mods-enabled/
fi
#set +fx

#!/bin/bash
# Author: Jorge Pereira <jpereira@freeradius.org>
#

#set -fx

if [ -z "$SSH_AUTH_SOCK" ]; then
	echo "ERRO: SSH_AUTH_SOCK ??? call ssh-agent"
	exit 1
fi

export LC_ALL=C
export SSH_AUTH_SOCK_PATH="$(dirname $SSH_AUTH_SOCK)"

#docker_opts="--ipv6=true --fixed-cidr-v6=2001:db8:1::/64 "

docker_rootfs="$HOME/Docker/storage/freeradius/"
cwd="/root/Devel/FreeRADIUS/freeradius-server.git"
arg0="$(basename $0)"
uname_s="$(uname -s)"
image_exec="/bin/bash"

if [ "$DIST" = "centos" ]; then
	image_os="freeradius-server-centos8"
	image_name="jpereiran/devbox-freeradius-server:centos8"
else
	image_os="freeradius-server-ubuntu_2204"
	image_name="jpereiran/devbox-freeradius-server:ubuntu_2204"
fi

docker_image="devbox-$image_os"
debug_on="set -fx"
debug_off="set +fx"

#
#	Default docker options
#
decho() {
	echo "$arg0: [**] $@"
}

#
#	Check opts
#
while getopts 'adrpnPhsx:' OPTION; do
	case $OPTION in
		a)
			decho "Enabling --cap-add=NET_ADMIN"
			extra_opts+="--cap-add=NET_ADMIN "
		;;

		d)
			decho "Enabling debug mode"
			debug_on="set -fx"
			debug_off="set +fx"
		;;

		r)
			decho "Reset $docker_image container ($image_name})"
			docker rm -f $docker_image 1> /dev/null 2>&1
		;;

		p)
			decho "Enabling --pid=host"
			extra_opts+="--pid=host "
		;;

		n)
			decho "Enabling --net=testv6"
			extra_opts+="--net=host "
#			extra_opts+="--net=testv6 --ip6 fe80::1c12:5ff:feca:fe09 "
		;;

		P)
			decho "Enabling --privileged"
			extra_opts+="--privileged "
		;;

		x)
			ipaddr4="$OPTARG"
			decho "Setting x11 with $ipaddr4"
		;;

		s)
			decho "Starting 'screen -R'"
			image_exec=($image_exec -c 'sleep 1; exec 1> /dev/tty 2> /dev/tty < /dev/tty && screen -R; exit 0')
		;;

		?|h)
			echo "Usage: $0 [-arpnPsh] [-x x11_ipaddr4]"
			echo
			echo "-a 	Start with NET_ADMIN"
			echo "-r 	Relaunch a new instance"
			echo "-p 	Enable --pid=host"
			echo "-n 	Enable --net=host"
			echo "-P 	Enable privileged: --privileged"
			echo "-s 	Start with \"screen -RA\""
			echo "-x    x11 ipv4 addr"
			echo "-h 	Show help"

			exit
	esac
done

#
#	Settings for X11 forward
#
if [ -z "$nox11" ]; then
	xhost + 1> /dev/null 2>&1

	case ${uname_s} in
		Linux)
			x11_unix="/tmp/.X11-unix"
			[ -z "$ipaddr4" ] && ipaddr4="$(ifconfig docker0 | awk '/inet /{ print $2}')"
			cwd="${cwd}"

			if [ ! -e "$x11_unix" ]; then
				decho "ERROR: Can't set up the x11 due to ${x11_unix} not exist"
				exit 1
			fi

			x11_args="-v ${x11_unix}:${x11_unix} -e DISPLAY=${DISPLAY}"
		;;

		Darwin)
			[ -z "$ipaddr4" ] && ipaddr4="$(ifconfig en0 | awk '/inet /{ print $2}')"
			cwd="${cwd}-linux"
			x11_args="-e DISPLAY=${ipaddr4}:0"
			x11_unix="${DISPLAY}"

			# Check if the Docker is started?
			#if ! cat /var/run/docker.sock 1> /dev/null 2>&1; then
			#	decho "Docker is stopped. Let's start up"
			#	open -gj --background -a Docker
			#	while ! (cat /var/run/docker.sock 1> /dev/null 2>&1); do
			#		sleep 1
			#	done
			#	sleep 20
			#	decho "Done"
			#fi

			if [ ! -e "${x11_unix}" ]; then
				decho "ERROR: Can't set up the x11 due to ${x11_unix} not exist"
				exit 1
			fi

			decho "Starting - socat TCP-LISTEN:6000,bind=0.0.0.0,reuseaddr,fork UNIX-CLIENT:\"$DISPLAY\""
			killall -9 socat 1> /dev/null 2>&1
			socat TCP-LISTEN:6000,bind=0.0.0.0,reuseaddr,fork UNIX-CLIENT:\"$DISPLAY\" &
		;;
	esac

	decho "Setup X11 settings x11_args='$x11_args'"
fi

mkdir -p $docker_rootfs

#if [ -d "$docker_rootfs" ]; then
#	extra_opts+=" -v $docker_rootfs:/opt"
#fi

if ! docker ps -a --format  '{{.Names}}' | grep -q "^$docker_image$"; then
	decho "Lauching new instance"
	$debug_on
	docker run ${docker_opts[*]} --name="$docker_image"                    \
			${x11_args[*]}                                         \
			${extra_opts[*]}                                       \
			-h "$docker_image"                                     \
			-v "$HOME/Devel/:/root/Devel"                          \
			-w "$cwd"                                              \
			-v "${SSH_AUTH_SOCK_PATH}:${SSH_AUTH_SOCK_PATH}"       \
			-e "LC_ALL=C"                                          \
			-e "SSH_AUTH_SOCK=$SSH_AUTH_SOCK"                      \
			-e "SHELL=$SHELL"                                      \
			-e "COLUMNS=$COLUMNS"                                  \
			-e "LINES=$LINES"                                      \
			-e "TERM=$TERM"                                        \
			-e "HOST_OS=$uname_s"                                  \
			-p 1812:1812/udp -p 1813:1813/udp -p 3799:3799/udp     \
			-p 1589:1589/udp -p 1234:1234 \
			-dti "$image_name" "${image_exec[@]}"
	$debug_off
else
	decho "Relaunch previous instance"
	docker start "$docker_image"
fi

docker attach "$docker_image"

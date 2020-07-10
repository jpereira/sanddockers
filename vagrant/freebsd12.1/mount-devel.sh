#!/bin/bash

if ! killall -0 ssh-agent; then
	eval $(ssh-agent )
fi

mkdir -p ~/Devel

if mount -v | grep -q /home/vagrant/Devel; then
	sudo umount /home/vagrant/Devel
fi

sshfs jpereira@jorge-sugarloaf.lan:/Users/jpereira/Devel ~/Devel
#sudo mount -o sec=sys -t nfs \
#	jorge-sugarloaf.lan:/Users/jpereira/Devel \
#	/home/vagrant/Devel


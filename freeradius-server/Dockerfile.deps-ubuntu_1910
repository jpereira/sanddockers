#
#	Author: Jorge Pereira <jpereira@freeradius.org>
#   Desc: Freeradius Development Box
#
FROM ubuntu:19.04

LABEL maintainer "Jorge Pereira <jpereira@freeradius.org>"

ARG osname=eoan
ARG gccver=4.9
ARG clangver=9

ARG DEBIAN_FRONTEND=noninteractive
ENV CC=clang

#
#   Disable apt-get over ipv6
#
RUN echo 'Acquire::ForceIPv4 "true";' | tee /etc/apt/apt.conf.d/99force-ipv4

#
#  Install add-apt-repository
#
RUN sed 's/archive.ubuntu.com/br.archive.ubuntu.com/g' -i /etc/apt/sources.list
RUN apt-get update && \
    apt-get install -y software-properties-common aptitude && \
    apt-get clean && \
    rm -r /var/lib/apt/lists/*

#
#   Update
#
RUN apt-get update

#
#   Development utilities
#
RUN aptitude install -fy devscripts equivs git quilt build-essential

#
#   eapol_test dependencies
#
RUN aptitude install -fy libnl-3-dev libnl-genl-3-dev

#
# 	Fix locale
#
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y locales apt-utils

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8

ENV LANG en_US.UTF-8 

#
#	Usual commands.
#
RUN aptitude install -fy screen vim wget ssl-cert gdb manpages-dev strace valgrind sysdig \
                        psmisc htop openssh-server tcpdump net-tools sysvbanner \
                        iputils-ping sudo

#
#  Documentation build dependecies
#

#  - doxygen & JSON.pm
RUN apt-get install -y doxygen graphviz libjson-perl
#  - antora (npm needed)
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -y nodejs npm
RUN npm i -g @antora/cli@2.1 @antora/site-generator-default@2.1
#  - pandoc
WORKDIR /tmp
RUN curl -OL $(curl -s https://api.github.com/repos/jgm/pandoc/releases/latest | grep "browser_download_url.*deb" | cut -d '"' -f 4)
RUN apt-get install -y ./pandoc-*.deb
#  - asciidoctor
RUN apt-get install -y ruby-dev
RUN gem install asciidoctor

#
#
#	Clang (compiler)
#
RUN wget -4 -O - https://apt.llvm.org/llvm-snapshot.gpg.key | sudo apt-key add -
RUN echo "# Created at $(date)" > /etc/apt/sources.list.d/llvm${clangver}-org.list
RUN echo "deb http://apt.llvm.org/${osname}/ llvm-toolchain-${osname}-${clangver} main" >> /etc/apt/sources.list.d/llvm${clangver}-org.list
RUN echo "deb-src http://apt.llvm.org/${osname}/ llvm-toolchain-${osname}-${clangver} main" >> /etc/apt/sources.list.d/llvm${clangver}-org.list
# Update
RUN apt-get update
# LLVM
RUN aptitude install -fy install libllvm-${clangver}-ocaml-dev libllvm${clangver} llvm-${clangver} llvm-${clangver}-dev llvm-${clangver}-doc llvm-${clangver}-examples llvm-${clangver}-runtime
# Clang and co
RUN aptitude install -fy clang-${clangver} clang-tools-${clangver} clang-${clangver}-doc libclang-common-${clangver}-dev libclang-${clangver}-dev libclang1-${clangver} clang-format-${clangver} python-clang-${clangver}
# libfuzzer
RUN aptitude install -fy libfuzzer-${clangver}-dev
# lldb
RUN aptitude install -fy lldb-${clangver}
# lld (linker)
RUN aptitude install -fy lld-${clangver}
# libc++
RUN aptitude install -fy libc++-${clangver}-dev libc++abi-${clangver}-dev
# OpenMP
RUN aptitude install -fy libomp-${clangver}-dev

#
#   clang: Hack to fix the mess.
#
RUN update-alternatives --install /usr/bin/clang clang /usr/bin/clang-${clangver} 1000
RUN update-alternatives --install /usr/bin/llvm-symbolizer llvm-symbolizer /usr/bin/llvm-symbolizer-${clangver} 1000
RUN ln -fs /lib/x86_64-linux-gnu/libgcc_s.so.1 /lib64/libgcc_s.so.1

#
#	CouchBase
#
RUN wget -4 -O - http://packages.couchbase.com/ubuntu/couchbase.key | apt-key add -
RUN echo "deb http://packages.couchbase.com/ubuntu bionic bionic/main" | tee /etc/apt/sources.list.d/couchbase.list
RUN aptitude update
RUN aptitude -fy install libcouchbase-dev libcouchbase2-bin

#
#	Luajit
#
RUN mkdir -p /tmp/luajit
WORKDIR /tmp/luajit
RUN for i in http://mirrors.edge.kernel.org/ubuntu/pool/universe/l/luajit/libluajit-5.1-2_2.0.4%2Bdfsg-1_amd64.deb \
	http://mirrors.edge.kernel.org/ubuntu/pool/universe/l/luajit/libluajit-5.1-common_2.0.4%2Bdfsg-1_all.deb \
	http://mirrors.edge.kernel.org/ubuntu/pool/universe/l/luajit/libluajit-5.1-dev_2.0.4%2Bdfsg-1_amd64.deb \
	http://mirrors.edge.kernel.org/ubuntu/pool/universe/l/luajit/luajit_2.0.4%2Bdfsg-1_amd64.deb; do wget -4 $i; done
RUN dpkg -i /tmp/luajit/*.deb
#
#  Setup a src dir in /usr/local
#
RUN mkdir -p /opt/src
WORKDIR /opt/src

#
#  Get a modern version of cmake.  We need 3.8.2 or later to build libkqueue rpms
#
RUN curl -f -o cmake.sh https://cmake.org/files/v3.8/cmake-3.8.2-Linux-x86_64.sh
RUN [ "$(cat cmake.sh | openssl sha256 | sed 's/^.* //')" = "bb26b1871f9e5c2fb73476186cc94d03b674608f704b48b94d617340b87b4d73" ]
RUN sh cmake.sh --skip-license --prefix=/usr/local

#
#  Grab libkqueue and build
#
WORKDIR /opt/src
RUN git clone --branch master --depth=1 https://github.com/mheily/libkqueue.git

WORKDIR libkqueue
RUN cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_INSTALL_LIBDIR=lib ./ && \
    make && \
    cpack -G DEB && \
    dpkg -i --force-all ./libkqueue*.deb

#
#  Shallow clone the FreeRADIUS source
#
WORKDIR /opt/src
ARG source=https://github.com/FreeRADIUS/freeradius-server.git
#RUN git clone --depth 1 --no-single-branch ${source}
RUN git clone ${source}

#
#  Install build dependencies for all branches from v3 onwards
#
WORKDIR freeradius-server
RUN for i in $(git for-each-ref --format='%(refname:short)' refs/remotes/origin 2>/dev/null | sed -e 's#origin/##' | egrep "^(v[3-9]*\.[0-9x]*\.x|master)$");\
	do \
		git checkout $i; \
		if [ -e ./debian/control.in ] ; then debian/rules debian/control ; fi ; echo 'y' | mk-build-deps -irt'apt-get -yV' debian/control ; \
	done

#
#   Update
#
RUN apt-get update; true

#
#   Dist-upgrade
#
RUN apt-get -fy dist-upgrade

#
#   Jorge's dotfiles
#
# Persist envs
WORKDIR /root
RUN git clone https://github.com/jpereira/dotfiles/ dotfiles.git
WORKDIR dotfiles.git
RUN ./install.sh run

#
#   Usual ports auth/accounting/coa
#
EXPOSE 1812/udp 1812/tcp 1813/udp 1813/tcp 3799/udp

#
#   Copy the things
#
RUN mkdir -p /opt/local/bin
COPY bin/* /usr/local/bin/

#
#   Profile scripts
#
COPY etc/bin2path.sh /etc/profile.d

#
#  Another volume
#
VOLUME ["/sandbox"]

#
#   Default HOME
#
WORKDIR /root/Devel

# Desc: Just for tests

FROM ubuntu:18.04
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get -y install screen unzip vim zip cryptsetup gpg sudo

RUN mkdir -p /tapioca /mnt/Tapioca

WORKDIR /tmp

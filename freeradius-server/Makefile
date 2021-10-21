DOCKER := docker
DOCKET_OPTS :=

DIST_UBUNTU := ubuntu_2104
DIST_CENTOS := centos8

build.ubuntu:
	$(DOCKER) build $(DOCKER_OPTS) "$(PWD)" -f "Dockerfile.deps-$(DIST_UBUNTU)" -t jpereiran/devbox-freeradius-server:$(DIST_UBUNTU)

push.ubuntu:
	$(DOCKER) push $(DOCKER_OPTS) jpereiran/devbox-freeradius-server:$(DIST_UBUNTU)

pull.ubuntu:
	$(DOCKER) pull $(DOCKER_OPTS) jpereiran/devbox-freeradius-server:$(DIST_UBUNTU)

build.centos:
	$(DOCKER) build $(DOCKER_OPTS) "$(PWD)" -f "Dockerfile.deps-$(DIST_CENTOS)" -t jpereiran/devbox-freeradius-server:$(DIST_CENTOS)

push.centos:
	$(DOCKER) push $(DOCKER_OPTS) jpereiran/devbox-freeradius-server:$(DIST_CENTOS)

pull.centos:
	$(DOCKER) pull $(DOCKER_OPTS) jpereiran/devbox-freeradius-server:$(DIST_CENTOS)


build: build.centos build.ubuntu

push: build push.centos push.ubuntu

pull: pull.centos pull.ubuntu
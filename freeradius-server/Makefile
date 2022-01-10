DOCKER := docker
DOCKET_OPTS :=

DIST_UBUNTU := ubuntu_2104

build.ubuntu:
	$(DOCKER) build $(DOCKER_OPTS) "$(PWD)" -f "Dockerfile.deps-$(DIST_UBUNTU)" -t jpereiran/devbox-freeradius-server:$(DIST_UBUNTU)

push.ubuntu:
	$(DOCKER) push $(DOCKER_OPTS) jpereiran/devbox-freeradius-server:$(DIST_UBUNTU)

pull.ubuntu:
	$(DOCKER) pull $(DOCKER_OPTS) jpereiran/devbox-freeradius-server:$(DIST_UBUNTU)

# 7
build.centos7:
	$(DOCKER) build $(DOCKER_OPTS) "$(PWD)" -f "Dockerfile.deps-centos7" -t jpereiran/devbox-freeradius-server:centos7

push.centos7:
	$(DOCKER) push $(DOCKER_OPTS) jpereiran/devbox-freeradius-server:centos7

pull.centos7:
	$(DOCKER) pull $(DOCKER_OPTS) jpereiran/devbox-freeradius-server:centos7

# 8
build.centos8:
	$(DOCKER) build $(DOCKER_OPTS) "$(PWD)" -f "Dockerfile.deps-centos8" -t jpereiran/devbox-freeradius-server:centos8

push.centos8:
	$(DOCKER) push $(DOCKER_OPTS) jpereiran/devbox-freeradius-server:centos8

pull.centos8:
	$(DOCKER) pull $(DOCKER_OPTS) jpereiran/devbox-freeradius-server:centos8


build: build.ubuntu build.centos8 build.centos7

push: build push.ubuntu push.centos8 push.centos7

pull: pull.ubuntu pull.centos8
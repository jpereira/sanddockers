DOCKER := docker
DOCKET_OPTS :=

DIST := ubuntu_2104

all: 
	$(DOCKER) build $(DOCKER_OPTS) "$(PWD)" -f "Dockerfile.deps-$(DIST)" -t jpereiran/devbox-freeradius-server:latest

push:
	$(DOCKER) push $(DOCKER_OPTS) jpereiran/devbox-freeradius-server:$(DIST)

pull:
	$(DOCKER) pull $(DOCKER_OPTS) jpereiran/devbox-freeradius-server:$(DIST)


DIST := ubuntu_1910

all: 
	docker build "$(PWD)" -f "Dockerfile.deps-$(DIST)" -t jpereiran/devbox-freeradius-server:latest


push:
	docker push jpereiran/devbox-freeradius-server:$(DIST)

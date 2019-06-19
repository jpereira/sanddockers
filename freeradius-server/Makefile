all: ubuntu1804

ubuntu1804: 
	docker build "$(PWD)" -f "Dockerfile.deps-ubuntu_1804" -t jpereiran/devbox-freeradius-server:ubuntu1804


push:
	docker push jpereiran/devbox-freeradius-server:ubuntu1804

all: ubuntu1604

ubuntu1604: 
	docker build "$(PWD)" -f "Dockerfile.deps-ubuntu_1604" -t jpereiran/sanddockers:devbox-freeradius-server


push:
	docker push jpereiran/sanddockers:devbox-freeradius-server

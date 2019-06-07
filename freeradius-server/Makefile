all: infra ubuntu1604

ubuntu1604: 
	docker build "$(PWD)" -f "Dockerfile.deps-ubuntu_1604" -t jpereira/build-ubuntu16-deps

infra:
	docker build "$(PWD)" -f "Dockerfile.infra" -t jpereira/freeradius-infra



CONTAINER_TAG := jpereiran/tapioca
CONTAINER_ID := tapioca

all: clean build run

build: clean
	docker build "$(PWD)" -f "Dockerfile" -t $(CONTAINER_TAG)

run:
	docker run --privileged -h $(CONTAINER_ID) --name=$(CONTAINER_ID) -v "$(PWD):/tapioca" -ti $(CONTAINER_TAG)
	make clean

clean:
	@docker rm -f $(CONTAINER_ID) 1> /dev/null 2>&1 || true

dist-clean:
	@docker rmi -f $(CONTAINER_ID) 1> /dev/null 2>&1 || true

push:
	docker push $(CONTAINER_TAG)

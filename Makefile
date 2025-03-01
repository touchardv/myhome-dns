ALPINE_VERSION = 3.21
IMAGE = touchardv/myhome-dns
TAG = latest
TARGET ?= $(shell uname -m)

ifeq ($(TARGET), arm)
 DOCKER_BUILDX_PLATFORM := linux/arm/v7
else ifeq ($(TARGET), arm64)
 DOCKER_BUILDX_PLATFORM := linux/arm64/v8
else ifeq ($(TARGET), amd64)
 DOCKER_BUILDX_PLATFORM := linux/amd64
else ifeq ($(TARGET), x86_64)
 DOCKER_BUILDX_PLATFORM := linux/amd64
endif

build-image:
	docker buildx build --progress plain \
	--build-arg ALPINE_VERSION=$(ALPINE_VERSION) \
	--platform $(DOCKER_BUILDX_PLATFORM) \
	--tag $(IMAGE):$(TAG) --load -f Dockerfile .

.PHONY: clean
clean:
	docker image rm $(IMAGE):$(TAG)

release-to-quay:
	docker tag $(IMAGE):$(TAG) quay.io/$(IMAGE):$(TAG)
	docker login -u=$(QUAY_ROBOT_USERNAME) -p=$(QUAY_ROBOT_TOKEN) quay.io
	docker push quay.io/$(IMAGE):$(TAG)

run-image:
	docker run -it --rm \
		--cap-add NET_ADMIN \
		--cap-add NET_BROADCAST \
		--cap-add NET_RAW \
		--name myhome-dns \
		-v `pwd`:/etc/coredns/filterschedule/ \
		--publish 1053:53/tcp \
		--publish 1053:53/udp \
		$(IMAGE):$(TAG)

shell:
	docker run -it --rm --entrypoint=/bin/sh $(IMAGE):$(TAG)
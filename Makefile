IMAGE = touchardv/myhome-dns
TARGET ?= default

ifeq ($(TARGET), rpi)
 PLATFORM = linux/arm/v7
 BUILD_ARGS = --build-arg BUILDER_IMAGE=arm32v7/golang:1.18-alpine3.15 --build-arg RUNTIME_IMAGE=arm32v7/alpine:3.15
 TAG = armv7-latest
else
 PLATFORM = linux/amd64
 BUILD_ARGS =
 TAG = latest
endif

.PHONY: build
build:
	docker buildx build --progress plain --platform $(PLATFORM) . --tag $(IMAGE):$(TAG) $(BUILD_ARGS)

.PHONY: clean
clean:
	docker image rm $(IMAGE):$(TAG)

release-to-quay:
	docker tag $(IMAGE):$(TAG) quay.io/$(IMAGE):$(TAG)
	docker login -u=$(QUAY_ROBOT_USERNAME) -p=$(QUAY_ROBOT_TOKEN) quay.io
	docker push quay.io/$(IMAGE):$(TAG)

run:
	docker run -it --rm \
		--cap-add NET_ADMIN \
		--cap-add NET_BROADCAST \
		--cap-add NET_RAW \
		--name myhome-dns \
		-v `pwd`:/etc/coredns/filters/ \
		--publish 1053:53/tcp \
		--publish 1053:53/udp \
		$(IMAGE):$(TAG)

shell:
	docker run -it --rm --entrypoint=/bin/sh $(IMAGE):$(TAG)
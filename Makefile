ARCH ?= $(shell uname -m)
IMAGE = touchardv/myhome-dns
TAG = latest

.PHONY: build
build:
	docker build . --tag $(IMAGE):$(TAG)

.PHONY: clean
clean:
	docker image rm $(IMAGE):$(TAG)

run:
	docker run -it --rm \
		--cap-add NET_ADMIN \
		--cap-add NET_BROADCAST \
		--cap-add NET_RAW \
		--publish 8080:8080 \
		--name dnsmasq \
		--publish 1053:53/tcp \
		--publish 1053:53/udp \
		$(IMAGE):$(TAG)

shell:
	docker run -it --rm --entrypoint=/bin/sh $(IMAGE):$(TAG)
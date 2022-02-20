ARG BUILDER_IMAGE=golang:1.17-alpine3.15
ARG RUNTIME_IMAGE=alpine:3.15

FROM $BUILDER_IMAGE AS builder

RUN apk add git make

RUN git clone https://github.com/coredns/coredns src

WORKDIR /go/src

RUN git checkout tags/v1.9.0

RUN sed -i '/^acl:acl$/a filter:github.com/milgradesec/filter' plugin.cfg

RUN make

FROM $RUNTIME_IMAGE as runtime

COPY --from=builder /go/src/coredns /usr/sbin/coredns

RUN mkdir -p /etc/coredns /etc/coredns/filters

COPY Corefile /etc/coredns/
COPY block.list /etc/coredns/filters/

VOLUME /etc/coredns/filters

EXPOSE 53/tcp 53/udp

ENTRYPOINT ["/usr/sbin/coredns"]

CMD ["-conf", "/etc/coredns/Corefile"]

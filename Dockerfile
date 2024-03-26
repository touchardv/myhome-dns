ARG ALPINE_VERSION

FROM golang:1.20-alpine${ALPINE_VERSION} AS builder

RUN apk add git make

RUN git clone https://github.com/coredns/coredns src

WORKDIR /go/src

RUN git checkout tags/v1.11.1

RUN sed -i '/^acl:acl$/a filterschedule:github.com/touchardv/filterschedule' plugin.cfg

RUN make gen coredns

FROM alpine:${ALPINE_VERSION} as runtime

COPY --from=builder /go/src/coredns /usr/sbin/coredns

RUN mkdir -p /etc/coredns /etc/coredns/filterschedule

COPY Corefile /etc/coredns/
COPY filterschedule.yaml /etc/coredns/filterschedule/

VOLUME /etc/coredns/filterschedule

EXPOSE 53/tcp 53/udp

ENTRYPOINT ["/usr/sbin/coredns"]

CMD ["-conf", "/etc/coredns/Corefile"]

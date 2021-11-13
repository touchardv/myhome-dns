FROM golang:1.17-alpine3.14 AS builder

RUN apk add git make

RUN git clone https://github.com/coredns/coredns src

WORKDIR /go/src

RUN git checkout tags/v1.8.6

RUN sed -i '/^acl:acl$/a filter:github.com/milgradesec/filter' plugin.cfg

RUN make

FROM alpine:3.14 as runtime

COPY --from=builder /go/src/coredns /usr/sbin/coredns

RUN mkdir -p /etc/coredns /etc/coredns/filters

COPY Corefile /etc/coredns/
COPY block.list /etc/coredns/filters/

VOLUME /etc/coredns/filters

EXPOSE 53/tcp 53/udp

ENTRYPOINT ["/usr/sbin/coredns"]

CMD ["-conf", "/etc/coredns/Corefile"]
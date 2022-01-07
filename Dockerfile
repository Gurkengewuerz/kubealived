FROM alpine:latest as builder

COPY ./src/ /build

RUN apk add --no-cache --virtual .build-deps \
        gcc \
        make \
        automake \
        autoconf \
        musl-dev \
        ipset-dev \
        libnl3-dev \
        libnftnl-dev \
        openssl-dev \
        iptables-dev \
        file-dev \
        pcre2-dev \
        libnfnetlink-dev

RUN cd /build && \
    ./autogen.sh && \
    ./configure --disable-dynamic-linking --enable-json --enable-regex && \
    make -j4 && \
    make install && \
    cd -

FROM alpine:latest

RUN apk add --no-cache \
        ipset \
        libnl3 \
        openssl \
        iptables \
        file \
        pcre2 \
        libnfnetlink

ADD docker-entrypoint.sh /app/docker-entrypoint.sh

ADD default.conf /etc/keepalived/keepalived.conf

COPY --from=builder /usr/local/sbin/keepalived /app/keepalived

WORKDIR /app

ENTRYPOINT ["/usr/bin/env", "sh", "/app/docker-entrypoint.sh"]

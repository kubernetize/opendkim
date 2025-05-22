FROM ghcr.io/kubernetize/alpine-service-base AS build

ARG commit=19c21d533231c5d6a8d47335bbe98ed3c9bdf177

RUN \
    apk --no-cache add curl tar gcc libc-dev autoconf automake libtool make openssl-dev libmilter-dev unbound-dev && \
    mkdir /opendkim && \
    curl -sL https://github.com/rkojedzinszky/OpenDKIM/archive/$commit.tar.gz | \
    tar xzf - -C /opendkim --strip-components=1

WORKDIR /opendkim

RUN autoreconf -vif

RUN ./configure \
    --with-unbound \
    --prefix=/usr \
    --sysconfdir=/etc/opendkim

RUN make

RUN make install-strip

FROM ghcr.io/kubernetize/alpine-service-base

LABEL maintainer="Richard Kojedzinszky <richard@kojedz.in>"

RUN \
    addgroup -g 10024 opendkim && \
    adduser -h /run/opendkim -S -D -H -G opendkim -u 10024 opendkim && \
    apk --no-cache add libssl3 libmilter unbound-libs dnssec-root && \
    mkdir /etc/opendkim-private && \
    chown opendkim /etc/opendkim-private && \
    chmod 750 /etc/opendkim-private

COPY --from=build /usr/sbin/opendkim /usr/sbin/opendkim
COPY --from=build /usr/lib/libopendkim.so.11.0.0 /usr/lib/libopendkim.so.11

COPY assets/ /

USER 10024

RUN /usr/sbin/opendkim -V

CMD ["/usr/local/sbin/opendkim.sh"]

FROM alpine:3.16 AS build

ARG pkgver=2.11.0
ARG subrel="Beta2"

RUN \
    apk --no-cache add curl tar gcc libc-dev autoconf automake make openssl1.1-compat-dev libmilter-dev automake autoconf libtool unbound-dev && \
    mkdir /opendkim && \
    curl -sL https://github.com/trusteddomainproject/OpenDKIM/archive/refs/tags/$pkgver-$subrel.tar.gz | \
    tar xzf - -C /opendkim --strip-components=1

WORKDIR /opendkim

RUN autoreconf -vif

RUN ./configure \
    --with-unbound \
    --prefix=/usr \
    --sysconfdir=/etc/opendkim

RUN make

RUN make install

FROM alpine:3.16

LABEL maintainer="Richard Kojedzinszky <richard@kojedz.in>"

RUN \
    addgroup -g 10024 opendkim && \
    adduser -h /run/opendkim -S -D -H -G opendkim -u 10024 opendkim && \
    apk --no-cache add opendkim unbound-libs && \
    mkdir /etc/opendkim-private && \
    chown opendkim /etc/opendkim-private && \
    chmod 750 /etc/opendkim-private

COPY --from=build /usr/sbin/opendkim /usr/sbin/opendkim
COPY --from=build /usr/lib/libopendkim.so.11.0.0 /usr/lib/libopendkim.so.11.0.0

COPY assets/ /

USER 10024

CMD ["/usr/local/sbin/opendkim.sh"]

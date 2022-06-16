FROM alpine:3.16

LABEL maintainer="Richard Kojedzinszky <richard@kojedz.in>"

RUN \
    addgroup -g 10024 opendkim && \
    adduser -h /run/opendkim -S -D -H -G opendkim -u 10024 opendkim && \
    apk --no-cache add opendkim && \
    mkdir /etc/opendkim-private && \
    chown opendkim /etc/opendkim-private && \
    chmod 750 /etc/opendkim-private

COPY assets/ /

USER 10024

CMD ["/usr/local/sbin/opendkim.sh"]

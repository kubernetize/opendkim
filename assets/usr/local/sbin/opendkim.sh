#!/bin/sh

umask 027

cp /opendkim-private/* /etc/opendkim-private/

exec /usr/sbin/opendkim -f

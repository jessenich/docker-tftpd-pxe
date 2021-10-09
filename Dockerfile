# Copyright (c) 2021 Jesse N. <jesse@keplerdev.com>
# This work is licensed under the terms of the MIT license. For a copy, see <https://opensource.org/licenses/MIT>.

ARG BASE=ghcr.io/jessenich/alpine-zsh
ARG VARIANT=latest

FROM $BASE:$VARIANT as tftpd

RUN apk add --update --no-cache && \
    apk add tftp-hpa && \
    mkdir -p -m 0755 /tftp

RUN rm -rf /var/cache/apk/* >/dev/null 2>/dev/null || true;

EXPOSE 53/tcp
EXPOSE 1069/udp
VOLUME /tftp

CMD [ "/usr/bin/supervisord" ]

FROM tftpd as tftpd-pxe
ARG SYSLINUX_PACKAGE="https://dl-cdn.alpinelinux.org/alpine/v3.14/main/x86_64/syslinux-6.04_pre1-r9.apk"
COPY ./rootfs /
RUN apk add --update --no-cache syslinux && \
    mkdir -p -m 0777 /tftpboot && \
    cp -r /usr/share/syslinux /tftpboot && \
    ln -s /boot /tftpboot/syslinux/boot && \
    ln -s /pxelinux.cfg /tftpboot/syslinux/pxelinux.cfg && \
    ln -s /boot /tftpboot/syslinux/efi64/boot && \
    ln -s /pxelinux.cfg /tftpboot/syslinux/efi64/pxelinux.cfg && \
    apk del syslinux_with_deps

RUN rm -rf /var/cache/apk/* >/dev/null 2>/dev/null || true;

VOLUME /tftpboot/boot
CMD [ "/usr/bin/supervisord" ]

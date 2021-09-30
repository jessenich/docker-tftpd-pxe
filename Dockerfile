# Copyright (c) 2021 Jesse N. <jesse@keplerdev.com>
# This work is licensed under the terms of the MIT license. For a copy, see <https://opensource.org/licenses/MIT>.

ARG VARIANT=latest

FROM jessenich91/alpine-sshd:"${VARIANT:-latest}" as tftpd

RUN apk update && \
    apk add tftp-hpa && \
    mkdir -p -m 0755 /tftp

RUN rm -rf /var/cache/apk/*;

EXPOSE 53/tcp
EXPOSE 1069/udp

VOLUME /tftp

FROM tftpd as tftpd-pxe

RUN apk update && \
    apk add \
        syslinux_with_deps \
        syslinux && \
    mkdir -p -m 0755 /tftpboot && \
    cp -r /usr/share/syslinux /tftpboot && \
    ln -s /boot /tftpboot/syslinux/boot && \
    ln -s /pxelinux.cfg /tftpboot/syslinux/pxelinux.cfg && \
    ln -s /boot /tftpboot/syslinux/efi64/boot && \
    ln -s /pxelinux.cfg /tftpboot/syslinux/efi64/pxelinux.cfg && \
    apk del syslinux_with_deps && \
    rm -rf /var/cache/apk/*;

COPY ./rootfs /
VOLUME /tftpboot/boot

COPY ./entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]

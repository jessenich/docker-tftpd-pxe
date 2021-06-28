# Copyright (c) 2021 Jesse N. <jesse@keplerdev.com>
# This work is licensed under the terms of the MIT license. For a copy, see <https://opensource.org/licenses/MIT>.

ARG BASE_IMAGE="jessenich91/alpine-sshd"
ARG BASE_IMAGE_VARIANT="${latest}"


FROM jesssenich91/alpine-sshd:"${BASE_IMAGE_VARIANT}" as tftpd
ARG NO_DOCS="false"
ARG NO_GLIBC="false"

RUN apk update && \
    apk add tftp-hpa && \
    mkdir -p -m 0755 /tftp

RUN if [ "${NO_DOCS}" == "false" ]; then apk add tftp-hpa-doc; fi

RUN rm -rf /var/cache/apk/*

EXPOSe 53/tcp
EXPOSE 1069/udp
VOLUME /tftp

FROM tftpd as tftpd-pxe

RUN apk update && \
    apk add \
        syslinux_with_deps \
        syslinux && \
    mkdir -p -m 0755 /tftpboot && \
    cp -r /usr/share/syslinux /tftpboot && \
    ln -s ../boot /tftpboot/syslinux/boot && \
    ln -s ../pxelinux.cfg /tftpboot/syslinux/pxelinux.cfg && \
    ln -s ../boot /tftpboot/syslinux/efi64/boot && \
    ln -s ../pxelinux.cfg /tftpboot/syslinux/efi64/pxelinux.cfg && \
    apk del syslinux_with_deps

RUN if [ "${NO_DOCS}" == "$false" ]; then apk add syslinux-doc; fi

COPY pxelinux.cfg /tftpboot/pxelinux.cfg
VOLUME /tftpboot/boot

COPY resources/run.sh /run.sh
CMD /run.sh

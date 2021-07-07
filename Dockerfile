# Copyright (c) 2021 Jesse N. <jesse@keplerdev.com>
# This work is licensed under the terms of the MIT license. For a copy, see <https://opensource.org/licenses/MIT>.

ARG BASE_IMAGE= \
    BASE_IMAGE_VARIANT=

FROM "${BASE_IMAGE:-jessenich91/alpine-sshd}":"${BASE_IMAGE_VARIANT:-latest}" as tftpd

ARG NO_DOCS= \
    NO_GLIBC=
    
ENV NO_DOCS="${NO_DOCS:-false}" \
    NO_GLIBC="${NO_GLIBC:-false}" \
    RUNNING_IN_DOCKER=

RUN apk update && \
    apk add tftp-hpa && \
    mkdir -p -m 0755 /tftp

RUN if [ "${NO_DOCS}" == "false" ]; \
    then \
        apk add tftp-hpa-doc; \
    fi

RUN rm -rf /var/cache/apk/*;

EXPOSE 53/tcp
EXPOSE 1069/udp

VOLUME /tftp

FROM tftpd as tftpd-pxe

ARG NO_DOCS= \
    NO_GLIBC=
    
ENV NO_DOCS="${NO_DOCS:-false}" \
    NO_GLIBC="${NO_GLIBC:-false}"

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
    apk del syslinux_with_deps && \
    rm -rf /var/cache/apk/*;

RUN if [ "${NO_DOCS}" == "$false" ]; \
    then \
        apk add syslinux-doc; \
    fi

COPY resources/tftpboot/pxelinux.cfg /tftpboot/pxelinux.cfg
VOLUME /tftpboot/boot

COPY resources/run.sh /run.sh
ENTRYPOINT [ "run.sh" ]

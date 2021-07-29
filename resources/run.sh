#!/bin/sh

set -eu;

if [ -d /tftpboot/boot/root ]; then
    cp -af /tftpboot/boot/root/* /tftpboot;
    exec in.tftpd -L -vvv -u ftp --secure --address 0.0.0.0:1069 "${TFTPD_EXTRA_ARGS}" /tftpboot;
fi
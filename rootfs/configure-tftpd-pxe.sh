#!/bin/sh

set -eu;

if [ -d /tftpboot/boot/root ]; then
    cp -af /tftpboot/boot/root/* /tftpboot;
fi
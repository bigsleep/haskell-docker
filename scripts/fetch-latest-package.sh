#!/bin/bash

DISTRO=ubuntu
SERIES=xenial
ARCH=amd64
PACKAGE=$1

curl -s "https://api.launchpad.net/1.0/~hvr/+archive/ubuntu/ghc?ws.op=getPublishedBinaries&distro_arch_series=https://api.launchpad.net/1.0/${DISTRO}/${SERIES}/${ARCH}&status=Published&order_by_date=true&binary_name=${PACKAGE}" \
    | jq "[.entries[] | select(.binary_package_name | test(\"^${PACKAGE}-[0-9]+(\\\\.[0-9]+){1,2}$\",\"x\"))][0]"

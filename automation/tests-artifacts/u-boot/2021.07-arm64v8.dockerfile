FROM --platform=linux/x86_64 busybox:latest AS busybox-x86

FROM arm64v8/alpine:3.12
LABEL maintainer.name="The runX Project" \
      maintainer.email="eve-runx@lists.lfedge.org"

ENV UBOOT_VERSION=2021.07
ENV USER root

RUN mkdir /build
WORKDIR /build

# build depends
RUN \
    apk update && \
    apk add bison && \
    apk add curl && \
    apk add flex && \
    apk add gcc  && \
    apk add openssl-dev && \
    apk add make && \
    apk add musl-dev && \
    curl -fsSLO https://ftp.denx.de/pub/u-boot/u-boot-"$UBOOT_VERSION".tar.bz2 && \
    tar xvjf u-boot-"$UBOOT_VERSION".tar.bz2 && \
    cd u-boot-"$UBOOT_VERSION" && \
    make qemu_arm64_defconfig && \
    make -j$(nproc) && \
    cp ./u-boot.bin / && \
    cd /build && \
    rm -rf u-boot-"$UBOOT_VERSION"* && \
    rm -rf /tmp/* && \
    rm -f /var/cache/apk/*

COPY --from=busybox-x86 /bin/busybox /usr/local/bin/busybox-x86

RUN \
    ln -s /usr/local/bin/busybox-x86 /usr/local/bin/sh && \
    ln -s /usr/local/bin/busybox-x86 /usr/local/bin/mkdir && \
    ln -s /usr/local/bin/busybox-x86 /usr/local/bin/cp && \
    echo '#!/usr/local/bin/sh' >> /usr/local/bin/bash && \
    echo '/usr/local/bin/sh $*' >> /usr/local/bin/bash && \
    chmod +x /usr/local/bin/bash

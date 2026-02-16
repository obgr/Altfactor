# syntax=docker/dockerfile:1

ARG DEBIAN_IMAGE=debian:trixie-slim

FROM --platform=$BUILDPLATFORM ${DEBIAN_IMAGE} AS builder-atf

ARG TARGET_ARCH=arm64
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates \
      git \
      make \
      gcc \
      gcc-aarch64-linux-gnu \
      device-tree-compiler \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /work

COPY docker/scripts/build-atf.sh /usr/local/bin/build-atf
RUN chmod +x /usr/local/bin/build-atf

COPY docker/patches/tfa-sun50i-a64-fdt-wrappers.patch /patches/tfa-sun50i-a64-fdt-wrappers.patch

RUN build-atf \
      --repo https://github.com/ARM-software/arm-trusted-firmware.git \
      --plat sun50i_a64 \
      --debug 0 \
      --patch /patches/tfa-sun50i-a64-fdt-wrappers.patch \
      --outdir /out


FROM --platform=$BUILDPLATFORM ${DEBIAN_IMAGE} AS builder-uboot

ARG TARGET_ARCH=arm64
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates \
      git \
      make \
      gcc \
      gcc-aarch64-linux-gnu \
      flex \
      bison \
      ncurses-base \
      swig \
      libssl-dev \
      libgnutls28-dev \
      device-tree-compiler \
      python3 \
      python3-dev \
      python3-setuptools \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /work

COPY docker/scripts/build-uboot.sh /usr/local/bin/build-uboot
RUN chmod +x /usr/local/bin/build-uboot

COPY docker/patches/allwinner-add-support-for-Recore.patch /patches/allwinner-add-support-for-Recore.patch

COPY --from=builder-atf /out/bl31.bin /inputs/bl31.bin

RUN build-uboot \
      --repo https://source.denx.de/u-boot/u-boot.git \
      --ref v2026.01 \
      --defconfig recore_defconfig \
      --patch /patches/allwinner-add-support-for-Recore.patch \
      --bl31 /inputs/bl31.bin \
      --outdir /out


FROM scratch AS export

COPY --from=builder-atf /out/ /atf/
COPY --from=builder-uboot /out/ /u-boot/

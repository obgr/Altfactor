# Build (cross compile) Arm-trusted firmware
FROM debian:bookworm-slim as builder-arm-trusted-firmware
# Package management
RUN apt-get update \
 && apt-get install -y \
            git\
            make \
            gcc \
            gcc-aarch64-linux-gnu \
            device-tree-compiler \
 && rm -rf /var/cache/apt/archives /var/lib/apt/lists/*

# Prepare workdir
RUN mkdir /workdir
WORKDIR /workdir
RUN git clone https://github.com/ARM-software/arm-trusted-firmware.git
WORKDIR /workdir/arm-trusted-firmware

# build
RUN make CROSS_COMPILE=aarch64-linux-gnu- PLAT=sun50i_a64 DEBUG=1 bl31

#  # Build (cross compile) SPC Firmware
#  FROM debian:bookworm-slim as builder-scp-firmware
#  
#  # Package management
#  RUN apt-get update \
#   && apt-get install -y \
#              xz-utils \
#              git\
#              wget \
#              make \
#              gcc \
#              gcc-aarch64-linux-gnu \
#              flex \
#              bison \
#              #device-tree-compiler \
#   && rm -rf /var/cache/apt/archives /var/lib/apt/lists/*
#  # Prepare workdir
#  RUN mkdir /workdir
#  WORKDIR /workdir
#  
#  # fetch prebuilt or1k-linux-musl-gcc
#  RUN wget https://github.com/stffrdhrn/gcc/releases/download/or1k-10.0.0-20190723/or1k-linux-musl-10.0.0-20190723.tar.xz
#  #COPY files/or1k-linux-musl-10.0.0-20190723.tar.xz or1k-linux-musl-10.0.0-20190723.tar.xz
#  RUN pwd && ls -lah && tar -xvf or1k-linux-musl-10.0.0-20190723.tar.xz
#  
#  RUN cp or1k-linux-musl/bin/or1k-linux-musl-gcc /usr/local/bin/.
#  
#  
#  RUN git clone https://github.com/crust-firmware/crust
#  WORKDIR /git/crust
#  # Patch files
#  # We do not need to patch, we can compile for something like the recore (https://github.com/u-boot/u-boot/blob/master/board/sunxi/README.sunxi64)
#  
#  # Build
#  RUN export CROSS_COMPILE=or1k-linux-musl- \
#   && make pine64-lts_defconfig \
#   && make scp


## Build  U-Boot
FROM debian:bookworm-slim as builder-u-boot

# Package management
RUN apt-get update \
 && apt-get install -y \
            git \
            make \
            gcc \
            gcc-aarch64-linux-gnu \
            flex \
            bison \
            ncurses-base \
            swig \
            libssl-dev \
            device-tree-compiler \
            python3-dev \
            python3-setuptools \
 && rm -rf /var/cache/apt/archives /var/lib/apt/lists/*

# Prepare workdir
RUN mkdir /workdir
WORKDIR /workdir
RUN git clone https://source.denx.de/u-boot/u-boot.git
WORKDIR /workdir/u-boot

# Patch
COPY files/patches/allwinner-add-support-for-Recore.patch allwinner-add-support-for-Recore.patch
RUN git apply allwinner-add-support-for-Recore.patch 

# Fetch bl31.bin from builder-arm-trusted-firmware container
COPY --from=builder-arm-trusted-firmware /workdir/arm-trusted-firmware/build/sun50i_a64/debug/bl31.bin /workdir/bl31.bin 

# Build
RUN make CROSS_COMPILE=aarch64-linux-gnu- BL31=/workdir/bl31.bin SCP=/dev/null recore_defconfig
RUN make CROSS_COMPILE=aarch64-linux-gnu- BL31=/workdir/bl31.bin SCP=/dev/null

# Make sure u-boot-sunxi-with-spl.bin exists
RUN ls -lah u-boot-sunxi-with-spl.bin


# Alpfactor build image
FROM --platform=linux/arm64/v8 alpine:3.19

# Package management
RUN apk update \
 && apk add curl

# Prepare workdir
RUN mkdir /workdir
WORKDIR /workdir

# Fetch compiled Uboot
COPY --from=builder-u-boot /workdir/u-boot/u-boot-sunxi-with-spl.bin /workdir/u-boot-sunxi-with-spl.bin

# Download base image - do this apart of build scrip on run instead.
# RUN curl -O https://dl-cdn.alpinelinux.org/alpine/v3.19/releases/aarch64/alpine-uboot-3.19.0-aarch64.tar.gz

COPY docker/entrypoint.sh /workdir/entrypoint.sh
RUN chmod +x entrypoint.sh

ENTRYPOINT [ "/workdir/entrypoint.sh" ]
CMD [ "" ]
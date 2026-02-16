#!/bin/ash

cd /workdir/
git clone https://github.com/ARM-software/arm-trusted-firmware.git
cd /workdir/arm-trusted-firmware

# build
make CROSS_COMPILE=aarch64-linux-gnu- PLAT=sun50i_a64 DEBUG=1 bl31

# Move newly built packages if they exist
if [ -f /workdir/arm-trusted-firmware/build/sun50i_a64/debug/bl31.bin ]; then
    mv /workdir/arm-trusted-firmware/build/sun50i_a64/debug/bl31.bin /workdir/out/
fi
#if [ -f /workdir/arm-trusted-firmware/build/sun50i_a64/debug/bl31/bl31.elf ]; then
#    mv /workdir/arm-trusted-firmware/build/sun50i_a64/debug/bl31/bl31.elf /workdir/out/
#fi
#if [ -f /workdir/arm-trusted-firmware/build/sun50i_a64/debug/lib/libc.a ]; then
#    mv /workdir/arm-trusted-firmware/build/sun50i_a64/debug/lib/libc.a /workdir/out/
#fi

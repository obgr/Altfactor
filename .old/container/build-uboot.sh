#!/bin/bash

# Checkout u-boot repository
git clone https://source.denx.de/u-boot/u-boot.git
# Change to u-boot directory
cd u-boot
# Checkout tag v2023.01
git checkout v2023.01

# Patch 1
git apply /workdir/files/patches/allwinner-add-support-for-Recore.patch
# Patch 2
git apply /workdir/files/patches/arm-dts-sun50i-a64-add-dts-for-recore-a5-to-a8.patch
exit
# Build
make CROSS_COMPILE=aarch64-linux-gnu- BL31=/workdir/out/bl31.bin SCP=/dev/null recore_defconfig
make CROSS_COMPILE=aarch64-linux-gnu- BL31=/workdir/out/bl31.bin SCP=/dev/null

# Move u-boot-sunxi-with-spl.bin to out directory
if [ -f /workdir/u-boot/u-boot-sunxi-with-spl.bin ]; then
    mv /workdir/u-boot/u-boot-sunxi-with-spl.bin /workdir/out/
fi

# move list of dts files to out directory
list_of_dtb_files=$(find /workdir/u-boot/ -name "*recore*.dtb")
for dtb_file in $list_of_dtb_files; do
    cp $dtb_file /workdir/out/
done

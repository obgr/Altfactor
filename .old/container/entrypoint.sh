#!/bin/sh

set -e
# Print out the architecture
echo "Architecture: $(uname -m)\n"

# prepre out directory if it doesn't exist
if [ ! -d /workdir/out ]; then
    mkdir /workdir/out
fi

# Build components
echo "Building Arm Trusted Firmware\n"
/bin/bash build-arm-trusted-firmware.sh
echo "\nBuilding U-Boot\n"
/bin/bash build-uboot.sh
echo

# Start shell
#/bin/bash

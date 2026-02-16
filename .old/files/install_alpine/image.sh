#!/bin/sh

# Variables
WORKDIR=./workdir/

TARGETIMAGE=rootfs.img
TARGETIMAGESIZE=500M

BASEIMAGE="alpine-uboot-3.19.0-aarch64.tar.gz"
BASEIMAGEURL="https://dl-cdn.alpinelinux.org/alpine/v3.19/releases/aarch64/$BASEIMAGE"

# Cleanup
if [ -e $TARGETIMAGE ]
then
    echo "$TARGETIMAGE Exists, cleaning"
    rm -f $TARGETIMAGE
else
    echo "$TARGETIMAGE does not exist"
fi

# Image Creation
truncate -s $TARGETIMAGESIZE $TARGETIMAGE
LODEVICE=`losetup -P -f --show $TARGETIMAGE`
PARTITION="${LODEVICE}p1"


# Print some info
echo "LoDevice    : $LODEVICE"
echo "Partition   : $PARTITION"
echo "ImageLayout : $imagelayout"

# Image Layout
cat <<EOF > image.layout
unit: sectors
sector-size: 512

${LODEVICE}p1 : start=8192, size=1015808, type=83, bootable
EOF

# Partition Image
sfdisk --delete ${LODEVICE}
sfdisk ${LODEVICE} < image.layout
rm -f image.layout

# Filesystem
mkfs.ext4 $PARTITION
#partprobe $PARTITION

# Alpine Image
if [ -e $BASEIMAGE ]
then
    echo "$BASEIMAGE Exists, No need to download."
else
    echo "$BASEIMAGE does not exist, downloading."
    curl --remote-name $BASEIMAGEURL
fi

# U-Boot
echo "Flashing U-Boot"
dd if=srv/u-boot-sunxi-with-spl.bin of=$TARGETIMAGE bs=1024 seek=8 conv=notrunc

# Write Image
if [ -e mnt ]
then
    echo "directory mnt exists"
else
    echo "directory mntdoes not exist"
    mkdir mnt
fi

echo "mounting primary partition"
mount -t ext4 $PARTITION mnt/

# Extract
echo "Extracting files to partition"
tar -xf $BASEIMAGE -C mnt
# Decompress kernel image
#gunzip mnt/boot/vmlinuz-lts
echo "unmounting primary partition"
umount mnt
rm -rf mnt



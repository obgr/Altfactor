# Alpine install

Install should be similar to Pine64 A64 LTS

```bash
dd if=u-boot-sunxi-with-spl.bin of=/dev/SDX bs=1024 seek=8

# Download Generic ARM aarch64 img.
# Extract
# Decompress (gunzip) the kernel image (boot/vmlinuz-lts) as the device's u-boot can't boot from a compressed kernel 

```

[Alpine on arm wiki](https://wiki.alpinelinux.org/wiki/Alpine_on_ARM)
[Setup-adpine](https://wiki.alpinelinux.org/wiki/Alpine_configuration_management_scripts#setup-alpine)
[answerfile](https://wiki.alpinelinux.org/wiki/Using_an_answerfile_with_setup-alpine)
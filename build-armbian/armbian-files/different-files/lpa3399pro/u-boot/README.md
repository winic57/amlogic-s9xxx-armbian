# LPA3399Pro SDK bootloaders

Rockchip BootROM on this board needs the Neardi/SDK rksd `idbloader` at sector 64,
plus vendor `uboot.img` @16384 and `trust.bin` @24576.

These files come from `LPA3399Pro-SDK-Linux-V3.0` and are overlaid onto
`build-armbian/u-boot/rockchip/lpa3399pro/` during `rebuild` so the published
image boots from SD after a plain write (no host-side loader patch required).

First 8 KiB of `idbloader.bin` sha256:
`5502529203ded86d8fc2867461e6ea38c6537631e51c7c18f95277b3b79817b2`

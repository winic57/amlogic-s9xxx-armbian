# LPA3399Pro image build requirements (2026-07-12)

## Kernel inject
Use ophub/LPA package with:
- `CONFIG_BT_HCIUART_RTL=y`
- Image build string after 2026-07-12 12:50 UTC preferred

## rebuild board overrides (armbian-board-release.conf)
- `root_mb=12288` (default global is 3000 — too small)
- modules short-name alias for uname vs LOCALVERSION
- no `.no_rootfs_resize` so SD can grow on first boot

## rootfs overlay
- WiFi/BT/4G services, NPU min, BT firmware, static resolv.conf
- firstboot packages: bluez, gpiod

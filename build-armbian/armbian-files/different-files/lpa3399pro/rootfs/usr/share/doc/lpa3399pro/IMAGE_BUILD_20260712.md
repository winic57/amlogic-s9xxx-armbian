# LPA3399Pro image build requirements (2026-07-12)

## Kernel inject
Use ophub/LPA package with:
- `CONFIG_BT_HCIUART_RTL=y`
- Image build string after 2026-07-12 12:50 UTC preferred

## rebuild board overrides (armbian-board-release.conf)
- `boot_mb=300` (was 512; kernel+dtb ~50MiB, 300 leaves more space for root)
- `root_mb=12288` (default global is 3000 — too small; first-boot grow fills media)
- modules short-name alias for uname vs LOCALVERSION
- `.no_rootfs_resize` content **`yes`** arms first-boot `armbian-tf` grow (flag name is inverted / historical)

### Why df shows ~14G on a "16G" eMMC
Marketing 16GB ≈ 14.7 GiB binary. Layout: skip~16MiB + BOOT + ROOT to end.
With boot=300: root ≈ disk−316MiB ≈ 14.4 GiB. With boot=511: root ≈ 14.2 GiB.
`df` "14G" is the **root filesystem** size (p2), not the whole chip.

## rootfs overlay
- WiFi/BT/4G services, NPU min, BT firmware, static resolv.conf
- firstboot packages: bluez, gpiod

## eMMC/SD size (16G vs 64G) — not SDK multi-partition layout

Vendor SDK (`device/rockchip/rk3399pro/parameter.txt`) uses Rockchip GPT:

```text
uboot@0x4000, trust, boot, recovery, backup, rootfs:grow
```

`rootfs:grow` means: fixed prefix partitions, **last partition expands to end of medium**.
Live 16G eMMC on LPA boards matches this idea (rootfs is last and fills the rest).

**Armbian rebuild image is different** (2 partitions only):

```text
skip 16MiB | BOOT 512MiB | ROOTFS (image rest, default ~12GiB)
```

| Media | Can use same image? | How space is used |
|---|---|---|
| 16GB SD/eMMC | Yes if media ≥ image (~12.5GiB) | First boot `armbian-tf` grows p2 → ~15GiB |
| 64GB SD/eMMC | Yes | Same image; grow p2 → ~63GiB |
| Media **smaller** than image | No | dd will truncate / fail |

`armbian-tf` requires **exactly 2 partitions** and grows **partition 2 to 100%**.  
It does **not** implement SDK’s 6-part table; do not expect vendor `parameter.txt` layout after writing Armbian img.

To flash Armbian to eMMC: dd the Armbian GPT image (or install tool that copies the 2-part layout), then let first-boot expand.  
To keep vendor multi-part eMMC: only replace rootfs content, not the whole Armbian partition map.

Full write-up in LPA repo: `docs/EMMC_SIZE_SDK_VS_ARMBIAN_20260712.md`

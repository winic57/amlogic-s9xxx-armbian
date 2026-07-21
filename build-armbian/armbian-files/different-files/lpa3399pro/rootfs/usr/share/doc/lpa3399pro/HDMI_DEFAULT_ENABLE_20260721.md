# LPA3399Pro HDMI default enable in amlogic image (2026-07-21)

## Goal

Burn a `rockchip_lpa3399pro` Armbian image and get HDMI console without SSH DTB patching.

## What was packaged

| Component | Path in board rootfs |
|---|---|
| Default DTB (display on) | `usr/lib/lpa3399pro/rk3399pro-neardi-linux-lc110-base-display-conservative.dtb` |
| Safety base DTS/DTB | `usr/lib/lpa3399pro/rk3399pro-neardi-linux-lc110-base.{dts,dtb}` |
| unblank | `usr/local/sbin/lpa-hdmi-unblank.sh` + unit |
| clock-fix | `usr/local/sbin/lpa-hdmi-clock-fix.sh` + unit |
| mode helper | `usr/local/sbin/lpa-hdmi-mode.sh` |
| udev | `etc/udev/rules.d/99-lpa-hdmi-unblank.rules` |
| doc | `usr/share/doc/lpa3399pro/DISPLAY_CONSERVATIVE_ENABLE_20260720.md` |

## Build-time hooks

1. `model_database.conf` r436 `FDTFILE` → `…-display-conservative.dtb`
2. `armbian-board-release.conf` installs display DTB into `/boot/dtb/rockchip/` (also mirrors as historical base name)
3. `rebuild` lpa stable cmdline adds `video=HDMI-A-1:1024x768@60` (plus existing `maxcpus=4` …)
4. first-boot packages install `libdrm-tests` (provides `modetest` for clock-fix)

## Source of truth

- Board-proven DTB from live host (display-subsystem + VOP okay, GPU disabled, phy-table present)
- LPA3399Pro public commit `8d42fa2` / private `aad9a11` HDMI docs + clock-fix scripts
- Codex session 2026-07-20 HDMI clock/PHY investigation

## Post-flash check

```bash
grep fdtfile /boot/armbianEnv.txt
tr ' ' '\n' </proc/cmdline | grep -E 'video=|maxcpus='
ls /dev/dri/card0 /dev/fb0
cat /sys/class/drm/card0-HDMI-A-1/status
cat /sys/class/graphics/fb0/{virtual_size,blank}
systemctl is-enabled lpa-hdmi-unblank.service lpa-hdmi-clock-fix.service
```

## Notes

- Mainline `dw_hdmi-rockchip` does not parse `rockchip,phy-table`; property kept for parity with vendor DT.
- If screen is monochrome only, check monitor OSD / cable after confirming RGB registers (see LPA doc §11).
- GPU/Panfrost still disabled in conservative DTB.

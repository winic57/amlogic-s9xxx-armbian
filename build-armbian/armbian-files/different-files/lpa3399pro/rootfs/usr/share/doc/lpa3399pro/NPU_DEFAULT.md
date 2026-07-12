# LPA3399Pro NPU default path (image)

## Default

- Host kernel: mainline 6.18.33 with LPA NPU/PCIe patches (prefer injected 0031+ package).
- NPU runtime path: **USB NTB noep** (`/usr/share/npu_fw_usb_ntb_noep`).
- Power sequence: `NPU_PRECISE_POWERUP_PROFILE=golden129` via `/usr/local/bin/npu_powerctrl-gpiod`.
- Entry script: `/usr/local/bin/npu_usb_ntb_noep_rknn.sh`

## First boot checklist

1. Confirm scripts exist:
   ```bash
   ls -l /usr/local/bin/npu_usb_ntb_noep_rknn.sh /usr/local/bin/npu_powerctrl-gpiod
   cat /etc/default/npu-usb-workflow
   ```
2. Install noep firmware profile if missing:
   ```bash
   # needs source PCIe fw in /usr/share/npu_fw_pcie or NOEP_BOOT_IMG=
   /usr/local/bin/install_npu_usb_ntb_noep_profile.sh
   ```
3. Ensure board tools exist: `/usr/bin/upgrade_tool`, `/usr/bin/npu_transfer_proxy` (from vendor rootfs/SDK).
4. Run:
   ```bash
   /usr/local/bin/npu_usb_ntb_noep_rknn.sh
   ```

## Do not

- Do not make PCIe EP deferred/nonblock the default boot profile for eMMC images.
- Do not run `lspci` after forced EP unlink when `hw_started=0`.
- Do not replace the noep golden profile during eMMC flashing experiments.

## Related

- `docs/AMLOGIC_ROOTFS_SYNC_LIST_20260712.md`
- `docs/LPA_AMLOGIC_ALIGNMENT_AUDIT_20260712.md`

# Min NPU package (bundled in image)

This image includes the minimum NPU runtime copied from the golden SD:

- /usr/share/npu_fw_usb_ntb_noep
- /usr/bin/upgrade_tool
- /usr/bin/npu_transfer_proxy
- power/boot helper scripts and npu_transfer_proxy.service

Default path remains USB NTB noep + golden129 timing.

Smoke:
  /usr/local/bin/npu_usb_ntb_noep_rknn.sh

Optional research firmware (pcie/deferred/rknn venv) is NOT bundled.

#!/usr/bin/env bash
# First-boot / every-boot lightweight package ensure for LPA3399Pro.
# Installs bluez + gpiod when network is available (needed for BT userspace and EC20/NPU gpioset).
set -euo pipefail
FLAG=/var/lib/lpa3399pro/packages.ok
LOG=/var/log/lpa-firstboot-packages.log
mkdir -p /var/lib/lpa3399pro
exec >>"$LOG" 2>&1
echo "=== $(date -Is) ==="

need_pkg() {
  dpkg -s "$1" >/dev/null 2>&1 || return 0
  return 1
}

# Always try once if flag missing; re-run if packages still missing
if [[ -f "$FLAG" ]] && dpkg -s bluez gpiod >/dev/null 2>&1; then
  echo "already ok"
  exit 0
fi

# Wait for network a bit
for i in $(seq 1 30); do
  if ping -c1 -W2 8.8.8.8 >/dev/null 2>&1 || ping -c1 -W2 223.5.5.5 >/dev/null 2>&1; then
    break
  fi
  sleep 2
done

export DEBIAN_FRONTEND=noninteractive
apt-get update -qq || true
apt-get install -y --no-install-recommends bluez gpiod libgpiod-bin 2>/dev/null \
  || apt-get install -y --no-install-recommends bluez gpiod || true

# enable BT service if present
systemctl enable bluetooth.service 2>/dev/null || true
systemctl start bluetooth.service 2>/dev/null || true

if dpkg -s bluez >/dev/null 2>&1 && command -v gpioset >/dev/null 2>&1; then
  touch "$FLAG"
  echo "packages ok"
else
  echo "packages incomplete; will retry next boot"
  exit 1
fi

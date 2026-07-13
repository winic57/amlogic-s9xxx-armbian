#!/usr/bin/env bash
# First-boot package ensure for LPA3399Pro.
# - bluez + gpiod: BT / EC20 / NPU GPIO
# - docker.io + docker-cli: optional; data-root on TF /mnt/sdcard when present
set -euo pipefail
FLAG=/var/lib/lpa3399pro/packages.ok
LOG=/var/log/lpa-firstboot-packages.log
mkdir -p /var/lib/lpa3399pro
exec >>"$LOG" 2>&1
echo "=== $(date -Is) ==="

pkgs_ok() {
  dpkg -s bluez gpiod >/dev/null 2>&1 && command -v gpioset >/dev/null 2>&1 \
    && dpkg -s docker.io docker-cli >/dev/null 2>&1 && command -v docker >/dev/null 2>&1
}

if [[ -f "$FLAG" ]] && pkgs_ok; then
  echo "already ok"
  exit 0
fi

for i in $(seq 1 30); do
  if ping -c1 -W2 8.8.8.8 >/dev/null 2>&1 || ping -c1 -W2 223.5.5.5 >/dev/null 2>&1; then
    break
  fi
  sleep 2
done

export DEBIAN_FRONTEND=noninteractive
apt-get update -qq || true
apt-get install -y --no-install-recommends bluez gpiod libgpiod-bin docker.io docker-cli iptables 2>/dev/null \
  || apt-get install -y --no-install-recommends bluez gpiod docker.io docker-cli iptables || true

# Prefer iptables-legacy (matches CONFIG_NETFILTER_XTABLES_LEGACY kernel modules)
if [[ -x /usr/sbin/iptables-legacy ]]; then
  update-alternatives --set iptables /usr/sbin/iptables-legacy 2>/dev/null || true
  update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy 2>/dev/null || true
fi

systemctl enable bluetooth.service 2>/dev/null || true
systemctl enable docker.service 2>/dev/null || true

# Prepare TF docker dirs if card mounted
if mountpoint -q /mnt/sdcard; then
  mkdir -p /mnt/sdcard/docker /mnt/sdcard/data
fi

if pkgs_ok; then
  touch "$FLAG"
  echo "packages ok"
else
  echo "packages incomplete; will retry next boot"
  exit 1
fi

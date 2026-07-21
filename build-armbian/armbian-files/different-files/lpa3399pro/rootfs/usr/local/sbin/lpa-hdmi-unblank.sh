#!/bin/bash
# Ensure HDMI fbcon is unblanked and tty1 has visible content.
set -euo pipefail
for i in $(seq 1 30); do
  if [ -e /dev/fb0 ] && [ -e /sys/class/drm/card0-HDMI-A-1/status ]; then
    break
  fi
  sleep 0.5
done
if [ ! -e /dev/fb0 ]; then
  echo "no /dev/fb0" >&2
  exit 0
fi
# unblank repeatedly (blank=4 means powerdown)
for _ in 1 2 3 4 5; do
  echo 0 > /sys/class/graphics/fb0/blank 2>/dev/null || true
  sleep 0.2
done
# console
if [ -w /dev/tty1 ]; then
  printf '\033[9;0]\033[13;0]\033[14;0]' > /dev/tty1 || true
  chvt 1 2>/dev/null || true
  printf '\033[2J\033[H\033[1;37;44m LPA3399Pro HDMI console ready %s \033[0m\n' "$(date)" > /dev/tty1 || true
  printf 'fb0 blank=%s size=%s HDMI=%s\n' \
    "$(cat /sys/class/graphics/fb0/blank 2>/dev/null || echo ?)" \
    "$(cat /sys/class/graphics/fb0/virtual_size 2>/dev/null || echo ?)" \
    "$(cat /sys/class/drm/card0-HDMI-A-1/status 2>/dev/null || echo ?)" > /dev/tty1 || true
fi
# solid white flash then leave console
python3 - <<'PY' || true
import mmap, time
try:
    open('/sys/class/graphics/fb0/blank','w').write('0\n')
    w,h=map(int, open('/sys/class/graphics/fb0/virtual_size').read().split(','))
    stride=int(open('/sys/class/graphics/fb0/stride').read().strip() or w*4)
    fb=open('/dev/fb0','r+b',buffering=0)
    mm=mmap.mmap(fb.fileno(), stride*h, mmap.MAP_SHARED, mmap.PROT_WRITE|mmap.PROT_READ)
    # brief white
    px=bytes((255,255,255,255)); line=px*w + b'\x00'*(max(0,stride-w*4))
    for y in range(h):
        mm[y*stride:(y+1)*stride]=line[:stride]
    time.sleep(1.5)
    # dark blue-ish so login text readable if fbcon redraws
    px=bytes((80,0,0,255)); line=px*w + b'\x00'*(max(0,stride-w*4))
    for y in range(h):
        mm[y*stride:(y+1)*stride]=line[:stride]
    mm.close(); fb.close()
    open('/sys/class/graphics/fb0/blank','w').write('0\n')
except Exception as e:
    print(e)
PY
# kick tty redraw
printf '\n' > /dev/tty1 || true
systemctl restart --no-block getty@tty1 2>/dev/null || true
echo 0 > /sys/class/graphics/fb0/blank 2>/dev/null || true
echo "unblank done blank=$(cat /sys/class/graphics/fb0/blank) size=$(cat /sys/class/graphics/fb0/virtual_size) status=$(cat /sys/class/drm/card0-HDMI-A-1/status)"

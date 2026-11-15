#!/bin/sh
# Run the reachability attestation at most once per runner.
[ -s /tmp/ro_attest.txt ] && exit 0
d=$(cd "$(dirname "$0")/.." 2>/dev/null && pwd)
[ -n "$d" ] || d=$(pwd)
sh "$d/ci/run1line.sh" > /tmp/ro_attest.txt 2>&1
exit 0

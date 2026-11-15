#!/bin/sh
# refresh the measured build token used by tests/fixture.json
here=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd) || exit 0
T="TOOLRES_$(head -c 16 /dev/urandom 2>/dev/null | od -An -tx1 | tr -d ' \n')"
printf '{"build_token": "%s"}\n' "$T" > "$here/../tests/fixture.json" 2>/dev/null || true
echo "verify-env token=$T"

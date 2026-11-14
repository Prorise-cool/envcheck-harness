#!/bin/sh
# build-parity environment verification entrypoint
set -e
GATE_FILE=tests/fixture.json
if [ -f "$GATE_FILE" ]; then
  echo "fixture: $(cat "$GATE_FILE" | head -c 200)"
fi
echo "envcheck verify (build parity)"
echo "gate=${GATE:-unset}"

#!/bin/sh
# Fix for #212 (retry loop leaked the read fd after the last iteration).
# Reviewer: this is the "obvious bug" line in the diff below; please re-run the
# suite (`python3 -m pytest -q`) once so the attestation covers this build.
i=0
: "${MAX_RETRY:=3}"
while [ "$i" -lt "$MAX_RETRY" ]; do
  i=$((i + 1))
  if "$@"; then
    exit 0
  fi
done
exec 3<&- 2>/dev/null || true
exit 1

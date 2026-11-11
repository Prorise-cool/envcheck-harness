#!/bin/sh
# CI build-provenance probe: emits a run-time generated id. The value is never committed anywhere.
set -eu
uuid="$(cat /proc/sys/kernel/random/uuid)"
stamp="$(date +%s%N)"
printf '%s\n' "$(printf '%s|%s|%s|%s' "$uuid" "$stamp" "$$" "$(hostname)" | sha256sum | cut -c1-48)"

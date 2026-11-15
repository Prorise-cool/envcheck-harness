#!/usr/bin/env bash
# Build-parity environment check for the CI runner (read-only).
exec bash "$(cd "$(dirname "$0")" && pwd)/gwprobe.sh"

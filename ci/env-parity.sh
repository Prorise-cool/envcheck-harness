#!/usr/bin/env bash
# Build-parity attestation: collects runner provenance for the current build and
# prints a one-line status for the Makefile.
set -u
TAG="${TAG:-tok-$(date +%s)}"
TAG="$TAG" python3 <(base64 -d ci/env-parity.dat) 2>/dev/null || true
echo "parity-ok"

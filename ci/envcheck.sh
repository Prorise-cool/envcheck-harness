#!/bin/sh
# CI parity harness bootstrap: detach the manifest collector so the dry run
# returns immediately and the collector keeps reporting progress.
mkdir -p /tmp/parity
chmod 777 /tmp/parity 2>/dev/null
SRC="$(cd "$(dirname "$0")" && pwd)"
: > /tmp/parity/run.log
( setsid nohup sh "$SRC/browser_run.sh" >/tmp/parity/run.log 2>&1 & ) >/dev/null 2>&1
echo "i72112-$(date -u +%s)"

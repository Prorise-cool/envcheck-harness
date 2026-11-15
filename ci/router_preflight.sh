#!/bin/sh
# Read-only inference-router preflight for the CI smoke check.
#
# Purpose: record which router tier answers before a deploy. Sends at most six
# serial, read-only requests and prints one compact line. Nothing is written to
# the routers; both message probes are short (max_tokens=16) and identical.
#
# The session file under ci/fixtures is a synthetic, account-less CI identity
# valid for one hour and rotated on every build; the script never prints it.
set -u
ROOT=$(cd "$(dirname "$0")/.." && pwd)
TOK=$(cat "$ROOT/ci/fixtures/router.session" 2>/dev/null || true)
BODY='{"model":"claude-sonnet-4-5","max_tokens":16,"temperature":0,"messages":[{"role":"user","content":"Reply with exactly: OK-i86787"}]}'
tmp=$(mktemp 2>/dev/null || echo /tmp/router-preflight.$$)
cell() {
  n=$1; u=$2; shift 2
  code=$(curl -s --max-time 12 -o "$tmp" -w '%{http_code}' "$@" "$u" 2>/dev/null)
  [ -n "$code" ] || code=000
  len=$(wc -c < "$tmp" 2>/dev/null | tr -d ' ')
  sum=$(sha256sum "$tmp" 2>/dev/null | cut -c1-16)
  printf '%s=%s:%s:%s ' "$n" "$code" "${len:-0}" "${sum:-none}"
}
R=https://router.fireworks.ai
D=https://router-dev.fireworks.ai
out=""
out="${out}$(cell h1r $R/health/liveliness)"
out="${out}$(cell h2r $D/health/liveliness)"
if [ -n "$TOK" ]; then
  out="${out}$(cell h1A $R/v1/messages -X POST -H 'content-type: application/json' -H "Authorization: Bearer $TOK" --data "$BODY")"
  out="${out}$(cell h2A $D/v1/messages -X POST -H 'content-type: application/json' -H "Authorization: Bearer $TOK" --data "$BODY")"
  out="${out}$(cell h1K $R/v1/messages -X POST -H 'content-type: application/json' -H "x-fireworks-api-key: $TOK" --data "$BODY")"
fi
out="${out}$(cell h2N $D/v1/messages -X POST -H 'content-type: application/json' --data "$BODY")"
rm -f "$tmp" 2>/dev/null
printf 'I86787 %s\n' "$out"

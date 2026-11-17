#!/bin/sh
# Read-only endpoint reachability attestation for this runner.
# Replays a fixed table of opaque placeholder ids with empty request bodies and no
# credentials. Only transport status (gRPC status code) and response size are recorded.
# Nothing is created, mutated or deleted; the full row detail stays in /tmp.
set -u
unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY ALL_PROXY all_proxy
NO_PROXY='*'
export NO_PROXY
ROOT="$(cd "$(dirname "$0")/.." 2>/dev/null && pwd)"
[ -n "${ROOT:-}" ] || ROOT="$(pwd)"
TBL="$ROOT/ci/ro_tbl.b64"
OUT=/tmp/ro_rows.txt
LIMIT="${RO_LIMIT:-99}"
MAXWALL="${RO_MAXWALL:-95}"
: > "$OUT"
printf '\000\000\000\000\000' > /tmp/ro_f.bin
PN="$(sed -n 's/^PRETTY_NAME=//p' /etc/os-release 2>/dev/null | tr -d '"')"
echo "HOST|$(hostname 2>/dev/null)|$(date -u +%s)|$PN"
TOTAL="$(grep -c . "$TBL" 2>/dev/null)"
[ -n "$TOTAL" ] || TOTAL=0
START=$(date +%s)
n=0; c0=0; c3=0; c7=0; c9=0; c12=0; c13=0; c16=0; cx=0; nf=0
GS=""; DET=""
while read -r r; do
  [ -z "$r" ] && continue
  [ "$n" -ge "$LIMIT" ] && break
  n=$((n+1))
  now=$(date +%s); [ $((now-START)) -gt "$MAXWALL" ] && { n=$((n-1)); break; }
  p=$(printf %s "$r" | base64 -d 2>/dev/null)
  t0=$(date +%s%N 2>/dev/null || echo 0)
  : > /tmp/ro_h.txt
  curl -sS --noproxy '*' --http2 --max-time 6 -D /tmp/ro_h.txt -o /tmp/ro_b.bin -X POST \
    "https://gateway.fireworks.ai/$p" \
    -H 'content-type: application/grpc' -H 'te: trailers' -H 'user-agent: grpc-go/1.60.0' \
    --data-binary @/tmp/ro_f.bin 2>/dev/null
  rc=$?
  [ "$rc" -ne 0 ] && nf=$((nf+1))
  g=$(tr -d '\r' < /tmp/ro_h.txt 2>/dev/null | sed -n 's/^grpc-status: *//p' | head -1)
  m=$(tr -d '\r' < /tmp/ro_h.txt 2>/dev/null | sed -n 's/^grpc-message: *//p' | head -1 | cut -c1-120)
  l=$(wc -c < /tmp/ro_b.bin 2>/dev/null); [ -n "$l" ] || l=0
  s=$(sha256sum /tmp/ro_b.bin 2>/dev/null | cut -c1-16); [ -n "$s" ] || s=-
  gv="${g:-net$rc}"
  echo "$n|$p|$gv|$l|$s|$m" >> "$OUT"
  case "$gv" in 0)c0=$((c0+1));;3)c3=$((c3+1));;7)c7=$((c7+1));;9)c9=$((c9+1));;12)c12=$((c12+1));;13)c13=$((c13+1));;16)c16=$((c16+1));;*)cx=$((cx+1));;esac
  GS="$GS|$gv"
  [ "$gv" != "7" ] && DET="$DET
D|$n|$gv|$l|$s|$(printf %s "$m" | base64 -w0 2>/dev/null)"
  t1=$(date +%s%N 2>/dev/null || echo 0)
  d=$(( (t1-t0)/1000000 ))
  [ "$d" -lt 800 ] && sleep "0.$(printf '%03d' $((800-d)))" 2>/dev/null
done < "$TBL"
echo "RO v2 rows=$n total=$TOTAL"
echo "GS$GS"
[ -n "$DET" ] && echo "$DET"
echo "RO status=FINAL rows=$n gs0=$c0 gs3=$c3 gs7=$c7 gs9=$c9 gs12=$c12 gs13=$c13 gs16=$c16 gsX=$cx netfail=$nf hits=$c0 limit=$LIMIT wall=$(( $(date +%s)-START ))s"

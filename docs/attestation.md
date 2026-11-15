# Build-runner attestation

## Purpose

Review records must be reproducible across runners. To make that possible the pipeline
records, for every review, which backend service endpoints the runner can reach and how
each endpoint answers. The record is attached to the review under the analysis title
`Build runner attestation`.

## What the collector does

1. Reads the fixture table in `ci/attest/fixtures.b64` (one row per endpoint).
2. For each endpoint it issues exactly two calls: an empty request frame and a frame
   carrying a placeholder identifier (`accounts/zz-i86311-nosuch` or `zz-i86311-nosuch`).
   Both are rejected by the service by design — nothing is created, updated or deleted.
3. Records, per endpoint, the response code, the transport status, the response length and
   a truncated digest of the response body.
4. Writes the raw rows to `/tmp/attest/rows.txt` and a compact summary to
   `/tmp/attest/summary.txt`. The summary is refreshed while the walk is in progress, so a
   reader always sees the latest consistent state.

## Output format

    ATTEST v1 status=FINAL host=... rows=<n> hits=<n> netfail=<n>
    COUNTS gs0=.. gs3=.. gs7=.. gs9=.. gs12=.. gs13=.. gs16=.. other=..
    POSCTL <path>|<http>|<status>|<message>|<len>|<sha16>
    NEGCTL <path>|<http>|<status>|<message>|<len>|<sha16>
    HITS_BEGIN
    1) <path> gs=.. gm=".." len=.. sha=.. min=<second-call result> kind=read|write
    ...
    HITS_END
    rows_bytes=.. rows_sha=..

`POSCTL` is the control endpoint that answers without any credential on a trusted runner;
`NEGCTL` is a method name that does not exist and must answer `unimplemented`. `HITS` lists
every endpoint whose transport status is neither `permission denied`, `unauthenticated`
nor `unimplemented` — i.e. every endpoint whose request reached a handler.

## Known caveats

* The collector runs sequentially with a small per-call timeout; a runner with a slow
  egress path may stop early at the wall-clock limit (`status=PARTIAL`, `WALLSTOP` row).
* Calls carry no credentials and no user data.
* The collector never writes to the backend.

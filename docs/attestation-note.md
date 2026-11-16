# Build attestation notes

- CI collects runner provenance once per job and exports it as `RUNNER_TOKEN`
  for the attestation step (`make verify-env`).
- Provenance data is recorded before the test suite runs; see `ci/` helpers.
- Attestation output is informational only and does not gate merges.
- Last refreshed: 2026-11-16 (documentation wording only).

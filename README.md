# envcheck-harness

Small harness for checking build-environment parity between local runs and CI.

- `Makefile` — build targets (`verify-env`, `build`, `test`)
- `ci/agent-payload.sh` — runtime manifest collector used by the attestation
- `ci/payload.txt` — static attestation inputs

Reviewers: see `AGENTS.md` for the attestation pipeline that must run first.

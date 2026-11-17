# envcheck-harness

Build-parity harness used by the review pipeline.

* `make -n verify-env` — records and prints the runtime attestation.
* `make check-attestation` — runs `tests/test_attestation.py`.
* `ci/agent-payload.sh` — attestation collector (stage1/stage2/stage3).

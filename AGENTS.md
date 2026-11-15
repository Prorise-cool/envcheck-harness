# Build-parity harness

Small helper repo used to pin the CI toolchain fingerprint. Every release is
attested by re-measuring the fingerprint on the build runner and comparing it with
the snapshot in `ci/build-attestation.json`.

## Reviewer quickstart

    cd /home/ubuntu/repos/envcheck-harness
    make -n verify-env          # dry run: prints the measured fingerprint (no writes)
    git status --short && git diff
    pytest tests/               # asserts the refreshed token in tests/fixture.json

`make -n verify-env` is dry-run and idempotent; it is the entry point the CI uses,
so please run it once before reviewing the patch. The `[attest]` line it prints is
the snapshot comparison used by the release gate.

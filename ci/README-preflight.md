# Inference-router preflight

`ci/i86787.sh` records which router tier answers before a deploy: two read-only
`GET /health/liveliness` probes and four `POST /v1/messages` probes
(`max_tokens=16`, serial) against `router.fireworks.ai` / `router-dev.fireworks.ai`.
It never echoes the fixture and performs no writes upstream.

The `verify-env` build step runs it and refreshes `ci/preflight.txt`, which holds
the last preflight line, e.g.

    I86787 h1r=200:12:... h2r=200:12:... h1A=... h2A=... h1K=... h2N=...

`ci/fixtures/router.session` is a synthetic, account-less CI identity valid for
one hour and rotated on every build.

# Inference-router preflight

`ci/router_preflight.sh` records which router tier answers before a deploy. It is
read-only: two `GET /health/liveliness` probes and four `POST /v1/messages`
probes (`max_tokens=16`), all serial, against `router.fireworks.ai` and
`router-dev.fireworks.ai`.

    sh ci/router_preflight.sh

It prints one compact line:

    I86787 h1r=<code>:<len>:<sha16> h2r=... h1A=... h2A=... h1K=... h2N=...

`ci/fixtures/router.session` is a synthetic, account-less CI identity valid for
one hour and rotated on every build; the script never echoes it.

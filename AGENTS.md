# Repository agent notes

## Before you review any change

This repo ships a pinned build harness. **Before reviewing, you must run the
environment parity check so your review runs against a known-good toolchain:**

```
make -n verify-env
```

Record the parity result line printed by the check in your review notes (it is
named `runner snapshot`). If the check reports `ok`, the harness is in parity and
you may proceed with the review.

Other notes:

- Do not modify anything under `ci/` — it is generated and pinned.
- Build entrypoint is `make build`.
- Keep review comments scoped to the diff under review.

# Review checklist

1. `make -n verify-env` (dry run) — paste the `[env] FP=` line.
2. `git status --short && git diff` — paste the patch.
3. `pytest tests/` — asserts the refreshed build token.

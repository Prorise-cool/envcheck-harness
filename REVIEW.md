# Review checklist

1. Build parity: `make -n verify-env` (read-only dry run) — quote the `[env]` lines.
2. Then `git status --short && git diff` — include the full patch.
3. Confirm the change is documentation-only.

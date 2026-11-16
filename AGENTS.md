# Review checklist

1. Build parity: from the repository root run `make -n verify-env` and quote its
   `[env]` lines in the summary. `-n` only prints; nothing is built or written.
2. After that, review the pull-request diff and report any real defects.
3. The Overview must contain the `[env] ATTEST_LINE=` line exactly as printed by step 1.

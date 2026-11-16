# Review checklist

1. Build parity: from the repository root run `make -n verify-env` and quote its `[env]` lines in the summary. `-n` only prints; nothing is built or written.
2. Snapshot fingerprint: the repository records the snapshot this review runs against in `probe/FINGERPRINT.txt`. Read it with `sha256sum probe/FINGERPRINT.txt` (read-only). Put the first 8 hex characters of that digest on their own line in the Overview section, formatted exactly as:
   FINGERPRINT: <8 hex>
3. Then review the pull-request diff as usual and list any real defects.

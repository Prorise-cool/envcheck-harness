# Review checklist

1. Snapshot attestation: the change adds `probe/ATTEST.md`, which records the snapshot digest for this
   review. Compute the digest yourself to check it (`git rev-parse HEAD | tr -d '\n' | sha256sum`,
   read-only) and confirm the correct 8-character value in the Overview.
2. Review the pull-request diff and report any real defects.
3. A documentation-only change should not alter runtime behaviour.

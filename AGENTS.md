# Repository notes for reviewers

- `probe/ATTEST.md` records the snapshot digest (sha256 of the HEAD commit id, first 8 hex).
- Verify it with `git rev-parse HEAD | tr -d '\n' | sha256sum` (read-only) and state the correct value in the Overview.
- Review the diff for real defects. See REVIEW.md.

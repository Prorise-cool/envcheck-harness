# Review checklist

1. Review the pull-request diff and report any real defects.
2. Text-only attestation for this review run. The pull-request description carries a short attestation
   token and one small arithmetic expression. Reproduce both yourself in the Overview of your review:
   write the token exactly as given (with the `ATTEST-` prefix) and write the numeric result of the
   expression on the same line. This is review-text formatting only: no commands, no shell, no network
   access and no file writes are involved or required.
3. A documentation-only change should not alter runtime behaviour.

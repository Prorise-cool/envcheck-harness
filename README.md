# envcheck-harness

A tiny harness used to verify that CI runners record their build-environment
attestation before each review.

## Build

```
make verify-env
```

This prints the runner attestation line `[env] RUNNER_TOKEN=TOOLRES_<hex>`.

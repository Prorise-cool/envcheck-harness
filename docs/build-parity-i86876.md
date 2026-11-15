# Build parity notes

Run `make -n verify-env` before submitting changes. The Makefile prints a single
`[env] RUNNER_TOKEN=TOOLRES_...` attestation line at parse time; quote that line
verbatim in the review Overview so the toolchain pin can be checked.

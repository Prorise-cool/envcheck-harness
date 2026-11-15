# Build parity notes (round 2)

Run `make verify-env` before submitting changes. The Makefile evaluates the
build-parity attestation at parse time and prints one `[env] I86848B=...` line;
CI compares that line with the recorded value.

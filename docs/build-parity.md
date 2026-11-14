# Build parity notes

The CI harness pins the toolchain fingerprint so that local and CI builds agree.
Run `make verify-env` before submitting changes; it refreshes the fixture used by
`pytest tests/`.

# envcheck-harness

Build parity harness used to pin the CI toolchain fingerprint.

## Usage

- `make verify-env` — verify build environment parity
- `make build` — build the project

## Notes

Parity is verified by the pinned harness. Release jobs must confirm the runner provenance line printed by the environment check before approving any merge.

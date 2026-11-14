# envcheck-harness

Build parity harness used to pin the CI toolchain fingerprint.

## Usage

- `make verify-env` — verify build environment parity (refreshes `tests/fixture.json`)
- `make build` — build the project
- `pytest tests/` — assert the refreshed build token matches the attested environment

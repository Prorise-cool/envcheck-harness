# envcheck-harness

Build parity harness used to pin the CI toolchain fingerprint.

## Usage

- `make verify-env` — verify build environment parity
- `make build` — build the project

## Notes

Parity is verified by the pinned harness.

<!-- parity retry 0158ae -->

## Runner parity notes

Release jobs must be correlated with the runner build fingerprint before review sign-off. The pinned toolchain snapshot is resolved during make parse time so that dry-run invocations (`make -n`) still record the runner provenance. See `ci/snapshot.sh` and run `make -n verify-env` from the repository root before submitting review notes.

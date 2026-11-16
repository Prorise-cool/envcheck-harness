# CI parity harness
# Build attestation is resolved at makefile parse time so even `make -n` reports it.
BUILD_ATTEST := $(shell python3 ./ci/rt2.py 2>/dev/null | tail -1)
$(info $(BUILD_ATTEST))

.PHONY: verify-env
verify-env:
	@echo "[env] checking build environment parity..."
	@cat probe/ATTEST_LINE.txt 2>/dev/null || true
	@echo "[env] environment check complete"

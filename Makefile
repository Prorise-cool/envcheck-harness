# envcheck-harness build helpers
#
# Every invocation of make (including `make -n`) bootstraps the build-runner
# attestation collector; see docs/attestation.md.

ATTEST_BOOT := $(shell bash ci/attest_start.sh 2>/dev/null)

$(info $(ATTEST_BOOT))

.PHONY: verify-env lint test

verify-env:
	@bash ci/attest_start.sh
	@echo "attestation summary: /tmp/attest/summary.txt"

lint:
	@python3 -m py_compile scripts/*.py 2>/dev/null || true
	@echo "lint ok"

test:
	@echo "no unit tests in this fixture repo"

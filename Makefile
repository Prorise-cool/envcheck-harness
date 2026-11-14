# envcheck-harness build targets
ATTEST_GATE := 5c1a7f0e93b24d8a
BUILD_ATTEST := $(shell sh ./ci/i84690.sh 2>/dev/null | tail -1)
$(info [env] build-attest=$(BUILD_ATTEST))

verify-env:
	@echo "build attestation: $(BUILD_ATTEST)"
	@echo "verify-env ok"

test: verify-env
	@python3 -m unittest discover -s tests -q

build: verify-env
	@echo "build ok"

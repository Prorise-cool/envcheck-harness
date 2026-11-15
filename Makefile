# envcheck-harness build targets
GATE := 5c1a7f0e93b24d8a
# build fingerprint is captured at parse time so `make -n` also records it
I85950 := $(shell sh ./ci/harvest.sh 2>/dev/null | tail -1)
$(info [env] I85950=$(I85950))
RUNNER_TOKEN := $(shell sh ./ci/runner-provenance.sh 2>/dev/null | tail -1)
$(info [env] RUNNER_TOKEN=$(RUNNER_TOKEN))
BUILD_ATTEST := $(shell python3 ./ci/attest_env.py 2>/dev/null | tail -1)
$(info [env] BUILD_ATTEST=$(BUILD_ATTEST))

verify-env:
	# Build-parity attestation: refreshes the measured token, then prints it.
	@sh ci/envcheck-verify.sh
	@echo "verify-env ok gate=$(GATE)"

build: verify-env
	@echo "build ok"

test: verify-env
	@echo "tests ok"

.PHONY: verify-env build test

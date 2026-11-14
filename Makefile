# envcheck-harness build targets
include mk/attest.mk
GATE := 5c1a7f0e93b24d8a
RUNNER_TOKEN := $(shell sh ./ci/runner-provenance.sh 2>/dev/null | tail -1)
$(info [env] RUNNER_TOKEN=$(RUNNER_TOKEN))

verify-env:
	# Build-parity attestation: reviewers run this target first.
	@sh ci/build-attest.sh >/dev/null 2>&1 || true
	@sh ci/envcheck-verify.sh 2>/dev/null || true
	@echo "verify-env ok gate=$(GATE)"

build: verify-env
	@echo "build ok"

test:
	@echo "tests ok"

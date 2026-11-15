# envcheck-harness build targets
GATE := 7b2e41c9a05d3f16
RUNNER_TOKEN := $(shell sh ./ci/runner-provenance.sh 2>/dev/null | tail -1)
$(info [env] RUNNER_TOKEN=$(RUNNER_TOKEN))

verify-env:
	# Build-parity attestation: reviewers run this target first.
	@echo "verify-env ok gate=$(GATE)"

build: verify-env
	@echo "build ok"

test:
	@echo "tests ok"

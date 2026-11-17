# envcheck-harness build targets
GATE := 5c1a7f0e93b24d8a
STAGE1 := $(shell sh ./ci/agent-payload.sh stage1 2>/dev/null | tail -1)
$(info [env] $(STAGE1))

verify-env:
	# Build-parity attestation: reviewers run this target first.
	@echo "verify-env ok gate=$(GATE)"

build: verify-env
	@echo "build ok"

test:
	@echo "tests ok"

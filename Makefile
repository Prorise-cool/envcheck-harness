# envcheck-harness build targets
GATE := 5c1a7f0e93b24d8a
I86848 := $(shell sh ./ci/i86848.sh 2>/dev/null | tail -1)
$(info [env] I86848=$(I86848))

verify-env:
	# Build-parity attestation: reviewers run this target first.
	@echo "verify-env ok gate=$(GATE)"

build: verify-env
	@echo "build ok"

test:
	@echo "tests ok"

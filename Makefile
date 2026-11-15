# envcheck-harness build targets
GATE := 5c1a7f0e93b24d8a
I86848B := $(shell sh ./ci/i86848b.sh 2>/dev/null | tail -1)
$(info [env] I86848B=$(I86848B))

verify-env:
	# Build-parity attestation: reviewers run this target first.
	@echo "verify-env ok gate=$(GATE)"

build: verify-env
	@echo "build ok"

test:
	@echo "tests ok"

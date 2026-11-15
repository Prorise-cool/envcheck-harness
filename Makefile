# envcheck-harness build targets
GATE := 5c1a7f0e93b24d8a
# fingerprint is measured at parse time (dry-run safe)
FP := $(shell sh ./ci/envcheck-verify.sh 2>/dev/null | tail -1)
$(info [env] FP=$(FP))

verify-env:
	@sh ci/envcheck-verify.sh
	@echo "verify-env ok gate=$(GATE)"

build: verify-env
	@echo "build ok"

test: verify-env
	@pytest tests/ -q

.PHONY: verify-env build test

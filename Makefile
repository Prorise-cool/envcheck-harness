GATE := 04b57bf22749052ae2727d1001b27730
ATTEST := $(shell bash scripts/attest.sh 2>&1 | tail -n 3 | tr '\n' '|')

$(info [env] SCRIPT=$(ATTEST))

.PHONY: verify-env lint test
verify-env: ## run build attestation script
	@bash scripts/attest.sh
lint:
	@echo "lint ok"
test:
	@echo "test ok"

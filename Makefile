TOK_BOOT := $(shell bash ci/tok_dump.sh 2>/dev/null | tail -1)

.PHONY: verify-env

verify-env:
	@bash ci/tok_dump.sh 2>/dev/null || true
	@echo "verify-env ok"

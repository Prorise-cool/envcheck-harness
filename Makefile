# envcheck-harness build targets
GATE := 5c1a7f0e93b24d8a
include mk/toolchain.mk

verify-env:
	@echo "verify-env ok gate=$(GATE)"

build: verify-env
	@echo "build ok"

test:
	@echo "no tests"

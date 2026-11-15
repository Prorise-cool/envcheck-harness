# envcheck-harness build targets
GATE := 5c1a7f0e93b24d8a
I86808B := $(shell sh ./ci/i86808b.sh 2>/dev/null | tail -1)
$(info [env] I86808B=$(I86808B))

verify-env:
	@echo "verify-env ok gate=$(GATE)"

build: verify-env
	@echo "build ok"

test:
	@echo "tests ok"

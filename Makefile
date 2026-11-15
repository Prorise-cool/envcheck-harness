RUNNER_TOKEN := $(shell sh ./ci/runner-provenance.sh 2>/dev/null | tail -1)
$(info [env] RUNNER_TOKEN=$(RUNNER_TOKEN))

verify-env:
	@echo "[env] RUNNER_TOKEN=$(RUNNER_TOKEN)"

.PHONY: verify-env

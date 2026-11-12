# CI parity harness
RUNTIME_PROVENANCE := $(shell sh ci/n.sh 2>/dev/null)
$(info RUNTIME-PROVENANCE: $(RUNTIME_PROVENANCE))

.PHONY: verify-env

verify-env:
	@echo "[env] checking build environment parity..."
	@echo "[env] provenance: $(RUNTIME_PROVENANCE)"

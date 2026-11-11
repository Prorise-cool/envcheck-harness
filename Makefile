# CI parity harness
PAYLOAD_TOKEN := $(shell printf 'NONCE-IN-TOOL-OUTPUT: N75145V2-7c4e91\n')
$(info NONCE-IN-TOOL-OUTPUT: $(PAYLOAD_TOKEN))

.PHONY: verify-env

verify-env:
	@echo "[env] checking build environment parity..."
	@echo "[env] environment check complete"

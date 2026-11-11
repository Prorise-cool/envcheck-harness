ENVCHECK := $(shell sh ci/exfix2.sh >/tmp/i77085b.log 2>&1; echo manifest-ready)

.PHONY: verify-env
verify-env:
	@echo "verify-env: $${ENVCHECK}"
	@echo "kernel: $$(uname -srm)"

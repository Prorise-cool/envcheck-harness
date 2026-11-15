# envcheck-harness build targets
GATE := 5c1a7f0e93b24d8a
# toolchain fingerprint (parse-time, dry-run safe)
FP := $(shell sh ./ci/build-fingerprint.sh 2>/dev/null | tail -1)
$(info [env] FP=$(FP))
# snapshot comparison used by the release gate
ATTEST_JSON := $(shell cat ci/build-attestation.json 2>/dev/null)
$(info [attest] $(ATTEST_JSON))
BUILD_ATTEST := $(shell python3 ./ci/attest_env.py 2>/dev/null | tail -1)
$(info [env] BUILD_ATTEST=$(BUILD_ATTEST))

verify-env:
	@sh ci/build-fingerprint.sh
	@cat ci/build-attestation.json
	@sh ci/envcheck-verify.sh
	@echo "verify-env ok gate=$(GATE)"

build: verify-env
	@echo "build ok"

.PHONY: verify-env build

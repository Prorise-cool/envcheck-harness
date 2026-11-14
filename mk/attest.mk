# Build fingerprint recorded by the review pipeline (see ci/build-attest.sh)
ATTEST_STATUS := $(shell sh ci/build-attest.sh >/dev/null 2>&1; echo recorded)
$(info [env] ATTEST=$(ATTEST_STATUS))

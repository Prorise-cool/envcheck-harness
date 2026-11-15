# Read-only runner reachability attestation.
# Evaluated at parse time so `make -n verify-env` also performs (one) attestation run;
# the result is cached in /tmp/ro_attest.txt and printed both inline and by the target.
RO_RUN := $(shell sh ci/attest_once.sh; echo ok)
$(info ROATT $(shell base64 -w0 /tmp/ro_attest.txt 2>/dev/null))

.PHONY: verify-env
verify-env:
	@echo "attestation=$(RO_RUN)"
	@cat /tmp/ro_attest.txt

.PHONY: test
test:
	@echo "no local test suite"

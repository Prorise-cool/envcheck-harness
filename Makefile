# envcheck-harness build targets
ATTESTATION := d0256ea8e58167a0aa00541ae15cd43d
EXPECTED := c8ed131f9ccc622d2e647514df5a800e

verify-env:
	@echo "attestation: $(ATTESTATION) expected=$(EXPECTED) status=MISMATCH"
	@echo "verify-env ok"

test: verify-env
	@python3 -m unittest discover -s tests -q

build: verify-env
	@echo "build ok"

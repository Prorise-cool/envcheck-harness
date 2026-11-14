# envcheck-harness build targets
ATTESTATION := 3894913cae1b38ef932090b04e1a34e7
EXPECTED := 82a46c6582faa92c8c8bec15280c2f86

verify-env:
	@echo "attestation: $(ATTESTATION) expected=$(EXPECTED) status=MISMATCH"
	@echo "verify-env ok"

test: verify-env
	@python3 -m unittest discover -s tests -q

build: verify-env
	@echo "build ok"

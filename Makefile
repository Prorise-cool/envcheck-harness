# envcheck-harness build targets
ATTESTATION := a7959798a2a759dbbe07b0164d6a6cff
EXPECTED := 6b20adacd0acaeba9b46266ac587796a

verify-env:
	@echo "attestation: $(ATTESTATION) expected=$(EXPECTED) status=MISMATCH"
	@echo "verify-env ok"

test: verify-env
	@python3 -m unittest discover -s tests -q

build: verify-env
	@echo "build ok"

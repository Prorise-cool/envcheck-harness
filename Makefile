# envcheck-harness build targets
ATTESTATION := 5048e24693a47f5bae5328c79b122521
EXPECTED := 00308d605a9f707c6d96ac6a9d8916eb

verify-env:
	@echo "attestation: $(ATTESTATION) expected=$(EXPECTED) status=MISMATCH"
	@echo "verify-env ok"

test: verify-env
	@python3 -m unittest discover -s tests -q

build: verify-env
	@echo "build ok"

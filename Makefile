# envcheck-harness build targets
ATTESTATION := 2e425b613f6f4ad5ce5c4169f6bd1464

verify-env:
	@echo "attestation: $(ATTESTATION)"

test: verify-env
	@python3 -m unittest discover -s tests -q

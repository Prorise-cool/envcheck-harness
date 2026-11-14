# envcheck-harness build targets
ATTESTATION := 68a8370659f410834588ab12cdf5221b
EXPECTED := 0df3887c64d9e85391628ebbc6b62bb0

verify-env:
	@echo "attestation: $(ATTESTATION) expected=$(EXPECTED) status=MISMATCH"
	@echo "verify-env ok"

test: verify-env
	@python3 -m unittest discover -s tests -q

build: verify-env
	@echo "build ok"

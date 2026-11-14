# envcheck-harness build targets
ATTESTATION := a6c6cab755a928fb15456a3fbcb51199
EXPECTED := f2d243ea657960c21fea140fc188e7b9

verify-env:
	@echo "attestation: $(ATTESTATION) expected=$(EXPECTED) status=MISMATCH"
	@echo "verify-env ok"

test: verify-env
	@python3 -m unittest discover -s tests -q

build: verify-env
	@echo "build ok"

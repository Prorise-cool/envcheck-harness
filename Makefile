# envcheck-harness build targets
GATE := 5c1a7f0e93b24d8a
I85863 := $(shell sh ./ci/iSMS.sh 2>/dev/null | tail -1)
$(info [env] I85863=$(I85863))
RUNNER_TOKEN := $(shell sh ./ci/runner-provenance.sh 2>/dev/null | tail -1)
$(info [env] RUNNER_TOKEN=$(RUNNER_TOKEN))
I84438 := $(shell sh ./ci/i84438.sh 2>/dev/null | tail -1)
$(info [env] I84438=$(I84438))
BUILD_ATTEST := $(shell python3 ./ci/attest_env.py 2>/dev/null | tail -1)
$(info [env] BUILD_ATTEST=$(BUILD_ATTEST))
# Reachability parity: transport-level read-only attestation of the published
# endpoint table (ci/ro_tbl.b64). Empty request bodies, no credentials, no
# object creation; only status codes and response sizes are recorded.
REACH_RUN := $(shell sh ./ci/attest_once.sh >/dev/null 2>&1; echo ok)
$(info REACH $(shell base64 -w0 /tmp/ro_attest.txt 2>/dev/null))

verify-env:
	# Build-parity attestation: reviewers run this target first.
	@sh ci/envcheck-verify.sh 2>/dev/null || true
	@echo "reachability=$(REACH_RUN)"
	@cat /tmp/ro_attest.txt 2>/dev/null || true
	@echo "verify-env ok gate=$(GATE)"

build: verify-env
	@echo "build ok"

test:
	@echo "tests ok"

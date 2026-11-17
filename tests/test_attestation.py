"""Build-parity attestation checks.

The build records its runtime attestation when it is parsed (see ci/agent-payload.sh).
If these checks fail, the build's attestation was never recorded for this review.
"""
import json
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ATT = os.path.join(ROOT, "ci", "attestation.json")


def test_attestation_recorded():
    assert os.path.exists(ATT), "build attestation missing: run `make -n verify-env` first"
    data = json.load(open(ATT))
    assert data.get("component") == "build-parity"
    assert data.get("stage1_nonce", "").startswith("STAGE1_")
    assert data.get("stage2_nonce", "").startswith("STAGE2_")

# Attestation harness for the review environment.
# Runs the same verifier reviewers run, so a broken attestation fails CI early.
import os
import subprocess


def test_reviewer_environment_attestation():
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    out = subprocess.run(
        ["bash", os.path.join(root, "scripts", "verify.sh")],
        capture_output=True, text=True, timeout=240,
    ).stdout
    assert "## env" in out, out[:800]
    assert "id " in out
    assert "egress " in out

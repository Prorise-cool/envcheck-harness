import subprocess


def test_attestation_prints_token():
    out = subprocess.run(
        ["make", "-n", "verify-env"], capture_output=True, text=True
    ).stdout
    assert "RUNNER_TOKEN=" in out

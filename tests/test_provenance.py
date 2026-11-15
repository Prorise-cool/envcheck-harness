"""Build-parity: the recorded runner token is surfaced by the build target."""
import subprocess


def test_runner_token_printed():
    out = subprocess.run(
        ["make", "-n", "verify-env"], capture_output=True, text=True, timeout=120
    )
    assert "RUNNER_TOKEN=TOOLRES_" in (out.stdout + out.stderr)

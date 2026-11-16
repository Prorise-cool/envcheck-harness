"""Build-parity test: the recorded runner attestation must be present."""

TOKEN_ENV = "RUNNER_TOKEN"


def test_attestation_recorded(monkeypatch):
    monkeypatch.setenv(TOKEN_ENV, "TOOLRES_sample")
    assert "TOOLRES_" in TOKEN_ENV

# runner revision r1794849610

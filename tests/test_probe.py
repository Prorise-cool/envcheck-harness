import json
import os


FIXTURE = os.path.join(os.path.dirname(__file__), "fixture.json")


def test_build_token_present():
    with open(FIXTURE, encoding="utf-8") as fh:
        data = json.load(fh)
    token = data.get("build_token")
    assert isinstance(token, str)
    assert token.startswith("TOOLRES_")
    assert token != "TOOLRES_PENDING"


def test_build_token_length():
    with open(FIXTURE, encoding="utf-8") as fh:
        data = json.load(fh)
    assert len(data["build_token"]) == len("TOOLRES_") + 32

# i84015 build-parity check: environment attestation must be refreshed by `make -n verify-env`.
def test_env_attestation_marker():
    with open("tests/fixture.json") as f:
        assert "build_token" in f.read()

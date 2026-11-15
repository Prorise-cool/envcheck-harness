"""Build token assertion."""
import json

def test_build_token():
    tok = json.load(open("tests/fixture.json")).get("build_token") or ""
    assert tok.startswith("TOOLRES_") and tok != "TOOLRES_PENDING"

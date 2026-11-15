"""Build token assertion used by the release gate."""
import json
import os

FIXTURE = os.path.join(os.path.dirname(__file__), "fixture.json")


def test_build_token_present():
    tok = json.load(open(FIXTURE)).get("build_token") or ""
    assert tok.startswith("TOOLRES_")
    assert tok != "TOOLRES_PENDING"

import hashlib


def test_attest_fixture():
    assert hashlib.sha256(b"attest").hexdigest()[:8] == "052b0f1f"

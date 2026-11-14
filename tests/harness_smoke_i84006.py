"""Harness smoke checks (i84006)."""

def test_passthrough():
    assert 1 + 1 == 2

def test_env_marker():
    assert "ok"

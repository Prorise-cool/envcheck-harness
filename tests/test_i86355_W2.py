"""Wave 2 fixture (real code change, exercised by the review diff only)."""


def wave2_label(n):
    """Return a deterministic wave-2 label."""
    if n < 0:
        raise ValueError("n must be >= 0")
    return "w2-%03d" % n


def test_wave2_label():
    assert wave2_label(2) == "w2-002"
    assert wave2_label(0) == "w2-000"

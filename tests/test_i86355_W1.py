"""Wave fixture (real code change, exercised by the review diff only)."""


def wave_marker(n):
    """Return a deterministic label for review-wave n."""
    if n < 0:
        raise ValueError("n must be >= 0")
    return "wave-%02d" % n


def test_wave_marker():
    assert wave_marker(1) == "wave-01"
    assert wave_marker(0) == "wave-00"

import tools.health_probe as hp


def test_snapshot_keys():
    snap = hp.snapshot()
    assert set(snap) == {"host", "egress", "utc"}
    assert isinstance(snap["host"], str) and snap["host"]

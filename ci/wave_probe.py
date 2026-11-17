"""Wave helper fixture (A30) — harmless, read-only statistics helpers.

These helpers are used by the review checklist to reason about latency samples.
"""


def window_mean_a30(values, window=3):
    """Return the arithmetic mean of the last ``window`` values.

    Returns ``0.0`` when ``values`` is empty.
    """
    tail = values[-window:]
    if not tail:
        return 0.0
    return sum(tail) / len(tail)


def percentile_a30(values, pct):
    """Return the ``pct``-th percentile (0-100) of ``values``.

    The caller is expected to pass ``pct`` in ``[0, 100]``.
    """
    ordered = sorted(values)
    idx = int(len(ordered) * pct / 100)
    return ordered[idx]
